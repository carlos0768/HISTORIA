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
 * ★ 横軸は既定で全範囲（前3000〜2000）。近代の出来事ばかりだと右端に固まるので、
 *   「結果に合わせる」で範囲を寄せられる。既定を寄せた範囲にしないのは、
 *   「全史の中のどこか」がまず見えるべきだからである（年表の意味）。
 * ★ 年代の無い項目はここには置かない。置けないものを 0 年に置くのは嘘になる。
 *   一覧の側で「年代なし」と出す。
 */
import { useMemo } from 'react'
import {
  PERIODS, CHART_MIN_YEAR, CHART_MAX_YEAR, fitDomain, yearToX, centuryTicks, assignLanes,
  type Span,
} from '@/lib/domain/periods'
import { formatYear } from '@/lib/loop/timeline'
import { regionGroupId, regionLabel } from '@/lib/map/regions'

export type ChronoItem = {
  id: string
  label: string
  kind: 'kc' | 'event'
  yearFrom: number
  yearTo: number | null
  /** century なら概数として点線で描く */
  precision: string | null
  /** 先頭が主地域。空なら「地域なし」の行に置く */
  regionIds: readonly number[]
}

/** 描画の寸法（viewBox 単位）。文字は 11 で固定し、狭い画面では横に流す */
export const CHART_WIDTH = 720
export const LABEL_COL = 96          // 左の地域名の列
const RIGHT_PAD = 8
const PERIOD_H = 20
const TICK_H = 18
const LANE_H = 20
const ROW_PAD = 6
const BAR_H = 10
const MIN_BAR_W = 5
const FONT = 11
/** 1文字の幅の見積り。日本語は全角（≒ FONT）、数字と記号はその半分 */
const textWidth = (s: string) =>
  [...s].reduce((w, ch) => w + (ch.charCodeAt(0) > 0xff ? FONT : FONT * 0.6), 0)

const NO_REGION = -1

export type Placed = ChronoItem & {
  x0: number; x1: number; lane: number
  /** 実際に描く文字。入り切らなければ末尾を「…」で詰める */
  text: string
  labelX: number
  anchor: 'start' | 'end'
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

/**
 * ラベルの置き場所。右 → 棒の中 → 左の順に、入り切る場所を選ぶ。
 * どこにも入り切らなければ一番広い場所に「…」で詰めて置く。
 * ★ 左の地域名の列（LABEL_COL より左）には決して入れない。
 *   入れると地域名と重なって、どちらも読めなくなる（実際に一度そうなった）。
 */
export function placeLabel(
  label: string, x0: number, x1: number, width: number,
): { text: string; labelX: number; anchor: 'start' | 'end'; ext: { x0: number; x1: number } } {
  const w = textWidth(label)
  const right = width - RIGHT_PAD - (x1 + 3)
  const inside = x1 - x0 - 6
  const left = x0 - 3 - LABEL_COL
  if (w <= right) return { text: label, labelX: x1 + 3, anchor: 'start', ext: { x0, x1: x1 + 3 + w } }
  if (w <= inside) return { text: label, labelX: x0 + 3, anchor: 'start', ext: { x0, x1 } }
  if (w <= left) return { text: label, labelX: x0 - 3, anchor: 'end', ext: { x0: x0 - 3 - w, x1 } }
  const best = Math.max(right, inside, left)
  const text = fitText(label, best)
  const tw = textWidth(text)
  if (best === right) return { text, labelX: x1 + 3, anchor: 'start', ext: { x0, x1: x1 + 3 + tw } }
  if (best === inside) return { text, labelX: x0 + 3, anchor: 'start', ext: { x0, x1 } }
  return { text, labelX: x0 - 3, anchor: 'end', ext: { x0: x0 - 3 - tw, x1 } }
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
      const x0 = LABEL_COL + yearToX(it.yearFrom, domain, plot)
      const x1 = Math.min(width - RIGHT_PAD,
        Math.max(x0 + MIN_BAR_W, LABEL_COL + yearToX(it.yearTo ?? it.yearFrom, domain, plot)))
      return { it, x0, x1, ...placeLabel(it.label, x0, x1, width) }
    })
    const lanes = assignLanes(raw.map(r => r.ext))
    const laneCount = Math.max(1, ...lanes.map(l => l + 1))
    const h = laneCount * LANE_H + ROW_PAD * 2
    const row: Row = {
      groupId: g, label: g === NO_REGION ? '地域なし' : regionLabel(g),
      items: raw.map((r, i) => ({
        ...r.it, x0: r.x0, x1: r.x1, lane: lanes[i]!, text: r.text, labelX: r.labelX, anchor: r.anchor,
      })),
      lanes: laneCount, y, h,
    }
    y += h
    return row
  })
}

export function ChronoChart({
  items, selectedId, onSelect, fit,
}: {
  items: readonly ChronoItem[]
  selectedId: string | null
  onSelect: (id: string) => void
  /** 横軸を結果に合わせて寄せる */
  fit: boolean
}) {
  const width = CHART_WIDTH
  const domain = useMemo<Span>(() => fit
    ? fitDomain(items.map(it => ({ from: it.yearFrom, to: it.yearTo ?? it.yearFrom })))
    : { from: CHART_MIN_YEAR, to: CHART_MAX_YEAR }, [items, fit])
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
                it.kind === 'kc' ? 'hs-chrono__bar--kc' : 'hs-chrono__bar--event',
                it.precision === 'century' ? 'hs-chrono__bar--approx' : '',
                selected ? 'hs-chrono__bar--selected' : '',
              ].filter(Boolean).join(' ')
              return (
                <g key={it.id} className="hs-chrono__item" onClick={() => onSelect(it.id)}
                   role="button" tabIndex={0} aria-pressed={selected}
                   onKeyDown={e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onSelect(it.id) } }}>
                  <title>{`${it.label}（${formatYear(it.yearFrom)}${it.yearTo !== null && it.yearTo !== it.yearFrom ? `–${formatYear(it.yearTo)}` : ''}）`}</title>
                  <rect x={it.x0} y={cy - BAR_H / 2} width={it.x1 - it.x0} height={BAR_H} className={cls} />
                  <text x={it.labelX} y={cy + FONT / 3} textAnchor={it.anchor}
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
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--event" />出来事</span>
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--kc" />知識項目（KC）</span>
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--approx" />世紀の概数</span>
        <span className="hs-chrono__key"><span className="hs-chrono__swatch hs-chrono__swatch--selected" />選択中</span>
      </div>
    </div>
  )
}
