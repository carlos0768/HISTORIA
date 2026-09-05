'use client'

/**
 * 版図の再生（docs/11-ux.md §4.1）
 *
 * 国家の版図を、年代順のスナップショットで地図に塗る。
 * 再生ボタンで段階を順に流し、**前の段階から失った領域**を別の色で示す。
 * 版図が縮んでいく過程（オスマン帝国の 1683 → 1923 等）が目で追える。
 *
 * ★ 基図は lib/map/basemap.ts（110m・約80KB）。地域の地図（world-map.tsx）と同じ。
 *   実行時に地図データも d3 も取りに行かない（CSP を広げない）。
 * ★ `geo` の付いた段階は historical-basemaps の境界ポリゴン（lib/map/territory-geo/）で塗る。
 *   国家ごとに別 chunk で、開いたときだけ動的 import する。無い段階は現在の国で近似し、そう書く。
 * ★ 再生は setInterval で段階を進めるだけ。自動で最後まで行ったら止まる。
 */
import { useEffect, useState } from 'react'
import {
  COUNTRY_PATHS, MICRO_PINS, SPHERE_PATH, GRATICULE_PATH, BORDERS_PATH, MAP_VIEWBOX, COUNTRY_NAMES,
} from '@/lib/map/basemap'
import { diffSnapshots, type Polity, type TerritorySnapshot } from '@/lib/map/territories'
import type { PolityMatch } from '@/lib/loop/territory-search'
import { formatYear } from '@/lib/loop/timeline'
// ★ 一覧（index.ts）だけを静的に読む。国家ごとの境界データは index.ts が動的 import する
import { TERRITORY_GEO } from '@/lib/map/territory-geo'
import { TERRITORY_GEO_SOURCE } from '@/lib/map/territory-geo/attribution'
import type { TerritoryPaths } from '@/lib/map/territory-geo/types'

/** 1段階あたりの表示時間。読める長さと、10段階でも待たされない長さの間 */
export const STEP_MS = 1600

const nameOf = (code: string) => COUNTRY_NAMES[code] ?? code

const PRECISION_LABEL: Record<number, string> = { 1: '概略', 2: '中程度', 3: '国際法で確定' }

/** 境界データの読み込み状態。none = この国家には境界データが無い */
type GeoState = { status: 'none' | 'loading' | 'ready' | 'failed'; paths: TerritoryPaths | null }

