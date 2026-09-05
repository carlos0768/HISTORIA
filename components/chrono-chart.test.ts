import { describe, it, expect } from 'vitest'
import { chartRows, placeBox, fitText, CHART_WIDTH, LABEL_COL, type ChronoItem } from './chrono-chart'

const item = (o: Partial<ChronoItem> & { id: string; yearFrom: number }): ChronoItem => ({
  label: o.label ?? o.id, kind: 'event', yearTo: null, precision: null, regionIds: [], ...o,
})

describe('年表チャートの配置（docs/11 §4.1）', () => {
  it('行は地域の順、地域なしは最後', () => {
    const rows = chartRows([
      item({ id: 'none', yearFrom: 100 }),
      item({ id: 'china', yearFrom: -221, regionIds: [22] }),      // 中国 → 東アジア(21)
      item({ id: 'meso', yearFrom: -1750, regionIds: [10, 11] }), // 主地域が先頭 → 西アジア(9)
    ], { from: -3000, to: 2000 }, CHART_WIDTH)
    expect(rows.map(r => r.label)).toEqual(['西アジア', '東アジア', '地域なし'])
    expect(rows.map(r => r.items.map(i => i.id))).toEqual([['meso'], ['china'], ['none']])
  })

  it('名前は箱の中。箱は地域名の列に入らず、右端からも出ない', () => {
    const long = 'アッシリアとアケメネス朝の統治方法の違い'
    const rows = chartRows([
      item({ id: 'a', label: long, yearFrom: 1500, yearTo: 1990, regionIds: [10] }),
      item({ id: 'b', label: long, yearFrom: -2990, yearTo: -2980, regionIds: [10] }),
      item({ id: 'c', label: long, yearFrom: 1995, regionIds: [10] }),
    ], { from: -3000, to: 2000 }, CHART_WIDTH)
    for (const it of rows[0]!.items) {
      expect(it.text.length, it.id).toBeGreaterThan(0)
      expect(it.x0, it.id).toBeGreaterThanOrEqual(LABEL_COL)
      expect(it.x1, it.id).toBeLessThanOrEqual(CHART_WIDTH)
      // 文字は箱に収まる（全角 11 の見積り）
      expect(it.x1 - it.x0, it.id).toBeGreaterThanOrEqual([...it.text].length * 11 * 0.6)
    }
    // 右端の点（c）は箱をずらし、本当の年に印が付く
    const c = rows[0]!.items.find(i => i.id === 'c')!
    expect(c.yearX).not.toBeNull()
    expect(c.yearX!).toBeGreaterThan(c.x0)
    // ずらさなくて済む箱には印が無い
    const b = rows[0]!.items.find(i => i.id === 'b')!
    expect(b.yearX).toBeNull()
  })

  it('重なる項目は別の段に置き、行の高さに反映する', () => {
    const rows = chartRows([
      item({ id: 'a', yearFrom: 1000, regionIds: [10] }),
      item({ id: 'b', yearFrom: 1005, regionIds: [10] }),
    ], { from: -3000, to: 2000 }, CHART_WIDTH)
    expect(rows[0]!.lanes).toBe(2)
    expect(new Set(rows[0]!.items.map(i => i.lane)).size).toBe(2)
  })

  it('箱は年の幅と文字の幅の大きい方。右に出るなら左へずらす', () => {
    // 短い年の幅 → 文字の分だけ広がる
    const p = placeBox('あいう', 200, 205, CHART_WIDTH)
    expect(p.x0).toBe(200)
    expect(p.x1).toBeGreaterThanOrEqual(200 + 33 + 8)
    expect(p.yearX).toBeNull()
    // 広い年の幅 → その幅のまま
    const q = placeBox('あ', 200, 500, CHART_WIDTH)
    expect([q.x0, q.x1]).toEqual([200, 500])
    // 右端 → ずらして印
    const r = placeBox('あいう', 710, 715, CHART_WIDTH)
    expect(r.x1).toBe(CHART_WIDTH - 8)
    expect(r.x0).toBeLessThan(710)
    expect(r.yearX).toBe(710)
  })

  it('入り切らなければ「…」で詰め、3文字未満には削らない', () => {
    expect(fitText('あいうえお', 44)).toBe('あいう…')
    expect(fitText('あいうえお', 20)).toBe('')
    expect(fitText('abc', 100)).toBe('abc')
  })
})
