import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import postgres from 'postgres'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import {
  reserve, settle, release, budgetStatus, reapStaleReservations, ensureBudgetRow, setCap,
  estimateJpy, periodOf, BudgetExceededError, JPY_PER_USD, SAFETY_MARGIN,
} from './budget'

const NOW = new Date('2026-09-15T03:00:00Z')

// ---- 純粋な計算はDBなしでテストする ----

describe('§7.1 見積り', () => {
  const price = { inputPerMTok: 2, outputPerMTok: 10 }

  it('入力＋max_output_tokens を上限として計算する', () => {
    const e = estimateJpy(1_200, 400, price)
    const usd = (1200 / 1e6) * 2 + (400 / 1e6) * 10
    expect(e).toBeCloseTo(usd * JPY_PER_USD * SAFETY_MARGIN, 10)
  })

  it('安全余裕が乗っている（未知の課金項目への備え）', () => {
    expect(estimateJpy(1000, 1000, price)).toBeGreaterThan(
      ((1000 / 1e6) * 2 + (1000 / 1e6) * 10) * JPY_PER_USD,
    )
  })

  it('出力上限が増えれば見積りも増える', () => {
    expect(estimateJpy(1000, 4000, price)).toBeGreaterThan(estimateJpy(1000, 400, price))
  })
})

describe('§7.1 集計期間', () => {
  it('月初（Asia/Tokyo）をキーにする', () => {
    expect(periodOf(new Date('2026-09-15T03:00:00Z'))).toBe('2026-09-01')
  })
  it('UTC で月末でも JST で翌月なら翌月に入る', () => {
    // 2026-09-30T16:00Z = 2026-10-01T01:00 JST
    expect(periodOf(new Date('2026-09-30T16:00:00Z'))).toBe('2026-10-01')
  })
  it('JST の月初直前は前月のまま', () => {
    // 2026-09-30T14:59Z = 2026-09-30T23:59 JST
    expect(periodOf(new Date('2026-09-30T14:59:00Z'))).toBe('2026-09-01')
  })
})