export function TerritoryPlayer({ polity }: { polity: Polity }) {
  const snaps = polity.snapshots
  const [i, setI] = useState(0)
  const [playing, setPlaying] = useState(false)
  const hasGeo = snaps.some(s => s.geo)
  const [geo, setGeo] = useState<GeoState>({ status: hasGeo ? 'loading' : 'none', paths: null })

  /**
   * 境界データは国家ごとに別 chunk。開いた国家の分だけ読む（app/map/loader.tsx と同じ形）。
   * 読み込み中と失敗時は countries による国塗りで描き続ける（表示が消えない・ずれない）。
   */
  useEffect(() => {
    const load = TERRITORY_GEO[polity.id]
    if (!hasGeo || !load) return
    let live = true
    load()
      .then(m => { if (live) setGeo({ status: 'ready', paths: m.TERRITORY_PATHS }) })
      .catch(() => { if (live) setGeo({ status: 'failed', paths: null }) })
    return () => { live = false }
  }, [polity.id, hasGeo])

  // 再生。最後の段階に着いたら止まる（繰り返さない。滅亡の後に建国が来ると混乱する）
  useEffect(() => {
    if (!playing) return
    const t = window.setInterval(() => {
      setI(cur => {
        if (cur >= snaps.length - 1) { setPlaying(false); return cur }
        return cur + 1
      })
    }, STEP_MS)
    return () => window.clearInterval(t)
  }, [playing, snaps.length])

  const cur = snaps[i]!
  const prev = i > 0 ? snaps[i - 1]! : null
  const { gained, lost } = diffSnapshots(prev, cur)
  const now = new Set(cur.countries)
  const lostSet = new Set(lost)
  // この段階と前の段階の境界パス。無ければ国塗りに落ちる
  const pathOf = (s: TerritorySnapshot | null) =>
    s?.geo && geo.paths ? geo.paths[s.geo.year] ?? null : null
  const curGeo = pathOf(cur)
  const prevGeo = pathOf(prev)
  const landClass = (code: string) =>
    curGeo ? 'lv-map__land'   // 境界データで塗るときは国は塗らない（二重に塗ると境界が読めない）
    : now.has(code) ? 'lv-map__land lv-map__land--highlight'
    : lostSet.has(code) ? 'lv-map__land lv-map__land--select'
    : 'lv-map__land'

  const play = () => {
    // 最後で押されたら最初から流す
    if (i >= snaps.length - 1) setI(0)
    setPlaying(true)
  }

  return (
    <div className="hs-territory">
      <div className="hs-titlerow">
        <span className="lv-label">版図: {polity.label}</span>
        <span className="lv-caption">{i + 1} / {snaps.length}</span>
      </div>

      <figure className="lv-map">
        <svg viewBox={MAP_VIEWBOX} role="img"
             aria-label={`${polity.label}の版図。${formatYear(cur.year)}年、${cur.label}。${cur.countries.length}か国分の領域`}>
          <path className="lv-map__sphere" d={SPHERE_PATH} />
          <path className="lv-map__graticule" d={GRATICULE_PATH} />
          {Object.entries(COUNTRY_PATHS).map(([code, d]) => (
            <path key={code} d={d} className={landClass(code)} />
          ))}
          {/* 境界データ。失った領域（前の段階の形）を下に、この段階の形を上に。国境はさらに上から描く */}
          {curGeo && prevGeo && <path className="lv-map__territory lv-map__territory--lost" d={prevGeo.d} />}
          {curGeo && <path className="lv-map__territory" d={curGeo.d} />}
          <path className="lv-map__border" d={BORDERS_PATH} />
          <g className="lv-map__micro">
            {MICRO_PINS.map(p => (
              <circle key={p.id} cx={p.x} cy={p.y} r={1.9}
                      className={`lv-map__pin lv-map__pin--micro${!curGeo && now.has(p.id) ? ' lv-map__pin--hot' : ''}`} />
            ))}
          </g>
        </svg>
        <figcaption className="lv-map__caption">
          <span className="lv-map__title">{formatYear(cur.year)}年 — {cur.label}</span>
          {curGeo ? (
            <span>
              境界は {TERRITORY_GEO_SOURCE.name} の {formatYear(cur.geo!.year)} 年の図で {formatYear(cur.year)} 年を代用しています。
              境界の精度: {PRECISION_LABEL[curGeo.precision] ?? curGeo.precision}。
              {prev && !prevGeo && '前の段階は現在の国で近似しているため、失った領域は示しません。'}
              {cur.note && `（${cur.note}）`}
            </span>
          ) : (
            <span>模式図です。現在の国境で当時の版図を近似しており、境界線は正確ではありません。{cur.note && `（${cur.note}）`}</span>
          )}
          {hasGeo && (
            <span>
              出典: {TERRITORY_GEO_SOURCE.name}（{TERRITORY_GEO_SOURCE.author}、{TERRITORY_GEO_SOURCE.license}）の境界データを加工。
              加工後のデータも {TERRITORY_GEO_SOURCE.license} で再配布します。基図: Natural Earth（パブリックドメイン）。
            </span>
          )}
        </figcaption>
        <div className="lv-map__legend">
          <span className="lv-map__key"><span className="lv-map__swatch" style={{ background: 'var(--lv-map-highlight)' }} />この段階の版図{curGeo && '（境界データ）'}</span>
          <span className="lv-map__key"><span className="lv-map__swatch" style={{ background: 'var(--lv-map-select)' }} />前の段階から失った領域</span>
        </div>
      </figure>
      {geo.status === 'loading' && <p className="lv-caption">境界線を読み込んでいます…（先に現在の国で近似して示しています）</p>}
      {geo.status === 'failed' && <p className="lv-caption">境界線を読み込めなかったため、現在の国で近似して示しています。</p>}

      <div className="hs-territory__bar">
        <button type="button" className="lv-btn" onClick={() => { setPlaying(false); setI(Math.max(0, i - 1)) }}
                disabled={i === 0} aria-label="前の段階">◀</button>
        {playing ? (
          <button type="button" className="lv-btn lv-btn--primary" onClick={() => setPlaying(false)}>■ 停止</button>
        ) : (
          <button type="button" className="lv-btn lv-btn--primary" onClick={play}>▶ 再生</button>
        )}
        <button type="button" className="lv-btn" onClick={() => { setPlaying(false); setI(Math.min(snaps.length - 1, i + 1)) }}
                disabled={i >= snaps.length - 1} aria-label="次の段階">▶|</button>
        <input type="range" min={0} max={snaps.length - 1} value={i} aria-label="段階"
               className="hs-territory__range"
               onChange={e => { setPlaying(false); setI(Number(e.target.value)) }} />
      </div>

      {/* 段階の一覧。押せば飛べる。いまの段階を強調する */}
      <div className="hs-territory__steps">
        {snaps.map((s, k) => (
          <button key={s.year + s.label} type="button"
                  className={`hs-territory__step${k === i ? ' hs-territory__step--active' : ''}`}
                  aria-current={k === i ? 'step' : undefined}
                  onClick={() => { setPlaying(false); setI(k) }}>
            <span className="hs-timeline__year">{formatYear(s.year)}</span>
            <span className="hs-timeline__label">{s.label}{s.countries.length === 0 && '（版図なし）'}</span>
          </button>
        ))}
      </div>

      {/* 前の段階との差。失った領域を先に書く（縮小の過程を追うための画面）。
           境界データで塗っているときは、国単位の近似であることを添える（図と矛盾させない） */}
      {prev && (lost.length > 0 || gained.length > 0) && (
        <p className="lv-caption">
          {curGeo && '国単位の近似: '}
          {lost.length > 0 && <>失った領域: {lost.map(nameOf).join('、')}。</>}
          {gained.length > 0 && <>{lost.length > 0 ? ' ' : ''}得た領域: {gained.map(nameOf).join('、')}。</>}
        </p>
      )}
    </div>
  )
}

