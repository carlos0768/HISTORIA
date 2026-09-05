import { describe, it, expect } from 'vitest'
import { POLITIES, findPolities, diffSnapshots, polityById } from './territories'
import { COUNTRY_PATHS, MICRO_PINS } from './basemap'

describe('版図マスタ（docs/11 §4.1）', () => {
  const drawable = new Set([...Object.keys(COUNTRY_PATHS), ...MICRO_PINS.map(p => p.id)])

  it('id と名前が重ならない', () => {
    expect(new Set(POLITIES.map(p => p.id)).size).toBe(POLITIES.length)
    expect(new Set(POLITIES.map(p => p.label)).size).toBe(POLITIES.length)
  })

  it('全ての国コードが基図で描ける（描けないコードは黙って消える）', () => {
    for (const p of POLITIES) for (const s of p.snapshots) for (const c of s.countries) {
      expect(drawable.has(c), `${p.label} ${s.year} の ${c}`).toBe(true)
    }
  })

  it('段階は年代順で、同じ国を2度書かない', () => {
    for (const p of POLITIES) {
      expect(p.snapshots.length, p.label).toBeGreaterThanOrEqual(2)
      for (let k = 1; k < p.snapshots.length; k++) {
        expect(p.snapshots[k]!.year, `${p.label} ${k}`).toBeGreaterThan(p.snapshots[k - 1]!.year)
      }
      for (const s of p.snapshots) {
        expect(new Set(s.countries).size, `${p.label} ${s.year}`).toBe(s.countries.length)
      }
    }
  })

  it('縮小の過程を持つ国家がある（最大の後に減る段階が続く）', () => {
    const ottoman = polityById('ottoman')!
    const sizes = ottoman.snapshots.map(s => s.countries.length)
    const peak = sizes.indexOf(Math.max(...sizes))
    for (let k = peak + 1; k < sizes.length; k++) expect(sizes[k]).toBeLessThan(sizes[k - 1]!)
    expect(sizes[sizes.length - 1]).toBe(0)
  })
})

describe('国名で引く', () => {
  it('正式名・別名・部分一致で当たり、確からしい順', () => {
    expect(findPolities('オスマン帝国').map(p => p.id)).toEqual(['ottoman'])
    expect(findPolities('オスマン')[0]!.id).toBe('ottoman')
    expect(findPolities('トルコ')[0]!.id).toBe('ottoman')
    expect(findPolities('東ローマ帝国')[0]!.id).toBe('byzantium')
    // 語が名前を含んでいても当たる
    expect(findPolities('オスマン帝国の版図')[0]!.id).toBe('ottoman')
    // 「ローマ」は正式名が一致するローマ帝国が先、東ローマは部分一致で後
    const rome = findPolities('ローマ')
    expect(rome[0]!.id).toBe('rome')
    expect(rome.map(p => p.id)).toContain('byzantium')
  })
  it('無関係な語には何も返さない', () => {
    expect(findPolities('ハンムラビ法典')).toEqual([])
    expect(findPolities('   ')).toEqual([])
  })
  it('件数の上限を守る', () => {
    expect(findPolities('帝国', 2)).toHaveLength(2)
  })
})

describe('段階の差', () => {
  it('得た国と失った国を分ける', () => {
    const d = diffSnapshots({ year: 1, label: 'a', countries: ['100', '200'] }, { year: 2, label: 'b', countries: ['200', '300'] })
    expect(d).toEqual({ gained: ['300'], lost: ['100'] })
    expect(diffSnapshots(null, { year: 2, label: 'b', countries: ['200'] })).toEqual({ gained: ['200'], lost: [] })
  })
})
