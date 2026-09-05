import { mkdir, readFile, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { readCsv } from '../db/csv'

type Binding = {
  item: { value: string }
  itemLabel: { value: string }
  date: { value: string }
  coord: { value: string }
}

type Candidate = {
  wikidataId: string
  label: string
  year: number
  coordinates: [number, number]
  sourceUrl: string
  sourceClaims: ['P585', 'P625']
  matchedTerms: string[]
  recommendedUnitIds: string[]
  status: 'candidate'
}

const arg = (name: string, fallback: number) => {
  const hit = process.argv.find(value => value.startsWith(`${name}=`))
  return hit ? Number(hit.slice(name.length + 1)) : fallback
}

function parsePoint(value: string): [number, number] | null {
  const match = /^Point\((-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?)\)$/.exec(value)
  if (!match) return null
  const point: [number, number] = [Number(match[1]), Number(match[2])]
  return point[0] >= -180 && point[0] <= 180 && point[1] >= -90 && point[1] <= 90 ? point : null
}

function parseYear(value: string): number | null {
  const match = /^([+-]?\d+)-/.exec(value)
  const year = match ? Number(match[1]) : Number.NaN
  return Number.isInteger(year) && year !== 0 && year >= -10_000 && year <= 2100 ? year : null
}

async function main() {
  const from = arg('--from', 1400)
  const to = arg('--to', 2000)
  const limit = Math.min(500, Math.max(1, arg('--limit', 250)))
  if (!Number.isInteger(from) || !Number.isInteger(to) || from > to || from === 0 || to === 0) {
    throw new Error('--from/--to は年0を含まない昇順の整数にしてください')
  }
  const query = `SELECT ?item ?itemLabel ?date ?coord WHERE {
    ?item wdt:P585 ?date; wdt:P625 ?coord; rdfs:label ?itemLabel.
    FILTER(LANG(?itemLabel) = "ja")
    FILTER(YEAR(?date) >= ${from} && YEAR(?date) <= ${to})
  } LIMIT ${limit}`
  const url = new URL('https://query.wikidata.org/sparql')
  url.searchParams.set('query', query)
  const response = await fetch(url, {
    headers: { Accept: 'application/sparql-results+json', 'User-Agent': 'HISTORIA-atlas/0.1 educational-data-import' },
    signal: AbortSignal.timeout(60_000),
  })
  if (!response.ok) throw new Error(`Wikidata Query Service: ${response.status}`)
  const json = await response.json() as { results: { bindings: Binding[] } }

  const kc = readCsv(join(process.cwd(), 'seed', 'kc.csv')).filter(row => !row.retired)
  const terms = kc.flatMap(row => [row.label, row.why_confusable]
    .filter((value): value is string => Boolean(value && value.length >= 4))
    .map(value => ({ term: value, unitId: row.unit_id! })))
  const seen = new Set<string>()
  const candidates: Candidate[] = []
  for (const row of json.results.bindings) {
    const wikidataId = row.item.value.split('/').pop()
    const year = parseYear(row.date.value)
    const coordinates = parsePoint(row.coord.value)
    if (!wikidataId || seen.has(wikidataId) || !year || !coordinates) continue
    seen.add(wikidataId)
    const matched = terms.filter(item => row.itemLabel.value.includes(item.term) || item.term.includes(row.itemLabel.value))
    if (matched.length === 0 && !process.argv.includes('--include-unmatched')) continue
    candidates.push({
      wikidataId, label: row.itemLabel.value, year, coordinates,
      sourceUrl: `https://www.wikidata.org/wiki/Special:EntityData/${wikidataId}.json`,
      sourceClaims: ['P585', 'P625'],
      matchedTerms: [...new Set(matched.map(item => item.term))],
      recommendedUnitIds: [...new Set(matched.map(item => item.unitId))],
      status: 'candidate',
    })
  }

  console.log(`Wikidata: ${json.results.bindings.length} rows → ${candidates.length} exam-scoped candidates`)
  if (!process.argv.includes('--apply')) {
    console.log('dry-run: 候補ファイルは変更していません。--apply で保存します。')
    return
  }
  const dir = join(process.cwd(), 'seed', 'atlas', 'candidates')
  await mkdir(dir, { recursive: true })
  const file = join(dir, `wikidata-${from}-${to}.ndjson`)
  let prior = ''
  try { prior = await readFile(file, 'utf8') } catch { /* 初回 */ }
  const byId = new Map<string, Candidate>()
  for (const line of prior.split(/\r?\n/).filter(Boolean)) {
    const candidate = JSON.parse(line) as Candidate
    byId.set(candidate.wikidataId, candidate)
  }
  for (const candidate of candidates) byId.set(candidate.wikidataId, candidate)
  const body = [...byId.values()].sort((a, b) => a.year - b.year || a.wikidataId.localeCompare(b.wikidataId))
    .map(candidate => JSON.stringify(candidate)).join('\n') + '\n'
  await writeFile(file, body)
  console.log(`${file} を ${byId.size}件に更新しました。候補はAtlasへ昇格する前に出典・単元を検証してください。`)
}

await main()
