/**
 * 既にマイグレーション済みのデータベースへ当てる、RLS の差分 SQL を出す
 *
 *   npx tsx scripts/db/dump-rls.ts            # seed/sql/03_rls.sql に書き出す
 *   npx tsx scripts/db/dump-rls.ts --stdout   # 標準出力に出す
 *
 * ★ docs/schema.sql から生成する。手で書き写した差分は必ず本体からずれる。
 *   ずれていないことは dump-rls.test.ts が確かめる。
 *
 * ★ 新しいデータベースにはこのファイルは要らない。docs/schema.sql をそのまま
 *   流せば同じ状態になる。これは「もう流してしまった DB」を追いつかせる道具である。
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs'
import { join } from 'node:path'
import { SEED_DIR } from './seed'
import { SCHEMA_PATH } from './schema'

/** ALTER TABLE ... ENABLE ROW LEVEL SECURITY; の表名を、書かれた順に拾う */
export function rlsTables(schema: string): string[] {
  return [...schema.matchAll(/^ALTER TABLE\s+(\w+)\s+ENABLE ROW LEVEL SECURITY;/gm)].map(m => m[1]!)
}

/** CREATE POLICY 文を、書かれた順に丸ごと拾う */
export function policyStatements(schema: string): { name: string; table: string; sql: string }[] {
  const out: { name: string; table: string; sql: string }[] = []
  for (const part of schema.split('CREATE POLICY ').slice(1)) {
    const end = part.indexOf(';')
    if (end < 0) throw new Error('CREATE POLICY に ; が無い')
    const sql = 'CREATE POLICY ' + part.slice(0, end + 1)
    const m = /^CREATE POLICY\s+(\w+)\s+ON\s+(\w+)/.exec(sql)
    if (!m) throw new Error(`ポリシー名を読めない: ${sql.slice(0, 80)}`)
    out.push({ name: m[1]!, table: m[2]!, sql })
  }
  return out
}

export function buildRlsSql(schema = readFileSync(SCHEMA_PATH, 'utf8')): string {
  const tables = rlsTables(schema)
  const policies = policyStatements(schema)
  const o: string[] = []
  const say = (s = '') => o.push(s)

  say('-- HISTORIA: RLS の修正（自動生成 — 手で編集しない）')
  say('-- 作り直す: npx tsx scripts/db/dump-rls.ts')
  say('--')
  say('-- 既に docs/schema.sql を流してしまったデータベースを、いまの docs/schema.sql に')
  say('-- 追いつかせるための差分である。Supabase の SQL エディタに貼って実行する。')
  say('-- 何度流しても結果は同じになる。')
  say('--')
  say('-- 直すもの（2026-09-02 に本番のデータベースを読んで見つけた3件）:')
  say('--')
  say('--   1. v_weakness_evidence が「定義者の権限で実行する」ビューだった。')
  say('--      response の RLS を素通りするため、公開されている anon キー1本で')
  say('--      /rest/v1/v_weakness_evidence を叩くだけで全利用者の解答履歴が読めた。')
  say('--')
  say('--   2. 19 の表で RLS が無効だった。Supabase は public に作った表へ')
  say('--      anon / authenticated の ALL を既定で付けるので、無効は「誰でも')
  say('--      読み書きできる」を意味する。実測: ')
  say("--        has_table_privilege('anon','public.kc','DELETE') → true")
  say('--')
  say('--   3. ポリシーが PUBLIC 向けだった。material_select の「OR user_id IS NULL」')
  say('--      （共有教材）は anon にも当たるため、未ログインで共有教材の本文が読めた。')
  say('--      HISTORIA は招待制（上限10名・docs/10）なので、これは意図と違う。')
  say('')
  say('BEGIN;')
  say('')
  say('-- ---- 1. ビューを「問い合わせた本人の権限」で評価させる ----')
  say('ALTER VIEW v_weakness_evidence SET (security_invoker = true);')
  say('')
  say(`-- ---- 2. public の全ての表で RLS を有効にする（${tables.length} 表）----`)
  for (const t of tables) say(`ALTER TABLE ${t.padEnd(20)} ENABLE ROW LEVEL SECURITY;`)
  say('')
  say(`-- ---- 3. ポリシーを貼り直す（${policies.length} 本）----`)
  say('-- ★ ポリシーには CREATE OR REPLACE も IF NOT EXISTS も無い。')
  say('--   DROP IF EXISTS → CREATE が、何度流しても同じにする唯一の書き方である。')
  say('')
  for (const p of policies) {
    say(`DROP POLICY IF EXISTS ${p.name} ON ${p.table};`)
    say(p.sql)
    say('')
  }
  say('COMMIT;')
  say('')
  say('-- ---- 確認 ----')
  say(`-- rls_無効な表 が 0、ポリシー本数 が ${policies.length} になっていれば当たっている。`)
  say('SELECT')
  say("  (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace")
  say("    WHERE n.nspname = 'public' AND c.relkind = 'r' AND NOT c.relrowsecurity) AS rls_無効な表,")
  say("  (SELECT count(*) FROM pg_policies WHERE schemaname = 'public') AS ポリシー本数,")
  say("  (SELECT reloptions FROM pg_class WHERE relname = 'v_weakness_evidence') AS ビューの設定;")
  return o.join('\n') + '\n'
}

/** 書き出し先。リポジトリに入れて、実行しなくても GitHub から取れるようにする */
export const RLS_SQL_PATH = join(SEED_DIR, 'sql', '03_rls.sql')

if (process.argv[1]?.endsWith('dump-rls.ts')) {
  const sql = buildRlsSql()
  if (process.argv.includes('--stdout')) {
    process.stdout.write(sql)
  } else {
    mkdirSync(join(SEED_DIR, 'sql'), { recursive: true })
    writeFileSync(RLS_SQL_PATH, sql)
    const schema = readFileSync(SCHEMA_PATH, 'utf8')
    console.log(`seed/sql/03_rls.sql に書き出した（${(sql.length / 1024).toFixed(0)}KB）`)
    console.log(`  RLS を有効にする表 ${rlsTables(schema).length} / ポリシー ${policyStatements(schema).length} 本`)
  }
}
