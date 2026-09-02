import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { mkdtempSync, cpSync, readFileSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedAll, seedKc, seedCanonEvent, seedPerson, SEED_DIR } from './seed'
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

  /**
   * ★ 件数を数値で書かない。KC は起草が進むたびに増えるので、
   *   「60件」と書いた瞬間にこの試験は内容ではなく件数を守る試験になる。
   *   CSV から期待値を導き、承認された分だけが入ることを見る。
   */
  it('承認済みの KC だけが入る（作者承認制 docs/02 §5）', async () => {
    const counts = await seedAll(db, SEED_DIR)
    const csv = readCsv(`${SEED_DIR}/kc.csv`)
    const approved = csv.filter(r => r.approve === '○')
    const pending = csv.filter(r => r.approve !== '○')
    expect(approved.length).toBeGreaterThan(0)
    expect(counts.kc).toBe(approved.length)
    expect(counts.skippedUnapproved).toBe(pending.length)
    const rows = await db<{ count: string }[]>`SELECT count(*) FROM kc`
    expect(Number(rows[0]!.count)).toBe(approved.length)
    // 未承認の id が1件も入っていないこと
    if (pending.length > 0) {
      const ids = pending.map(r => r.id!)
      const found = await db<{ id: string }[]>`SELECT id FROM kc WHERE id IN ${db(ids)}`
      expect(found).toHaveLength(0)
    }
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
    const base = readCsv(`${SEED_DIR}/kc.csv`)
    const approvedBefore = base.filter(r => r.approve === '○').length
    // 写しでは承認を2件外したので、入る数はちょうど2件減る
    expect(c.kc).toBe(approvedBefore - 2)
    expect(c.skippedUnapproved).toBe(base.length - approvedBefore + 2)

    const skipped = readCsv(`${SEED_DIR}/kc.csv`).slice(0, 2).map(r => r.id!)
    const found = await db<{ id: string }[]>`SELECT id FROM kc WHERE id IN ${db(skipped)}`
    expect(found).toHaveLength(0)
  })

  /**
   * ---- 層2の正典（docs/08 §5 層2）----
   *
   * ★ ここも件数を数値で書かない。canon_event は起草が進むたびに増える。
   *
   * ★ この2件は対になっている。実データが**全件未承認**の間は、この試験の
   *   「入る」側が0件で空回りする。だから次の試験が、承認を付けた写しで
   *   「入る」側を示している（KC は全件承認なので逆向きに写しを作っている）。
   *   **どちらか一方だけを消すと、承認制が壊れても気づけなくなる。**
   */
  it('承認済みの canon_event / person だけが入る', async () => {
    await db`TRUNCATE canon_event, person RESTART IDENTITY CASCADE`
    const counts = await seedAll(db, SEED_DIR)

    const ce = readCsv(`${SEED_DIR}/canon_event.csv`)
    const pe = readCsv(`${SEED_DIR}/person.csv`)
    const ceOk = ce.filter(r => r.approve === '○')
    const peOk = pe.filter(r => r.approve === '○')

    expect(counts.canonEvent).toBe(ceOk.length)
    expect(counts.person).toBe(peOk.length)
    expect(counts.skippedCanonEvent).toBe(ce.length - ceOk.length)
    expect(counts.skippedPerson).toBe(pe.length - peOk.length)

    const n = async (t: string) => {
      const r = await db<{ count: string }[]>`SELECT count(*) FROM ${db(t)}`
      return Number(r[0]!.count)
    }
    expect(await n('canon_event')).toBe(ceOk.length)
    expect(await n('person')).toBe(peOk.length)
  })

  it('承認欄が空の canon_event / person は入らない', async () => {
    await db`TRUNCATE canon_event, person RESTART IDENTITY CASCADE`

    // 承認を付けた写しを作って「入る」側を示す。実データは起草中で全件空欄なので、
    // そのままでは「入らない」しか示せず、投入経路が壊れても気づけない
    const dir = mkdtempSync(join(tmpdir(), 'historia-canon-'))
    cpSync(SEED_DIR, dir, { recursive: true })
    const approveFirst = (file: string, howMany: number) => {
      const lines = readFileSync(join(dir, file), 'utf8').split('\n')
      for (let i = 1; i <= howMany; i++) lines[i] = '○' + lines[i]!
      writeFileSync(join(dir, file), lines.join('\n'))
    }
    approveFirst('canon_event.csv', 3)
    approveFirst('person.csv', 2)

    const c = await seedCanonEvent(db, dir)
    const p = await seedPerson(db, dir)
    expect(c.canonEvent).toBe(3)
    expect(p.person).toBe(2)

    // 承認していない行は1件も入っていない
    const rest = readCsv(`${SEED_DIR}/canon_event.csv`).slice(3).map(r => r.id!)
    const found = await db<{ id: string }[]>`SELECT id FROM canon_event WHERE id IN ${db(rest)}`
    expect(found).toHaveLength(0)
  })

  it('canon_event は冪等（2回流しても増えない・aliases も保たれる）', async () => {
    await db`TRUNCATE canon_event, person RESTART IDENTITY CASCADE`
    const dir = mkdtempSync(join(tmpdir(), 'historia-canon2-'))
    cpSync(SEED_DIR, dir, { recursive: true })
    const lines = readFileSync(join(dir, 'canon_event.csv'), 'utf8').split('\n')
    for (let i = 1; i <= 5; i++) lines[i] = '○' + lines[i]!
    writeFileSync(join(dir, 'canon_event.csv'), lines.join('\n'))

    await seedCanonEvent(db, dir)
    await seedCanonEvent(db, dir)
    const rows = await db<{ count: string }[]>`SELECT count(*) FROM canon_event`
    expect(Number(rows[0]!.count)).toBe(5)

    // aliases（text[]）と region_ids（smallint[]）が配列として入っていること
    const withAlias = await db<{ id: string; aliases: string[]; region_ids: number[] }[]>`
      SELECT id, aliases, region_ids FROM canon_event WHERE cardinality(aliases) > 0 LIMIT 1`
    expect(withAlias.length).toBe(1)
    expect(Array.isArray(withAlias[0]!.aliases)).toBe(true)
    expect(withAlias[0]!.region_ids.length).toBeGreaterThan(0)
  })

  it('person は label が同じなら1件にまとまる（id は自動採番）', async () => {
    await db`TRUNCATE person RESTART IDENTITY CASCADE`
    const dir = mkdtempSync(join(tmpdir(), 'historia-person-'))
    cpSync(SEED_DIR, dir, { recursive: true })
    const lines = readFileSync(join(dir, 'person.csv'), 'utf8').split('\n')
    lines[1] = '○' + lines[1]!
    writeFileSync(join(dir, 'person.csv'), lines.join('\n'))

    await seedPerson(db, dir)
    await seedPerson(db, dir)
    const rows = await db<{ count: string }[]>`SELECT count(*) FROM person`
    expect(Number(rows[0]!.count)).toBe(1)
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

  it('承認を無視して投入すると起草中の KC も対応関係ごと入る', async () => {
    const csv = readCsv(`${SEED_DIR}/kc.csv`)
    const c = await seedKc(db, SEED_DIR, { requireApproval: false })
    expect(c.kc).toBe(csv.length)
    const q = async (t: string) => {
      const r = await db<{ count: string }[]>`SELECT count(*) FROM ${db(t)}`
      return Number(r[0]!.count)
    }
    expect(await q('kc')).toBe(csv.length)
    // KC はちょうど1つの節に属する
    expect(await q('kc_syllabus_unit')).toBe(csv.length)
    // primary は1件ずつ、others は ; 区切り
    const others = csv.reduce((n, r) =>
      n + (r.region_others ? r.region_others.split(';').filter(Boolean).length : 0), 0)
    expect(await q('kc_region')).toBe(csv.length + others)
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
