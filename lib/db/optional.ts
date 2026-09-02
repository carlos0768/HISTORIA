/**
 * DATABASE_URL が無い環境でも画面が描けるようにする。
 * Vercel のプレビューには DB を繋がないので、落とさず「未接続」を出す。
 */
import type { Sql } from 'postgres'
import { sql } from './client'

export function tryDb(): Sql | null {
  if (!process.env.DATABASE_URL) return null
  try { return sql() } catch { return null }
}
