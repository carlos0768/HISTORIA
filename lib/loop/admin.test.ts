import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createMaterial } from './fixture'
import {
  generationToday, blockedMaterials, spendByPurpose, verificationSpend,
  cronHealth, resumeBudget, RPD_LIMIT, CRON_SILENCE_HOURS,
} from './admin'
import { budgetStatus, periodOf } from '@/lib/ai/budget'

/**
 * 管理ビューの集計（docs/12-nonfunctional.md §7.1）
 *
 * ★ ここが間違っていても画面は普通に描かれる。「支出が0円に見える」
 *   「cron が生きているように見える」は、気づけない種類の壊れ方である。
 *   だから数の出どころを1つずつ実 DB で確かめる。
 */

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('管理ビューの集計（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  let userId: string
  /** 日本時間 2026-09-15 20:00 */
  const NOW = new Date('2026-09-15T11:00:00Z')
  const PERIOD = periodOf(NOW)
  const UNIT = 'wh.2.1.1'

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_admin_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    for (const t of ['ops_log', 'ai_spend', 'ai_budget', 'material_section', 'material',
                     'generation_job', 'app_user']) {
      await db.unsafe(`DELETE FROM ${t}`)
    }
    userId = await createUser(db, NOW)
  })

  const job = async (o: { status?: string; at?: Date } = {}) => {
    await db`
      INSERT INTO generation_job (id, user_id, kind, scope_id, params_hash, status,
                                  provider, model, created_at)
      VALUES (${randomUUID()}, ${userId}, 'material', ${UNIT}, ${randomUUID()},
              ${o.status ?? 'succeeded'}, 'fake', 'fake', ${o.at ?? NOW})`
  }

  const budgetRow = async () => { await budgetStatus(db, NOW) }
  const spend = async (o: {
    purpose: string; state?: string; est: number; actual?: number
  }) => {
    await budgetRow()
    await db`
      INSERT INTO ai_spend (period, provider, model, purpose, state, est_jpy, actual_jpy,
                            jpy_per_usd, settled_at)
      VALUES (${PERIOD}, 'fake', 'fake', ${o.purpose}, ${o.state ?? 'reserved'},
              ${o.est}, ${o.actual ?? null}, 150,
              ${o.state === 'settled' ? NOW : null})`
  }

  describe('当日の生成', () => {
    it('件数・失敗・実行中を数え、RPD に対する率を出す', async () => {
      await job()
      await job({ status: 'failed' })
      await job({ status: 'running' })
      const g = await generationToday(db, NOW)
      expect(g.requests).toBe(3)
      expect(g.failed).toBe(1)
      expect(g.running).toBe(1)
      expect(g.usage).toBeCloseTo(3 / RPD_LIMIT, 10)
    })

    /**
     * ★ 日付は日本時間で切る。UTC で切ると、日本時間の朝9時までのあいだ
     *   前日ぶんが混ざったまま残り、消費率が実際より高く見える
     */
    it('日本時間の同じ日なら、UTC で前日でも当日に入る', async () => {
      // 日本時間 2026-09-15 00:30 = UTC 2026-09-14 15:30
      await job({ at: new Date('2026-09-14T15:30:00Z') })
      expect((await generationToday(db, NOW)).requests).toBe(1)
    })

    it('前日の分は数えない（逆対照）', async () => {
      // 日本時間 2026-09-14 23:30 = UTC 14:30
      await job({ at: new Date('2026-09-14T14:30:00Z') })
      expect((await generationToday(db, NOW)).requests).toBe(0)
    })

    it('1件も無ければ 0', async () => {
      expect(await generationToday(db, NOW)).toEqual({
        requests: 0, usage: 0, failed: 0, running: 0,
      })
    })
  })

  describe('配信できなかった教材', () => {
    it('blocked だけを出す', async () => {
      await createMaterial(db, { userId, unitId: UNIT, status: 'ready' })
      const id = await createMaterial(db, { userId, unitId: UNIT, status: 'blocked' })
      await db`UPDATE material SET blocked_reason = '年号が2件ずれている' WHERE id = ${id}`
      const b = await blockedMaterials(db)
      expect(b).toHaveLength(1)
      expect(b[0]!.reason).toBe('年号が2件ずれている')
      expect(b[0]!.unitId).toBe(UNIT)
    })

    it('理由が無くても落とさない（件数を見失わない）', async () => {
      await createMaterial(db, { userId, unitId: UNIT, status: 'blocked' })
      const b = await blockedMaterials(db)
      expect(b).toHaveLength(1)
      expect(b[0]!.reason).toBeNull()
    })
  })

  describe('支出の内訳', () => {
    it('purpose 別に、予約と確定を分けて出す', async () => {
      await spend({ purpose: 'generate', state: 'settled', est: 10, actual: 7 })
      await spend({ purpose: 'generate', est: 5 })
      await spend({ purpose: 'factcheck', state: 'settled', est: 30, actual: 22 })
      const s = await spendByPurpose(db, PERIOD)
      const gen = s.find(x => x.purpose === 'generate')!
      expect(gen.settledJpy).toBe(7)
      expect(gen.reservedJpy).toBe(5)
      expect(gen.count).toBe(2)
    })

    /** ★ 解放された予約は「使わなかった」もの。数えると支出が二重に見える */
    it('released は数えない', async () => {
      await spend({ purpose: 'generate', state: 'released', est: 100 })
      expect(await spendByPurpose(db, PERIOD)).toEqual([])
    })

    /** ★ 確定分は actual_jpy。est_jpy は上限額なので必ず実額より大きい */
    it('確定した行は見積りではなく実額で出す', async () => {
      await spend({ purpose: 'judge', state: 'settled', est: 100, actual: 3 })
      const [row] = await spendByPurpose(db, PERIOD)
      expect(row!.settledJpy).toBe(3)
    })

    it('二次照合だけを別に数える（factcheck と judge）', async () => {
      await spend({ purpose: 'generate', state: 'settled', est: 10, actual: 10 })
      await spend({ purpose: 'factcheck', state: 'settled', est: 20, actual: 20 })
      await spend({ purpose: 'judge', est: 5 })
      const v = await verificationSpend(db, PERIOD)
      expect(v.runs).toBe(2)
      expect(v.jpy).toBe(25)
    })

    it('別の月の支出は混ぜない', async () => {
      await spend({ purpose: 'generate', state: 'settled', est: 10, actual: 10 })
      expect(await spendByPurpose(db, '2026-08-01')).toEqual([])
    })
  })

  describe('定時実行の生存', () => {
    const log = async (kind: string, at: Date, ok = true) => {
      await db`INSERT INTO ops_log (kind, ok, ran_at) VALUES (${kind}, ${ok}, ${at})`
    }

    it('直近の実行を出す', async () => {
      await log('remind', new Date('2026-09-14T11:00:00Z'))
      await log('remind', new Date('2026-09-15T11:00:00Z'))
      const [r] = await cronHealth(db, NOW, ['remind'])
      expect(r!.lastRunAt?.toISOString()).toBe('2026-09-15T11:00:00.000Z')
      expect(r!.stale).toBe(false)
    })

    it(`${CRON_SILENCE_HOURS} 時間を超えたら警告する`, async () => {
      await log('remind', new Date('2026-09-14T10:00:00Z'))   // 25時間前
      const [r] = await cronHealth(db, NOW, ['remind'])
      expect(r!.stale).toBe(true)
    })

    it('ぎりぎり24時間以内なら警告しない（逆対照）', async () => {
      await log('remind', new Date('2026-09-14T11:30:00Z'))   // 23.5時間前
      expect((await cronHealth(db, NOW, ['remind']))[0]!.stale).toBe(false)
    })

    /**
     * ★ 一度も走っていない種別も stale として出す。行が無いことを
     *   「まだ動かしていないだけ」と黙って許すと、設定を忘れたまま
     *   何ヶ月も通知が来ないことに気づけない
     */
    it('一度も走っていなければ警告する', async () => {
      const [r] = await cronHealth(db, NOW, ['remind'])
      expect(r!.lastRunAt).toBeNull()
      expect(r!.stale).toBe(true)
    })

    it('失敗した実行も「走った」として扱い、失敗であることを残す', async () => {
      await log('remind', NOW, false)
      const [r] = await cronHealth(db, NOW, ['remind'])
      expect(r!.stale).toBe(false)
      expect(r!.lastOk).toBe(false)
    })

    it('種別ごとに別々に見る', async () => {
      await log('remind', NOW)
      const r = await cronHealth(db, NOW, ['remind', 'reap_reservations'])
      expect(r.map(x => x.stale)).toEqual([false, true])
    })
  })

  describe('遮断の解除', () => {
    const halt = async () => {
      await budgetRow()
      await db`UPDATE ai_budget SET halted = true, halted_at = ${NOW},
                 halted_reason = 'cap_exceeded' WHERE period = ${PERIOD}`
    }

    it('解除できる', async () => {
      await halt()
      expect(await resumeBudget(db, PERIOD)).toEqual({ resumed: true })
      expect((await budgetStatus(db, NOW)).halted).toBe(false)
    })

    /**
     * ★ 上限は動かさない（docs/12 §7.2）。上限に達して止まったのに
     *   解除と同時に上限も上がるなら、遮断器は何も守っていない
     */
    it('解除しても上限は変わらない', async () => {
      await halt()
      const before = (await budgetStatus(db, NOW)).capJpy
      await resumeBudget(db, PERIOD)
      expect((await budgetStatus(db, NOW)).capJpy).toBe(before)
    })

    it('遮断されていなければ何もしない', async () => {
      await budgetRow()
      expect(await resumeBudget(db, PERIOD)).toEqual({ resumed: false })
    })
  })
})
