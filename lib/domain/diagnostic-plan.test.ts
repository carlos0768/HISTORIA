import { describe, it, expect } from 'vitest'
import { planCells, totalToGenerate, TARGET_PER_CELL } from './diagnostic-plan'
import { allCells, cellKey, CELL_COUNT } from './diagnostic'

/**
 * 診断プールの補充の配分（docs/04 §5.2）
 *
 * ★ 作者の判断（2026-09-02）: 既存408問と合流させて648問にする。列も印も増やさない。
 *   生成する240問は**薄いセルを埋める向き**に配分する。
 */
describe('補充の配分', () => {
  const empty = () => allCells().map(cell => ({ cell, have: 0 }))

  it('全セルが空なら、12セル × 20問 = 240問', () => {
    const plan = planCells(empty())
    expect(plan).toHaveLength(CELL_COUNT)
    expect(totalToGenerate(plan)).toBe(240)
    expect(plan.every(p => p.need === TARGET_PER_CELL)).toBe(true)
  })

  it('目標に達しているセルには足さない', () => {
    const counts = empty().map(c =>
      c.cell === cellKey(1, 1) ? { ...c, have: TARGET_PER_CELL } : c)
    const plan = planCells(counts)
    expect(plan.find(p => p.cell === cellKey(1, 1))!.need).toBe(0)
    expect(totalToGenerate(plan)).toBe(240 - TARGET_PER_CELL)
  })

  it('目標を超えているセルからは減らさない（負にしない）', () => {
    const counts = empty().map(c => c.cell === cellKey(1, 1) ? { ...c, have: 50 } : c)
    expect(planCells(counts).every(p => p.need >= 0)).toBe(true)
  })

  /**
   * ★ ここが作者の判断そのもの。薄いセルから埋める。
   *   配り方は**水位を上げる形**（water-filling）である。
   *   0,1,2,… と並ぶセルに6問配ると、薄い3つが同じ高さ（3問）に揃う。
   *   「薄い6セルに1問ずつ」ではない（最初そう書いて落ちた）。
   *   1問ずつ配るより、こちらのほうが「最も測れていないセル」が早く解消する。
   */
  it('予算が足りないときは、薄いセルが同じ高さに揃うように配る', () => {
    const counts = allCells().map((cell, i) => ({ cell, have: i }))   // 0,1,2,…,11
    const plan = planCells(counts, 6)
    expect(totalToGenerate(plan)).toBe(6)
    const filled = plan.filter(p => p.need > 0)
    // 配ったセルは、配ったあと全部同じ高さになる
    expect(new Set(filled.map(p => p.have + p.need)).size).toBe(1)
    // 配られたのは最も薄い3セル（0,1,2 → 全部3問へ）
    expect(filled.map(p => p.have).sort((a, b) => a - b)).toEqual([0, 1, 2])
  })

  /**
   * ★ 1セルだけ極端に薄いときは、そこへ集中させるのが正しい。
   *   他が19問あるのに1問ずつ足しても、測定は1つも良くならない
   */
  it('1セルだけ極端に薄ければ、そこへ集中させる', () => {
    const counts = allCells().map((cell, i) => ({ cell, have: i === 0 ? 0 : 19 }))
    const plan = planCells(counts, 12)
    const filled = plan.filter(p => p.need > 0)
    expect(filled).toHaveLength(1)
    expect(filled[0]!.have).toBe(0)
    expect(filled[0]!.need).toBe(12)
    expect(Math.max(...plan.map(p => p.have + p.need))).toBeLessThanOrEqual(TARGET_PER_CELL)
  })

  /** 予算が十分にあれば、集中させたあと他のセルにも回る */
  it('予算が十分なら、薄いセルを埋めてから他にも配る', () => {
    const counts = allCells().map((cell, i) => ({ cell, have: i === 0 ? 0 : 19 }))
    const plan = planCells(counts, 25)
    expect(plan.filter(p => p.need > 0).length).toBeGreaterThan(1)
    expect(plan.find(p => p.have === 0)!.need).toBe(20)
  })

  it('予算が0なら何も作らない', () => {
    expect(totalToGenerate(planCells(empty(), 0))).toBe(0)
  })

  it('予算が余っても目標を超えて作らない', () => {
    expect(totalToGenerate(planCells(empty(), 10_000))).toBe(240)
  })

  it('知らないセルの件数は無視する（12セル以外を作らない）', () => {
    const plan = planCells([{ cell: '9:9', have: 100 }])
    expect(plan).toHaveLength(CELL_COUNT)
    expect(plan.map(p => p.cell)).not.toContain('9:9')
  })

  /** ★ 乱数を使わない。同じ入力からは同じ配分が出る */
  it('同じ入力からは毎回同じ配分が出る', () => {
    const counts = allCells().map((cell, i) => ({ cell, have: i % 3 }))
    const a = planCells(counts, 17)
    const b = planCells([...counts].reverse(), 17)
    expect(a).toEqual(b)
  })
})
