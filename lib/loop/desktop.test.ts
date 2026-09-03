import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, seedCanonEvent, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createMaterial } from './fixture'
import { materialLibrary, MATERIAL_STATUSES, LIBRARY_LIMIT } from './library'
import { timeline, formatYear, formatSpan, TIMELINE_LIMIT } from './timeline'
import { commandsFor, SCREEN_COMMANDS, MAX_COMMANDS } from './commands'

/**
 * デスクトップの画面が読むもの（docs/06-desktop.md）
 */

describe('年の見せ方', () => {
  it('紀元前は「前」を付ける', () => {
    expect(formatYear(-330)).toBe('前330')
    expect(formatYear(1867)).toBe('1867')
  })

  it('1年で終わる出来事は年を1つだけ出す', () => {
    expect(formatSpan({ yearFrom: 1867, yearTo: null })).toBe('1867')
    expect(formatSpan({ yearFrom: 1867, yearTo: 1867 })).toBe('1867')
  })

  it('続いた出来事は範囲で出す', () => {
    expect(formatSpan({ yearFrom: 1868, yearTo: 1869 })).toBe('1868–1869')
    expect(formatSpan({ yearFrom: -334, yearTo: -323 })).toBe('前334–前323')
  })
})

describe('画面への移動', () => {
  it('主要な画面が全部さがせる', () => {
    const hrefs = SCREEN_COMMANDS.map(c => c.href)
    for (const h of ['/', '/study', '/drills', '/records', '/library', '/timeline', '/map', '/settings']) {
      expect(hrefs, `${h} がさがせない`).toContain(h)
    }
  })

  it('同じ id が2つ無い', () => {
    expect(new Set(SCREEN_COMMANDS.map(c => c.id)).size).toBe(SCREEN_COMMANDS.length)
  })

  /** ★ 管理画面はさがせない。ADMIN_USER_ID を知らない人に存在を教えない */
  it('管理画面はさがせない', () => {
    expect(SCREEN_COMMANDS.map(c => c.href)).not.toContain('/admin')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('デスクトップの画面（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  let userId: string
  const NOW = new Date('2026-09-15T03:00:00Z')
  const UNIT = 'wh.2.1.1'

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_desktop_test'))
    await seedMasters(db, SEED_DIR)
    await seedCanonEvent(db, SEED_DIR, { requireApproval: false })
  }, 180_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    for (const t of ['material_read', 'material_section', 'material', 'app_user']) {
      await db.unsafe(`DELETE FROM ${t}`)
    }
    userId = await createUser(db, NOW)
  })

  // ★ material_section.id は uuid で DEFAULT が無い（docs/schema.sql）。自分で採番する
  const section = async (materialId: string, ord: number, chars = 500, hidden = false) => {
    const id = randomUUID()
    await db`
      INSERT INTO material_section (id, material_id, ord, heading, body_md, char_count, hidden)
      VALUES (${id}, ${materialId}, ${ord}, ${`見出し${ord}`}, '本文', ${chars}, ${hidden})`
    return id
  }

  describe('教材の一覧', () => {
    it('自分の教材と共有教材を出す', async () => {
      await createMaterial(db, { userId, unitId: UNIT })
      await createMaterial(db, { userId: null, unitId: UNIT })
      expect(await materialLibrary(db, userId)).toHaveLength(2)
    })

    /** ★ 可視範囲を緩めない。他人の教材の題名が漏れる */
    it('他人の教材は出さない', async () => {
      const other = await createUser(db, NOW)
      await createMaterial(db, { userId: other, unitId: UNIT })
      expect(await materialLibrary(db, userId)).toHaveLength(0)
    })

    it('生成中も配信不可も隠さない', async () => {
      await createMaterial(db, { userId, unitId: UNIT, status: 'generating' })
      await createMaterial(db, { userId, unitId: UNIT, status: 'blocked' })
      const rows = await materialLibrary(db, userId)
      expect(rows.map(r => r.status).sort()).toEqual(['blocked', 'generating'])
    })

    it('状態で絞れる', async () => {
      await createMaterial(db, { userId, unitId: UNIT, status: 'ready' })
      await createMaterial(db, { userId, unitId: UNIT, status: 'blocked' })
      expect(await materialLibrary(db, userId, { status: 'blocked' })).toHaveLength(1)
    })

    /** ★ CHECK 外の値を SQL へ渡さない。知らない状態は「絞らない」に落とす */
    it('知らない状態を渡されても落ちない（絞らない扱い）', async () => {
      await createMaterial(db, { userId, unitId: UNIT })
      expect(await materialLibrary(db, userId, { status: "'; DROP TABLE material; --" }))
        .toHaveLength(1)
      expect(MATERIAL_STATUSES).not.toContain('nonsense')
    })

    it('題名・章・節でさがせる', async () => {
      const id = await createMaterial(db, { userId, unitId: UNIT })
      await db`UPDATE material SET title = 'オリエントの統一' WHERE id = ${id}`
      expect(await materialLibrary(db, userId, { query: 'オリエント' })).toHaveLength(1)
      expect(await materialLibrary(db, userId, { query: '該当なし' })).toHaveLength(0)
      // 節のラベルでも引ける
      const [u] = await db<{ label: string }[]>`SELECT label FROM syllabus_unit WHERE id = ${UNIT}`
      expect(await materialLibrary(db, userId, { query: u!.label })).toHaveLength(1)
    })

    /** ★ `%` を打たれると全件一致になり、絞れなくなる */
    it('LIKE のメタ文字を無効にする', async () => {
      const id = await createMaterial(db, { userId, unitId: UNIT })
      await db`UPDATE material SET title = '普通の教材' WHERE id = ${id}`
      expect(await materialLibrary(db, userId, { query: '%' })).toHaveLength(0)
      expect(await materialLibrary(db, userId, { query: '_' })).toHaveLength(0)
    })

    it('字数と読了を数える', async () => {
      const id = await createMaterial(db, { userId, unitId: UNIT })
      const s1 = await section(id, 1, 400)
      await section(id, 2, 600)
      await db`INSERT INTO material_read (user_id, section_id, dwell_ms, read_at)
               VALUES (${userId}, ${s1}, 60000, ${NOW})`
      const [row] = await materialLibrary(db, userId)
      expect(row!.chars).toBe(1000)
      expect(row!.sections).toBe(2)
      expect(row!.readSections).toBe(1)
    })

    /** ★ 伏せたセクションは読めない。分母に入れると永遠に読了しない */
    it('伏せたセクションは字数にも分母にも入れない', async () => {
      const id = await createMaterial(db, { userId, unitId: UNIT })
      await section(id, 1, 400)
      await section(id, 2, 600, true)
      const [row] = await materialLibrary(db, userId)
      expect(row!.chars).toBe(400)
      expect(row!.sections).toBe(1)
    })

    it('他人の読了を自分の読了として数えない', async () => {
      const other = await createUser(db, NOW)
      const id = await createMaterial(db, { userId: null, unitId: UNIT })
      const s = await section(id, 1)
      await db`INSERT INTO material_read (user_id, section_id, dwell_ms, read_at)
               VALUES (${other}, ${s}, 60000, ${NOW})`
      const [row] = await materialLibrary(db, userId)
      expect(row!.readSections).toBe(0)
    })

    // ★ ready は (user, unit) で1本しか置けない（material_one_ready_per_user_unit）。
    //   別の単元を使う
    it('新しい順に出す', async () => {
      const a = await createMaterial(db, { userId, unitId: UNIT })
      const b = await createMaterial(db, { userId, unitId: 'wh.2.1.2' })
      await db`UPDATE material SET generated_at = '2026-01-01' WHERE id = ${a}`
      await db`UPDATE material SET generated_at = '2026-06-01' WHERE id = ${b}`
      expect((await materialLibrary(db, userId)).map(r => r.id)).toEqual([b, a])
    })

    it('上限を守る', async () => {
      expect(LIBRARY_LIMIT).toBeLessThanOrEqual(500)
    })
  })

  describe('年表', () => {
    it('正典を年の順に出す', async () => {
      const rows = await timeline(db, { from: -400, to: -300 })
      expect(rows.length).toBeGreaterThan(0)
      const years = rows.map(r => r.yearFrom)
      expect([...years].sort((a, b) => a - b)).toEqual(years)
      expect(Math.min(...years)).toBeGreaterThanOrEqual(-400 - 2000)
    })

    it('年の範囲で絞る', async () => {
      const rows = await timeline(db, { from: 1900, to: 1950 })
      // 範囲に重なる出来事だけ（開始が範囲より前でも、終了が範囲に入っていれば出す）
      for (const r of rows) {
        expect(r.yearFrom).toBeLessThanOrEqual(1950)
        expect(r.yearTo ?? r.yearFrom).toBeGreaterThanOrEqual(1900)
      }
    })

    it('名前でさがせる', async () => {
      // ★ 正典に実在するラベルで引く（「フランス革命」は seed に無かった）
      const rows = await timeline(db, { query: '辛亥革命' })
      expect(rows.length).toBeGreaterThan(0)
      expect(rows.some(r => r.label.includes('辛亥革命'))).toBe(true)
    })

    it('部分一致で引ける', async () => {
      const rows = await timeline(db, { query: '革命' })
      expect(rows.length).toBeGreaterThan(1)
    })

    it('LIKE のメタ文字を無効にする', async () => {
      expect(await timeline(db, { query: '%' })).toHaveLength(0)
    })

    it('地域で絞る', async () => {
      const all = await timeline(db, { from: 1500, to: 1600 })
      const one = await timeline(db, { from: 1500, to: 1600, regionId: 1 })
      expect(one.length).toBeLessThanOrEqual(all.length)
      for (const r of one) expect(r.regionIds).toContain(1)
    })

    it('件数の上限を守る', async () => {
      const rows = await timeline(db)
      expect(rows.length).toBeLessThanOrEqual(TIMELINE_LIMIT)
    })

    it('条件に合わなければ空を返す', async () => {
      expect(await timeline(db, { from: 3000, to: 3100 })).toHaveLength(0)
    })
  })

  describe('⌘K でさがせるもの', () => {
    it('画面に加えて単元も出す', async () => {
      const cmds = await commandsFor(db)
      expect(cmds.length).toBeGreaterThan(SCREEN_COMMANDS.length)
      expect(cmds.some(c => c.kind === '単元')).toBe(true)
    })

    it('節だけを出す（部や章は出さない）', async () => {
      const cmds = await commandsFor(db)
      const unitIds = cmds.filter(c => c.kind === '単元').map(c => c.id.slice(2))
      const levels = await db<{ level: number }[]>`
        SELECT DISTINCT level FROM syllabus_unit WHERE id IN ${db(unitIds)}`
      expect(levels.map(l => l.level)).toEqual([3])
    })

    /** ★ 教材の本文は入れない。他人の教材が見えてしまう */
    it('教材の本文は入れない', async () => {
      const id = await createMaterial(db, { userId, unitId: UNIT })
      await section(id, 1)
      const cmds = await commandsFor(db)
      expect(cmds.some(c => c.href.includes('/material/'))).toBe(false)
    })

    it('上限を守る', async () => {
      const cmds = await commandsFor(db)
      expect(cmds.filter(c => c.kind === '単元').length).toBeLessThanOrEqual(MAX_COMMANDS)
    })
  })
})
