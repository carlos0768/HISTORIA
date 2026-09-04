/**
 * 実 API で教材を1本作り、仕様の実測項目を確かめる
 *
 *   npx tsx scripts/measure/generate-once.ts [unit_id] [--keep]
 *
 *   --keep を付けると使い捨て DB を消さない。1回に実費（約50円）がかかるので、
 *   読み損ねたときに払い直さずに済むようにするため。
 *
 * 測るもの（docs/14）:
 *   M5  responseSchema が docs/07 §5.3 のまま通るか
 *   M27 モデルが claims を実際に何件出すか。その主張が本文に実在するか
 *   M2  1ユニットの生成時間が240秒以内か（Vercel の300秒上限）
 *   M2b **層2の機械照合率が80%以上か**（docs/13 Phase 0 の 0-4b）
 *
 * ★ 検証（層3）は鍵が無ければフェイクになる。ここで測るのは生成側である。
 * ★ 使い捨ての DB を作って消す。既存のデータには触らない。
 */
import postgres from 'postgres'
import { applySchema } from '../db/schema'
import { seedMasters, seedKc, SEED_DIR } from '../db/seed'
import { createClient, readConfig } from '@/lib/ai/client'
import { ensureBudgetRow, periodOf, budgetStatus } from '@/lib/ai/budget'
import { generateMaterial } from '@/lib/pipeline/generate'
import { matchRate } from '@/lib/pipeline/factcheck'
import { createUser } from '@/lib/loop/fixture'

const unitId = process.argv[2] ?? 'wh.2.1.1'
const admin = process.env.TEST_DATABASE_URL ?? process.env.DATABASE_URL
if (!admin) throw new Error('TEST_DATABASE_URL か DATABASE_URL が要ります')

const cfg = readConfig()

/**
 * ★ 鍵の有無を env で直接見ない。**どちらのプロバイダが生成側かは設定で変わる**。
 *   2026-09-04 に向きが「生成 Claude / 検証 Gemini」へ入れ替わったとき、
 *   ここは `GEMINI_API_KEY` だけを見ていたので、**生成側の鍵が無いまま通っていた**。
 *   その場合フェイクが本文を書き、本物の検証がそれを検証して、
 *   この道具は「でたらめな教材の実測値」を出す。
 *
 *   createClient が返す名前は resolveProvider が実際に選んだものなので
 *   （鍵が無ければ 'fake:...'）、ここを唯一の判断材料にすれば設定と食い違わない。
 */
const ai = createClient(cfg)
const genFake = ai.genProviderName.startsWith('fake:')
const verifyFake = ai.verifyProviderName.startsWith('fake:')
if (genFake || verifyFake) {
  const need = [
    genFake ? `生成 ${cfg.genProvider}` : null,
    verifyFake ? `検証 ${cfg.verifyProvider}` : null,
  ].filter(Boolean).join(' と ')
  console.error(`${need} の鍵がありません。実測にならないので止めます。`)
  console.error('  GEMINI_API_KEY と ANTHROPIC_API_KEY の両方が要ります。')
  console.error('  （生成と検証は必ず別プロバイダなので、片方だけでは足りません）')
  process.exit(1)
}
console.log(`生成: ${ai.genProviderName}/${cfg.genModel}`)
console.log(`検証: ${ai.verifyProviderName}/${cfg.verifyModel}`)
console.log(`単元: ${unitId}\n`)

const name = `historia_measure_${Date.now()}`
const a = postgres(admin, { prepare: false, max: 1, onnotice: () => {} })
await a.unsafe(`CREATE DATABASE "${name}"`)
await a.end({ timeout: 5 })

const url = new URL(admin); url.pathname = `/${name}`
const db = postgres(url.toString(), { prepare: false, max: 4, onnotice: () => {} })

