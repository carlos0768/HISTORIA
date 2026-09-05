/**
 * 版図の境界データを、基図と同じ投影のパス文字列に焼く
 *
 *   npx tsx scripts/map/build-territories.mjs        # lib/map/territory-geo/<国家id>.ts と index.ts を作り直す
 *
 * ★ tsx で動かす。lib/map/territories.ts（TS）を読むため。
 *
 * 入力: scripts/map/data/historical-basemaps/world_<year>.geojson（scripts/map/fetch-historical.mjs が取る）
 *       lib/map/territories.ts の各スナップショットの `geo`（データ側の年と NAME）
 * 出力: lib/map/territory-geo/<国家id>.ts（geo を持つ国家だけ）、index.ts（動的 import の一覧）、attribution.ts
 *
 * ★ 投影は build-basemap.mjs と**同一**にする（Natural Earth 1 を 660×340 に fitExtent）。
 *   1画素でもずれると国土のパスと重ならず、境界が現在の国境から浮いて見える。
 * ★ 環の向きを直してから投影する。GeoJSON は RFC 7946（外環が反時計回り）で出ていることが多く、
 *   d3-geo は外環を時計回りと仮定する。直さないと**球面の補集合**（全世界）が塗られる。
 * ★ 一致するフィーチャが 0 件なら落とす。黙って空の版図を焼くと、画面が「版図なし」の顔をする。
 * ★ 出典は GPL-3.0（docs/10 §7b）。生成物のヘッダに出典とコミットを書き、LICENSE を同梱する。
 */
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs'
import { join } from 'node:path'
import { geoNaturalEarth1, geoPath, geoArea } from 'd3-geo'
import { simplify } from './simplify.mjs'
import { POLITIES } from '../../lib/map/territories.ts'
import { historicalFileName } from '../../lib/map/historical-years.ts'
import { HISTORICAL_BASEMAPS_COMMIT, HISTORICAL_BASEMAPS_REPO, DATA_DIR } from './fetch-historical.mjs'

const OUT_DIR = 'lib/map/territory-geo'

// build-basemap.mjs の 110m と同じ
const W = 660, H = 340
const PAD = [[10, 12], [W - 10, H - 12]]
const proj = geoNaturalEarth1().fitExtent(PAD, { type: 'Sphere' })
const path = geoPath(proj)
const STEP = 0.35, RING = 0.5

/** 外環は時計回り（球面積 < 2π）、穴は反時計回りに直す（d3-geo の約束） */
function rewindPolygon(rings) {
  return rings.map((ring, i) => {
    const area = geoArea({ type: 'Polygon', coordinates: [ring] })
    const outerOk = area < 2 * Math.PI
    // i === 0 は外環、それ以外は穴
    return (i === 0 ? outerOk : !outerOk) ? ring : [...ring].reverse()
  })
}
function rewind(geometry) {
  if (geometry.type === 'Polygon') return { type: 'Polygon', coordinates: rewindPolygon(geometry.coordinates) }
  if (geometry.type === 'MultiPolygon') {
    return { type: 'MultiPolygon', coordinates: geometry.coordinates.map(rewindPolygon) }
  }
  throw new Error(`扱えないジオメトリ: ${geometry.type}`)
}

const trim = s => (typeof s === 'string' ? s.trim() : '')

const cache = new Map()
function loadYear(year) {
  const file = join(DATA_DIR, historicalFileName(year))
  if (!existsSync(file)) {
    throw new Error(`${file} がありません。node scripts/map/fetch-historical.mjs ${year} で取ってください`)
  }
  if (!cache.has(file)) cache.set(file, JSON.parse(readFileSync(file, 'utf8')))
  return cache.get(file)
}

function select(features, geo) {
  const by = geo.by ?? 'NAME'
  const names = new Set(geo.names.map(trim))
  return features.filter(f => {
    const p = f.properties ?? {}
    if (names.has(trim(p.NAME))) return true
    return by === 'SUBJECTO' && names.has(trim(p.SUBJECTO))
  })
}

