import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, seedKc, SEED_DIR } from '@/scripts/db/seed'
import { createUser } from '@/lib/loop/fixture'
import { kcsForUnits, checkOverlap, createDrill, unitTree } from './drill'
import { OVERLAP_WARN_RATIO } from '@/lib/domain/scheduler'

const dbSuite = TEST_DB_URL ? describe : describe.skip

/**
 * 節が持つ KC の数を DB から数える。
 *
 * ★ 「wh.2.1.1 は5件」と数値で書かない。seed の KC は起草が進むたびに増えるので、
 *   件数を書いた瞬間に、この試験は kcsForUnits の振る舞いではなく
 *   seed の中身を守る試験に変わってしまう。実際 60 件から 408 件に増えたとき、
 *   このファイルの7件が一斉に落ちた。
 */
const kcCountOf = async (db: Sql, ...units: string[]): Promise<number> => {
  const r = await db<{ n: string }[]>`
    SELECT count(DISTINCT ku.kc_id) AS n
      FROM kc_syllabus_unit ku JOIN kc k ON k.id = ku.kc_id
     WHERE ku.unit_id IN ${db(units)} AND NOT k.retired`
  return Number(r[0]!.n)
}

dbSuite('集中特訓の作成（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const DEADLINE = new Date('2026-12-01T00:00:00Z')
  let userId: string

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_drill_test'))
    await seedMasters(db, SEED_DIR)
    await seedKc(db, SEED_DIR, { requireApproval: false })
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await db`TRUNCATE drill_kc, drill_unit, drill, app_user RESTART IDENTITY CASCADE`
    await db`UPDATE kc SET retired = false`
    userId = await createUser(db, NOW)
  })

  describe('kcsForUnits', () => {
    it('選んだ節の KC を返す', async () => {
      expect(await kcsForUnits(db, ['wh.2.1.1'])).toHaveLength(await kcCountOf(db, 'wh.2.1.1'))
    })

    it('複数の節をまたいでも重複せず、順序が安定する', async () => {
      const a = await kcsForUnits(db, ['wh.2.1.1', 'wh.2.1.2'])
      const b = await kcsForUnits(db, ['wh.2.1.2', 'wh.2.1.1'])
      const n = await kcCountOf(db, 'wh.2.1.1', 'wh.2.1.2')
      expect(a).toHaveLength(n)
      expect(new Set(a).size).toBe(n)   // 節をまたいでも重複しない
      // 引数の順序に依存しない。冪等キーや重複判定が入力順で揺れないようにするため
      expect(a).toEqual(b)
    })

    it('空の範囲は空を返す（SQL を組み立てない）', async () => {
      expect(await kcsForUnits(db, [])).toEqual([])
    })

    it('引退した KC は含めない', async () => {
      const all = await kcsForUnits(db, ['wh.2.1.1'])
      await db`UPDATE kc SET retired = true WHERE id = ${all[0]!}`
      const after = await kcsForUnits(db, ['wh.2.1.1'])
      expect(after).toHaveLength(all.length - 1)
      expect(after).not.toContain(all[0])
    })
  })

  describe('checkOverlap', () => {
    it('既存の特訓が無ければ警告しない', async () => {
      const kcs = await kcsForUnits(db, ['wh.2.1.1'])
      expect(await checkOverlap(db, userId, kcs)).toBeNull()
    })

    it('全部重なれば警告する（比率・件数・相手の題名を返す）', async () => {
      await createDrill(db, { userId, title: '古代オリエント', unitIds: ['wh.2.1.1'], deadline: DEADLINE })
      const kcs = await kcsForUnits(db, ['wh.2.1.1'])
      const w = await checkOverlap(db, userId, kcs)
      expect(w).not.toBeNull()
      expect(w!.ratio).toBe(1)
      expect(w!.sharedKcCount).toBe(await kcCountOf(db, 'wh.2.1.1'))
      expect(w!.withTitles).toEqual(['古代オリエント'])
    })

    it('閾値（40%）以下なら警告しない', async () => {
      await createDrill(db, { userId, title: '既存', unitIds: ['wh.2.1.1'], deadline: DEADLINE })
      // 既存の1節だけが重なる、もっと広い範囲を新しく作る
      const range = ['wh.2.1.1', 'wh.2.1.2', 'wh.2.1.3', 'wh.2.2.1']
      const kcs = await kcsForUnits(db, range)
      const shared = await kcCountOf(db, 'wh.2.1.1')
      // 前提が崩れたら（重なりが閾値を超えたら）ここで気づけるようにしておく
      expect(shared / kcs.length).toBeLessThan(OVERLAP_WARN_RATIO)
      expect(await checkOverlap(db, userId, kcs)).toBeNull()
    })

    it('終了した特訓は重複に数えない', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '終わったやつ', unitIds: ['wh.2.1.1'], deadline: DEADLINE,
      })
      await db`UPDATE drill SET status = 'completed' WHERE id = ${drillId}`
      const kcs = await kcsForUnits(db, ['wh.2.1.1'])
      expect(await checkOverlap(db, userId, kcs)).toBeNull()
    })

    it('他人の特訓は重複に数えない', async () => {
      const other = await createUser(db, NOW)
      await createDrill(db, { userId: other, title: '他人', unitIds: ['wh.2.1.1'], deadline: DEADLINE })
      const kcs = await kcsForUnits(db, ['wh.2.1.1'])
      expect(await checkOverlap(db, userId, kcs)).toBeNull()
    })
  })

  describe('createDrill', () => {
    it('drill / drill_unit / drill_kc を揃えて作る', async () => {
      const { drillId, kcCount } = await createDrill(db, {
        userId, title: '古代オリエント', unitIds: ['wh.2.1.1', 'wh.2.1.2'], deadline: DEADLINE,
      })
      expect(kcCount).toBe(await kcCountOf(db, 'wh.2.1.1', 'wh.2.1.2'))
      const [d] = await db`SELECT title, mode, status FROM drill WHERE id = ${drillId}`
      expect(d).toMatchObject({ title: '古代オリエント', mode: 'ai_material', status: 'active' })
      const units = await db`SELECT unit_id FROM drill_unit WHERE drill_id = ${drillId} ORDER BY unit_id`
      expect(units.map(u => u.unit_id)).toEqual(['wh.2.1.1', 'wh.2.1.2'])
      const [row] = await db<{ n: string }[]>`SELECT count(*) AS n FROM drill_kc WHERE drill_id = ${drillId}`
      expect(Number(row!.n)).toBe(kcCount)
    })

    it('KC の無い範囲は作らせない', async () => {
      // wh.1.1 には KC を割り当てていない
      await expect(createDrill(db, {
        userId, title: '空', unitIds: ['wh.1.1'], deadline: DEADLINE,
      })).rejects.toThrow('KC がありません')
      const [row] = await db<{ n: string }[]>`SELECT count(*) AS n FROM drill`
      expect(Number(row!.n)).toBe(0)
    })

    it('自習モードも作れる', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '自習', unitIds: ['wh.2.1.1'], deadline: DEADLINE, mode: 'self_study',
      })
      const [d] = await db`SELECT mode FROM drill WHERE id = ${drillId}`
      expect(d!.mode).toBe('self_study')
    })
  })

  describe('unitTree', () => {
    it('部→章→節の3階層で返す', async () => {
      const roots = await unitTree(db)
      expect(roots.every(r => r.level === 1)).toBe(true)
      const wh2 = roots.find(r => r.id === 'wh.2')!
      expect(wh2.children.every(c => c.level === 2)).toBe(true)
      expect(wh2.children[0]!.children.every(c => c.level === 3)).toBe(true)
    })

    it('KC 数を親に積み上げる（KC は節にしか付かない）', async () => {
      const roots = await unitTree(db)
      const wh2 = roots.find(r => r.id === 'wh.2')!
      const ch = wh2.children.find(c => c.id === 'wh.2.1')!
      const leaves = ch.children.map(c => c.kcCount)
      expect(leaves).toEqual(await Promise.all(ch.children.map(c => kcCountOf(db, c.id))))
      expect(leaves.every(n => n > 0)).toBe(true)
      expect(ch.kcCount).toBe(leaves.reduce((a, b) => a + b, 0))
      expect(wh2.kcCount).toBe(wh2.children.reduce((s, c) => s + c.kcCount, 0))
    })

    it('全 KC 数が根の合計と一致する', async () => {
      const roots = await unitTree(db)
      const [row] = await db<{ n: string }[]>`
        SELECT count(DISTINCT ku.kc_id) AS n FROM kc_syllabus_unit ku
          JOIN kc k ON k.id = ku.kc_id AND NOT k.retired`
      expect(roots.reduce((s, r) => s + r.kcCount, 0)).toBe(Number(row!.n))
    })
  })
})
