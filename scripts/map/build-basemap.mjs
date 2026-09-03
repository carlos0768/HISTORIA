/**
 * 世界地図の基図を作る
 *
 *   node scripts/map/build-basemap.mjs
 *
 * 意匠は docs/design/litverse-map.css（作者提供の Litverse Map System v3）に従う。
 * 図法・経緯線の刻み・国境の描き方・極小国のピンは、同システムの実装に合わせてある。
 *
 * 出典: Natural Earth（パブリックドメイン）。
 * npm の world-atlas が TopoJSON として再配布しているものを使う。
 * Natural Earth は「使用許諾を求める必要がない」と明示しているため、
 * docs/10 §2 の第三者著作物のリスクに当たらない。
 *
 * ★ 設計系は d3 と地図データを CDN から実行時に取る作りだが、こちらは
 *   **ビルド時に d3 で投影してパス文字列だけを出す**。
 *   proxy.ts の CSP（script-src / connect-src を絞っている）を広げずに済み、
 *   配信先が落ちても地図が消えない。実行時の d3 依存はゼロである。
 *
 * ★ 極小国（マルタ・バーレーン・ルクセンブルク等）は 110m の基図に存在しない。
 *   10m から面積で拾い、重心に点を打つ（.lv-map__pin--micro）。
 *   これは設計系 v3 が加えた対処である。
 */
import { readFileSync, writeFileSync } from 'node:fs'
import { feature, mesh } from 'topojson-client'
import { geoNaturalEarth1, geoPath, geoGraticule, geoArea, geoCentroid } from 'd3-geo'

/**
 * ★ 解像度を引数で選べるようにした（2026-09-02）。
 *
 *   node scripts/map/build-basemap.mjs        … 110m を lib/map/basemap.ts へ
 *   node scripts/map/build-basemap.mjs 50m    … 50m を lib/map/basemap-50m.ts へ
 *
 * ★ **既定は 110m のまま。** 50m は数倍の大きさになるので、
 *   モバイルが毎回読む lib/map/basemap.ts には入れない。
 *   50m はデスクトップの地図ワークスペース（app/map）が動的 import で読む。
 *   docs/06 の「初回転送量を増やさない」はこの分離で守る。
 */
const RES = process.argv[2] === '50m' ? '50m' : '110m'
const HI = RES === '50m'

// 拡大して見るための図なので、50m は基準の寸法も大きく取る。
// 縦横比（660:340）は 110m と同じにして、CSS と地域の対応表をそのまま使えるようにする
const W = HI ? 1320 : 660, H = HI ? 680 : 340
const PAD = [[10, 12], [W - 10, H - 12]]

const topo = JSON.parse(readFileSync(`node_modules/world-atlas/countries-${RES}.json`, 'utf8'))
const countries = feature(topo, topo.objects.countries)
const proj = geoNaturalEarth1().fitExtent(PAD, { type: 'Sphere' })
const path = geoPath(proj)

// 間引きの強さ。50m は拡大して見るので、110m ほど落とせない
const STEP = HI ? 0.25 : 0.35
const RING = HI ? 0.4 : 0.5

/**
 * 投影後の座標で間引く。660×340 で見えない差は落とす。
 * minStep: 直前の点からこれ未満しか動かない点を落とす（px）
 * minRing: これより小さい輪を落とす（px）。0 なら落とさない
 */
function simplify(d, minStep, minRing) {
  const out = []
  for (const sub of d.split('M').filter(Boolean)) {
    const closed = sub.endsWith('Z')
    const pts = sub.replace(/Z$/, '').split('L').map(s => s.split(',').map(Number))
    if (pts.some(p => !isFinite(p[0]) || !isFinite(p[1]))) continue
    if (minRing > 0) {
      const xs = pts.map(p => p[0]), ys = pts.map(p => p[1])
      if (Math.max(...xs) - Math.min(...xs) < minRing && Math.max(...ys) - Math.min(...ys) < minRing) continue
    }
    const kept = [pts[0]]
    for (const p of pts.slice(1)) {
      const q = kept[kept.length - 1]
      if (Math.hypot(p[0] - q[0], p[1] - q[1]) >= minStep) kept.push(p)
    }
    if (kept.length < 3) continue
    const s = kept.map(([a, b]) => `${Math.round(a * 10) / 10},${Math.round(b * 10) / 10}`)
      .filter((v, i, a) => v !== a[i - 1]).join('L')
    out.push('M' + s + (closed ? 'Z' : ''))
  }
  return out.join('')
}

