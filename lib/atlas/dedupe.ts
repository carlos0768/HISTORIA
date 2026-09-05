import { spatialDistanceKm } from './geo'
import type { AtlasEvent, AtlasPosition } from './schema'

export function normalizeAtlasLabel(label: string): string {
  return label.normalize('NFKC').toLocaleLowerCase('ja')
    .replace(/[\s・＝=‐‑–—―,，.。()（）「」『』]/g, '')
}

function firstPoint(event: AtlasEvent): AtlasPosition | null {
  for (const feature of event.features) {
    if (feature.kind === 'point') return feature.coordinates
    if (feature.kind === 'route') return feature.coordinates[0] ?? null
  }
  return null
}

function datesOverlap(a: AtlasEvent, b: AtlasEvent): boolean {
  const aEnd = a.end?.year ?? a.start.year
  const bEnd = b.end?.year ?? b.start.year
  return a.start.year <= bEnd && b.start.year <= aEnd
}

export function isAtlasDuplicate(a: AtlasEvent, b: AtlasEvent): boolean {
  if (a.wikidataId && b.wikidataId) return a.wikidataId === b.wikidataId
  if (normalizeAtlasLabel(a.label) !== normalizeAtlasLabel(b.label)) return false
  if (!datesOverlap(a, b)) return false
  const pa = firstPoint(a); const pb = firstPoint(b)
  return pa !== null && pb !== null && spatialDistanceKm(pa, pb) <= 75
}

export function dedupeAtlasEvents(events: AtlasEvent[]): AtlasEvent[] {
  const unique: AtlasEvent[] = []
  for (const event of events) {
    if (!unique.some(candidate => isAtlasDuplicate(candidate, event))) unique.push(event)
  }
  return unique
}
