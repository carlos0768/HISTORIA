/**
 * PostgreSQL 接続
 *
 * Supabase の Serverless からの直接接続はコネクションを食い潰すため、
 * 本番は Supavisor（transaction モード）経由にする（docs/12 §4）。
 * ローカルとテストは DATABASE_URL をそのまま使う。
 */
import postgres from 'postgres'
import { DbNotConfiguredError } from './error'

let _sql: postgres.Sql | null = null

export function sql(): postgres.Sql {
  if (_sql) return _sql
  const url = process.env.DATABASE_URL
  // ★ 名前付きの例外を投げる。呼び出し側（lib/db/error.ts の分類器）が
  //   文面を比べずに「未設定」だと判別できるようにするため
  if (!url) throw new DbNotConfiguredError()
  _sql = postgres(url, {
    // transaction モードのプーラーでは prepared statement が使えない
    prepare: false,
    max: Number(process.env.PGPOOL_MAX ?? 5),
    idle_timeout: 20,
  })
  return _sql
}
