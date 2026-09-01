/**
 * DB を使うテストの土台。
 * TEST_DATABASE_URL が無いテストはスキップする（鍵の要らない環境でも CI を通すため）。
 */
import postgres from 'postgres'
import type { Sql } from 'postgres'
import { applySchema } from '@/scripts/db/schema'

export const TEST_DB_URL = process.env.TEST_DATABASE_URL

/** 使い捨てのデータベースを作ってスキーマを流す */
export async function createTestDb(name: string): Promise<{ db: Sql; drop: () => Promise<void> }> {
  if (!TEST_DB_URL) throw new Error('TEST_DATABASE_URL が未設定です')
  const admin = postgres(TEST_DB_URL, { prepare: false, max: 1, onnotice: () => {} })
  await admin.unsafe(`DROP DATABASE IF EXISTS "${name}"`)
  await admin.unsafe(`CREATE DATABASE "${name}"`)
  await admin.end({ timeout: 5 })

  const url = new URL(TEST_DB_URL)
  url.pathname = `/${name}`
  const db = postgres(url.toString(), { prepare: false, max: 6, onnotice: () => {} })
  await applySchema(db, { pgvector: process.env.PGVECTOR !== 'off' })

  return {
    db,
    drop: async () => {
      await db.end({ timeout: 5 })
      const a = postgres(TEST_DB_URL!, { prepare: false, max: 1, onnotice: () => {} })
      await a.unsafe(`DROP DATABASE IF EXISTS "${name}"`)
      await a.end({ timeout: 5 })
    },
  }
}
