import { describe, expect, it } from 'vitest'
import { bindingToEvent, type WikidataBinding } from './bootstrap-wikidata'

function binding(overrides: Partial<WikidataBinding> = {}): WikidataBinding {
  return {
    item: { value: 'http://www.wikidata.org/entity/Q123' },
    itemLabel: { value: '試験用の出来事' },
    date: { value: '+1492-10-12T00:00:00Z' },
    dateProp: { value: 'http://www.wikidata.org/prop/direct/P585' },
    coord: { value: 'Point(-74.5 24.1)' },
    ...overrides,
  }
}

describe('Wikidata bootstrap normalizer', () => {
  it('日時と座標を出典つきの要検証イベントへ変換する', () => {
    const event = bindingToEvent(binding(), '2026-09-05')
    expect(event).toMatchObject({
      id: 'ae.wikidata.q123',
      start: { year: 1492 },
      features: [{ kind: 'point', coordinates: [-74.5, 24.1] }],
      evidence: { confidence: 'low' },
      unitIds: [],
    })
    expect(event?.sources[0]?.url).toContain('Special:EntityData/Q123.json')
  })

  it('西暦0年と範囲外座標を除外する', () => {
    expect(bindingToEvent(binding({ date: { value: '+0000-01-01T00:00:00Z' } }), '2026-09-05')).toBeNull()
    expect(bindingToEvent(binding({ coord: { value: 'Point(181 0)' } }), '2026-09-05')).toBeNull()
  })
})
