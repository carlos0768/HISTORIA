/**
 * 学習用の世界地図
 *
 * 仕様の背景: geo の KC（位置・版図）は地図が無いとテキスト問題に落ちる。
 * docs/10 §2 は第三者の地図を権利リスクとして挙げているので、
 * 基図は Natural Earth（パブリックドメイン）から自前で作ったものを埋め込む。
 * 実行時に外部から取りに行かない（CSP を広げずに済む）。
 *
 * ★ これは模式図である。正確な国境や歴史上の版図を示すものではない。
 *   地域の枠は lib/map/regions.ts の暫定値であり、デザイン確定後に差し替える。
 */
import { LAND_PATH, MAP_VIEWBOX, project } from '@/lib/map/basemap'
import { regionShape } from '@/lib/map/regions'

export type WorldMapProps = {
  /** 強調する地域の id（seed/region.csv の id） */
  highlight: number[]
  /** 図の下に出す説明。何を示している地図なのかを必ず書く */
  caption?: string
}

export function WorldMap({ highlight, caption }: WorldMapProps) {
  const shapes = highlight.map(regionShape).filter(s => s !== undefined)
  if (shapes.length === 0) return null

  // 親地域（ヨーロッパ等）は子を含む大枠なので、子が同時に指定されていたら出さない。
  // 二重の枠が重なって、どちらが答えなのか分からなくなる
  const childIds = new Set(shapes.filter(s => !s.isParent).map(s => s.id))
  const drawn = shapes.filter(s => !s.isParent || childIds.size === 0)

  return (
    <figure className="hs-map">
      <svg
        viewBox={MAP_VIEWBOX}
        className="hs-map__svg"
        role="img"
        aria-label={`世界地図。${drawn.map(s => s.label).join('、')}を示しています`}
      >
        <path d={LAND_PATH} className="hs-map__land" />
        {drawn.map((s, i) => {
          const a = project(s.box[0], s.box[3])
          const b = project(s.box[2], s.box[1])
          return (
            <g key={s.id}>
              <rect
                x={a.x} y={a.y} width={Math.max(2, b.x - a.x)} height={Math.max(2, b.y - a.y)}
                className="hs-map__zone" rx="1.5"
              />
              {/* 地名を図に載せない。隣り合う地域では必ず重なって読めなくなる。
                  番号だけ振って、下の凡例で受ける */}
              <circle cx={a.x + 4} cy={a.y + 4} r="3.4" className="hs-map__pin" />
              <text x={a.x + 4} y={a.y + 5.7} className="hs-map__pinnum">{i + 1}</text>
            </g>
          )
        })}
      </svg>
      <figcaption className="hs-map__cap">
        <ol className="hs-map__legend">
          {drawn.map((s, i) => (
            <li key={s.id}><span className="hs-map__key">{i + 1}</span>{s.label}</li>
          ))}
        </ol>
        {caption && <span>{caption}</span>}
        <span className="hs-map__note">
          模式図です。おおよその位置を示すもので、正確な国境・版図ではありません。
        </span>
      </figcaption>
    </figure>
  )
}
