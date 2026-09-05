'use client'

/**
 * 年表チャート（docs/11-ux.md §4.1）
 *
 * 検索で当たった項目を、横軸＝年・縦軸＝地域の格子に置く。
 * 添付の「世界史年表」（前3000年〜2000年を100年刻み、行が地域、上に時代区分）と同じ骨組みで、
 * **どの時代・どの地域か**が一目で分かることだけを目的にする。
 *
 * ★ 実行時に d3 も外部の描画ライブラリも持ちこまない（CSP を広げない）。
 *   位置の計算は lib/domain/periods.ts の純関数で、ここは SVG に写すだけである。
 * ★ 横軸は既定で**結果のある時代に合わせる**（lib/domain/periods.ts の adaptiveDomain）。
 *   近代の出来事ばかりなのに前3000年から描くと右端に固まって読めない。
 *   「全史の中のどこか」を見たいときは「全範囲を表示」で前3000〜2000に戻せる。
 *   上の時代区分の帯は、寄せた範囲でもその時代の名前が読めるように残す。
 * ★ 年代の無い項目はここには置かない。置けないものを 0 年に置くのは嘘になる。
 *   一覧の側で「年代なし」と出す。
 */
import { useMemo } from 'react'
import {
  PERIODS, CHART_MIN_YEAR, CHART_MAX_YEAR, adaptiveDomain, yearToX, centuryTicks, assignLanes,
  type Span,
} from '@/lib/domain/periods'
import { formatYear } from '@/lib/loop/timeline'
import { regionGroupId, regionLabel } from '@/lib/map/regions'

export type ChronoItem = {
  id: string
  label: string
  kind: 'kc' | 'event' | 'section'
  yearFrom: number
  yearTo: number | null
  /** century なら概数として点線で描く */
  precision: string | null
  /** 先頭が主地域。空なら「地域なし」の行に置く */
  regionIds: readonly number[]
}

/** 描画の寸法（viewBox 単位）。文字は 11 で固定し、狭い画面では横に流す。箱は文字が入る高さ */
export const CHART_WIDTH = 720
export const LABEL_COL = 96          // 左の地域名の列
const RIGHT_PAD = 8
const PERIOD_H = 20
const TICK_H = 18
const LANE_H = 22
const ROW_PAD = 6
const BAR_H = 16
const MIN_BAR_W = 5
const FONT = 11
/** 1文字の幅の見積り。日本語は全角（≒ FONT）、数字と記号はその半分 */
const textWidth = (s: string) =>
  [...s].reduce((w, ch) => w + (ch.charCodeAt(0) > 0xff ? FONT : FONT * 0.6), 0)

const NO_REGION = -1

export type Placed = ChronoItem & {
  /** 箱の左右。年の幅より文字が長ければ文字の分だけ広げる */
  x0: number; x1: number; lane: number
  /** 実際に描く文字。箱に入り切らなければ末尾を「…」で詰める */
  text: string
  /** 本当の年の位置。右端で箱をずらしたときだけ、ここに印を打つ */
  yearX: number | null
}
export type Row = { groupId: number; label: string; items: Placed[]; lanes: number; y: number; h: number }

/** 幅に収まるまで末尾を落として「…」を付ける。3文字も残せなければ空にする */
export function fitText(label: string, maxWidth: number): string {
  if (textWidth(label) <= maxWidth) return label
  const chars = [...label]
  for (let n = chars.length - 1; n >= 3; n--) {
    const t = chars.slice(0, n).join('') + '…'
    if (textWidth(t) <= maxWidth) return t
  }
  return ''
}

const PAD_X = 4

/**
 * 出来事の名前を**箱の中**に入れる（添付の年表と同じ見せ方）。
 *
 * 箱は年の幅（yearX0〜yearX1）を最低とし、文字が長ければ文字の分だけ右へ広げる。
 * 右端から出るなら箱ごと左へずらし、**本当の年の位置には印を残す**（ずらした分だけ
 * 棒の始点が年からずれるので、印が無いと年を読み違える）。
 * ★ 左の地域名の列（LABEL_COL より左）には決して入れない。
 */