try {
  await applySchema(db, { pgvector: process.env.PGVECTOR !== 'off' })
  await seedMasters(db, SEED_DIR)
  await seedKc(db, SEED_DIR)

  const now = new Date()
  await ensureBudgetRow(db, periodOf(now))
  const userId = await createUser(db, now)

  const t0 = Date.now()
  const r = await generateMaterial(db, ai, { userId, unitId, now })
  const ms = Date.now() - t0

  console.log(`結果: ${r.status}`)
  console.log(`所要: ${(ms / 1000).toFixed(1)} 秒（M2 の基準は240秒）`)
  if (r.status === 'failed') {
    console.log(`理由: ${r.reason}`)
    process.exitCode = 1
  }

  const [job] = await db<{ status: string; attempts: number; input_tokens: number | null; output_tokens: number | null; error: string | null }[]>`
    SELECT status, attempts, input_tokens, output_tokens, error FROM generation_job WHERE user_id = ${userId}`
  if (job) {
    console.log(`ジョブ: ${job.status} / 試行 ${job.attempts + 1} 回 / 入力 ${job.input_tokens ?? '-'} tok・出力 ${job.output_tokens ?? '-'} tok`)
    if (job.error) console.log(`ジョブの誤り: ${job.error}`)
  }

  /**
   * ★ **user_id で絞らない。** 個別化の必要が無い文脈から作った教材は
   *   `user_id IS NULL`（共有教材）で保存される（generate.ts の owner）。
   *   初回はほぼ必ずこちらになるので、`user_id = ${userId}` で引くと**空振りする**。
   *
   *   2026-09-04、これで報告が丸ごと飛んだ。生成は成功していたのに
   *   文字数も claims も照合率も1つも出ず、**¥52 かけた実測が読めなかった**。
   *   generate.ts は同じ罠を踏んで既に直してある（冪等の短絡のところ）。
   *   道具の側が追随していなかった。
   */
  const [m] = await db<{ id: string; title: string; status: string; blocked_reason: string | null; user_id: string | null }[]>`
    SELECT id, title, status, blocked_reason, user_id FROM material
     WHERE user_id = ${userId} OR user_id IS NULL
     ORDER BY generated_at DESC LIMIT 1`
  if (!m) {
    // ★ 黙って終わらせない。ここに来たら道具の側の欠陥である
    console.log('\n⚠ 教材の行が見つかりません。生成は成功しているのに読めていません。')
    console.log('  scripts/measure/generate-once.ts の material の問い合わせを疑ってください。')
  }
  if (m) {
    console.log(`（${m.user_id === null ? '共有教材 user_id IS NULL' : '個別教材'}）`)
    console.log(`\n教材: 「${m.title}」 (${m.status})`)
    if (m.blocked_reason) console.log(`配信不可の理由: ${m.blocked_reason}`)

    const secs = await db<{ ord: number; heading: string; char_count: number; body_md: string }[]>`
      SELECT ord, heading, char_count, body_md FROM material_section WHERE material_id = ${m.id} ORDER BY ord`
    const total = secs.reduce((n, s) => n + s.char_count, 0)
    console.log(`\n本文 ${total} 字（受け入れ範囲 3,050〜4,500）`)
    for (const s of secs) console.log(`  §${s.ord} ${String(s.char_count).padStart(5)}字  ${s.heading}`)

    const items = await db<{ format: string; n: string }[]>`
      SELECT format, count(*) AS n FROM item WHERE material_id = ${m.id} GROUP BY format ORDER BY format`
    console.log(`設問: ${items.map(i => `${i.format} ${i.n}`).join(' / ')}`)

    // ---- M27: claims の件数と、それが本文に実在するか ----
    const body = secs.map(s => s.body_md).join('\n')
    const check = 'check' in r ? r.check : undefined
    const claims = check?.verdicts ?? []
    console.log(`\nclaims ${claims.length} 件（プロンプトの要求 12〜24 / スキーマ下限 6）`)
    const byKind: Record<string, number> = {}
    let grounded = 0
    for (const v of claims) {
      byKind[v.claim.type] = (byKind[v.claim.type] ?? 0) + 1
      // 主張の中の3字以上の語が本文に出るか、という粗い確認
      const key = v.claim.text.replace(/[はがをにでとのしますでした。、「」]/g, '').slice(0, 8)
      if (key.length >= 3 && body.includes(key.slice(0, 4))) grounded++
    }
    console.log(`  種別: ${Object.entries(byKind).map(([k, n]) => `${k} ${n}`).join(' / ') || '-'}`)
    console.log(`  本文に語が見つかったもの: ${grounded} / ${claims.length}`)

    // ★ subject と year_from は照合の鍵になった（層2）。プロンプトは求めているが
    //   モデルが実際に埋めるかは未測定である。埋まらなければ照合は本文の部分一致に
    //   落ちて誤当たりが増えるので、ここで率を出しておく
    const target = claims.filter(v => v.claim.type === 'year' || v.claim.type === 'person')
    const withSubject = target.filter(v => v.claim.subject).length
    const withYear = claims.filter(v => v.claim.type === 'year' && v.claim.yearFrom !== undefined).length
    const years = claims.filter(v => v.claim.type === 'year').length
    console.log(`  subject が埋まった (year/person): ${withSubject} / ${target.length}`)
    console.log(`  year_from が埋まった (year): ${withYear} / ${years}`)
    console.log('\n  最初の5件:')
    for (const v of claims.slice(0, 5)) console.log(`   [${v.claim.type}] ${v.claim.text}`)

    // ---- M2b: 層2の機械照合率（docs/13 Phase 0 の 0-4b・目標 80%） ----
    if (check) {
      const rate = matchRate(check)
      const pct = rate === null ? '—' : `${(rate * 100).toFixed(1)}%`
      const gate = rate === null ? '測定不能' : rate >= 0.8 ? '達成' : '未達'
      console.log(`\n機械照合率: ${check.matched} / ${check.matchable} = ${pct}（目標80% → ${gate}）`)

      // ★ 分母が痩せていないかを見る。年を読み取れない claim を分母に入れると
      //   正典を何件足しても届かなくなるので、外した件数を必ず出す
      const canonEvents = await db<{ n: string }[]>`SELECT count(*) AS n FROM canon_event`
      const persons = await db<{ n: string }[]>`SELECT count(*) AS n FROM person`
      console.log(`  分母から外した（年を読み取れない）: ${check.unreadable} 件`)
      console.log(`  正典: canon_event ${canonEvents[0]!.n} 件 / person ${persons[0]!.n} 件`)
      if (Number(canonEvents[0]!.n) === 0) {
        console.log('  ※ canon_event が0件です。照合率は正典を入れるまで意味を持ちません（M26）')
      }

      const unmatched = claims.filter(v => v.status === 'unmatched' && (v.claim.type === 'year' || v.claim.type === 'person'))
      if (unmatched.length > 0) {
        console.log('\n  照合できなかったもの（正典に足す候補）:')
        for (const v of unmatched.slice(0, 10)) {
          console.log(`   [${v.claim.type}] ${v.claim.subject ?? v.claim.text} — ${v.reason ?? ''}`)
        }
      }
      const wrong = claims.filter(v => v.status === 'wrong')
      for (const v of wrong) console.log(`  ✗ ${v.reason}`)
    }
  }

  const spend = await db<{ provider: string; model: string; purpose: string; state: string; est_jpy: string; actual_jpy: string | null }[]>`
    SELECT provider, model, purpose, state, est_jpy, actual_jpy FROM ai_spend ORDER BY id`
  console.log('\n元帳:')
  for (const s of spend) console.log(`  ${s.purpose} ${s.provider}/${s.model} ${s.state} 予約${Number(s.est_jpy).toFixed(3)}円 確定${s.actual_jpy ? Number(s.actual_jpy).toFixed(3) : '-'}円`)
  const b = await budgetStatus(db, now)
  console.log(`予算: 使用 ${b.usedJpy.toFixed(3)}円 / 上限 ${b.capJpy}円 / 残り ${b.remainingJpy.toFixed(3)}円 / 停止 ${b.halted}`)
} finally {
  await db.end({ timeout: 5 })
  /**
   * ★ **--keep を付けたら消さない。** 1回の実行に実費がかかる（Opus 5 の生成で
   *   約50円）。報告の側に欠陥があると、**払った実測がそのまま消える**。
   *   2026-09-04 に実際に起きた。読み損ねたときに DB を残せる逃げ道を作る。
   */
  if (process.argv.includes('--keep')) {
    console.log(`\n使い捨て DB を残しました: ${name}`)
    console.log(`  psql "${admin.replace(/\/[^/]*$/, '')}/${name}" で覗けます`)
    console.log(`  消すとき: DROP DATABASE "${name}"`)
  } else {
    const c = postgres(admin, { prepare: false, max: 1, onnotice: () => {} })
    await c.unsafe(`DROP DATABASE IF EXISTS "${name}"`)
    await c.end({ timeout: 5 })
  }
}
