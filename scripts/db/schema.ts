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

export async function applySchema(db: Sql, opts: { pgvector?: boolean; authShim?: boolean } = {}): Promise<void> {
  const pgvector = opts.pgvector ?? process.env.PGVECTOR !== 'off'
  if (opts.authShim ?? true) await ensureAuthShim(db)
  await db.unsafe(readSchema({ pgvector }))
}
