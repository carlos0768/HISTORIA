import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { readFileSync } from 'node:fs'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { buildSeedSql, SEED_SQL_PATH } from './dump-sql'
import { seedAll, SEED_DIR } from './seed'
import { readCsv } from './csv'

/**
 * postgres.js はプール接続での BEGIN / COMMIT を拒む（UNSAFE_TRANSACTION）。
 * psql や Supabase の SQL エディタでは問題なく通るので、
 * ここでは同じ原子性を db.begin で与えて中身だけを流す。
 */
const applySeedSql = (db: Sql, sql: string) =>
  db.begin(tx => tx.unsafe(sql.replace(/^BEGIN;$/m, '').replace(/^COMMIT;$/m, '')))

describe('Supabase 用の SQL', () => {
  it('リポジトリに入っている SQL が CSV と揃っている', () => {
    // ずれていたら npx tsx scripts/db/dump-sql.ts で作り直す
    expect(readFileSync(SEED_SQL_PATH, 'utf8')).toBe(buildSeedSql().sql)
  })

  it('承認されていない KC を含めない（作者承認制）', () => {
    const { sql } = buildSeedSql()
    const rows = readCsv(`${SEED_DIR}/kc.csv`)
    for (const k of rows.filter(r => r.approve !== '○')) {
      expect(sql, `未承認の ${k.id} が含まれている`).not.toContain(k.id!)
    }
    for (const k of rows.filter(r => r.approve === '○')) {
      expect(sql, `承認済みの ${k.id} が含まれていない`).toContain(k.id!)
    }
  })

  it('単引用符を含む文字列を壊さない', () => {
    const { sql } = buildSeedSql()
    // 生成器は '' でエスケープする。閉じられていない引用符が無いことを見る
    for (const line of sql.split('\n')) {
      const quotes = (line.match(/'/g) ?? []).length
      expect(quotes % 2, `引用符が閉じていない: ${line.slice(0, 80)}`).toBe(0)
    }
  })

  it('トランザクションで囲まれている（途中で落ちても半端に入らない）', () => {
    const { sql } = buildSeedSql()
    expect(sql).toContain('BEGIN;')
    expect(sql.trimEnd().split('\n').filter(l => l === 'COMMIT;')).toHaveLength(1)
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('Supabase 用の SQL（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>

  beforeAll(async () => { ({ db, drop } = await createTestDb('historia_dumpsql_test')) }, 120_000)
  afterAll(async () => { await drop() })

  it('空のデータベースに流れ、tsx のローダーと同じ結果になる', async () => {
    const { sql, counts } = buildSeedSql()
    await applySeedSql(db, sql)

    const q = async (t: string) => {
      const r = await db<{ n: string }[]>`SELECT count(*) AS n FROM ${db(t)}`
      return Number(r[0]!.n)
    }
    expect(await q('era')).toBe(counts.era)
    expect(await q('region')).toBe(counts.region)
    expect(await q('syllabus_unit')).toBe(counts.syllabusUnit)
    expect(await q('kc')).toBe(counts.kc)
    expect(await q('kc_region')).toBe(counts.kcRegion)
    expect(await q('kc_syllabus_unit')).toBe(counts.kc)

    // ★ SQL とローダーが同じものを入れることを確かめる。
    //   ずれると「貼ったのに動かない」が起きる
    const before = await db<Record<string, unknown>[]>`SELECT * FROM kc ORDER BY id`
    const counts2 = await seedAll(db, SEED_DIR)
    expect(counts2.kc).toBe(counts.kc)
    const after = await db<Record<string, unknown>[]>`SELECT * FROM kc ORDER BY id`
    expect(after).toEqual(before)
  })

  it('二度流しても件数が増えない', async () => {
    const { sql, counts } = buildSeedSql()
    await applySeedSql(db, sql)
    const [n] = await db<{ n: string }[]>`SELECT count(*) AS n FROM kc_region`
    expect(Number(n!.n)).toBe(counts.kcRegion)
  })
})
