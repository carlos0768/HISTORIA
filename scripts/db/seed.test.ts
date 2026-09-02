import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { mkdtempSync, cpSync, readFileSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedAll, seedKc, SEED_DIR } from './seed'
import { readCsv } from './csv'
import { parseCsv } from './csv'

describe('CSV パーサ', () => {
  it('引用符と埋め込みカンマを読む', () => {
    expect(parseCsv('a,b\n"x,1","y""z"\n')).toEqual([{ a: 'x,1', b: 'y"z' }])
  })
  it('空行を落とす', () => {
    expect(parseCsv('a\n1\n\n2\n')).toEqual([{ a: '1' }, { a: '2' }])
  })
  it('末尾に改行が無くても読む', () => {
    expect(parseCsv('a,b\n1,2')).toEqual([{ a: '1', b: '2' }])
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('seed 投入（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>

  beforeAll(async () => { ({ db, drop } = await createTestDb('historia_seed_test')) }, 120_000)
  afterAll(async () => { await drop() })

  it('承認済みの KC が入る（作者承認制 docs/02 §5）', async () => {
    const counts = await seedAll(db, SEED_DIR)
    const csv = readCsv(`${SEED_DIR}/kc.csv`)
    expect(csv).toHaveLength(60)
    // 第1バッチは作者が60件すべてを承認した
    expect(csv.every(r => r.approve === '○')).toBe(true)
    expect(counts.kc).toBe(60)
    expect(counts.skippedUnapproved).toBe(0)
    const rows = await db<{ count: string }[]>`SELECT count(*) FROM kc`
    expect(Number(rows[0]!.count)).toBe(60)
  })

  /**
   * 承認制そのものの検査。
   * 実データが全件承認になったので、seed/kc.csv では「入らない」側を示せない。
   * 承認欄を落とした写しを作って、そちらで確かめる。
   */
  it('承認欄が空の KC は入らない', async () => {
    // このスイートは1つの DB を共有する。前のテストが入れた60件を消してから見る
    await db`TRUNCATE kc, kc_region, kc_syllabus_unit RESTART IDENTITY CASCADE`

    const dir = mkdtempSync(join(tmpdir(), 'historia-seed-'))
    cpSync(SEED_DIR, dir, { recursive: true })
    const lines = readFileSync(join(dir, 'kc.csv'), 'utf8').split('\n')
    // 先頭2件の承認を外す
    lines[1] = lines[1]!.replace(/^○,/, ',')
    lines[2] = lines[2]!.replace(/^○,/, ',')
    writeFileSync(join(dir, 'kc.csv'), lines.join('\n'))

    await seedAll(db, dir)          // マスタを入れてから
    const c = await seedKc(db, dir) // 既定は requireApproval: true
    expect(c.kc).toBe(58)
    expect(c.skippedUnapproved).toBe(2)

    const skipped = readCsv(`${SEED_DIR}/kc.csv`).slice(0, 2).map(r => r.id!)
    const found = await db<{ id: string }[]>`SELECT id FROM kc WHERE id IN ${db(skipped)}`
    expect(found).toHaveLength(0)
  })

  it('マスタは全件入る', async () => {
    await seedAll(db, SEED_DIR)
    const q = async (t: string) => {
      const r = await db<{ count: string }[]>`SELECT count(*) FROM ${db(t)}`
      return Number(r[0]!.count)
    }
    expect(await q('era')).toBe(3)
    expect(await q('region')).toBe(24)
    expect(await q('syllabus_unit')).toBe(117)
  })

  it('章立ては3階層で、節が75件', async () => {
    await seedAll(db, SEED_DIR)
    const rows = await db<{ level: number; n: string }[]>`
      SELECT level, count(*) AS n FROM syllabus_unit GROUP BY level ORDER BY level`
    expect(rows.map(r => [r.level, Number(r.n)])).toEqual([[1, 9], [2, 33], [3, 75]])
  })

  it('承認を無視して投入すると KC 60件と対応関係が入る', async () => {
    const c = await seedKc(db, SEED_DIR, { requireApproval: false })
    expect(c.kc).toBe(60)
    const q = async (t: string) => {
      const r = await db<{ count: string }[]>`SELECT count(*) FROM ${db(t)}`
      return Number(r[0]!.count)
    }
    expect(await q('kc')).toBe(60)
    expect(await q('kc_syllabus_unit')).toBe(60)
    expect(await q('kc_region')).toBe(93) // primary 60 + others 33
  })

  it('primary region がちょうど1件（UNIQUE INDEX が効いている）', async () => {
    await seedKc(db, SEED_DIR, { requireApproval: false })
    const bad = await db<{ kc_id: string }[]>`
      SELECT kc_id FROM kc_region WHERE is_primary GROUP BY kc_id HAVING count(*) <> 1`
    expect(bad).toHaveLength(0)
    const missing = await db<{ id: string }[]>`
      SELECT k.id FROM kc k WHERE NOT EXISTS (SELECT 1 FROM kc_region r WHERE r.kc_id = k.id AND r.is_primary)`
    expect(missing).toHaveLength(0)
  })

  it('prereq_ids の参照先がすべて存在する（text[] なので FK が張れない分ここで見る）', async () => {
    await seedKc(db, SEED_DIR, { requireApproval: false })
    const dangling = await db<{ id: string; p: string }[]>`
      SELECT k.id, p FROM kc k, unnest(k.prereq_ids) p
       WHERE NOT EXISTS (SELECT 1 FROM kc WHERE id = p)`
    expect(dangling).toHaveLength(0)
  })

  it('KC を1件も持たない節が、第1バッチの範囲（wh.2.*）には無い', async () => {
    await seedKc(db, SEED_DIR, { requireApproval: false })
    const uncovered = await db<{ id: string }[]>`
      SELECT u.id FROM syllabus_unit u
       WHERE u.level = 3 AND u.id LIKE 'wh.2.%'
         AND NOT EXISTS (SELECT 1 FROM kc_syllabus_unit k WHERE k.unit_id = u.id)`
    expect(uncovered).toHaveLength(0)
  })

  it('冪等: 2回流しても件数が増えない', async () => {
    await seedAll(db, SEED_DIR)
    await seedKc(db, SEED_DIR, { requireApproval: false })
    const before = await db<{ count: string }[]>`SELECT count(*) FROM kc_region`
    await seedAll(db, SEED_DIR)
    await seedKc(db, SEED_DIR, { requireApproval: false })
    const after = await db<{ count: string }[]>`SELECT count(*) FROM kc_region`
    expect(after[0]!.count).toBe(before[0]!.count)
  })

  it('kind の分布が docs/02 §3 のゲートを満たす（fact が35%を超えない）', async () => {
    await seedKc(db, SEED_DIR, { requireApproval: false })
    const rows = await db<{ kind: string; n: string }[]>`SELECT kind, count(*) AS n FROM kc GROUP BY kind`
    const total = rows.reduce((s, r) => s + Number(r.n), 0)
    const pct = Object.fromEntries(rows.map(r => [r.kind, (Number(r.n) / total) * 100]))
    expect(pct.fact ?? 0).toBeLessThanOrEqual(35)
    expect(pct.distinction ?? 0).toBeGreaterThanOrEqual(20)
    expect(pct.causal ?? 0).toBeGreaterThanOrEqual(20)
    expect(pct.chronology ?? 0).toBeGreaterThanOrEqual(12)
    expect(pct.geo ?? 0).toBeGreaterThanOrEqual(3)
  })
})
