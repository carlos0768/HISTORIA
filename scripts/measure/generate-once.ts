/**
 * 実 API で教材を1本作り、仕様の実測項目を確かめる
 *
 *   GEMINI_API_KEY=... npx tsx scripts/measure/generate-once.ts [unit_id]
 *
 * 測るもの（docs/14）:
 *   M5  responseSchema が docs/07 §5.3 のまま通るか
 *   M27 モデルが claims を実際に何件出すか。その主張が本文に実在するか
 *   M2  1ユニットの生成時間が240秒以内か（Vercel の300秒上限）
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
import { createUser } from '@/lib/loop/fixture'

const unitId = process.argv[2] ?? 'wh.2.1.1'
const admin = process.env.TEST_DATABASE_URL ?? process.env.DATABASE_URL
if (!admin) throw new Error('TEST_DATABASE_URL か DATABASE_URL が要ります')

const cfg = readConfig()
if (!cfg.geminiApiKey) throw new Error('GEMINI_API_KEY が要ります')
console.log(`生成: ${cfg.genProvider}/${cfg.genModel}`)
console.log(`検証: ${cfg.verifyProvider}/${cfg.verifyModel}${cfg.anthropicApiKey ? '' : '（鍵が無いのでフェイク）'}`)
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
  const r = await generateMaterial(db, createClient(cfg), { userId, unitId, now })
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

  const [m] = await db<{ id: string; title: string; status: string; blocked_reason: string | null }[]>`
    SELECT id, title, status, blocked_reason FROM material WHERE user_id = ${userId} ORDER BY generated_at DESC LIMIT 1`
  if (m) {
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
    const claims = (r as { check?: { verdicts: { claim: { text: string; type: string } }[] } }).check?.verdicts ?? []
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
    console.log('\n  最初の5件:')
    for (const v of claims.slice(0, 5)) console.log(`   [${v.claim.type}] ${v.claim.text}`)
  }

  const spend = await db<{ provider: string; model: string; purpose: string; state: string; est_jpy: string; actual_jpy: string | null }[]>`
    SELECT provider, model, purpose, state, est_jpy, actual_jpy FROM ai_spend ORDER BY id`
  console.log('\n元帳:')
  for (const s of spend) console.log(`  ${s.purpose} ${s.provider}/${s.model} ${s.state} 予約${Number(s.est_jpy).toFixed(3)}円 確定${s.actual_jpy ? Number(s.actual_jpy).toFixed(3) : '-'}円`)
  const b = await budgetStatus(db, now)
  console.log(`予算: 使用 ${b.usedJpy.toFixed(3)}円 / 上限 ${b.capJpy}円 / 残り ${b.remainingJpy.toFixed(3)}円 / 停止 ${b.halted}`)
} finally {
  await db.end({ timeout: 5 })
  const c = postgres(admin, { prepare: false, max: 1, onnotice: () => {} })
  await c.unsafe(`DROP DATABASE IF EXISTS "${name}"`)
  await c.end({ timeout: 5 })
}
