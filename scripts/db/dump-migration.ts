/**
 * 既にマイグレーション済みのデータベースへ「後から足した表と列」を当てる差分 SQL を出す
 *
 *   npx tsx scripts/db/dump-migration.ts            # seed/sql/04_phase3.sql に書き出す
 *   npx tsx scripts/db/dump-migration.ts --stdout   # 標準出力に出す
 *
 * ★ なぜ要るか。`docs/schema.sql` は CREATE TABLE に IF NOT EXISTS を付けていないので、
 *   **空のデータベースにしか流せない**（`scripts/db/migrate.ts` が既存の表を見たら止める）。
 *   本番の Supabase は既に流し終わっているため、後から表を足すには差分が要る。
 *   `03_rls.sql` は RLS だけを直す差分で、**表そのものは作らない**。
 *
 * ★ 手で書き写さない。`docs/schema.sql` から切り出して IF NOT EXISTS を足すだけにする。
 *   写すと必ず本体からずれる（`dump-rls.ts` と同じ理由）。
 *   ずれていないことは `dump-migration.test.ts` が確かめる。
 *
 * ★ RLS とポリシーはここでは出さない。`03_rls.sql` が
 *   `docs/schema.sql` の全ての ALTER TABLE ... ENABLE ROW LEVEL SECURITY と
 *   全ての CREATE POLICY を毎回貼り直すので、そちらを後から流せば新しい表も覆われる。
 *   二重に書くと、片方だけ直したときに食い違う。
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs'
import { join } from 'node:path'
import { SEED_DIR } from './seed'
import { SCHEMA_PATH } from './schema'

/**
 * この差分が足すもの。`docs/schema.sql` は「いまの姿」しか持たないので、
 * 「どれが後から足された分か」はここに書くしかない。
 */
export const NEW_TABLES = ['push_subscription', 'ops_log'] as const
export type NewColumn = {
  table: string
  column: string
  type: string
  check?: string
  /**
   * 列と一緒に足す索引の本体（`ON <表>` の後ろ）。
   * `indexStatements` は `CREATE INDEX ON <表> (列)` の形しか拾わないので、
   * `USING hnsw (…)` のような索引はここに書く。名前は PostgreSQL の自動命名
   * （<表>_<列>_idx）に合わせる。ずれると IF NOT EXISTS が効かず2本できる。
   */
  index?: string
}
export const NEW_COLUMNS: readonly NewColumn[] = [
  { table: 'app_user', column: 'remind_hour', type: 'smallint', check: 'remind_hour BETWEEN 0 AND 23' },
  // 教材の中の「調べる」の近傍検索（docs/11-ux.md §4.1）。kc.embedding と同じ次元・同じモデル
  { table: 'canon_event', column: 'embedding', type: 'vector(768)',
    index: 'USING hnsw (embedding vector_cosine_ops)' },
  // 同じ「調べる」が教材の本文（節）も引く。見出し＋本文の先頭を埋め込む
  { table: 'material_section', column: 'embedding', type: 'vector(768)',
    index: 'USING hnsw (embedding vector_cosine_ops)' },
]

/**
 * 導出テーブルの作り直し。
 *
 * ★ 表を足しただけでは中身が空である。`user_activity` は「連続学習日数」の
 *   土台で、これから先は submitAnswer と recordRead が書くが、
 *   **既にある解答の分は誰も書いてくれない**。空のまま出すと、
 *   これまで毎日やってきた人の連続日数が 0 に見える。
 *
 * ★ response が唯一の真実なので、そこから作り直せる（docs/03 §2.2）。
 *   何度流しても同じ値になる（合計を数え直して上書きする）。
 */
export const BACKFILLS = [
  {
    title: 'user_activity を response と material_read から作り直す',
    why: [
      '★ 日付は Asia/Tokyo。UTC で入れると日本時間の深夜0〜9時が前日に落ちる。',
      '  アプリ側（lib/domain/streak.ts の jstDate）と同じ基準にそろえる。',
      '★ 何度流しても同じ。数え直して上書きするので、増え続けることはない。',
    ],
    sql: `INSERT INTO user_activity (user_id, activity_date, responses, sections_read)
SELECT user_id, day, sum(r), sum(s) FROM (
  SELECT user_id, (answered_at AT TIME ZONE 'Asia/Tokyo')::date AS day,
         count(*) AS r, 0 AS s
    FROM response GROUP BY 1, 2
  UNION ALL
  SELECT user_id, (read_at AT TIME ZONE 'Asia/Tokyo')::date AS day,
         0 AS r, count(*) AS s
    FROM material_read GROUP BY 1, 2
) t GROUP BY user_id, day
ON CONFLICT (user_id, activity_date) DO UPDATE
  SET responses = EXCLUDED.responses, sections_read = EXCLUDED.sections_read;`,
  },
] as const

/** CREATE TABLE <name> ( … ); を丸ごと切り出す */
export function tableBlock(schema: string, name: string): string {
  const head = `CREATE TABLE ${name} (`
  const at = schema.indexOf(head)
  if (at < 0) throw new Error(`docs/schema.sql に ${name} の CREATE TABLE がありません`)
  const end = schema.indexOf('\n);', at)
  if (end < 0) throw new Error(`${name} の CREATE TABLE が閉じていません`)
  return schema.slice(at, end + 3)
}

