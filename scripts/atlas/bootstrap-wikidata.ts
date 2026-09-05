import { writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { AtlasEventSchema, type AtlasEvent } from '../../lib/atlas/schema'

export type WikidataBinding = {
  item: { value: string }
  itemLabel: { value: string }
  date: { value: string }
  dateProp: { value: string }
  coord: { value: string }
}

const DATE_CLAIM: Record<string, string> = { P585: '時点', P580: '開始日', P571: '成立日' }

function parsePoint(value: string): [number, number] | null {
  const match = /^Point\((-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?)\)$/.exec(value)
  if (!match) return null
  const point: [number, number] = [Number(match[1]), Number(match[2])]
  return point[0] >= -180 && point[0] <= 180 && point[1] >= -90 && point[1] <= 90 ? point : null
}

function parseYear(value: string): number | null {
  const match = /^([+-]?\d+)-/.exec(value)
  const year = match ? Number(match[1]) : Number.NaN
  return Number.isInteger(year) && year !== 0 && year >= -10_000 && year <= 2000 ? year : null
}

export function bindingToEvent(row: WikidataBinding, accessedAt: string): AtlasEvent | null {
  const wikidataId = row.item.value.split('/').pop()
  const dateProp = row.dateProp.value.split('/').pop()
  const year = parseYear(row.date.value)
  const coordinates = parsePoint(row.coord.value)
  if (!wikidataId || !/^Q\d+$/.test(wikidataId) || !dateProp || !year || !coordinates) return null
  const sourceId = `src.wikidata.${wikidataId.toLowerCase()}`
  const event = {
    id: `ae.wikidata.${wikidataId.toLowerCase()}`,
    wikidataId,
    label: row.itemLabel.value,
    aliases: [],
    summary: `${row.itemLabel.value}。Wikidataの日時・座標を地球儀表示用に正規化した自動取得データ。`,
    start: { year, precision: 'year' as const, approximate: true, label: year < 0 ? `前${Math.abs(year)}年` : `${year}年` },
    unitIds: [],
    kcIds: [],
    examWeight: 0.25,
    features: [{ kind: 'point' as const, coordinates, label: row.itemLabel.value }],
    sources: [{
      id: sourceId,
      url: `https://www.wikidata.org/wiki/Special:EntityData/${wikidataId}.json`,
      title: `${row.itemLabel.value} — Wikidata structured data`,
      publisher: 'Wikidata', accessedAt,
      claims: [`${dateProp}（${DATE_CLAIM[dateProp] ?? '日付'}）`, 'P625（座標）', '日本語ラベル'],
      license: 'CC0 1.0',
    }],
    evidence: {
      confidence: 'low' as const,
      date: { status: 'direct' as const, sourceIds: [sourceId], note: 'Wikidataの精度値は年単位へ正規化' },
      location: { status: 'direct' as const, sourceIds: [sourceId] },
      narrative: { status: 'inferred' as const, sourceIds: [sourceId], note: 'ラベル・日時・座標だけを自動要約。単元比定は未校閲' },
    },
    tags: ['Wikidata', '自動取得', '要検証'],
  }
  return AtlasEventSchema.parse(event)
}

async function main() {
  const limitArg = process.argv.find(value => value.startsWith('--limit='))
  const limit = Math.min(5000, Math.max(1, Number(limitArg?.slice(8) ?? 4500)))
  const query = `SELECT DISTINCT ?item ?itemLabel ?date ?dateProp ?coord WHERE {
    VALUES ?dateProp { wdt:P585 wdt:P580 wdt:P571 }
    ?item wdt:P31/wdt:P279* wd:Q13418847; ?dateProp ?date; wdt:P625 ?coord; rdfs:label ?itemLabel.
    FILTER(LANG(?itemLabel) = "ja")
    FILTER(YEAR(?date) >= -3000 && YEAR(?date) <= 2000)
  } LIMIT ${limit}`
  const url = new URL('https://query.wikidata.org/sparql')
  url.searchParams.set('query', query)
  const response = await fetch(url, {
    headers: { Accept: 'application/sparql-results+json', 'User-Agent': 'HISTORIA-atlas/0.1 educational-data-import' },
    signal: AbortSignal.timeout(120_000),
  })
  if (!response.ok) throw new Error(`Wikidata Query Service: ${response.status}`)
  const json = await response.json() as { results: { bindings: WikidataBinding[] } }
  const accessedAt = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Tokyo' }).format(new Date())
  const byId = new Map<string, AtlasEvent>()
  for (const binding of json.results.bindings) {
    const event = bindingToEvent(binding, accessedAt)
    if (event) byId.set(event.wikidataId!, event)
  }
  const events = [...byId.values()].sort((a, b) => a.start.year - b.start.year || a.id.localeCompare(b.id))
  console.log(`${json.results.bindings.length} rows → ${events.length} unique, drawable historical events`)
  if (!process.argv.includes('--apply')) {
    console.log('dry-run: wikidata-events.ndjson は変更していません。--apply で反映します。')
    return
  }
  const file = join(process.cwd(), 'seed', 'atlas', 'wikidata-events.ndjson')
  await writeFile(file, events.map(event => JSON.stringify(event)).join('\n') + '\n')
  console.log(`${file} を更新しました。全件「要検証」で、校閲済み物語とは分離されています。`)
}

if (process.argv[1]?.endsWith('bootstrap-wikidata.ts')) await main()
