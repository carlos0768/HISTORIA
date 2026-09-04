/**
 * 教材生成パイプライン — 1 unit = 1 ジョブ
 *
 * 仕様: docs/07-content-pipeline.md §4、docs/08-ai-architecture.md §5
 *
 * 分割は AI に決めさせない。syllabus_unit（教科書の節）を単位とする（07 §4）。
 * 同じ範囲が日によって違う数のユニットに割れると、締切逆算の分母が
 * 非決定的になり、再生成が進捗リセットになる。
 */
import { randomUUID, createHash } from 'node:crypto'
import type { Sql } from 'postgres'
import type { Client } from '@/lib/ai/client'
import type { Claim } from '@/lib/ai/types'
import { buildGenerationContext, isDefaultContext } from '@/lib/ai/redact'
import { renderMaterialPrompt, MATERIAL_PROMPT_VERSION, type UnitFacts } from '@/lib/ai/prompt'
import {
  MaterialOutput, materialJsonSchema, bodyCharCount, isCharCountOutOfRange, MIN_CHARS, MAX_CHARS,
} from '@/lib/ai/schema'
import { guessRateFor } from '@/lib/loop/answer'
import { machineCheck, type MachineCheckResult } from './factcheck'

/**
 * 教材1本の出力トークン上限。遮断器の見積りの分母になる（docs/08 §7.1・§3.3）。
 *
 * ★ ここは「実際に出うる最大」でなければならない。理由が2つある。
 *   1. 足りないと finishReason が MAX_TOKENS になり、gemini.ts が例外を投げて
 *      生成が毎回失敗する。12,000 は docs/08 §3.3 自身の見積り 12,168 を下回っていた
 *   2. 遮断器の不変条件（settled + reserved <= cap）は、この値が本当の天井である
 *      ことに依存している。天井でない値を入れると保証が崩れる
 *
 * 上げてもコストは増えない。settle は実測の usage で確定するためである
 * （reserve が大きくなるぶん同時実行の余裕が減るだけ）。
 *
 * 内訳（docs/08 §3.3 の 12,168 を、受け入れ範囲の最大構成まで伸ばしたもの）:
 *   本文 3,500 → 4,500字（docs/07 §2 の上限）  +約1,000
 *   フラッシュカード 12 → 14枚                  +約120
 *   四択 8 → 10問                               +約600
 *   claims 20 → 40件（スキーマの上限）          +約1,200
 *   合計 約15,100 に余裕を足して 16,000
 */
export const MATERIAL_MAX_OUTPUT_TOKENS = 16_000

/**
 * 検証の出力トークン上限。
 * claims 最大40件 × (index + status + 理由およそ60字) ≈ 3,600。余裕を足して 4,000。
 * 1,500 では24件を超えたあたりで打ち切られ、検証が失敗する。
 */
export const VERIFY_MAX_OUTPUT_TOKENS = 4_000
/** 文字数が範囲外だったときの作り直し回数。無料枠を無限に食わせない */
export const MAX_LENGTH_RETRIES = 1

export type GenerateOutcome =
  | { status: 'ready'; materialId: string; chars: number; itemCount: number; check: MachineCheckResult }
  | { status: 'blocked'; materialId: string; reason: string; check: MachineCheckResult }
  | { status: 'failed'; reason: string }

/** 同じ (user, unit, プロンプト版) の再実行を冪等にする鍵（docs/08 §4） */
export function paramsHash(unitId: string, promptVersion: string, kcIds: string[]): string {
  return createHash('sha256')
    .update([unitId, promptVersion, ...[...kcIds].sort()].join(' '))
    .digest('hex')
    .slice(0, 32)
}

/**
 * 単元まわりの公開情報を引く。プロンプトの差し込みに使う。
 * ★ export しているのは scripts/measure/render-prompt.ts が同じ問い合わせを
 *   使うため。写すと、片方だけ直したときにプロンプトが静かに食い違う
 */
