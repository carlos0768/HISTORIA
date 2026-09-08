import 'server-only'
import type { AtlasBundleV1, AtlasConfidence } from './schema'
import { readAtlasBundle } from './files'

/**
 * 地図の束（出来事 3,500 件・4MB の ndjson）を**プロセスで1回だけ**読む。
 *
 * ★ 以前は React の cache() で包んでいたが、あれは1回の描画のあいだしか記憶しない。
 *   /map を開くたび・/api/atlas を叩くたびに 4MB を読み直して zod で検証し直していたので、
 *   歴史地球儀への遷移だけが目に見えて遅かった。
 *   seed/atlas はビルドに含まれる静的な資料で、実行中に変わらない。
 *   Promise を保持することで、同時に来た要求も 1 回の読み込みを待ち合わせる。
 *
 * ★ 失敗は記憶しない。読めなかった Promise を持ち続けると、
 *   一時的な I/O の失敗がプロセスの寿命のあいだ全ての要求を巻き込む。
 */
let bundle: Promise<AtlasBundleV1> | null = null

export function loadAtlasBundle(): Promise<AtlasBundleV1> {
  if (!bundle) {
    bundle = readAtlasBundle().catch(error => {
      bundle = null
      throw error
    })
  }
  return bundle
}

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
