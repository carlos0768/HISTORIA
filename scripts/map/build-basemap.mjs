/**
 * 世界地図の基図を作る
 *
 *   node scripts/map/build-basemap.mjs
 *
 * 出典: Natural Earth 1:110m physical vectors（パブリックドメイン）。
 * npm の world-atlas が TopoJSON として再配布しているものを変換している。
 * Natural Earth は「使用許諾を求める必要がない」と明示しているため、
 * docs/10 §2 の第三者著作物のリスクに当たらない。
 *
 * ★ 生成物 lib/map/basemap.ts はリポジトリに入れる。
 *   実行時に外部から地図を取りに行かない。CSP を広げずに済み、
 *   配信先が落ちても地図が消えない。
 */
import { readFileSync, writeFileSync } from 'node:fs'
import { feature } from 'topojson-client'

const topo = JSON.parse(readFileSync('node_modules/world-atlas/land-110m.json', 'utf8'))
const land = feature(topo, topo.objects.land)

// 正距円筒図法。緯度は南緯60度から北緯84度まで（南極を落とし、北端は残す）
const LON0 = -180, LON1 = 180
const LAT0 = 84, LAT1 = -60
const W = 360, H = 144

const x = lon => ((lon - LON0) / (LON1 - LON0)) * W
const y = lat => ((LAT0 - lat) / (LAT0 - LAT1)) * H
const r = n => Math.round(n * 10) / 10

// 模式図なので細部は要らない。送る量を減らすために間引く
const MIN_RING = 1.2   // これより小さい輪（小島）は落とす。図の単位＝おおよそ1度
const MIN_STEP = 0.4   // 直前の点からこれ未満しか動かない点は落とす

/** 緯度の範囲外に出た輪はまるごと落とす（南極大陸） */
function ringPath(ring) {
  if (ring.every(([, lat]) => lat < LAT1)) return null

  const raw = ring.map(([lon, lat]) => [x(lon), y(Math.max(LAT1, Math.min(LAT0, lat)))])
  const xs = raw.map(p => p[0]), ys = raw.map(p => p[1])
  if (Math.max(...xs) - Math.min(...xs) < MIN_RING && Math.max(...ys) - Math.min(...ys) < MIN_RING) {
    return null
  }

  const kept = [raw[0]]
  for (const p of raw.slice(1)) {
    const q = kept[kept.length - 1]
    if (Math.hypot(p[0] - q[0], p[1] - q[1]) >= MIN_STEP) kept.push(p)
  }
  if (kept.length < 4) return null

  // ★ 日付変更線をまたぐ輪（フィジー・チュクチ半島など）は、経度が +180 から -180 へ
  //   飛ぶときに地図を横断する線を引いてしまう。またいだ箇所でパスを切る。
  const parts = []
  let run = [kept[0]]
  for (const p of kept.slice(1)) {
    if (Math.abs(p[0] - run[run.length - 1][0]) > W / 2) {
      parts.push(run)
      run = [p]
    } else {
      run.push(p)
    }
  }
  parts.push(run)

  const out = parts
    .map(part => part.map(([px, py]) => `${r(px)},${r(py)}`).filter((q, i, a) => q !== a[i - 1]))
    .filter(part => part.length >= 4)
    .map(part => `M${part.join('L')}Z`)
    .join('')
  return out || null
}

const paths = []
for (const g of land.features) {
  const polys = g.geometry.type === 'Polygon' ? [g.geometry.coordinates] : g.geometry.coordinates
  for (const poly of polys) {
    for (const ring of poly) {
      const p = ringPath(ring)
      if (p) paths.push(p)
    }
  }
}

const d = paths.join('')
const out = `/**
 * 世界地図の基図（自動生成）
 *
 * ★ 手で編集しない。scripts/map/build-basemap.mjs が作る。
 *
 * 出典: Natural Earth 1:110m physical vectors（パブリックドメイン）
 * 図法: 正距円筒図法。経度 ${LON0}〜${LON1}、緯度 ${LAT1}〜${LAT0}
 * 用途: 学習用の模式図であり、正確な国境や領域を示すものではない
 */
export const MAP_VIEWBOX = '0 0 ${W} ${H}' as const
export const MAP_WIDTH = ${W}
export const MAP_HEIGHT = ${H}
export const MAP_LON = [${LON0}, ${LON1}] as const
export const MAP_LAT = [${LAT1}, ${LAT0}] as const

/** 経度・緯度を図の座標に移す。地域の枠を描くのに使う */
export function project(lon: number, lat: number): { x: number; y: number } {
  return {
    x: ((lon - ${LON0}) / ${LON1 - LON0}) * ${W},
    y: ((${LAT0} - Math.max(${LAT1}, Math.min(${LAT0}, lat))) / ${LAT0 - LAT1}) * ${H},
  }
}

export const LAND_PATH =
  '${d}'
`
writeFileSync('lib/map/basemap.ts', out)
console.log(`輪 ${paths.length} 本 / パス ${d.length} 文字 → lib/map/basemap.ts`)
