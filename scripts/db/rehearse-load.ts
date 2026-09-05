/**
 * 本番へ投入する前の予行演習。
 *
 *   TEST_DATABASE_URL=postgres://... npx tsx scripts/db/rehearse-load.ts
 *
 * 使い捨ての DB にスキーマと seed を入れ、`material-sql.ts` の出力を **2回** 流す。
 *
 * ★ **2回流すことに意味がある。** 本番には既に配信中の教材があるので、
 *   実際に起きるのは「初回投入」ではなく「上書き」である。上書きの経路は
 *   一意索引（material_one_shared_ready_per_unit）に触れるうえ、
 *   `supersedes_id` を書く経路でもある。初回だけ試すと、そこが素通りする。
 *
 * ★ 数えるだけでは足りないので、最後に `materialView` を通す。
 *   行が入っていても画面が読めるとは限らない（節が欠ける・本文が空になる）。
 *
 * ★ 本番には触れない。接続先は TEST_DATABASE_URL の隣に作る使い捨ての DB だけ。
 */
import { execFileSync } from 'node:child_process'
import postgres from 'postgres'
import { applySchema } from './schema'
import { seedMasters, seedKc, SEED_DIR } from './seed'
import { materialView } from '@/lib/loop/material'
import { materialLibrary } from '@/lib/loop/library'

const ADMIN = process.env.TEST_DATABASE_URL
if (!ADMIN) throw new Error('TEST_DATABASE_URL が未設定です')
const NAME = 'historia_load_rehearsal'
/** 設問の紐づけ先。誰でもよいが、app_user に居る必要がある */
const USER = '00000000-0000-4000-8000-000000000001'

const admin = postgres(ADMIN, { prepare: false, max: 1, onnotice: () => {} })
await admin.unsafe(`DROP DATABASE IF EXISTS "${NAME}"`)
await admin.unsafe(`CREATE DATABASE "${NAME}"`)
await admin.end({ timeout: 5 })

const url = new URL(ADMIN)
url.pathname = `/${NAME}`
const db = postgres(url.toString(), { prepare: false, max: 4, onnotice: () => {} })
await applySchema(db, { pgvector: process.env.PGVECTOR !== 'off' })
await seedMasters(db, SEED_DIR)
await seedKc(db, SEED_DIR)
await db`
  INSERT INTO app_user (id, display_name, birth_date, guardian_consent_required,
                        guardian_email, guardian_consent_at, consent_version, consent_at)
  VALUES (${USER}, '予行演習', '2008-12-08', true, 'x@example.com', now(), 'v1', now())`

/** material-sql.ts を呼ぶ。id は毎回ランダムなので、呼ぶたびに別の版になる */
const gen = () =>
  execFileSync('npx', ['tsx', 'scripts/db/material-sql.ts', '--user', USER],
    { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, stdio: ['ignore', 'pipe', 'ignore'] })

// ★ 生成される SQL は BEGIN 〜 COMMIT で包まれている（全部入るか全部入らないか）。
//   postgres.js は多重接続の unsafe でトランザクション句を拒むので、投入だけ max:1 で繋ぐ。
const loader = postgres(url.toString(), { prepare: false, max: 1, onnotice: () => {} })
for (const pass of ['初回投入', '上書き'] as const) {
  const sql = gen()
  await loader.unsafe(sql)
  console.log(`${pass}: 流しました（${(sql.length / 1024).toFixed(0)}KB）`)
}
await loader.end({ timeout: 5 })

const [n] = await db<{
  ready: string; superseded: string; linked: string; same_unit: string
  secs: string; items: string; factcheck: string; not7: string
}[]>`
  SELECT
    (SELECT count(*) FROM material WHERE status = 'ready') AS ready,
    (SELECT count(*) FROM material WHERE status = 'superseded') AS superseded,
    (SELECT count(*) FROM material WHERE status = 'ready' AND supersedes_id IS NOT NULL) AS linked,
    (SELECT count(*) FROM material r JOIN material o ON o.id = r.supersedes_id
      WHERE r.status = 'ready' AND o.unit_id = r.unit_id) AS same_unit,
    (SELECT count(*) FROM material_section s JOIN material m ON m.id = s.material_id
      WHERE m.status = 'ready') AS secs,
    (SELECT count(*) FROM item i JOIN material m ON m.id = i.material_id
      WHERE m.status = 'ready') AS items,
    -- ★ 層3を通していないので factcheck は1件もあってはならない（docs/02 §5）
    (SELECT count(*) FROM item WHERE approved_by = 'factcheck') AS factcheck,
    (SELECT count(*) FROM material m WHERE m.status = 'ready'
      AND (SELECT count(*) FROM material_section s WHERE s.material_id = m.id) <> 7) AS not7`

const ids = await db<{ id: string; unit_id: string }[]>`
  SELECT id, unit_id FROM material WHERE status = 'ready' ORDER BY unit_id`
const unreadable: string[] = []
for (const r of ids) {
  const v = await materialView(db, USER, r.id)
  if (!v || v.sections.length !== 7 || v.sections.some(s => s.bodyMd.trim() === '')) {
    unreadable.push(r.unit_id)
  }
}
const lib = await materialLibrary(db, USER, { status: 'ready' })
await db.end({ timeout: 5 })

console.log(`
配信中          : ${n!.ready}（退けた版 ${n!.superseded}）
来歴の結び付き  : ${n!.linked}／うち同じ単元を指す ${n!.same_unit}
節              : ${n!.secs}（7節でないもの ${n!.not7}）
設問            : ${n!.items}
factcheck 詐称  : ${n!.factcheck}
画面から読める  : ${ids.length - unreadable.length} / ${ids.length}
一覧に出る      : ${lib.length}`)

const bad =
  unreadable.length > 0 || Number(n!.factcheck) > 0 || Number(n!.not7) > 0 ||
  Number(n!.linked) !== Number(n!.same_unit) || Number(n!.linked) !== Number(n!.ready)
if (bad) {
  if (unreadable.length) console.error(`✗ 読めない: ${unreadable.join(', ')}`)
  console.error('✗ 予行演習に失敗しました。本番へ流さないでください')
  process.exit(1)
}
console.log('✓ 本番へ流せます')
