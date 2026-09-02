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

/** 開発中の閲覧用。認証が入るまでの暫定（docs/03 §7 で Supabase Auth に置き換える） */
export const demoUserId = (): string | null => process.env.DEMO_USER_ID ?? null