export async function unitFacts(db: Sql, unitId: string): Promise<UnitFacts> {
  const rows = await db<{ id: string; subject: string; label: string; parent_id: string | null }[]>`
    WITH RECURSIVE up AS (
      SELECT id, subject, label, parent_id, 0 AS depth FROM syllabus_unit WHERE id = ${unitId}
      UNION ALL
      SELECT s.id, s.subject, s.label, s.parent_id, up.depth + 1
        FROM syllabus_unit s JOIN up ON s.id = up.parent_id
    )
    SELECT id, subject, label, parent_id FROM up ORDER BY depth DESC`
  const self = rows[rows.length - 1]
  if (!self) throw new Error(`syllabus_unit が見つかりません: ${unitId}`)

  const eras = await db<{ label: string; start_year: number; end_year: number }[]>`
    SELECT e.label, e.start_year, e.end_year
      FROM era e
      JOIN kc k ON k.era_id = e.id
      JOIN kc_syllabus_unit ku ON ku.kc_id = k.id AND ku.unit_id = ${unitId}
     GROUP BY e.id, e.label, e.start_year, e.end_year
     ORDER BY count(*) DESC LIMIT 1`

  const regions = await db<{ label: string }[]>`
    SELECT r.label FROM region r
      JOIN kc_region kr ON kr.region_id = r.id AND kr.is_primary
      JOIN kc_syllabus_unit ku ON ku.kc_id = kr.kc_id AND ku.unit_id = ${unitId}
     GROUP BY r.id, r.label ORDER BY count(*) DESC LIMIT 4`

  return {
    unitLabel: self.label,
    subject: self.subject,
    parentLabels: rows.slice(0, -1).map(r => r.label),
    eraLabel: eras[0]?.label ?? '（不明）',
    yearFrom: eras[0]?.start_year ?? null,
    yearTo: eras[0]?.end_year ?? null,
    regionLabels: regions.map(r => r.label),
  }
}

/**
 * 1つの単元の教材と設問を生成し、事実確認まで通す。
 *
 * ★ 事実確認を通らなかったユニットは**まるごと配信しない**（作者判断 Q4）。
 *   部分的に伏せる案は採らない。伏せた部分を前提にした記述が本文に残るため。
 */
/**
 * 共有教材の設問を、その教材を読む利用者に複製する。
 *
 * ★ 設問を共有しない理由: item.user_id IS NULL は「診断用の共有プール」を意味し、
 *   Elo の較正はそこでのみ行われる（docs/04b・schema の item のコメント）。
 *   生成物をそこに混ぜると較正の前提が壊れる。
 * ★ 複製は SQL だけで済む。高いのは生成であって行ではない。
 * ★ 承認の状態も引き継ぐ。共有教材は事実確認を通っているので approved である。
 */
export async function copyItemsToUser(
  db: Sql, materialId: string, userId: string, now: Date,
): Promise<number> {
  const [already] = await db<{ n: string }[]>`
    SELECT count(*) AS n FROM item WHERE material_id = ${materialId} AND user_id = ${userId}`
  if (Number(already?.n ?? 0) > 0) return Number(already!.n)

  // ★ 内容で重複を除かない。同じ問い文のフラッシュカードが正当に複数あるため、
  //   畳むと設問が減る。「誰か1人ぶんをそのまま写す」が正しい。
  const [donor] = await db<{ user_id: string }[]>`
    SELECT user_id FROM item
     WHERE material_id = ${materialId} AND user_id IS NOT NULL
     ORDER BY created_at, id LIMIT 1`
  if (!donor) return 0

  const rows = await db<{
    id: string; format: string; stem: string; choices: unknown; answer_key: unknown
    explanation: string | null; guess_rate: number; provider: string | null
    generated_by: string | null; prompt_version: string | null
    approved: boolean; approved_by: string | null
  }[]>`
    SELECT id, format, stem, choices, answer_key, explanation, guess_rate,
           provider, generated_by, prompt_version, approved, approved_by
      FROM item WHERE material_id = ${materialId} AND user_id = ${donor.user_id}
     ORDER BY created_at, id`
  if (rows.length === 0) return 0

  await db.begin(async tx => {
    for (const r of rows) {
      const itemId = randomUUID()
      await tx`
        INSERT INTO item (id, user_id, material_id, format, stem, choices, answer_key,
                          explanation, guess_rate, provider, generated_by, prompt_version,
                          approved, approved_by, approved_at, created_at)
        VALUES (${itemId}, ${userId}, ${materialId}, ${r.format}, ${r.stem},
                ${r.choices === null ? null : tx.json(r.choices as never)},
                ${r.answer_key === null ? null : tx.json(r.answer_key as never)},
                ${r.explanation}, ${r.guess_rate}, ${r.provider}, ${r.generated_by},
                ${r.prompt_version}, ${r.approved}, ${r.approved_by},
                ${r.approved ? now : null}, ${now})`
      await tx`
        INSERT INTO item_kc (item_id, kc_id, weight)
        SELECT ${itemId}, kc_id, weight FROM item_kc WHERE item_id = ${r.id}
        ON CONFLICT DO NOTHING`
    }
  })
  return rows.length
}

