/**
 * 学習用の世界地図
 *
 * 意匠は docs/design/litverse-map.css（作者提供の Litverse Map System v3）に従う。
 * ここで新しい意匠を定義しない。クラス名も同システムのものをそのまま使う。
 *
 * ★ タイル地図（Leaflet + OSM）の側は採っていない。
 *   proxy.ts の CSP が img-src / connect-src を 'self' に絞っているため、
 *   タイルを引くには CSP を広げることになる。SVG 側だけで足りる。
 * ★ 投影は d3 でビルド時に済ませてある（scripts/map/build-basemap.mjs）。
 *   実行時に d3 も地図データも取りに行かない。
 * ★ これは模式図である。現在の国境で歴史上の地域を近似しているにすぎない。
 */
import {
  COUNTRY_PATHS, MICRO_PINS, SPHERE_PATH, GRATICULE_PATH, BORDERS_PATH, MAP_VIEWBOX,
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

  // 国 → その国を最初に含む地域の順番。重なったときは先に指定された地域を優先する
  const rank = new Map<string, number>()
  drawn.forEach((s, i) => {
    for (const c of s.countries) if (!rank.has(c)) rank.set(c, i)
  })
  const landClass = (code: string) => {
    const at = rank.get(code)
    return at === undefined ? 'lv-map__land'
      : at === 0 ? 'lv-map__land lv-map__land--highlight'
      : 'lv-map__land lv-map__land--select'
  }

  return (
    <figure className="lv-map">
      <svg
        viewBox={MAP_VIEWBOX}
        role="img"
        aria-label={`世界地図。${drawn.map(s => s.label).join('、')}を示しています`}
      >
        <path className="lv-map__sphere" d={SPHERE_PATH} />
        <path className="lv-map__graticule" d={GRATICULE_PATH} />

        {Object.entries(COUNTRY_PATHS).map(([code, d]) => (
          <path key={code} d={d} className={landClass(code)} />
        ))}

        {/* 国境は共有辺だけ。海岸線は国土の stroke が描いている */}
        <path className="lv-map__border" d={BORDERS_PATH} />

        {/* 110m の国土で描けない極小国（マルタ・バーレーン等）は点で示す */}
        <g className="lv-map__micro">
          {MICRO_PINS.map(p => (
            <circle
              key={p.id}
              cx={p.x} cy={p.y} r={1.9}
              className={`lv-map__pin lv-map__pin--micro${rank.has(p.id) ? ' lv-map__pin--hot' : ''}`}
            />
          ))}
        </g>
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
