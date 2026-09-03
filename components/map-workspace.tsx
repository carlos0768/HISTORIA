'use client'

import { useEffect, useRef, useState, type PointerEvent as ReactPointerEvent } from 'react'
import { regionShape } from '@/lib/map/regions'

/**
 * 地図ワークスペース（docs/06-desktop.md 04）
 *
 * ★ `components/world-map.tsx` は**触らない**。あちらは静止 SVG・イベント0件で、
 *   教材の本文に埋まっている。パン・ズームを足すとモバイルの読書に
 *   影響が出るので、拡大して見るための版はここに別に作る。
 *
 * ★ 実行時に d3 も Leaflet も持ちこまない（CSP を広げない）。
 *   パンとズームは `viewBox` を自前で動かすだけである。
 *   基図はビルド時に投影済みのパス文字列で、実行時の地理計算はゼロ。
 *
 * ★ 50m の基図は約1MB ある。**この部品を開いたときだけ**読む
 *   （app/map/page.tsx が動的 import する）。モバイルの初回転送量は増えない。
 *
 * ★ PNG の書き出しは**地図に限る**。docs/10 G4 は過去問のダウンロード導線を
 *   禁じており、汎用の「この画面を画像で保存」を作るとそこに触れる。
 */

export type Basemap = {
  MAP_VIEWBOX: string
  MAP_WIDTH: number
  MAP_HEIGHT: number
  SPHERE_PATH: string
  GRATICULE_PATH: string
  BORDERS_PATH: string
  COUNTRY_PATHS: Readonly<Record<string, string>>
  MICRO_PINS: ReadonlyArray<{ id: string; x: number; y: number }>
}

/** 拡大の範囲。1 = 全体。これ以上寄っても基図の解像度が追いつかない */
export const MIN_ZOOM = 1
export const MAX_ZOOM = 8
const STEP = 1.4

export type View = { x: number; y: number; z: number }

/**
 * 表示範囲を地図の内側に留める。
 *
 * ★ これが無いと、勢いよくドラッグしたときに地図が画面外へ出て、
 *   真っ白な面だけが残る（戻し方が分からなくなる）。
 */
export function clampView(v: View, w: number, h: number): View {
  const z = Math.min(MAX_ZOOM, Math.max(MIN_ZOOM, v.z))
  const vw = w / z, vh = h / z
  return {
    z,
    x: Math.min(w - vw, Math.max(0, v.x)),
    y: Math.min(h - vh, Math.max(0, v.y)),
  }
}

/** ある点を軸にして拡大縮小する（その点が画面上で動かないようにする） */
export function zoomAt(v: View, w: number, h: number, factor: number, fx: number, fy: number): View {
  const z = Math.min(MAX_ZOOM, Math.max(MIN_ZOOM, v.z * factor))
  // 拡大前に fx,fy が指していた地図上の点
  const px = v.x + (w / v.z) * fx
  const py = v.y + (h / v.z) * fy
  return clampView({ z, x: px - (w / z) * fx, y: py - (h / z) * fy }, w, h)
}

export type Layers = { graticule: boolean; borders: boolean; regions: boolean }

