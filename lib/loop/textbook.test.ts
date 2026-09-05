import { describe, expect, it } from 'vitest'
import { groupTextbookArticles } from './textbook'

const article = (unit_id: string, year_from: number | null) => ({
  material_id: `material-${unit_id}`, unit_id, unit_label: unit_id,
  title: `教材 ${unit_id}`, year_from,
})

describe('教科書の国別時系列', () => {
  it('別の章にある中国の教材をまとめ、紀元前から近世へ並べる', () => {
    const rows = [article('wh.3.4.1', 1368), article('wh.4.1.3', 1789),
      article('wh.2.3.2', 220), article('wh.2.3.1', -1600), article('wh.3.2.1', 960)]
    const groups = groupTextbookArticles(rows)
    expect(groups.map(group => group.label)).toEqual(['中国', 'フランス'])
    expect(groups[0]!.articles.map(row => row.unitId)).toEqual([
      'wh.2.3.1', 'wh.2.3.2', 'wh.3.2.1', 'wh.3.4.1',
    ])
    expect(rows[0]!.unit_id).toBe('wh.3.4.1')
  })

  it('同じ国の年代不明教材は末尾に置き、同年は節順で安定させる', () => {
    const groups = groupTextbookArticles([
      article('gh.4.2.2', null), article('gh.2.3.2', 1868),
      article('gh.2.3.1', 1853), article('gh.2.4.1', 1868),
    ])
    expect(groups[0]!.label).toBe('日本')
    expect(groups[0]!.articles.map(row => row.unitId)).toEqual([
      'gh.2.3.1', 'gh.2.3.2', 'gh.2.4.1', 'gh.4.2.2',
    ])
  })

  it('科目をまたぐ国際関係と未知の節も欠落・重複なく表示する', () => {
    const groups = groupTextbookArticles([
      article('new.1', null), article('gh.3.1.1', 1914),
      article('wh.3.5.1', 1492), article('wh.4.5.1', 1914),
    ])
    expect(groups).toHaveLength(1)
    expect(groups[0]!.label).toBe('世界・国際関係')
    expect(groups[0]!.articles.map(row => row.unitId)).toEqual([
      'wh.3.5.1', 'gh.3.1.1', 'wh.4.5.1', 'new.1',
    ])
    expect(groupTextbookArticles([])).toEqual([])
  })
})
