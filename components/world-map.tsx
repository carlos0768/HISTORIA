/**
 * 学習用の世界地図
 *
 * 意匠は docs/design/litverse-map.css（作者提供の Litverse Map System）に従う。
 * ここで新しい意匠を定義しない。クラス名も同システムのものをそのまま使う。
 *
 * ★ タイル地図（Leaflet + OSM）の側は採っていない。
 *   proxy.ts の CSP が img-src / connect-src を 'self' に絞っているため、
 *   タイルを引くには CSP を広げることになる。SVG 側だけで足りる。
 * ★ 基図は Natural Earth（パブリックドメイン）から自前で作って埋め込む。
 *   実行時に外部へ取りに行かない（docs/10 §2 の第三者著作物のリスクを避ける）。
 * ★ これは模式図である。現在の国境で歴史上の地域を近似しているにすぎない。
 */
import {
  COUNTRY_PATHS, GRATICULE_PATH, EQUATOR_PATH, MAP_VIEWBOX,
} from '@/lib/map/basemap'
import { regionShape } from '@/lib/map/regions'

export type WorldMapProps = {
  /** 強調する地域の id（seed/region.csv の id） */
  highlight: number[]
  /** 図の題。何を示している地図なのかを書く */
  title?: string
}

export function WorldMap({ highlight, title }: WorldMapProps) {
  const shapes = highlight.map(regionShape).filter(s => s !== undefined)
  if (shapes.length === 0) return null

  // 親地域（ヨーロッパ等）は子を含む和集合なので、子が同時に指定されていたら出さない。
  // 二重に塗ると、どちらが答えなのか分からなくなる
  const hasChild = shapes.some(s => !s.isParent)
  const drawn = shapes.filter(s => !s.isParent || !hasChild)

  // 国 → その国を含む最初の地域。重なったときは先に指定された地域を優先する
  const owner = new Map<string, number>()
  drawn.forEach((s, i) => {
    for (const c of s.countries) if (!owner.has(c)) owner.set(c, i)
  })

  return (
    <figure className="lv-map">
      <svg
        viewBox={MAP_VIEWBOX}
        role="img"
        aria-label={`世界地図。${drawn.map(s => s.label).join('、')}を示しています`}
      >
        <rect className="lv-map__sea" x="0" y="0" width="100%" height="100%" />
        <path className="lv-map__graticule" d={GRATICULE_PATH} />
        <path className="lv-map__graticule" d={EQUATOR_PATH} />

        {Object.entries(COUNTRY_PATHS).map(([code, d]) => {
          const at = owner.get(code)
          return (
            <path
              key={code}
              d={d}
              className={
                at === undefined ? 'lv-map__land'
                : at === 0 ? 'lv-map__land lv-map__land--highlight'
                : 'lv-map__land lv-map__land--select'
              }
            />
          )
        })}
      </svg>

      <figcaption className="lv-map__caption">
        <span className="lv-map__title">{title ?? '関係する地域'}</span>
        <span>模式図です。現在の国境で近似しており、当時の版図ではありません。</span>
      </figcaption>

      {/* 凡例。塗りと地域名を対応させる。図に地名を載せると隣接地域で必ず重なる */}
      <div className="lv-map__legend">
        {drawn.map((s, i) => (
          <span className="lv-map__key" key={s.id}>
            <span
              className="lv-map__swatch"
              style={{ background: i === 0 ? 'var(--lv-map-highlight)' : 'var(--lv-map-select)' }}
            />
            {s.label}
          </span>
        ))}
      </div>
    </figure>
  )
}
