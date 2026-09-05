import 'server-only'
import { cache } from 'react'
import type { AtlasConfidence } from './schema'
import { readAtlasBundle } from './files'

export const loadAtlasBundle = cache(readAtlasBundle)

export type AtlasEventQuery = {
  q?: string
  year?: number
  unitId?: string
  confidence?: AtlasConfidence
  page: number
  limit: number
}

export async function searchAtlasEvents(query: AtlasEventQuery) {
  const { events } = await loadAtlasBundle()
  const needle = query.q?.trim().toLocaleLowerCase('ja')
  const filtered = events.filter(event => {
    if (needle && ![event.label, event.summary, ...event.aliases, ...event.tags]
      .some(value => value.toLocaleLowerCase('ja').includes(needle))) return false
    if (query.year !== undefined) {
      const endYear = event.end?.year ?? event.start.year
      if (query.year < event.start.year || query.year > endYear) return false
    }
    if (query.unitId && !event.unitIds.includes(query.unitId)) return false
    if (query.confidence && event.evidence.confidence !== query.confidence) return false
    return true
  }).sort((a, b) => a.start.year - b.start.year || b.examWeight - a.examWeight)
  const offset = (query.page - 1) * query.limit
  return { total: filtered.length, page: query.page, limit: query.limit, items: filtered.slice(offset, offset + query.limit) }
}