/**
 * 主と候補。先頭（最も近いもの）を出し、他は候補として並べて切り替えられる。
 * ★ どれくらい近いかを隠さない（「語が一致」か「近さ ◯%」）。
 */
export function TerritoryPanel({ items }: { items: ReadonlyArray<{ polity: Polity; match: PolityMatch }> }) {
  const [id, setId] = useState(items[0]?.polity.id ?? '')
  const cur = items.find(x => x.polity.id === id) ?? items[0]
  if (!cur) return null
  const how = (m: PolityMatch) =>
    m.textMatch ? '語が一致' : m.similarity !== null ? `近さ ${Math.round(m.similarity * 100)}%` : ''
  return (
    <div className="hs-stack">
      {items.length > 1 && (
        <>
          <span className="lv-label">候補</span>
          <div className="lv-chips">
            {items.map(x => (
              <button key={x.polity.id} type="button"
                      className={`lv-chip${x.polity.id === cur.polity.id ? ' lv-chip--active' : ''}`}
                      onClick={() => setId(x.polity.id)}>
                {x.polity.label}{how(x.match) && `（${how(x.match)}）`}
              </button>
            ))}
          </div>
        </>
      )}
      {items.length === 1 && how(cur.match) && (
        <p className="lv-caption">{cur.polity.label}: {how(cur.match)}</p>
      )}
      <TerritoryPlayer key={cur.polity.id} polity={cur.polity} />
    </div>
  )
}
