/**
 * 開発用のデータを作る。閉ループを画面で触るための最小構成。
 *   npx tsx scripts/db/dev-seed.ts
 * DATABASE_URL の DB を作り直して seed を入れ、ユーザーと特訓と設問を1本ぶん用意する。
 */
import postgres from 'postgres'
import { applySchema } from './schema'
import { seedMasters, seedKc, SEED_DIR } from './seed'
import { createUser, createItem } from '@/lib/loop/fixture'
import { createDrill } from '@/lib/pipeline/drill'

const url = process.env.DATABASE_URL
if (!url) throw new Error('DATABASE_URL が未設定です')

const target = new URL(url)
const dbName = target.pathname.slice(1)
const adminUrl = new URL(url)
adminUrl.pathname = '/postgres'

const admin = postgres(adminUrl.toString(), { prepare: false, max: 1, onnotice: () => {} })
await admin.unsafe(`DROP DATABASE IF EXISTS "${dbName}"`)
await admin.unsafe(`CREATE DATABASE "${dbName}"`)
await admin.end({ timeout: 5 })

const db = postgres(url, { prepare: false, max: 4, onnotice: () => {} })
await applySchema(db, { pgvector: process.env.PGVECTOR !== 'off' })
await seedMasters(db, SEED_DIR)
// 承認前の KC でも画面確認はしたいので、開発用に限り承認を無視する
await seedKc(db, SEED_DIR, { requireApproval: false })

const now = new Date()
const userId = await createUser(db, now)
const kcs = await db<{ id: string; label: string }[]>`
  SELECT k.id, k.label FROM kc k
    JOIN kc_syllabus_unit ku ON ku.kc_id = k.id
   WHERE ku.unit_id LIKE 'wh.2.1.%' ORDER BY k.id`

// 範囲は3節ぶん入れる。教材の状態が単元ごとに並ぶことを画面で確認するため
const deadline = new Date(now.getTime() + 21 * 86400000)
await createDrill(db, {
  userId, title: '古代オリエントと地中海世界',
  unitIds: ['wh.2.1.1', 'wh.2.1.2', 'wh.2.1.3'], deadline,
})

for (const k of kcs) {
  await createItem(db, { userId, kcs: [{ kcId: k.id }], answerKey: 'a', now })
}

console.log('DATABASE_URL =', url)
console.log('DEMO_USER_ID =', userId)
console.log(`KC ${kcs.length} 件・設問 ${kcs.length} 件を用意しました`)
await db.end({ timeout: 5 })
