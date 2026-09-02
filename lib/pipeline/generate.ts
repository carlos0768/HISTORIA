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
import { buildGenerationContext } from '@/lib/ai/redact'
import { renderMaterialPrompt, MATERIAL_PROMPT_VERSION, type UnitFacts } from '@/lib/ai/prompt'
import {
  MaterialOutput, materialJsonSchema, bodyCharCount, isCharCountOutOfRange, MIN_CHARS, MAX_CHARS,
} from '@/lib/ai/schema'
import { guessRateFor } from '@/lib/loop/answer'
import { machineCheck, type MachineCheckResult } from './factcheck'

/** 教材1本の出力トークン上限。遮断器の見積りの分母になる（docs/08 §7.1・§3.3） */
export const MATERIAL_MAX_OUTPUT_TOKENS = 12_000
/** 検証の出力トークン上限 */
export const VERIFY_MAX_OUTPUT_TOKENS = 1_500
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

async function unitFacts(db: Sql, unitId: string): Promise<UnitFacts> {
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
export async function generateMaterial(
  db: Sql,
  ai: Client,
  /** force: 冪等の短絡を飛ばして作り直す。blocked から抜ける唯一の道である */
  args: { userId: string; unitId: string; now: Date; force?: boolean },
): Promise<GenerateOutcome> {
  const ctx = await buildGenerationContext(db, args.userId, args.unitId)
  const facts = await unitFacts(db, args.unitId)
  const hash = paramsHash(args.unitId, MATERIAL_PROMPT_VERSION, ctx.weakKcs.map(k => k.kcId))
  const emptyCheck: MachineCheckResult = { verdicts: [], matched: 0, matchable: 0 }

  // 冪等: 同じ鍵の成功済みジョブがあれば作り直さない。リロード連打で二重生成しない。
  //
  // ★ force のときだけ短絡を飛ばす。ここを飛ばせないと、いちど blocked になった単元は
  //   params_hash が変わるまで永久に blocked のままになり、作者にも学習者にも直す手が無い。
  const done = args.force ? [] : await db<{ id: string }[]>`
    SELECT id FROM generation_job
     WHERE user_id = ${args.userId} AND kind = 'material'
       AND scope_id = ${args.unitId} AND params_hash = ${hash} AND status = 'succeeded'`
  if (done.length > 0) {
    const m = await db<{ id: string; status: string; blocked_reason: string | null }[]>`
      SELECT id, status, blocked_reason FROM material
       WHERE user_id = ${args.userId} AND unit_id = ${args.unitId}
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
            ${ai.config.genProvider}, ${ai.config.genModel}, ${args.now})
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
  const claims: Claim[] = material.claims.map(c => ({
    type: c.kind === 'event' ? 'causal' : c.kind,
    text: c.text,
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
  const materialId = randomUUID()
  const blocked = wrong.length > 0
  const blockedReason = blocked
    ? wrong.map(w => `「${w.text}」— ${w.reason ?? '誤りの疑い'}`).join(' / ').slice(0, 1000)
    : null

  await db.begin(async tx => {
    // 同じ単元の ready は1本だけ（material_one_ready_per_user_unit）
    if (!blocked) {
      await tx`UPDATE material SET status = 'superseded'
                WHERE user_id = ${args.userId} AND unit_id = ${args.unitId} AND status = 'ready'`
    }

    await tx`
      INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version,
                            status, blocked_reason, input_tokens, output_tokens, generated_at)
      VALUES (${materialId}, ${args.userId}, ${args.unitId}, ${material.title},
              ${ai.config.genProvider}, ${ai.config.genModel}, ${MATERIAL_PROMPT_VERSION},
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
                ${guessRateFor('mcq4')}, ${ai.config.genProvider}, ${ai.config.genModel},
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
                ${guessRateFor('flashcard')}, ${ai.config.genProvider}, ${ai.config.genModel},
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