export function placeBox(
  label: string, yearX0: number, yearX1: number, width: number,
): { x0: number; x1: number; text: string; yearX: number | null } {
  const right = width - RIGHT_PAD
  const need = textWidth(label) + PAD_X * 2
  let x0 = yearX0
  let x1 = Math.max(yearX1, yearX0 + need)
  if (x1 > right) {
    const shift = x1 - right
    x0 = Math.max(LABEL_COL, x0 - shift)
    x1 = right
  }
  const text = fitText(label, x1 - x0 - PAD_X * 2)
  return { x0, x1, text, yearX: x0 === yearX0 ? null : yearX0 }
}

export function chartRows(items: readonly ChronoItem[], domain: Span, width: number): Row[] {
  const plot = width - LABEL_COL - RIGHT_PAD
  const byGroup = new Map<number, ChronoItem[]>()
  for (const it of items) {
    const g = it.regionIds.length === 0 ? NO_REGION : regionGroupId(it.regionIds[0]!)
    byGroup.set(g, [...(byGroup.get(g) ?? []), it])
  }
  // 地域の順（seed/region.csv の並び ＝ id 順）。地域なしは最後
  const groups = [...byGroup.keys()].sort((a, b) =>
    a === NO_REGION ? 1 : b === NO_REGION ? -1 : a - b)

  let y = PERIOD_H + TICK_H
  return groups.map(g => {
    const raw = byGroup.get(g)!.map(it => {
      const yearX0 = LABEL_COL + yearToX(it.yearFrom, domain, plot)
      const yearX1 = Math.min(width - RIGHT_PAD,
        Math.max(yearX0 + MIN_BAR_W, LABEL_COL + yearToX(it.yearTo ?? it.yearFrom, domain, plot)))
      return { it, ...placeBox(it.label, yearX0, yearX1, width) }
    })
    // ★ 箱そのものが重なるかで段を分ける。文字は箱の中なので、箱が離れていれば重ならない
    const lanes = assignLanes(raw.map(r => ({ x0: r.x0, x1: r.x1 + 2 })))
    const laneCount = Math.max(1, ...lanes.map(l => l + 1))
    const h = laneCount * LANE_H + ROW_PAD * 2
    const row: Row = {
      groupId: g, label: g === NO_REGION ? '地域なし' : regionLabel(g),
      items: raw.map((r, i) => ({ ...r.it, x0: r.x0, x1: r.x1, lane: lanes[i]!, text: r.text, yearX: r.yearX })),
      lanes: laneCount, y, h,
    }
    y += h
    return row
  })
}

