/**
 * DATABASE_URL のデータベースにスキーマを流す
 *
 *   npx tsx scripts/db/migrate.ts            # 確認だけ（何もしない）
 *   npx tsx scripts/db/migrate.ts --apply    # 実行する
 *   npx tsx scripts/db/migrate.ts --apply --seed   # seed も入れる
 *
 * dev-seed.ts との違い:
 *   dev-seed.ts は DROP DATABASE から始まる。手元の使い捨て DB 専用である。
 *   Supabase など「消せない・消してはいけない」DB にはこちらを使う。
 *
 * ★ docs/schema.sql は CREATE TABLE に IF NOT EXISTS を付けていない。
 *   したがって**空のデータベースにしか流せない**。
 *   既存のテーブルがあれば、途中まで作って落ちるより先に止める。
 */
import postgres from 'postgres'
import { applySchema } from './schema'
import { seedMasters, seedKc, SEED_DIR } from './seed'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  console.error('Supabase なら Settings → Database → Connection string → URI を使う。')
  process.exit(1)
}

const apply = process.argv.includes('--apply')
const withSeed = process.argv.includes('--seed')

// 接続文字列を伏せて出す。ログや画面共有に鍵を残さない
const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}`)

const db = postgres(url, { prepare: false, max: 1, onnotice: () => {} })

try {
  const existing = await db<{ name: string }[]>`
    SELECT tablename AS name FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename`

  if (existing.length > 0) {
    console.error(`\npublic スキーマに既にテーブルが ${existing.length} 件あります:`)
    console.error('  ' + existing.map(t => t.name).slice(0, 10).join(', ') + (existing.length > 10 ? ' …' : ''))
    console.error('\ndocs/schema.sql は IF NOT EXISTS を使っていないため、上書きも追記もできません。')
    console.error('作り直すなら Supabase のダッシュボードで public スキーマを空にしてから流してください。')
    process.exit(1)
  }

  const pgvector = process.env.PGVECTOR !== 'off'
  console.log(`pgvector: ${pgvector ? '有効' : '無効（埋め込み列を作らない）'}`)

  if (!apply) {
    console.log('\n空のデータベースです。流せます。')
    console.log('実行するには --apply を付けてください。')
    console.log('  npx tsx scripts/db/migrate.ts --apply --seed')
    process.exit(0)
  }

  console.log('\nスキーマを流しています…')
  await applySchema(db, { pgvector })
  const after = await db<{ n: string }[]>`
    SELECT count(*) AS n FROM pg_tables WHERE schemaname = 'public'`
  const policies = await db<{ n: string }[]>`SELECT count(*) AS n FROM pg_policies WHERE schemaname = 'public'`
  console.log(`テーブル ${after[0]!.n} 件 / RLS ポリシー ${policies[0]!.n} 本を作りました。`)

  if (withSeed) {
    console.log('\nseed を入れています…')
    const m = await seedMasters(db, SEED_DIR)
    const k = await seedKc(db, SEED_DIR) // 承認済みのみ
    console.log(`時代 ${m.era} / 地域 ${m.region} / 章立て ${m.syllabusUnit}`)
    console.log(`KC ${k.kc}（承認されず除外 ${k.skippedUnapproved}）`)
  }

  console.log('\n完了。')
} finally {
  await db.end({ timeout: 5 })
}
