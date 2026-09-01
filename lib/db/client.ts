/**
 * PostgreSQL 接続
 *
 * Supabase の Serverless からの直接接続はコネクションを食い潰すため、
 * 本番は Supavisor（transaction モード）経由にする（docs/12 §4）。
 * ローカルとテストは DATABASE_URL をそのまま使う。
 */
import postgres from 'postgres'

let _sql: postgres.Sql | null = null

export function sql(): postgres.Sql {
  if (_sql) return _sql
  const url = process.env.DATABASE_URL
  if (!url) throw new Error('DATABASE_URL が設定されていません')
  _sql = postgres(url, {
    // transaction モードのプーラーでは prepared statement が使えない
    prepare: false,
    max: Number(process.env.PGPOOL_MAX ?? 5),
    idle_timeout: 20,
  })
  return _sql
}

export async function closeSql(): Promise<void> {
  if (_sql) {
    await _sql.end({ timeout: 5 })
    _sql = null
  }
}