export function ChronoChart({
  items, selectedId, onSelect, full = false,
}: {
  items: readonly ChronoItem[]
  selectedId: string | null
  onSelect: (id: string) => void
  /** true なら全範囲（前3000〜2000）。既定は結果のある時代に合わせる（adaptiveDomain） */
  full?: boolean
}) {
  const width = CHART_WIDTH
  const domain = useMemo<Span>(() => full
    ? { from: CHART_MIN_YEAR, to: CHART_MAX_YEAR }
    : adaptiveDomain(items.map(it => ({ from: it.yearFrom, to: it.yearTo ?? it.yearFrom }))), [items, full])
  const rows = useMemo(() => chartRows(items, domain, width), [items, domain, width])
  if (items.length === 0) return null

  const plot = width - LABEL_COL - RIGHT_PAD
  const height = rows.length === 0 ? PERIOD_H + TICK_H : rows[rows.length - 1]!.y + rows[rows.length - 1]!.h
  const ticks = centuryTicks(domain, 10)
  const periods = PERIODS
    .map(p => ({ ...p, x0: LABEL_COL + yearToX(p.from, domain, plot), x1: LABEL_COL + yearToX(p.to, domain, plot) }))
    .filter(p => p.x1 - p.x0 > 0)

  return (
    <div className="hs-chrono">
      <svg
        viewBox={`0 0 ${width} ${height}`}
        className="hs-chrono__svg"
        role="img"
        aria-label={`年表。${formatYear(domain.from)}年から${formatYear(domain.to)}年まで。` +
          rows.map(r => `${r.label}: ${r.items.map(i => i.label).join('、')}`).join('。')}
      >
        {/* 時代区分の帯 */}
        {periods.map((p, i) => (
          <g key={p.key}>
            <rect x={p.x0} y={0} width={p.x1 - p.x0} height={PERIOD_H}
                  className={`hs-chrono__period${i % 2 ? ' hs-chrono__period--alt' : ''}`} />
            {p.x1 - p.x0 >= textWidth(p.label) + 6 && (
              <text x={(p.x0 + p.x1) / 2} y={PERIOD_H - 6} textAnchor="middle"
                    className="hs-chrono__period-label">{p.label}</text>
            )}
          </g>
        ))}
        <text x={LABEL_COL - 4} y={PERIOD_H - 6} textAnchor="end" className="hs-chrono__period-label">時代</text>

        {/* 目盛り（100年刻みを基本）と縦の罫線 */}
        {ticks.map(t => {
          const x = LABEL_COL + yearToX(t, domain, plot)
          return (
            <g key={t}>
              <line x1={x} x2={x} y1={PERIOD_H} y2={height} className="hs-chrono__grid" />
              <text x={x} y={PERIOD_H + TICK_H - 5} textAnchor="middle" className="hs-chrono__tick">
                {formatYear(t)}
              </text>
            </g>
          )
        })}

        {/* 地域の行 */}
        {rows.map(row => (
          <g key={row.groupId}>
            <line x1={0} x2={width} y1={row.y} y2={row.y} className="hs-chrono__rule" />
            <text x={LABEL_COL - 6} y={row.y + ROW_PAD + LANE_H / 2 + FONT / 3} textAnchor="end"
                  className="hs-chrono__row-label">{row.label}</text>
            {row.items.map(it => {
              const cy = row.y + ROW_PAD + it.lane * LANE_H + LANE_H / 2
              const selected = it.id === selectedId
              const cls = [
                'hs-chrono__bar',
                it.kind === 'kc' ? 'hs-chrono__bar--kc' : it.kind === 'section' ? 'hs-chrono__bar--section' : 'hs-chrono__bar--event',
                it.precision === 'century' ? 'hs-chrono__bar--approx' : '',
                selected ? 'hs-chrono__bar--selected' : '',
              ].filter(Boolean).join(' ')
              return (
                <g key={it.id} className="hs-chrono__item" onClick={() => onSelect(it.id)}
                   role="button" tabIndex={0} aria-pressed={selected}
                   onKeyDown={e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onSelect(it.id) } }}>
                  <title>{`${it.label}（${formatYear(it.yearFrom)}${it.yearTo !== null && it.yearTo !== it.yearFrom ? `–${formatYear(it.yearTo)}` : ''}）`}</title>
                  <rect x={it.x0} y={cy - BAR_H / 2} width={it.x1 - it.x0} height={BAR_H} className={cls} />
                  {/* 右端で箱をずらしたときは、本当の年の位置に印を打つ */}
                  {it.yearX !== null && (
                    <line x1={it.yearX} x2={it.yearX} y1={cy - BAR_H / 2 - 3} y2={cy + BAR_H / 2 + 3}
                          className="hs-chrono__year-mark" />
                  )}
                  <text x={it.x0 + PAD_X} y={cy + FONT / 3} textAnchor="start"
                        className={`hs-chrono__label${selected ? ' hs-chrono__label--selected' : ''}`}>
                    {it.text}
                  </text>
                </g>
              )
            })}
          </g>
        ))}
        <line x1={0} x2={width} y1={height - 0.5} y2={height - 0.5} className="hs-chrono__rule" />
        <line x1={LABEL_COL} x2={LABEL_COL} y1={0} y2={height} className="hs-chrono__rule" />
      </svg>
      <div className="hs-chrono__legend">
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--section" />教材の節</span>
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--event" />出来事</span>
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--kc" />知識項目（KC）</span>
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--approx" />世紀の概数</span>
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--selected" />選択中</span>
      </div>
    </div>
  )
}