const header = (id, label) => `/**
 * ${label} の版図（自動生成）
 *
 * ★ 手で編集しない。scripts/map/build-territories.mjs が作る。
 *
 * 出典: historical-basemaps（André Ourednik）
 *       ${HISTORICAL_BASEMAPS_REPO} / commit ${HISTORICAL_BASEMAPS_COMMIT}
 *       ライセンス: GPL-3.0（同ディレクトリの LICENSE）。この派生データも GPL-3.0 で再配布する。
 * 図法: 基図と同じ Natural Earth 1（660×340）をビルド時に適用済み。
 * 用途: 学習用の模式図。境界の精度は precision（1=概略 … 3=国際法で確定）を見る。
 */
import type { TerritoryPaths } from './types'

`

mkdirSync(OUT_DIR, { recursive: true })
const built = []
for (const polity of POLITIES) {
  const snaps = polity.snapshots.filter(s => s.geo)
  if (snaps.length === 0) continue

  const byYear = new Map()
  for (const s of snaps) {
    const g = s.geo
    const key = g.year
    const sig = JSON.stringify([g.by ?? 'NAME', [...g.names].sort()])
    if (byYear.has(key) && byYear.get(key).sig !== sig) {
      throw new Error(`${polity.id}: データ年 ${key} に違う names が2つ付いています`)
    }
    byYear.set(key, { geo: g, sig })
  }

  const entries = []
  for (const [year, { geo }] of [...byYear.entries()].sort((a, b) => a[0] - b[0])) {
    const fc = loadYear(year)
    const hit = select(fc.features, geo)
    if (hit.length === 0) {
      throw new Error(`${polity.id} ${year}: NAME/SUBJECTO が ${JSON.stringify(geo.names)} に一致するフィーチャがありません`)
    }
    const polygons = []
    for (const f of hit) {
      const g = rewind(f.geometry)
      if (g.type === 'Polygon') polygons.push(g.coordinates)
      else polygons.push(...g.coordinates)
    }
    const d = simplify(path({ type: 'MultiPolygon', coordinates: polygons }) ?? '', STEP, RING)
    if (!d) throw new Error(`${polity.id} ${year}: 投影後のパスが空です`)
    const precision = Math.min(...hit.map(f => Number(f.properties?.BORDERPRECISION) || 1))
    const names = [...new Set(hit.map(f => trim(f.properties?.NAME)))].sort()
    entries.push({ year, d, precision, names, features: hit.length })
  }

  const body = entries
    .map(e => `  ${e.year}: ${JSON.stringify({ d: e.d, precision: e.precision, names: e.names })},`)
    .join('\n')
  const out = `${header(polity.id, polity.label)}export const TERRITORY_PATHS: TerritoryPaths = {\n${body}\n}\n`
  const file = join(OUT_DIR, `${polity.id}.ts`)
  writeFileSync(file, out)
  built.push({ id: polity.id, label: polity.label, bytes: Buffer.byteLength(out), entries })
}

// 動的 import の一覧。★ ここでも静的に import しない（全国家分がモバイル初回に乗る）
const index = `/**
 * 版図の境界データの一覧（自動生成。scripts/map/build-territories.mjs が作る。手で編集しない）
 *
 * ★ 動的 import だけ。国家ごとに別 chunk になり、版図を開いたときにその国家の分だけ読む。
 *   静的に import すると全国家分が初回の転送に乗る（components/desktop.test.tsx が見張る）。
 */
import type { TerritoryGeoModule } from './types'

export const TERRITORY_GEO: Readonly<Record<string, () => Promise<TerritoryGeoModule>>> = {
${built.map(b => `  ${b.id}: () => import('./${b.id}'),`).join('\n')}
}
`
writeFileSync(join(OUT_DIR, 'index.ts'), index)

const attribution = `/** 出典の表示に使う（自動生成。scripts/map/build-territories.mjs が作る。手で編集しない） */
export const TERRITORY_GEO_SOURCE = {
  name: 'historical-basemaps',
  author: 'André Ourednik',
  url: '${HISTORICAL_BASEMAPS_REPO}',
  license: 'GPL-3.0',
  commit: '${HISTORICAL_BASEMAPS_COMMIT}',
} as const
`
writeFileSync(join(OUT_DIR, 'attribution.ts'), attribution)

for (const b of built) {
  console.log(`${b.id}.ts（${b.label}）: ${(b.bytes / 1024).toFixed(1)}KB`)
  for (const e of b.entries) {
    console.log(`  ${e.year}: ${e.features} フィーチャ / パス ${(e.d.length / 1024).toFixed(1)}KB / 精度 ${e.precision} / ${e.names.join(', ')}`)
  }
}
console.log(`index.ts: ${built.length} 国家`)
