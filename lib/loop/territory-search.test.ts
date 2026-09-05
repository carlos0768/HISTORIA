import { describe, it, expect } from 'vitest'
import { POLITIES } from '@/lib/map/territories'
import {
  cosine, rankPolities, pickPolities, embedTextOfPolity, POLITY_TOP_MIN, POLITY_CANDIDATE_MIN,
} from './territory-search'

const dim = 8
const unit = (axis: number) => { const v = new Array<number>(dim).fill(0); v[axis] = 1; return v }
const mix = (a: number, b: number, t: number) => unit(a).map((x, i) => x * (1 - t) + unit(b)[i]! * t)

describe('版図を意味で引く', () => {
  it('cos 類似度', () => {
    expect(cosine(unit(0), unit(0))).toBeCloseTo(1)
    expect(cosine(unit(0), unit(1))).toBeCloseTo(0)
    expect(cosine([0, 0], unit(1).slice(0, 2))).toBe(0)
  })

  it('埋め込みにかける文は別名を含む', () => {
    const ottoman = POLITIES.find(p => p.id === 'ottoman')!
    expect(embedTextOfPolity(ottoman)).toContain('トルコ')
  })

  it('最も近いものが先頭、閾値以上が候補。語の一致は近さに関係なく先頭', () => {
    // 国家 i のベクトルを軸 i%dim に置き、検索語を国家 3 に近く、国家 5 にやや近くする
    const vectors = POLITIES.map((_, i) => unit(i % dim))
    const q = mix(3, 5, 0.3)   // 3 に約 0.92、5 に約 0.39 → 5 は候補の閾値未満
    const ranked = rankPolities('なにか', q, vectors)
    expect(ranked[0]!.id).toBe(POLITIES[3]!.id)
    expect(ranked[0]!.similarity!).toBeGreaterThan(POLITY_TOP_MIN)
    expect(ranked.every(r => r.textMatch || r.similarity! >= POLITY_CANDIDATE_MIN)).toBe(true)
    // 語が一致するものは近さが低くても先頭
    const byText = rankPolities('オスマン', q, vectors)
    expect(byText[0]!.id).toBe('ottoman')
    expect(byText[0]!.textMatch).toBe(true)
  })

  it('主が閾値未満なら何も出さない（何となく近い版図を主役にしない）', () => {
    const vectors = POLITIES.map((_, i) => unit(i % dim))
    const weak = mix(2, 6, 0.5)   // どちらにも約 0.7 → 候補には入るが…
    const ranked = rankPolities('なにか', weak, vectors)
    expect(pickPolities(ranked).length).toBeGreaterThan(0)   // 0.7 は主の閾値以上
    // 全方向に均等（どの軸とも cos ≈ 0.35）→ 候補にも主にも入らない
    const none = rankPolities('なにか', new Array<number>(dim).fill(0.1), vectors)
    expect(pickPolities(none)).toEqual([])
  })

  it('ベクトルが無ければ語の一致だけ', () => {
    const ranked = rankPolities('ローマ', null, null)
    expect(ranked.length).toBeGreaterThan(0)
    expect(ranked.every(r => r.textMatch && r.similarity === null)).toBe(true)
    expect(rankPolities('ハンムラビ法典', null, null)).toEqual([])
  })

  it('候補は主を含めて5つまで', () => {
    const vectors = POLITIES.map(() => unit(0))   // 全部同じ近さ
    expect(pickPolities(rankPolities('なにか', unit(0), vectors))).toHaveLength(5)
  })
})