// ---- DB を使うテスト ----

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('§7.1 遮断器（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const P = '2026-09-01'

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_budget_test'))
  }, 120_000)
  afterAll(async () => { await drop() })

  const resetBudget = async (cap = 10_000) => {
    await ensureBudgetRow(db, P)
    await db`UPDATE ai_budget SET cap_jpy = 10000, warn_jpy = 5000, degrade_jpy = 8000,
                reserved_jpy = 0, settled_jpy = 0,
                halted = false, halted_at = NULL, halted_reason = NULL WHERE period = ${P}`
    if (cap !== 10_000) await setCap(db, P, cap)
    await db`DELETE FROM ai_spend WHERE period = ${P}`
  }
  const res = (estJpy: number) =>
    reserve(db, { estJpy, provider: 'anthropic', model: 'claude-sonnet-5', purpose: 'factcheck', now: NOW })

  it('上限内の予約は通る', async () => {
    await resetBudget()
    const r = await res(9_990)
    expect(r.estJpy).toBe(9_990)
    expect((await budgetStatus(db, NOW)).usedJpy).toBe(9_990)
  })

  it('上限を超える予約は拒否され、呼び出しを発行しない', async () => {
    await resetBudget()
    await res(9_990)
    await expect(res(20)).rejects.toBeInstanceOf(BudgetExceededError)
    // 拒否された予約は元帳にも載らない
    const rows = await db<{ count: string }[]>`SELECT count(*) FROM ai_spend WHERE period = ${P}`
    expect(Number(rows[0]!.count)).toBe(1)
  })

  it('境界ちょうど（9,990 + 10 = 10,000）は通る', async () => {
    await resetBudget()
    await res(9_990)
    await expect(res(10)).resolves.toBeTruthy()
    expect((await budgetStatus(db, NOW)).usedJpy).toBe(10_000)
  })

  it('上限ちょうどに達したら halted になり、以後は1円でも拒否される', async () => {
    await resetBudget()
    await res(9_990)
    await res(10)
    expect((await budgetStatus(db, NOW)).halted).toBe(true)
    await expect(res(1)).rejects.toBeInstanceOf(BudgetExceededError)
  })

  it('確定すると見積りとの差額が枠に戻る', async () => {
    await resetBudget()
    const r = await res(100)
    await settle(db, r, { inputTokens: 1200, outputTokens: 300, actualJpy: 60 })
    const s = await budgetStatus(db, NOW)
    expect(s.usedJpy).toBe(60)
    expect(s.remainingJpy).toBe(9_940)
  })

  it('実額が見積りを超える確定は DB が拒否する（見積り式のバグに気づける）', async () => {
    await resetBudget()
    const r = await res(5)
    await expect(
      settle(db, r, { inputTokens: 1, outputTokens: 1, actualJpy: 99 }),
    ).rejects.toThrow()
  })

  it('呼び出しが失敗したら予約を解放する', async () => {
    await resetBudget()
    const r = await res(500)
    expect((await budgetStatus(db, NOW)).usedJpy).toBe(500)
    await release(db, r)
    expect((await budgetStatus(db, NOW)).usedJpy).toBe(0)
  })

  it('解放は冪等（二重に枠が戻らない）', async () => {
    await resetBudget()
    const r = await res(500)
    await release(db, r)
    await release(db, r)
    expect((await budgetStatus(db, NOW)).usedJpy).toBe(0)
  })

  it('15分を過ぎた予約を回収する（プロセス異常終了への備え）', async () => {
    await resetBudget()
    const r = await res(300)
    await db`UPDATE ai_spend SET created_at = now() - interval '20 minutes' WHERE id = ${r.spendId}`
    const fresh = await res(100)
    expect(await reapStaleReservations(db, P)).toBe(1)
    const s = await budgetStatus(db, NOW)
    expect(s.usedJpy).toBe(100) // 新しい方は残る
    expect(fresh.estJpy).toBe(100)
  })

  it('段階の閾値が状態に出る（5,000 通知 / 8,000 縮退 / 10,000 停止）', async () => {
    await resetBudget()
    expect(await budgetStatus(db, NOW)).toMatchObject({ warned: false, degraded: false, halted: false })
    await res(5_000)
    expect(await budgetStatus(db, NOW)).toMatchObject({ warned: true, degraded: false, halted: false })
    await res(3_000)
    expect(await budgetStatus(db, NOW)).toMatchObject({ warned: true, degraded: true, halted: false })
    await res(2_000)
    expect(await budgetStatus(db, NOW)).toMatchObject({ warned: true, degraded: true, halted: true })
  })

  it('停止からの自動復帰はしない（暴走なら復帰しても同じ支出を繰り返すため）', async () => {
    await resetBudget()
    const r = await res(10_000)
    expect((await budgetStatus(db, NOW)).halted).toBe(true)
    // 枠を全部返しても halted のまま
    await release(db, r)
    const s = await budgetStatus(db, NOW)
    expect(s.usedJpy).toBe(0)
    expect(s.halted).toBe(true)
    await expect(res(1)).rejects.toBeInstanceOf(BudgetExceededError)
  })

  it('月が替われば新しい period の行になり自動的に再開する', async () => {
    await resetBudget()
    await res(10_000)
    expect((await budgetStatus(db, NOW)).halted).toBe(true)
    const nextMonth = new Date('2026-10-15T03:00:00Z')
    const s = await budgetStatus(db, nextMonth)
    expect(s.period).toBe('2026-10-01')
    expect(s.halted).toBe(false)
    expect(s.usedJpy).toBe(0)
  })

  it('理由なしの停止は DB が拒否する', async () => {
    await resetBudget()
    await expect(db`UPDATE ai_budget SET halted = true WHERE period = ${P}`).rejects.toThrow()
  })

  // ---- これが要点 ----
  it('競合: 上限1万円に2セッションが同時に6,000円を要求すると片方だけが通る', async () => {
    await resetBudget(10_000)
    const url = new URL(TEST_DB_URL!)
    url.pathname = '/historia_budget_test'
    const a = postgres(url.toString(), { prepare: false, max: 1 })
    const b = postgres(url.toString(), { prepare: false, max: 1 })
    try {
      const attempt = (conn: Sql) =>
        reserve(conn, { estJpy: 6_000, provider: 'p', model: 'm', purpose: 'factcheck', now: NOW })
          .then(() => true)
          .catch(e => { if (e instanceof BudgetExceededError) return false; throw e })

      const [ra, rb] = await Promise.all([attempt(a), attempt(b)])
      expect([ra, rb].filter(Boolean)).toHaveLength(1) // ちょうど片方
      expect((await budgetStatus(db, NOW)).usedJpy).toBe(6_000) // 12,000 にならない
    } finally {
      await a.end({ timeout: 5 })
      await b.end({ timeout: 5 })
    }
  })

  it('競合: 上限に対し多数が同時要求しても合計は上限を超えない', async () => {
    await resetBudget(1_000)
    const url = new URL(TEST_DB_URL!)
    url.pathname = '/historia_budget_test'
    const conns = Array.from({ length: 12 }, () => postgres(url.toString(), { prepare: false, max: 1 }))
    try {
      const results = await Promise.all(
        conns.map(c =>
          reserve(c, { estJpy: 100, provider: 'p', model: 'm', purpose: 'factcheck', now: NOW })
            .then(() => true)
            .catch(e => { if (e instanceof BudgetExceededError) return false; throw e }),
        ),
      )
      expect(results.filter(Boolean)).toHaveLength(10) // 1000 / 100
      const s = await budgetStatus(db, NOW)
      expect(s.usedJpy).toBeLessThanOrEqual(s.capJpy)
      expect(s.usedJpy).toBe(1_000)
    } finally {
      await Promise.all(conns.map(c => c.end({ timeout: 5 })))
    }
  }, 30_000)
})
