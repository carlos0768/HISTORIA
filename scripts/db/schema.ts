/**
 * docs/schema.sql をデータベースに適用する。
 *
 * docs/schema.sql が唯一の真実であり、ここでコピーを持たない（docs/03 §0）。
 *
 * pgvector が入っていない環境（ローカルの検証用 PostgreSQL など）では
 * PGVECTOR=off を渡すと vector 型と HNSW インデックスだけを置換して読み込む。
 * 制約・RLS・トリガの検証には影響しない。Supabase では置換しない。
 */
import { readFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import type { Sql } from 'postgres'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..')
export const SCHEMA_PATH = join(ROOT, 'docs', 'schema.sql')

export function readSchema(opts: { pgvector: boolean }): string {
  let s = readFileSync(SCHEMA_PATH, 'utf8')
  if (!opts.pgvector) {
    s = s
      .replace(/^CREATE EXTENSION IF NOT EXISTS vector;/m, 'CREATE DOMAIN vector AS real[];')
      .replaceAll('vector(768)', 'vector')
      .replace(/^CREATE INDEX ON \w+ USING hnsw .*$/gm, '-- hnsw skipped (PGVECTOR=off)')
  }
  return s
}

/**
 * Supabase の auth.uid() をローカルで代替する。
 * schema.sql の RLS ポリシーが auth.uid() を参照するので、これが無いと
 * CREATE POLICY の時点で落ちる。
 */
export const AUTH_SHIM = `
CREATE SCHEMA IF NOT EXISTS auth;
CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
`

/**
 * auth.uid() が無ければ shim を作る。
 *
 * ★ pgvector の有無で判断してはいけない。CI は pgvector 入りのイメージを使うが
 *   Supabase ではないので auth.uid() は無い。「pgvector があれば Supabase」は成り立たない。
 * ★ CREATE OR REPLACE にしない。Supabase 上で実行したとき本物の auth.uid() を
 *   上書きしてしまい、認証が壊れる。存在しないときだけ作る。
 */
export async function ensureAuthShim(db: Sql): Promise<boolean> {
  const [row] = await db<{ present: boolean }[]>`
    SELECT to_regprocedure('auth.uid()') IS NOT NULL AS present`
  if (row?.present) return false
  await db.unsafe(AUTH_SHIM)
  return true
}

/**
 * Supabase の3ロールと、その**既定権限**をローカルで再現する。
 *
 * ★ ロールを作るだけでは足りない。権限まで真似ないと意味が無い。
 *   Supabase は public スキーマに ALTER DEFAULT PRIVILEGES を仕掛けており、
 *   あとから作った表に anon / authenticated 向けの ALL が自動で付く。
 *   素の PostgreSQL は逆で、GRANT しない限り誰も触れない。
 *   ここを再現しないと「手元では RLS が無くても誰も読めない」ように見え、
 *   本番だけ anon キーで読み書きできる、という食い違いが試験をすり抜ける。
 *   実際 2026-09-02 に本番で見つけた穴（19表が RLS 無効＝anon が DELETE 可能）は
 *   この食い違いのせいで手元の 343 件の試験を素通りしていた。
 *
 * ★ 既にあるロールには触れない。Supabase 上で流したとき本物を壊さないため。
 */
export const SUPABASE_ROLES_SHIM = `
DO $$
BEGIN
  -- 並行してテスト用DBを作るとロール作成が競合する。ロールはクラスタ共有なので
  -- 「既にある」系の失敗は握りつぶして良い（欲しいのは「存在すること」だけ）。
  --
  -- ★ duplicate_object だけでは足りない。CREATE ROLE が先に見るのは
  --   pg_authid の一意索引なので、**本当に同時**だと unique_violation (23505) が飛ぶ。
  --   「開始前から在った」= duplicate_object (42710) / 「今まさに他が作った」= unique_violation。
  --   前者しか捕まえていなかったため CI が確率的に落ちていた（2026-09-02・実測）。
  --   なお一意索引の待ち合わせで相手の COMMIT まで待つので、
  --   unique_violation を捕まえた時点でロールは必ず存在する。
  BEGIN CREATE ROLE anon          NOLOGIN NOINHERIT; EXCEPTION WHEN duplicate_object OR unique_violation THEN NULL; END;
  BEGIN CREATE ROLE authenticated NOLOGIN NOINHERIT; EXCEPTION WHEN duplicate_object OR unique_violation THEN NULL; END;
  BEGIN CREATE ROLE service_role  NOLOGIN NOINHERIT BYPASSRLS; EXCEPTION WHEN duplicate_object OR unique_violation THEN NULL; END;
END $$;

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA auth   TO anon, authenticated, service_role;

-- これから作る表・列・シーケンス・関数に既定で ALL を付ける（Supabase と同じ）
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON TABLES    TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth
  GRANT EXECUTE ON FUNCTIONS TO anon, authenticated, service_role;
`

/**
 * Supabase でなければ、3ロールと既定権限を用意する。
 *
 * ★ 判定に authenticated の有無を使ってはいけない。
 *   手元で一度でも CREATE ROLE authenticated を打つと「もうある」と見なされ、
 *   肝心の ALTER DEFAULT PRIVILEGES を飛ばしてしまう。ロールはクラスタ共有、
 *   既定権限はデータベース単位なので、片方だけ残るのが普通に起きる。
 *   本物の Supabase だけが持つ supabase_admin で判定する。
 * ★ shim 自体は何度流しても同じで、同時に流しても同じ
 *   （DO で duplicate_object と unique_violation の両方を握りつぶし、
 *   GRANT と ALTER DEFAULT PRIVILEGES は元々冪等）。
 */
export async function ensureSupabaseRoles(db: Sql): Promise<boolean> {
  const [row] = await db<{ real: boolean }[]>`
    SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') AS real`
  if (row?.real) return false
  await db.unsafe(SUPABASE_ROLES_SHIM)
  return true
}

export async function applySchema(db: Sql, opts: { pgvector?: boolean; authShim?: boolean } = {}): Promise<void> {
  const pgvector = opts.pgvector ?? process.env.PGVECTOR !== 'off'
  // ★ 順番が効く。auth スキーマ → ロールと既定権限 → 表、の順でなければ
  //   ALTER DEFAULT PRIVILEGES が表に効かない（既定権限は「後から作る物」にしか付かない）。
  if (opts.authShim ?? true) {
    await ensureAuthShim(db)
    await ensureSupabaseRoles(db)
  }
  await db.unsafe(readSchema({ pgvector }))
}