/**
 * その表に付いている CREATE INDEX を、書かれた順に拾う。
 *
 * ★ 索引名を自分で付ける。`CREATE INDEX IF NOT EXISTS` は名前を省略できないためである。
 *   PostgreSQL が自動で付ける名前（<表>_<列…>_idx）と同じ綴りにするので、
 *   docs/schema.sql から作った DB には既にその名前の索引があり、IF NOT EXISTS が効く。
 */
export function indexStatements(schema: string, table: string): string[] {
  const re = new RegExp(`^CREATE INDEX ON ${table} \\(([^)]*)\\)(.*?);$`, 'gm')
  return [...schema.matchAll(re)].map(m => {
    const cols = m[1]!.split(',')
      .map(c => c.trim().replace(/\s+(DESC|ASC)$/i, '').replace(/\W/g, ''))
      .join('_')
    return `CREATE INDEX IF NOT EXISTS ${table}_${cols}_idx ON ${table} (${m[1]})${m[2]};`
  })
}

export function buildMigrationSql(schema = readFileSync(SCHEMA_PATH, 'utf8')): string {
  const o: string[] = []
  const say = (s = '') => o.push(s)

  say('-- HISTORIA: 後から足した表と列（自動生成 — 手で編集しない）')
  say('-- 作り直す: npx tsx scripts/db/dump-migration.ts')
  say('--')
  say('-- 既に docs/schema.sql を流してしまったデータベースに、後から足した分だけを当てる。')
  say('-- Supabase の SQL エディタに貼って実行する。何度流しても結果は同じになる。')
  say('--')
  say('-- 新しいデータベースにはこのファイルは要らない。docs/schema.sql に同じものが入っている。')
  say('--')
  say('-- この差分のあと、seed/sql/03_rls.sql を流し直すこと。')
  say('-- 新しい表の RLS とポリシーはそちらが貼る（ここでは出さない。二重に書くとずれる）。')
  say('')
  say('BEGIN;')
  say('')

  for (const t of NEW_TABLES) {
    say(`-- ---- ${t} ----`)
    say(tableBlock(schema, t).replace(`CREATE TABLE ${t} (`, `CREATE TABLE IF NOT EXISTS ${t} (`))
    for (const s of indexStatements(schema, t)) say(s)
    say('')
  }

  for (const c of NEW_COLUMNS) {
    say(`-- ---- ${c.table}.${c.column} ----`)
    say(`ALTER TABLE ${c.table} ADD COLUMN IF NOT EXISTS ${c.column} ${c.type}` +
        (c.check ? ` CHECK (${c.check})` : '') + ';')
    if (c.index) {
      say(`CREATE INDEX IF NOT EXISTS ${c.table}_${c.column}_idx ON ${c.table} ${c.index};`)
    }
    say('')
  }

  for (const b of BACKFILLS) {
    say(`-- ---- ${b.title} ----`)
    for (const line of b.why) say(`-- ${line}`)
    say(b.sql)
    say('')
  }

  say('COMMIT;')
  say('')
  say('-- ---- 確認 ----')
  say(`-- 表 が ${NEW_TABLES.length}、列 が ${NEW_COLUMNS.length} になっていれば当たっている。`)
  say('SELECT')
  say(`  (SELECT count(*) FROM pg_tables WHERE schemaname = 'public'`)
  say(`     AND tablename IN (${NEW_TABLES.map(t => `'${t}'`).join(', ')})) AS 表,`)
  say(`  (SELECT count(*) FROM information_schema.columns WHERE table_schema = 'public'`)
  say(`     AND (table_name, column_name) IN (${
    NEW_COLUMNS.map(c => `('${c.table}', '${c.column}')`).join(', ')})) AS 列;`)
  return o.join('\n') + '\n'
}

/** 書き出し先。リポジトリに入れて、実行しなくても GitHub から取れるようにする */
export const MIGRATION_SQL_PATH = join(SEED_DIR, 'sql', '04_phase3.sql')

if (process.argv[1]?.endsWith('dump-migration.ts')) {
  const sql = buildMigrationSql()
  if (process.argv.includes('--stdout')) {
    process.stdout.write(sql)
  } else {
    mkdirSync(join(SEED_DIR, 'sql'), { recursive: true })
    writeFileSync(MIGRATION_SQL_PATH, sql)
    console.log(`seed/sql/04_phase3.sql に書き出した（${sql.length} バイト）`)
    console.log(`  表 ${NEW_TABLES.join(' / ')} と 列 ${NEW_COLUMNS.map(c => `${c.table}.${c.column}`).join(' / ')}`)
    console.log('')
    console.log('Supabase の SQL エディタに、この順で貼る:')
    console.log('  1. seed/sql/04_phase3.sql   （表と列を足す）')
    console.log('  2. seed/sql/03_rls.sql      （新しい表にも RLS を貼る）')
  }
}
