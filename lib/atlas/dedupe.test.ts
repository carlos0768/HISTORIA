import { describe, expect, it } from 'vitest'
import { dedupeAtlasEvents } from './dedupe'
import { AtlasEventSchema } from './schema'

function event(id: string, label: string, wikidataId?: string) {
  return AtlasEventSchema.parse({
    id,
    wikidataId,
    label,
    aliases: [],
    summary: '重複判定用イベント',
    start: { year: 1492, precision: 'year' },
    unitIds: [],
    kcIds: [],
    examWeight: 0.5,
    features: [{ kind: 'point', coordinates: [-74, 24], label }],
    sources: [{
      id: `src.${id}`,
      url: 'https://example.edu/source',
      title: 'Source',
      publisher: 'Example',
      accessedAt: '2026-09-05',
      claims: ['date', 'location'],
    }],
    evidence: {
      confidence: 'low',
      date: { status: 'direct', sourceIds: [`src.${id}`] },
      location: { status: 'direct', sourceIds: [`src.${id}`] },
      narrative: { status: 'direct', sourceIds: [`src.${id}`] },
    },
    tags: [],
  })
}

describe('atlas deduplication', () => {
  it('同じWikidata IDを統合する', () => {
    expect(dedupeAtlasEvents([
      event('ae.one', '第一表記', 'Q1'),
      event('ae.two', '第二表記', 'Q1'),
    ])).toHaveLength(1)
  })

  it('同年・同地点・正規化後の同名を統合する', () => {
    expect(dedupeAtlasEvents([
      event('ae.one', 'コロンブス の 航海'),
      event('ae.two', 'コロンブスの航海'),
    ])).toHaveLength(1)
  })
})
