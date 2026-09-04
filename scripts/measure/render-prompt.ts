/**
 * 鍵なしで、実際に送られるプロンプトを読む
 *
 *   PGVECTOR=off TEST_DATABASE_URL='postgres://...' npx tsx scripts/measure/render-prompt.ts [unit_id]
 *
 * unit_id を省くと、KC を持つ単元の候補を出す。
 *
 * ★ なぜ要るか。教材1本の生成は約57円（docs/08 §3.4）で、全75節なら約4,300円。
 *   **何を送っているのかを、金を使う前に読めるようにする。**
 *   generate-once.ts は実 API を叩くので、鍵とお金が要る。こちらは要らない。
 *
 * ★ 使い捨ての DB を作る。既存のデータには触らない。
 */
import postgres from 'postgres'
import { applySchema } from '../db/schema'
import { seedMasters, seedKc, SEED_DIR } from '../db/seed'
import { buildGenerationContext, isDefaultContext } from '@/lib/ai/redact'
import { renderMaterialPrompt } from '@/lib/ai/prompt'
import { materialJsonSchema } from '@/lib/ai/schema'
import { unitFacts } from '@/lib/pipeline/generate'
import { createUser } from '@/lib/loop/fixture'

const unitId = process.argv[2]
const admin = process.env.TEST_DATABASE_URL ?? process.env.DATABASE_URL
if (!admin) throw new Error('TEST_DATABASE_URL か DATABASE_URL が要ります')

const name = `historia_prompt_${Date.now()}`
const a = postgres(admin, { prepare: false, max: 1, onnotice: () => {} })
await a.unsafe(`CREATE DATABASE "${name}"`)
await a.end({ timeout: 5 })

const url = new URL(admin); url.pathname = `/${name}`
const db = postgres(url.toString(), { prepare: false, max: 4, onnotice: () => {} })

try {
  await applySchema(db, { pgvector: process.env.PGVECTOR !== 'off' })
  await seedMasters(db, SEED_DIR)
  await seedKc(db, SEED_DIR)

  if (!unitId) {
    const rows = await db<{ id: string; label: string; parent: string | null; n: string }[]>`
      SELECT s.id, s.label, p.label AS parent, count(*) AS n
        FROM syllabus_unit s
        JOIN kc_syllabus_unit ku ON ku.unit_id = s.id
        LEFT JOIN syllabus_unit p ON p.id = s.parent_id
       GROUP BY s.id, s.label, p.label
       ORDER BY count(*) DESC, s.id`
    console.log(`KC を持つ単元 ${rows.length} 件（生成の対象。docs/08 §3.4 の分母）\n`)
    for (const r of rows) {
      console.log(`${r.n.padStart(3)}件  ${r.id.padEnd(14)} ${r.parent ?? '—'} / ${r.label}`)
    }
    process.exit(0)
  }

  const now = new Date()
  const userId = await createUser(db, now)
  const ctx = await buildGenerationContext(db, userId, unitId)
  const p = renderMaterialPrompt(ctx, await unitFacts(db, unitId))

  // ★ 遮断器が予約に使う値と同じ式（lib/ai/client.ts の maxIn）で出す。
  //   「いくらぶん予約されるのか」を送る前に見られるようにするため
  const maxIn = Math.ceil((p.system.length + p.user.length) / 1.5) + 1000
  console.log(`共有教材にできるか: ${isDefaultContext(ctx)}（true なら全員がこの1本を読む）`)
  console.log(`プロンプト: system ${p.system.length} 字 / user ${p.user.length} 字`)
  console.log(`出力スキーマ: ${JSON.stringify(materialJsonSchema()).length} 字`)
  console.log(`遮断器が見積る入力: ${maxIn} トークン`)
  console.log('\n===== SYSTEM =====\n' + p.system)
  console.log('\n===== USER =====\n' + p.user)
} finally {
  await db.end({ timeout: 5 })
  const drop = postgres(admin, { prepare: false, max: 1, onnotice: () => {} })
  await drop.unsafe(`DROP DATABASE IF EXISTS "${name}"`)
  await drop.end({ timeout: 5 })
}
