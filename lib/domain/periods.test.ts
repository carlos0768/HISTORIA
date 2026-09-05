import { describe, it, expect } from 'vitest'
import {
  PERIODS, periodsOf, formatCentury, toCenturyBounds, fitDomain, adaptiveDomain, yearToX, centuryTicks, assignLanes,
  CHART_MIN_YEAR, CHART_MAX_YEAR,
} from './periods'

describe('時代区分（docs/11 §4.1）', () => {
  it('隙間も重なりも無く、既定の年表の範囲を覆う', () => {
    expect(PERIODS[0]!.from).toBe(CHART_MIN_YEAR)
    expect(PERIODS[PERIODS.length - 1]!.to).toBeGreaterThanOrEqual(CHART_MAX_YEAR)
    for (let i = 1; i < PERIODS.length; i++) {
      expect(PERIODS[i]!.from).toBe(PERIODS[i - 1]!.to)
    }
  })

  it('1年の出来事は1つの時代、跨ぐものは複数', () => {
    expect(periodsOf(-1750).map(p => p.key)).toEqual(['ancient'])
    expect(periodsOf(1789).map(p => p.key)).toEqual(['early_modern'])
    // 境界の年は後ろの時代に入る（1500年は近世）
    expect(periodsOf(1500).map(p => p.key)).toEqual(['early_modern'])
    expect(periodsOf(1450, 1550).map(p => p.key)).toEqual(['medieval', 'early_modern'])
    // 逆順に渡しても同じ
    expect(periodsOf(1550, 1450).map(p => p.key)).toEqual(['medieval', 'early_modern'])
  })

  it('世紀の呼び方（前1世紀の次が1世紀。0年は無い）', () => {
    expect(formatCentury(-1750)).toBe('前18世紀')
    expect(formatCentury(-100)).toBe('前1世紀')
    expect(formatCentury(-1)).toBe('前1世紀')
    expect(formatCentury(1)).toBe('1世紀')
    expect(formatCentury(100)).toBe('1世紀')
    expect(formatCentury(101)).toBe('2世紀')
    expect(formatCentury(1789)).toBe('18世紀')
    expect(formatCentury(2000)).toBe('20世紀')
  })
})

describe('年表の横軸', () => {
  it('世紀の境界に広げる（紀元前も外側へ）', () => {
    expect(toCenturyBounds({ from: -1750, to: -1201 })).toEqual({ from: -1800, to: -1200 })
    expect(toCenturyBounds({ from: 1789, to: 1815 })).toEqual({ from: 1700, to: 1900 })
  })

  it('結果が無ければ既定の範囲、あれば最小幅を保ちつつ結果に寄せる', () => {
    expect(fitDomain([])).toEqual({ from: CHART_MIN_YEAR, to: CHART_MAX_YEAR })
    // 1789 だけ → 1700..1800 では幅100。500 まで両側に広げる
    const d = fitDomain([{ from: 1789, to: 1789 }])
    expect(d.to - d.from).toBeGreaterThanOrEqual(500)
    expect(d.from).toBeLessThanOrEqual(1700)
    expect(d.to).toBeGreaterThanOrEqual(1800)
    // 既定の外へは出ない
    expect(fitDomain([{ from: 1990, to: 2000 }]).to).toBe(CHART_MAX_YEAR)
    expect(fitDomain([{ from: -3000, to: -2950 }]).from).toBe(CHART_MIN_YEAR)
  })

  it('結果のある時代に合わせる（近代だけなら近代の範囲、時代の境界は越えない）', () => {
    expect(adaptiveDomain([])).toEqual({ from: CHART_MIN_YEAR, to: CHART_MAX_YEAR })
    // 近代（1800〜1900）にしか無い → 近代の幅だけ
    expect(adaptiveDomain([{ from: 1810, to: 1815 }, { from: 1871, to: 1890 }])).toEqual({ from: 1800, to: 1900 })
    // 現代は 2000 で切る
    expect(adaptiveDomain([{ from: 1945, to: 1991 }])).toEqual({ from: 1900, to: 2000 })
    // 古代の中では世紀に寄せ、最小 500 年に広げる
    expect(adaptiveDomain([{ from: -670, to: -330 }])).toEqual({ from: -800, to: -200 })
    // 中世と近世に跨る → 両方の中で世紀に寄せる
    const d = adaptiveDomain([{ from: 1450, to: 1450 }, { from: 1550, to: 1550 }])
    expect(d.from).toBeGreaterThanOrEqual(500)
    expect(d.to).toBeLessThanOrEqual(1800)
    expect(d.from).toBeLessThanOrEqual(1400)
    expect(d.to).toBeGreaterThanOrEqual(1600)
  })

  it('年を横位置にする。範囲の外は端に留める', () => {
    const d = { from: -1000, to: 1000 }
    expect(yearToX(-1000, d, 200)).toBe(0)
    expect(yearToX(0, d, 200)).toBe(100)
    expect(yearToX(1000, d, 200)).toBe(200)
    expect(yearToX(5000, d, 200)).toBe(200)
    expect(yearToX(-9000, d, 200)).toBe(0)
  })

  it('目盛りは100年刻みを基本に、多すぎれば粗くする', () => {
    expect(centuryTicks({ from: 1500, to: 1900 })).toEqual([1500, 1600, 1700, 1800, 1900])
    const full = centuryTicks({ from: -3000, to: 2000 })
    expect(full.length).toBeLessThanOrEqual(12)
    expect(full[0]).toBe(-3000)
    expect(full[full.length - 1]).toBe(2000)
    // 100 で割り切れない端は内側の刻みから始める
    expect(centuryTicks({ from: -1750, to: -1200 })).toEqual([-1700, -1600, -1500, -1400, -1300, -1200])
    // 300年未満（近代だけ等）は世紀より細かく刻む
    expect(centuryTicks({ from: 1800, to: 1900 })).toEqual([1800, 1825, 1850, 1875, 1900])
    expect(centuryTicks({ from: 1900, to: 2000 })).toEqual([1900, 1925, 1950, 1975, 2000])
    expect(centuryTicks({ from: 1500, to: 1800 })).toEqual([1500, 1600, 1700, 1800])
  })

  it('重なるものは別の段に、重ならないものは同じ段に置く', () => {
    const lanes = assignLanes([
      { x0: 0, x1: 50 },    // 段0
      { x0: 10, x1: 30 },   // 0 と重なる → 段1
      { x0: 60, x1: 90 },   // 段0 が空いた → 段0
      { x0: 20, x1: 25 },   // 0 と 1 の両方と重なる → 段2
    ])
    expect(lanes).toEqual([0, 1, 0, 2])
  })

  it('幅0のものも場所を取る（同じ位置の点が重ならない）', () => {
    expect(assignLanes([{ x0: 5, x1: 5 }, { x0: 5, x1: 5 }])).toEqual([0, 1])
  })
})