// ---- 国土 ----
const paths = {}, names = {}
for (const f of countries.features) {
  const d = path(f)
  if (!d) continue
  const s = simplify(d, STEP, RING)
  if (!s) continue
  paths[String(f.id)] = s
  names[String(f.id)] = f.properties.name
}

// ---- 国境（共有辺のみ。海岸線は国土の stroke が描く）----
const borders = simplify(path(mesh(topo, topo.objects.countries, (a, b) => a !== b)) ?? '', STEP, 0)

// ---- 経緯線・球の輪郭 ----
// 経緯線は背景なので強めに間引く。曲線がわずかに角張っても読めれば足りる
const graticule = simplify(path(geoGraticule().step([20, 20])()) ?? '', HI ? 1.5 : 2.5, 0)
const sphere = path({ type: 'Sphere' }) ?? ''

// ---- 極小国：110m に無いものを 10m から拾い、重心に点を打つ ----
const hiTopo = JSON.parse(readFileSync('node_modules/world-atlas/countries-10m.json', 'utf8'))
const hi = feature(hiTopo, hiTopo.objects.countries)
const micro = []
for (const f of hi.features) {
  if (geoArea(f) >= 4e-5) continue          // 設計系 v3 と同じ閾値
  if (paths[String(f.id)]) continue          // 110m で描けているものは点にしない
  const c = geoCentroid(f)
  if (!c || !isFinite(c[0]) || !isFinite(c[1])) continue
  const p = proj(c)
  if (!p || !isFinite(p[0]) || !isFinite(p[1])) continue
  micro.push({ id: String(f.id), name: f.properties.name, x: Math.round(p[0] * 10) / 10, y: Math.round(p[1] * 10) / 10 })
}
micro.sort((a, b) => a.id.localeCompare(b.id))
for (const m of micro) names[m.id] = m.name

const kb = n => (n / 1024).toFixed(0)
const landBytes = Object.values(paths).reduce((n, d) => n + d.length, 0)

const out = `/**
 * 世界地図の基図（自動生成）
 *
 * ★ 手で編集しない。scripts/map/build-basemap.mjs が作る。
 *
 * 出典: Natural Earth（パブリックドメイン）。国土と国境は 1:${RES}、
 *       極小国の位置は 1:10m。
 * 図法: Natural Earth 1（d3.geoNaturalEarth1）をビルド時に適用済み。
 *       実行時の d3 依存は無い。
 * 用途: 学習用の模式図であり、正確な国境や領域を示すものではない。
 */
export const MAP_VIEWBOX = '0 0 ${W} ${H}' as const
export const MAP_WIDTH = ${W}
export const MAP_HEIGHT = ${H}

/** 球の輪郭（.lv-map__sphere） */
export const SPHERE_PATH = '${sphere}'
/** 経緯線 20度ごと（.lv-map__graticule） */
export const GRATICULE_PATH = '${graticule}'
/** 国境。共有辺のみ（.lv-map__border） */
export const BORDERS_PATH = '${borders}'

/** ISO 3166-1 の数値コード → 国土のパス（.lv-map__land） */
export const COUNTRY_PATHS: Readonly<Record<string, string>> = ${JSON.stringify(paths)}

/**
 * 110m の基図に入らない極小国。重心に点で示す（.lv-map__pin--micro）。
 * マルタ・バーレーン・ルクセンブルク・シンガポールなど。
 */
export const MICRO_PINS: ReadonlyArray<{ id: string; x: number; y: number }> =
  ${JSON.stringify(micro.map(({ id, x, y }) => ({ id, x, y })))}

/** 数値コード → 英語名。地域の対応表を作るときの確認に使う */
export const COUNTRY_NAMES: Readonly<Record<string, string>> = ${JSON.stringify(names)}
`
const target = HI ? 'lib/map/basemap-50m.ts' : 'lib/map/basemap.ts'
writeFileSync(target, out)
console.log(`${target}（${RES} / ${W}×${H}）`)
console.log(
  `国 ${Object.keys(paths).length}（陸 ${kb(landBytes)}KB / 国境 ${kb(borders.length)}KB / ` +
  `経緯線 ${kb(graticule.length)}KB）＋ 極小国の点 ${micro.length}`,
)
console.log('点で示す国:', micro.slice(0, 14).map(m => m.name).join(', ') + (micro.length > 14 ? ' …' : ''))
