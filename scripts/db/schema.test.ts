import { describe, it, expect } from 'vitest'
import postgres from 'postgres'
import { readSchema, ensureAuthShim } from './schema'
import { TEST_DB_URL } from '@/lib/db/test-helper'

describe('スキーマの読み込み', () => {
  it('pgvector があればそのまま読む', () => {
    const s = readSchema({ pgvector: true })
    expect(s).toContain('CREATE EXTENSION IF NOT EXISTS vector;')
    expect(s).toContain('vector(768)')
    expect(s).toContain('USING hnsw')
  })
  it('pgvector が無ければ型と索引だけ置換する（制約と RLS は触らない）', () => {
    const s = readSchema({ pgvector: false })
    expect(s).toContain('CREATE DOMAIN vector AS real[];')
    expect(s).not.toContain('vector(768)')
    expect(s).not.toContain('USING hnsw')
    // 置換で消えてはいけないもの
    expect(s).toContain('ENABLE ROW LEVEL SECURITY')
    expect(s).toContain('auth.uid()')
    expect(s).toContain('ef >= 1.3::real')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('auth シム', () => {
  it('auth.uid() が無ければ作り、あれば触らない（本物を上書きしない）', async () => {
    const admin = postgres(TEST_DB_URL!, { prepare: false, max: 1, onnotice: () => {} })
    await admin.unsafe('DROP DATABASE IF EXISTS historia_shim_test')
    await admin.unsafe('CREATE DATABASE historia_shim_test')
    await admin.end({ timeout: 5 })

    const url = new URL(TEST_DB_URL!)
    url.pathname = '/historia_shim_test'
    const db = postgres(url.toString(), { prepare: false, max: 1, onnotice: () => {} })
    try {
      expect(await ensureAuthShim(db)).toBe(true)  // 無かったので作った
      expect(await ensureAuthShim(db)).toBe(false) // もうあるので作らない
    } finally {
      await db.end({ timeout: 5 })
      const a = postgres(TEST_DB_URL!, { prepare: false, max: 1, onnotice: () => {} })
      await a.unsafe('DROP DATABASE IF EXISTS historia_shim_test')
      await a.end({ timeout: 5 })
    }
  }, 60_000)
})