export function MapWorkspace({
  basemap, regionIds = [], title,
}: {
  basemap: Basemap
  /** 塗る地域。lib/map/regions.ts の id */
  regionIds?: readonly number[]
  title: string
}) {
  const { MAP_WIDTH: W, MAP_HEIGHT: H } = basemap
  const [view, setView] = useState<View>({ x: 0, y: 0, z: 1 })
  const [layers, setLayers] = useState<Layers>({ graticule: true, borders: true, regions: true })
  const [dragging, setDragging] = useState(false)
  const drag = useRef<{ x: number; y: number; view: View } | null>(null)
  const svgRef = useRef<SVGSVGElement>(null)

  const shapes = regionIds.map(regionShape).filter(s => s !== undefined)
  const hasChild = shapes.some(s => !s.isParent)
  const drawn = shapes.filter(s => !s.isParent || !hasChild)
  const marked = new Set(drawn.flatMap(s => s.countries))

  const onPointerDown = (e: ReactPointerEvent<SVGSVGElement>) => {
    e.currentTarget.setPointerCapture(e.pointerId)
    drag.current = { x: e.clientX, y: e.clientY, view }
    setDragging(true)
  }
  const onPointerMove = (e: ReactPointerEvent<SVGSVGElement>) => {
    const d = drag.current
    if (!d) return
    const rect = e.currentTarget.getBoundingClientRect()
    // 画面上の移動量を、いまの縮尺での地図座標へ直す
    const dx = ((e.clientX - d.x) / rect.width) * (W / d.view.z)
    const dy = ((e.clientY - d.y) / rect.height) * (H / d.view.z)
    setView(clampView({ ...d.view, x: d.view.x - dx, y: d.view.y - dy }, W, H))
  }
  const endDrag = () => { drag.current = null; setDragging(false) }

  /**
   * ★ ホイールは `passive: false` で自前に付ける。
   *   React の onWheel は passive で登録されるので preventDefault が効かず、
   *   拡大しながら画面ごとスクロールしてしまう。
   */
  useEffect(() => {
    const el = svgRef.current
    if (!el) return
    const onWheel = (e: WheelEvent) => {
      e.preventDefault()
      const rect = el.getBoundingClientRect()
      const fx = (e.clientX - rect.left) / rect.width
      const fy = (e.clientY - rect.top) / rect.height
      setView(v => zoomAt(v, W, H, e.deltaY < 0 ? STEP : 1 / STEP, fx, fy))
    }
    el.addEventListener('wheel', onWheel, { passive: false })
    return () => el.removeEventListener('wheel', onWheel)
  }, [W, H])

  const zoom = (factor: number) => setView(v => zoomAt(v, W, H, factor, 0.5, 0.5))
  const reset = () => setView({ x: 0, y: 0, z: 1 })

  const vb = `${view.x} ${view.y} ${W / view.z} ${H / view.z}`

  return (
    <div className="hs-mapws">
      <div className="hs-mapws__bar">
        <button type="button" className="lv-btn" onClick={() => zoom(STEP)} aria-label="拡大">＋</button>
        <button type="button" className="lv-btn" onClick={() => zoom(1 / STEP)} aria-label="縮小">−</button>
        <button type="button" className="lv-btn" onClick={reset}>全体</button>
        <span className="hs-mapws__zoom">{view.z.toFixed(1)}倍</span>
        {(['graticule', 'borders', 'regions'] as const).map(k => (
          <label key={k} className="lv-caption">
            <input type="checkbox" checked={layers[k]}
                   onChange={e => setLayers(l => ({ ...l, [k]: e.target.checked }))} />
            {' '}{k === 'graticule' ? '経緯線' : k === 'borders' ? '国境' : '地域'}
          </label>
        ))}
        <button type="button" className="lv-btn"
                onClick={() => exportPng(svgRef.current, W, H, title)}>
          PNG で保存
        </button>
      </div>

      <div className={`hs-mapws__stage${dragging ? ' hs-mapws__stage--dragging' : ''}`}>
        <svg
          ref={svgRef} viewBox={vb} className="lv-map"
          role="img" aria-label={`${title}。ドラッグで移動、ホイールで拡大縮小できます`}
          onPointerDown={onPointerDown} onPointerMove={onPointerMove}
          onPointerUp={endDrag} onPointerCancel={endDrag}
        >
          <path className="lv-map__sphere" d={basemap.SPHERE_PATH} />
          {layers.graticule && <path className="lv-map__graticule" d={basemap.GRATICULE_PATH} />}
          <g>
            {Object.entries(basemap.COUNTRY_PATHS).map(([code, d]) => (
              <path key={code} d={d}
                    className={layers.regions && marked.has(code)
                      ? 'lv-map__land lv-map__land--highlight' : 'lv-map__land'} />
            ))}
          </g>
          {layers.borders && <path className="lv-map__border" d={basemap.BORDERS_PATH} />}
          {basemap.MICRO_PINS.map(p => (
            <circle key={p.id} className="lv-map__pin lv-map__pin--micro"
                    cx={p.x} cy={p.y} r={1.6} />
          ))}
        </svg>
      </div>

      <p className="lv-caption">
        出典: Natural Earth（パブリックドメイン）。学習用の模式図であり、
        正確な国境や領域を示すものではありません。
      </p>
    </div>
  )
}

/**
 * いまの表示を PNG で保存する。
 *
 * ★ 外部ライブラリを使わない。SVG を文字列にして data URI 経由で
 *   canvas に描き、`toBlob` する。CSP は `img-src 'self' data:` を既に許している。
 *
 * ★ 失敗しても何も壊さない。書き出しは付加的な機能である。
 */
async function exportPng(svg: SVGSVGElement | null, w: number, h: number, title: string) {
  if (!svg) return
  try {
    const clone = svg.cloneNode(true) as SVGSVGElement
    // ★ 画面の CSS は canvas に載らないので、色を属性として焼きこむ
    const style = getComputedStyle(svg)
    clone.setAttribute('xmlns', 'http://www.w3.org/2000/svg')
    clone.setAttribute('width', String(w * 2))
    clone.setAttribute('height', String(h * 2))
    for (const el of Array.from(clone.querySelectorAll<SVGElement>('*'))) {
      const src = svg.querySelector(`[d="${el.getAttribute('d')}"]`) ?? el
      const cs = getComputedStyle(src as Element)
      el.setAttribute('fill', cs.fill || 'none')
      el.setAttribute('stroke', cs.stroke || 'none')
      el.setAttribute('stroke-width', cs.strokeWidth || '0')
    }
    const bg = style.backgroundColor || '#FCF6E8'
    const xml = new XMLSerializer().serializeToString(clone)
    const url = `data:image/svg+xml;charset=utf-8,${encodeURIComponent(xml)}`

    const img = new Image()
    await new Promise<void>((ok, ng) => {
      img.onload = () => ok()
      img.onerror = () => ng(new Error('画像にできませんでした'))
      img.src = url
    })
    const canvas = document.createElement('canvas')
    canvas.width = w * 2; canvas.height = h * 2
    const ctx = canvas.getContext('2d')
    if (!ctx) return
    ctx.fillStyle = bg
    ctx.fillRect(0, 0, canvas.width, canvas.height)
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height)
    const blob = await new Promise<Blob | null>(r => canvas.toBlob(r, 'image/png'))
    if (!blob) return
    const a = document.createElement('a')
    a.href = URL.createObjectURL(blob)
    a.download = `${title}.png`
    a.click()
    URL.revokeObjectURL(a.href)
  } catch { /* 書き出しは付加的な機能。失敗しても画面は壊さない */ }
}
