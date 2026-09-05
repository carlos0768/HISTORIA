/**
 * 「転送が途中で切れて設問だけ欠けた」状態からの復旧を予行する。
 *
 *   TEST_DATABASE_URL=postgres://... npx tsx scripts/db/rehearse-repair.ts
 *
 * ★ これは机上の想定ではない。本番の wh.3.6.2 が実際にこの状態になった。
 *   本文7節は正しく（md5 一致）、設問が22問中3問で止まっていた。
 *   遠隔から 30KB の SQL を送る経路が途中で切れたためである。
 *
 * 手順は、その事故をそのまま再現する:
 *   1. 教材を正しく入れる
 *   2. 設問を3問だけ残して消す（＝切れた転送の跡）
 *   3. material-items-sql.ts を流す → 22問に戻るか
 *   4. **もう一度流す** → 増えないか（何度流しても増えない、が要）
 *   5. 本文が巻き添えで変わっていないか（md5 で確かめる）
 *   6. 画面から読めるか（materialView を通す）
 */
import { execFileSync } from 'node:child_process'
import { createHash } from 'node:crypto'
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import postgres from 'postgres'
import { applySchema } from './schema'
import { seedMasters, seedKc, SEED_DIR } from './seed'
import { AUTHORED_DIR } from '@/lib/ai/authored'
import { parseMaterialOutput } from '@/lib/ai/schema'
import { materialView } from '@/lib/loop/material'

const ADMIN = process.env.TEST_DATABASE_URL
if (!ADMIN) throw new Error('TEST_DATABASE_URL が未設定です')
const NAME = 'historia_repair_rehearsal'
const USER = '00000000-0000-4000-8000-000000000001'
/** 事故が起きた単元そのもので試す */
const UNIT = process.argv[2] ?? 'wh.3.6.2'
/** 切れた転送が残していった設問の数 */
const SURVIVED = 3

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

const run = (script: string) =>
  execFileSync('npx', ['tsx', script, '--user', USER, UNIT],
    { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, stdio: ['ignore', 'pipe', 'ignore'] })

// BEGIN 〜 COMMIT を含むので、投入だけ max:1 で繋ぐ（postgres.js の決まり）
const loader = postgres(url.toString(), { prepare: false, max: 1, onnotice: () => {} })

// 1. まっとうに入れる
await loader.unsafe(run('scripts/db/material-sql-compact.ts'))

const local = parseMaterialOutput(
  JSON.parse(readFileSync(join(AUTHORED_DIR, `${UNIT}.json`), 'utf8')))
if (!local.success) throw new Error(`${UNIT}: 手元の教材がスキーマに反しています`)
const want = local.data.mcqs.length + local.data.flashcards.length
const wantBody = createHash('md5')
  .update(local.data.sections.slice().sort((a, b) => a.ord - b.ord)
    .map(s => s.body_md).join('')).digest('hex').slice(0, 12)

const bodyMd5 = async () => {
  const [r] = await db<{ md5: string; secs: string }[]>`
    SELECT substr(md5(string_agg(s.body_md, '' ORDER BY s.ord)), 1, 12) AS md5,
           count(*)::text AS secs
      FROM material m JOIN material_section s ON s.material_id = m.id
     WHERE m.status = 'ready' AND m.user_id IS NULL AND m.unit_id = ${UNIT}`
  if (!r) throw new Error(`${UNIT}: 配信中の教材がありません`)
  return r
}
const items = async () => {
  const [r] = await db<{ n: string; kcs: string }[]>`
    SELECT count(*)::text AS n,
           (SELECT count(*)::text FROM item_kc k WHERE k.item_id IN
              (SELECT i2.id FROM item i2 JOIN material m2 ON m2.id = i2.material_id
                WHERE m2.status = 'ready' AND m2.user_id IS NULL AND m2.unit_id = ${UNIT})) AS kcs
      FROM item i JOIN material m ON m.id = i.material_id
     WHERE m.status = 'ready' AND m.user_id IS NULL AND m.unit_id = ${UNIT}`
  if (!r) throw new Error(`${UNIT}: 設問を数えられませんでした`)
  return r
}

const first = await items()
console.log(`まっとうに入れた: 設問 ${first.n}（手元 ${want}）／KC の結び ${first.kcs}`)

// 2. 転送が切れた跡を作る。3問だけ残して消す
await db`
  DELETE FROM item WHERE id IN (
    SELECT i.id FROM item i JOIN material m ON m.id = i.material_id
     WHERE m.status = 'ready' AND m.user_id IS NULL AND m.unit_id = ${UNIT}
     OFFSET ${SURVIVED})`
const broken = await items()
console.log(`事故を再現した: 設問 ${broken.n}（本番の wh.3.6.2 と同じ形）`)

// 3〜4. 直す。**2回流す**
const repair = run('scripts/db/material-items-sql.ts')
await loader.unsafe(repair)
const fixed = await items()
console.log(`1回目: 設問 ${fixed.n}／KC の結び ${fixed.kcs}（${(repair.length / 1024).toFixed(0)}KB）`)
await loader.unsafe(repair)
const twice = await items()
console.log(`2回目: 設問 ${twice.n}／KC の結び ${twice.kcs}`)
await loader.end({ timeout: 5 })

// 5. 本文が巻き添えになっていないか
const body = await bodyMd5()

// 6. 画面から読めるか
const [ready] = await db<{ id: string }[]>`
  SELECT id FROM material
   WHERE status = 'ready' AND user_id IS NULL AND unit_id = ${UNIT}`
const view = ready ? await materialView(db, USER, ready.id) : null

const ok = Number(fixed.n) === want
  && Number(twice.n) === want && twice.kcs === fixed.kcs
  && body.md5 === wantBody && Number(body.secs) === local.data.sections.length
  && view !== null && view.sections.length === local.data.sections.length

console.log(
  `\n設問 ${twice.n}/${want}（2回流しても増えない ${Number(twice.n) === want ? '✓' : '✗'}）` +
  `／本文 ${body.md5}（手元 ${wantBody} ${body.md5 === wantBody ? '✓ 無傷' : '✗ 壊れた'}）` +
  `／画面から読める ${view ? '✓' : '✗'}\n` +
  (ok ? '✓ 本番へ流せます' : '✗ 流してはいけません'))

await db.end({ timeout: 5 })
process.exit(ok ? 0 : 1)
