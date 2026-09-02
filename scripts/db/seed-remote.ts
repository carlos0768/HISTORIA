/**
 * 既に動いているデータベース（本番の Supabase など）へ seed を入れる
 *
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/seed-remote.ts           # 下見だけ
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/seed-remote.ts --apply   # 実行
 *
 * ★ なぜ専用の入口が要るのか。既存の2つはどちらも本番に向けられない。
 *   - dev-seed.ts は DROP DATABASE してから作り直す。本番に向けたら全部消える
 *   - migrate.ts は public に表があると拒否する（スキーマ適用のための道具だから）
 *
 * ★ この道具は壊さない。DROP も TRUNCATE も DELETE も書かない。
 *   seedAll（マスタ / KC / 正典）の INSERT は全て ON CONFLICT なので、
 *   何度流しても結果は同じになる。
 *
 * ★ SQL 本文を会話や画面に出さない。seed/sql/02_seed.sql は 400KB を超えるため、
 *   貼り付けで運ぶのは現実的でない。ここでは CSV から直接 INSERT する。
 */
import postgres from 'postgres'
import { seedAll, SEED_DIR } from './seed'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  console.error("  DATABASE_URL='postgresql://...' npx tsx scripts/db/seed-remote.ts --apply")
  process.exit(1)
}

const apply = process.argv.includes('--apply')

// パスワードは出さない（migrate.ts と同じ）
const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}`)

const db = postgres(url, { prepare: false, max: 1, onnotice: () => {} })

type Counts = { kc: string; ksu: string; kr: string; units: string; ce: string; pe: string }
const snapshot = async (): Promise<Counts> => {
  const [r] = await db<Counts[]>`
    SELECT (SELECT count(*) FROM kc)                              AS kc,
           (SELECT count(*) FROM kc_syllabus_unit)                AS ksu,
           (SELECT count(*) FROM kc_region)                       AS kr,
           (SELECT count(DISTINCT unit_id) FROM kc_syllabus_unit) AS units,
           (SELECT count(*) FROM canon_event)                     AS ce,
           (SELECT count(*) FROM person)                          AS pe`
  return r!
}
const show = (label: string, c: Counts) => {
  console.log(`  ${label}: kc ${c.kc} / kc_syllabus_unit ${c.ksu} / kc_region ${c.kr} / KC を持つ節 ${c.units}`)
  console.log(`  ${' '.repeat(label.length)}  正典: canon_event ${c.ce} / person ${c.pe}`)
}

try {
  // スキーマが無い相手に流さない。表が無いのに INSERT を始めると
  // 「途中まで入った」状態になりうる
  const [has] = await db<{ ok: boolean }[]>`
    SELECT to_regclass('public.kc') IS NOT NULL AS ok`
  if (!has?.ok) {
    console.error('\nkc 表がありません。先に docs/schema.sql を流してください。')
    process.exit(1)
  }

  const before = await snapshot()
  show('現在', before)

  if (!apply) {
    console.log('\n下見だけで終わります。実行するには --apply を付けてください。')
    console.log('  DATABASE_URL=... npx tsx scripts/db/seed-remote.ts --apply')
    process.exit(0)
  }

  console.log('\n投入しています…（KC 1件あたり3クエリ以上あるので少しかかります）')
  // 1トランザクションにまとめる。途中で切れても半端に入らないようにするため
  const counts = await db.begin(async tx =>
    seedAll(tx as unknown as postgres.Sql, SEED_DIR))

  console.log(`  時代 ${counts.era} / 地域 ${counts.region} / 章立て ${counts.syllabusUnit}`)
  console.log(`  KC ${counts.kc}（承認されず除外 ${counts.skippedUnapproved}）/ kc_region ${counts.kcRegion}`)
  console.log(`  正典: canon_event ${counts.canonEvent}（除外 ${counts.skippedCanonEvent}）` +
    ` / person ${counts.person}（除外 ${counts.skippedPerson}）`)

  const after = await snapshot()
  show('投入後', after)
  console.log('\n完了。')
} finally {
  await db.end({ timeout: 10 })
}
