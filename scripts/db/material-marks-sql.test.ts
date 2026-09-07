import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser } from '@/lib/loop/fixture'
import { stripImportant } from '@/lib/domain/markup'
import { buildMarksSql, readMarkedUnits } from './material-marks-sql'

const UNIT = 'wh.1.1.1'

describe('マークを反映する SQL（生成）', () => {
  it('マークの無い節は送らず、本文の md5 を両方（マーク前・後）条件に入れる', () => {
    const { sql, sections, marks } = buildMarksSql([{
      unitId: UNIT, sha: 'abcdef012345',
      sections: [
        { ord: 1, bodyMd: '問いだけ' },
        { ord: 3, bodyMd: '二足歩行が==先==で、脳は==後==' },
      ],
    }])
    expect(sections).toBe(1)
    expect(marks).toBe(2)
    expect(sql).not.toContain("'問いだけ'")
    expect(sql).toContain("s.ord = 3 AND md5(s.body_md) IN (")
    expect(sql).toContain("'mark_important'")
    expect(sql).toMatch(/^BEGIN;$/m)
    expect(sql).toMatch(/^COMMIT;$/m)
  })
  it('seed/material を読める（全件にマークがある）', () => {
    const units = readMarkedUnits([UNIT])
    expect(units).toHaveLength(1)
    expect(units[0]!.sections.some(s => s.bodyMd.includes('=='))).toBe(true)
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('マークを反映する SQL（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  let userId: string
  const NOW = new Date('2026-09-07T12:00:00Z')
  const unit = readMarkedUnits([UNIT])[0]!
  const marked3 = unit.sections.find(s => s.ord === 3)!
  const marked6 = unit.sections.find(s => s.ord === 6)!
  let shared: string, mine: string, sec3: string

  /** postgres.js はプール接続の BEGIN を拒むので、同じ原子性を db.begin で与える */
  const apply = (sql: string) =>
    db.begin(tx => tx.unsafe(sql.replace(/^BEGIN;$/m, '').replace(/^COMMIT;$/m, '')))

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_marks_sql_test'))
    await seedMasters(db, SEED_DIR)
    userId = await createUser(db, NOW)

    const material = async (owner: string | null) => {
      const id = randomUUID()
      await db`
        INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version, status, generated_at)
        VALUES (${id}, ${owner}, ${UNIT}, '教材', 'authored', 'claude-code', 'material_v2', 'ready', ${NOW})`
      return id
    }
    const section = async (materialId: string, ord: number, body: string) => {
      const id = randomUUID()
      await db`
        INSERT INTO material_section (id, material_id, ord, heading, body_md, char_count)
        VALUES (${id}, ${materialId}, ${ord}, ${`§${ord}`}, ${body}, ${body.length})`
      return id
    }
    shared = await material(null)
    // §3 は seed と同じ本文（マーク無し）。§6 は作者が直した別の本文
    sec3 = await section(shared, 3, stripImportant(marked3.bodyMd))
    await section(shared, 6, '誤りの報告で直した本文')
    // 個人向けの教材は seed と同じ本文でも触らない
    mine = await material(userId)
    await section(mine, 3, stripImportant(marked3.bodyMd))
    // 読了記録。節の id が変わらないので残るはず
    await db`INSERT INTO material_read (user_id, section_id, dwell_ms) VALUES (${userId}, ${sec3}, 60000)`
  })
  afterAll(async () => { await drop() })

  it('seed と一致する共有教材の節だけにマークが入り、読了記録は残る', async () => {
    await apply(buildMarksSql([unit]).sql)
    const [s3] = await db<{ body_md: string; char_count: number }[]>`
      SELECT body_md, char_count FROM material_section WHERE id = ${sec3}`
    expect(s3!.body_md).toBe(marked3.bodyMd)
    expect(s3!.char_count).toBe(stripImportant(marked3.bodyMd).length)

    const [s6] = await db<{ body_md: string }[]>`
      SELECT body_md FROM material_section WHERE material_id = ${shared} AND ord = 6`
    expect(s6!.body_md).toBe('誤りの報告で直した本文')
    expect(marked6.bodyMd).toContain('==')   // seed 側にはマークがあるのに、上書きしていない

    const [m3] = await db<{ body_md: string }[]>`
      SELECT body_md FROM material_section WHERE material_id = ${mine} AND ord = 3`
    expect(m3!.body_md).not.toContain('==')

    const reads = await db`SELECT 1 FROM material_read WHERE section_id = ${sec3}`
    expect(reads).toHaveLength(1)

    const [log] = await db<{ n: number }[]>`
      SELECT jsonb_array_length(human_edit_log) AS n FROM material WHERE id = ${shared}`
    expect(log!.n).toBe(1)
  })

  it('もう一度流しても同じ（マークは二重にならず、来歴も増えない）', async () => {
    await apply(buildMarksSql([unit]).sql)
    const [s3] = await db<{ body_md: string }[]>`SELECT body_md FROM material_section WHERE id = ${sec3}`
    expect(s3!.body_md).toBe(marked3.bodyMd)
    const [log] = await db<{ n: number }[]>`
      SELECT jsonb_array_length(human_edit_log) AS n FROM material WHERE id = ${shared}`
    expect(log!.n).toBe(1)
  })
})