export async function generateMaterial(
  db: Sql,
  ai: Client,
  /** force: 冪等の短絡を飛ばして作り直す。blocked から抜ける唯一の道である */
  args: { userId: string; unitId: string; now: Date; force?: boolean },
): Promise<GenerateOutcome> {
  const ctx = await buildGenerationContext(db, args.userId, args.unitId)
  const facts = await unitFacts(db, args.unitId)
  const hash = paramsHash(args.unitId, MATERIAL_PROMPT_VERSION, ctx.weakKcs.map(k => k.kcId))
  const emptyCheck: MachineCheckResult = { verdicts: [], matched: 0, matchable: 0, unreadable: 0 }

  // この利用者の弱点に寄せる必要があるか。無ければ共有教材で足りる
  const shareable = isDefaultContext(ctx)

  // ★ 共有教材があれば作らない。生成1回ぶんの課金が丸ごと消える。
  //   個別化の必要が出た利用者（shareable = false）は自分用に作り直す。
  if (shareable && !args.force) {
    const [shared] = await db<{ id: string }[]>`
      SELECT id FROM material
       WHERE user_id IS NULL AND unit_id = ${args.unitId} AND status = 'ready'`
    if (shared) {
      const itemCount = await copyItemsToUser(db, shared.id, args.userId, args.now)
      return { status: 'ready', materialId: shared.id, chars: 0, itemCount, check: emptyCheck }
    }
  }

  // 冪等: 同じ鍵の成功済みジョブがあれば作り直さない。リロード連打で二重生成しない。
  //
  // ★ force のときだけ短絡を飛ばす。ここを飛ばせないと、いちど blocked になった単元は
  //   params_hash が変わるまで永久に blocked のままになり、作者にも学習者にも直す手が無い。
  const done = args.force ? [] : await db<{ id: string }[]>`
    SELECT id FROM generation_job
     WHERE user_id = ${args.userId} AND kind = 'material'
       AND scope_id = ${args.unitId} AND params_hash = ${hash} AND status = 'succeeded'`
  if (done.length > 0) {
    // 共有教材として保存した場合もここに来る。user_id で絞ると自分の分が無く、
    // 「成功済みなのに教材が無い」状態になって作り直しが走ってしまう
    const m = await db<{ id: string; status: string; blocked_reason: string | null }[]>`
      SELECT id, status, blocked_reason FROM material
       WHERE (user_id = ${args.userId} OR user_id IS NULL) AND unit_id = ${args.unitId}
         AND status IN ('ready', 'blocked') ORDER BY generated_at DESC LIMIT 1`
    const hit = m[0]
    if (hit) {
      return hit.status === 'ready'
        ? { status: 'ready', materialId: hit.id, chars: 0, itemCount: 0, check: emptyCheck }
        : { status: 'blocked', materialId: hit.id, reason: hit.blocked_reason ?? '', check: emptyCheck }
    }
  }

  // ★ 衝突したときは既存行の id が生き残る。ここで RETURNING を取らずに
  //   新しい UUID を持ち回ると、ai_spend.job_id が存在しない行を指して外部キーで落ちる。
  //   同じ範囲を作り直すたびに（失敗後の再実行・force）必ず踏む。
  const [job] = await db<{ id: string }[]>`
    INSERT INTO generation_job (id, user_id, kind, scope_id, params_hash, status, provider, model, started_at)
    VALUES (${randomUUID()}, ${args.userId}, 'material', ${args.unitId}, ${hash}, 'running',
            ${ai.genProviderName}, ${ai.config.genModel}, ${args.now})
    ON CONFLICT (user_id, kind, scope_id, params_hash)
    DO UPDATE SET status = 'running', attempts = generation_job.attempts + 1, started_at = ${args.now}
    RETURNING id`
  const jobId = job!.id

  const fail = async (reason: string): Promise<GenerateOutcome> => {
    await db`UPDATE generation_job SET status = 'failed', error = ${reason}, finished_at = ${args.now}
              WHERE user_id = ${args.userId} AND kind = 'material'
                AND scope_id = ${args.unitId} AND params_hash = ${hash}`
    return { status: 'failed', reason }
  }

  /**
   * ★ **本物で作って偽物で検証した教材を配信しない。**
   *
   *   `lib/ai/client.ts` の resolveProvider は鍵が無いと黙ってフェイクに落ちる。
   *   そしてフェイクの verify は既定で全 claim を `ok` にする（`lib/ai/fake.ts` の
   *   `wrongRate ?? 0`）。つまり「検証を通った」という事実が偽になる。
   *
   *   質が悪いのは、それが**どこにも残らない**ことである。`material.provider` に
   *   入るのは生成側の名前だけで（下の INSERT）、検証側を記録する列が
   *   `docs/schema.sql` の material に無い。`components/fake-warning.tsx` の
   *   `isFake` もその1列しか見ない。だから:
   *
   *     生成がフェイク → provider = 'fake:...' → 画面に警告が出る
   *     検証がフェイク → 記録も警告も無い ← ここが素通りしていた
   *
   *   fake-warning.tsx 自身が警戒している「**嘘を覚えて、気づかない**」が、
   *   パイプラインの後半半分では効いていなかった。作者判断 Q4
   *   「エラー出して生成しない」に従い、**AI を呼ぶ前に**止める。
   *
   * ★ 両方フェイクは止めない。鍵なしで閉ループを通す動作確認はこの経路を使っており、
   *   そのとき provider が 'fake:...' になるので既存の FakeWarning が働く。
   *   塞ぐのは「片側だけ本物」という、警告の網から漏れる組み合わせだけである。
   */
  const genIsFake = ai.genProviderName.startsWith('fake:')
  const verifyIsFake = ai.verifyProviderName.startsWith('fake:')
  if (!genIsFake && verifyIsFake) {
    return fail(
      `検証プロバイダ（${ai.config.verifyProvider}）の鍵が無く、フェイクに落ちています。` +
        'フェイクの検証は全ての主張を「問題なし」と返すため、未検証の教材が' +
        '検証済みとして配信されます。生成を中止しました。',
    )
  }

  // ---- 生成。文字数が範囲外なら作り直す（docs/07 §2） ----
  let out: MaterialOutput | null = null
  let chars = 0
  let usedTokens = { inputTokens: 0, outputTokens: 0 }

  for (let attempt = 0; attempt <= MAX_LENGTH_RETRIES; attempt++) {
    const prompt = renderMaterialPrompt(ctx, facts)
    try {
      const r = await ai.generate<MaterialOutput>({
        db, prompt, schema: materialJsonSchema(),
        maxOutputTokens: MATERIAL_MAX_OUTPUT_TOKENS, jobId, now: args.now,
      })
      usedTokens = r.usage
      chars = bodyCharCount(r.value)
      if (!isCharCountOutOfRange(chars)) {
        out = r.value
        break
      }
    } catch (e) {
      return fail(e instanceof Error ? e.message : String(e))
    }
  }
  if (!out) {
    return fail(`教材の文字数が ${MIN_CHARS}〜${MAX_CHARS} の範囲に収まりませんでした（${chars}字）`)
  }
  const material = out

  // ---- 層1で出させた claims を、層2 → 層3 の順で確認する ----
  // ★ subject と year_from を落とさない。docs/08 §5 層2 は
  //   「claim.subject を canon_event.label / aliases と照合」と定めており、
  //   本文全体で部分一致させると関係ない正典に当たる。
  // ★ event を causal に畳まない。畳むと層3へ渡す種別が事実と食い違う
  const claims: Claim[] = material.claims.map(c => ({
    type: c.kind,
    text: c.text,
    ...(c.subject !== undefined ? { subject: c.subject } : {}),
    ...(c.year_from !== undefined ? { yearFrom: c.year_from } : {}),
    ...(c.year_to !== undefined ? { yearTo: c.year_to } : {}),
    sectionOrd: c.section_ord,
  }))

  // ★ 検証されなかった教材を配信しない。
  //   claims が空だと層2は0件を返し、層3は呼ばれず、wrong が空のまま ready になる。
  //   スキーマ側にも下限を入れてあるが、経路を1つに絞れない以上ここでも見る。
  if (claims.length === 0) {
    return fail('検証用の主張が1件も出力されませんでした。未検証の教材は配信しません')
  }

  const check = await machineCheck(db, claims)
  const machineWrong = check.verdicts.filter(v => v.status === 'wrong')

  // 層2で確定した誤りは層3を呼ばずに落とす。課金する必要がない
  let llmWrong: Array<{ text: string; reason?: string }> = []
  if (machineWrong.length === 0) {
    const toVerify = check.verdicts.filter(v => v.status !== 'ok').map(v => v.claim)
    if (toVerify.length > 0) {
      try {
        const v = await ai.verify({
          db, claims: toVerify, maxOutputTokens: VERIFY_MAX_OUTPUT_TOKENS, jobId, now: args.now,
        })
        llmWrong = v.verdicts
          .filter(x => x.status === 'wrong')
          .map(x => ({ text: x.claim.text, reason: x.reason }))
      } catch (e) {
        // 検証できなかったものを「問題なし」として配信しない
        return fail(`事実確認を実施できませんでした: ${e instanceof Error ? e.message : String(e)}`)
      }
    }
  }

  const wrong = [
    ...machineWrong.map(v => ({ text: v.claim.text, reason: v.reason })),
    ...llmWrong,
  ]

  // ---- 保存 ----
  // 個別化されていない文脈から作った教材は共有にする（user_id IS NULL）。
  // 次の利用者は生成せずにこれを読む。
  const owner: string | null = shareable ? null : args.userId
  const materialId = randomUUID()
  const blocked = wrong.length > 0
  const blockedReason = blocked
    ? wrong.map(w => `「${w.text}」— ${w.reason ?? '誤りの疑い'}`).join(' / ').slice(0, 1000)
    : null

  await db.begin(async tx => {
    // 同じ単元の ready は1本だけ（共有・個別それぞれに一意索引がある）
    if (!blocked) {
      await tx`UPDATE material SET status = 'superseded'
                WHERE unit_id = ${args.unitId} AND status = 'ready'
                  AND user_id IS NOT DISTINCT FROM ${owner}`
    }

    await tx`
      INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version,
                            status, blocked_reason, input_tokens, output_tokens, generated_at)
      VALUES (${materialId}, ${owner}, ${args.unitId}, ${material.title},
              ${ai.genProviderName}, ${ai.config.genModel}, ${MATERIAL_PROMPT_VERSION},
              ${blocked ? 'blocked' : 'ready'}, ${blockedReason},
              ${usedTokens.inputTokens}, ${usedTokens.outputTokens}, ${args.now})`

    for (const s of material.sections) {
      const sectionId = randomUUID()
      await tx`
        INSERT INTO material_section (id, material_id, ord, heading, body_md, char_count)
        VALUES (${sectionId}, ${materialId}, ${s.ord}, ${s.heading}, ${s.body_md}, ${s.body_md.length})`
      for (const kcId of s.kc_ids) {
        await tx`INSERT INTO material_section_kc (section_id, kc_id) VALUES (${sectionId}, ${kcId})
                 ON CONFLICT DO NOTHING`
      }
    }

    // 配信できない教材の設問は承認しない。approved を立てない
    for (const q of material.mcqs) {
      const itemId = randomUUID()
      await tx`
        INSERT INTO item (id, user_id, material_id, format, stem, choices, answer_key, explanation,
                          guess_rate, provider, generated_by, prompt_version,
                          approved, approved_by, approved_at, created_at)
        VALUES (${itemId}, ${args.userId}, ${materialId}, 'mcq4', ${q.stem},
                ${tx.json(q.choices as never)}, ${tx.json(q.answer_key as never)}, ${q.explanation},
                ${guessRateFor('mcq4')}, ${ai.genProviderName}, ${ai.config.genModel},
                ${MATERIAL_PROMPT_VERSION},
                ${!blocked}, ${blocked ? null : 'factcheck'}, ${blocked ? null : args.now}, ${args.now})`
      for (const kcId of q.kc_ids) {
        await tx`INSERT INTO item_kc (item_id, kc_id, weight) VALUES (${itemId}, ${kcId}, 1.0)
                 ON CONFLICT DO NOTHING`
      }
    }

    for (const f of material.flashcards) {
      const itemId = randomUUID()
      await tx`
        INSERT INTO item (id, user_id, material_id, format, stem, answer_key, explanation,
                          guess_rate, provider, generated_by, prompt_version,
                          approved, approved_by, approved_at, created_at)
        VALUES (${itemId}, ${args.userId}, ${materialId}, 'flashcard', ${f.front},
                ${tx.json(f.back as never)}, NULL,
                ${guessRateFor('flashcard')}, ${ai.genProviderName}, ${ai.config.genModel},
                ${MATERIAL_PROMPT_VERSION},
                ${!blocked}, ${blocked ? null : 'factcheck'}, ${blocked ? null : args.now}, ${args.now})`
      for (const kcId of f.kc_ids) {
        await tx`INSERT INTO item_kc (item_id, kc_id, weight) VALUES (${itemId}, ${kcId}, 1.0)
                 ON CONFLICT DO NOTHING`
      }
    }

    await tx`
      UPDATE generation_job
         SET status = 'succeeded', input_tokens = ${usedTokens.inputTokens},
             output_tokens = ${usedTokens.outputTokens}, finished_at = ${args.now}
       WHERE user_id = ${args.userId} AND kind = 'material'
         AND scope_id = ${args.unitId} AND params_hash = ${hash}`
  })

  return blocked
    ? { status: 'blocked', materialId, reason: blockedReason ?? '', check }
    : {
        status: 'ready', materialId, chars,
        itemCount: material.mcqs.length + material.flashcards.length, check,
      }
}
