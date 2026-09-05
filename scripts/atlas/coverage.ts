import { readFile } from 'node:fs/promises'
import path from 'node:path'
import { readAtlasBundle } from '../../lib/atlas/files'

type LeafUnit = { id: string; label: string }

async function readLeafUnits(): Promise<LeafUnit[]> {
  const csv = await readFile(path.join(process.cwd(), 'seed', 'syllabus_unit.csv'), 'utf8')
  return csv.split(/\r?\n/).slice(1).filter(Boolean).flatMap(line => {
    const [id, , , level, label] = line.split(',')
    return id && label && level === '3' ? [{ id, label }] : []
  })
}

export async function atlasCoverage() {
  const [bundle, units] = await Promise.all([readAtlasBundle(), readLeafUnits()])
  const storyUnits = new Set(bundle.stories.map(story => story.unitId))
  const eventUnits = new Set(bundle.events.flatMap(event => event.unitIds))
  return {
    eventCount: bundle.events.length,
    storyCount: bundle.stories.length,
    leafUnitCount: units.length,
    storyUnitCount: units.filter(unit => storyUnits.has(unit.id)).length,
    eventUnitCount: units.filter(unit => eventUnits.has(unit.id)).length,
    unassignedEventCount: bundle.events.filter(event => event.unitIds.length === 0).length,
    missingStoryUnits: units.filter(unit => !storyUnits.has(unit.id)),
  }
}

if (process.argv[1]?.endsWith('coverage.ts')) {
  const coverage = await atlasCoverage()
  console.log(`${coverage.eventCount} events / ${coverage.storyCount} stories`)
  console.log(`物語の単元カバー: ${coverage.storyUnitCount}/${coverage.leafUnitCount}`)
  console.log(`イベントの単元カバー: ${coverage.eventUnitCount}/${coverage.leafUnitCount}`)
  console.log(`未校閲・単元未割当イベント: ${coverage.unassignedEventCount}`)
  if (coverage.missingStoryUnits.length) {
    console.log('物語未作成の単元:')
    for (const unit of coverage.missingStoryUnits) console.log(`- ${unit.id} ${unit.label}`)
  }
}
