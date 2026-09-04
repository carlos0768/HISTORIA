import { describe, it, expect } from 'vitest'
import { chartRows, placeLabel, fitText, CHART_WIDTH, LABEL_COL, type ChronoItem } from './chrono-chart'

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

  it('ラベルは地域名の列に入らず、右端からも出ない', () => {
    const long = 'アッシリアとアケメネス朝の統治方法の違い'
    // 右端ぎりぎりの広い棒 → 右には置けない
    const rows = chartRows([
      item({ id: 'a', label: long, yearFrom: 1500, yearTo: 1990, regionIds: [10] }),
      item({ id: 'b', label: long, yearFrom: -2990, yearTo: -2980, regionIds: [10] }),
      item({ id: 'c', label: long, yearFrom: 1995, regionIds: [10] }),
    ], { from: -3000, to: 2000 }, CHART_WIDTH)
    for (const it of rows[0]!.items) {
      expect(it.text.length).toBeGreaterThan(0)
      const w = it.text.length * 11 // 全角の見積り
      const left = it.anchor === 'start' ? it.labelX : it.labelX - w
      const right = it.anchor === 'start' ? it.labelX + w : it.labelX
      expect(left, it.id).toBeGreaterThanOrEqual(LABEL_COL)
      expect(right, it.id).toBeLessThanOrEqual(CHART_WIDTH)
    }
  })

  it('重なる項目は別の段に置き、行の高さに反映する', () => {
    const rows = chartRows([
      item({ id: 'a', yearFrom: 1000, regionIds: [10] }),
      item({ id: 'b', yearFrom: 1005, regionIds: [10] }),
    ], { from: -3000, to: 2000 }, CHART_WIDTH)
    expect(rows[0]!.lanes).toBe(2)
    expect(new Set(rows[0]!.items.map(i => i.lane)).size).toBe(2)
  })

  it('右 → 中 → 左の順に入る場所を選ぶ', () => {
    expect(placeLabel('あ', 200, 210, CHART_WIDTH).anchor).toBe('start')
    expect(placeLabel('あ', 200, 210, CHART_WIDTH).labelX).toBe(213)
    // 右に余地が無く、棒の中には入る
    const inside = placeLabel('あいう', 400, 700, 720)
    expect(inside.labelX).toBe(403)
    // 右にも中にも入らないので左
    const left = placeLabel('あいう', 700, 705, 720)
    expect(left.anchor).toBe('end')
    expect(left.labelX).toBe(697)
  })

  it('入り切らなければ「…」で詰め、3文字未満には削らない', () => {
    expect(fitText('あいうえお', 44)).toBe('あいう…')
    expect(fitText('あいうえお', 20)).toBe('')
    expect(fitText('abc', 100)).toBe('abc')
  })
})
