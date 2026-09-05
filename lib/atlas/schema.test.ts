import { describe, expect, it } from 'vitest'
import { AtlasEventSchema, AtlasBundleSchema, HistoricalDateSchema, formatHistoricalDate } from './schema'

const source = {
  id: 'src.test', url: 'https://example.com/source', title: 'Source', publisher: 'Publisher',
  accessedAt: '2026-09-05', claims: ['date and place'],
}
const validEvent = {
  id: 'ae.test.event', label: '出来事', aliases: [], summary: '検証可能な出来事です。',
  start: { year: -44, month: 3, day: 15, precision: 'day', approximate: false },
  unitIds: ['wh.2.1.3'], kcIds: [], examWeight: 2,
  features: [{ kind: 'point', coordinates: [12.49, 41.89], label: 'ローマ' }],
  sources: [source], tags: [],
  evidence: {
    confidence: 'high', date: { status: 'direct', sourceIds: ['src.test'] },
    location: { status: 'direct', sourceIds: ['src.test'] },
    narrative: { status: 'direct', sourceIds: ['src.test'] },
  },
}

describe('Atlas schema', () => {
  it('紀元前を符号付き年で受け取り、日本語表示する', () => {
    const date = HistoricalDateSchema.parse(validEvent.start)
    expect(date.year).toBe(-44)
    expect(formatHistoricalDate(date)).toBe('前44年3月15日')
  })
  it('年0・座標外・出典参照切れを拒否する', () => {
    expect(HistoricalDateSchema.safeParse({ year: 0, precision: 'year' }).success).toBe(false)
    expect(AtlasEventSchema.safeParse({ ...validEvent, features: [{ kind: 'point', coordinates: [181, 0], label: '外' }] }).success).toBe(false)
    expect(AtlasEventSchema.safeParse({ ...validEvent, evidence: { ...validEvent.evidence, date: { status: 'direct', sourceIds: ['src.missing'] } } }).success).toBe(false)
  })
  it('物語から存在しないイベントへの参照を拒否する', () => {
    const story = { id: 'story.test', title: '物語', summary: '物語の概要', unitId: 'wh.2.1.3', kind: 'chronology', heroYear: -44, examWeight: 1,
      eventIds: ['ae.missing'], steps: [1, 2, 3, 4].map(ord => ({ id: `as.test.${ord}`, eventId: 'ae.missing', ord, title: '段階', narration: '説明', durationMs: 2000 })) }
    expect(AtlasBundleSchema.safeParse({ version: '1.0', generatedAt: new Date().toISOString(), events: [validEvent], stories: [story] }).success).toBe(false)
  })
})
