/**
 * 時代区分と、年表（横軸）への置き方
 *
 * 仕様: docs/11-ux.md §4.1（教材の中の「調べる」）
 *
 * ★ ここの時代区分は**見せるためのもの**である。測定用の粗いグリッドは
 *   DB の `era`（前近代／近世・近代／現代の3つ。seed/era.csv）であり、
 *   弱点の推定はそちらを使う。ここを変えても学習ロジックは動かない。
 * ★ 境界は教科書の慣例に寄せた概数である（古代の終わりを 500 年に丸める等）。
 *   「どのあたりの時代か」が一目で分かれば足り、境界の1年を争う場面では使わない。
 * ★ 年は負値で紀元前を表す（seed と同じ）。0年は存在しないが、計算上は連続した数直線として扱う。
 */

export type Period = { key: string; label: string; from: number; to: number }

export const PERIODS: readonly Period[] = [
  { key: 'ancient',      label: '古代',  from: -3000, to: 500 },
  { key: 'medieval',     label: '中世',  from: 500,   to: 1500 },
  { key: 'early_modern', label: '近世',  from: 1500,  to: 1800 },
  { key: 'modern',       label: '近代',  from: 1800,  to: 1900 },
  { key: 'contemporary', label: '現代',  from: 1900,  to: 2100 },
]

/** 年表の既定の範囲。添付の世界史年表と同じく前3000年から2000年まで */
export const CHART_MIN_YEAR = -3000
export const CHART_MAX_YEAR = 2000

export type Span = { from: number; to: number }

/** 年の範囲に重なる時代区分。1年の出来事は1つ、跨ぐものは複数返す */
export function periodsOf(yearFrom: number, yearTo: number | null = null): Period[] {
  const to = yearTo ?? yearFrom
  const lo = Math.min(yearFrom, to), hi = Math.max(yearFrom, to)
  return PERIODS.filter(p => lo < p.to && hi >= p.from)
}

/** 「前18世紀」「13世紀」。0年を挟む数え方（前1世紀の次が1世紀）に従う */
export function formatCentury(year: number): string {
  if (year < 0) return `前${Math.ceil(-year / 100)}世紀`
  return `${Math.floor((year - 1) / 100) + 1}世紀`
}

/** 年の範囲を、その範囲を含む世紀の境界（100年刻み）に広げる */
export function toCenturyBounds(s: Span): Span {
  return { from: Math.floor(s.from / 100) * 100, to: Math.ceil(s.to / 100) * 100 }
}

/**
 * 結果に合わせた横軸の範囲。
 *
 * ★ 最小の幅を持たせる。全部が同じ年だと幅 0 になり、何も描けない。
 *   足りない分は両側へ均等に広げ、既定の範囲の外へは出さない。
 */
export function fitDomain(spans: readonly Span[], opts: { minSpan?: number } = {}): Span {
  const minSpan = opts.minSpan ?? 500
  if (spans.length === 0) return { from: CHART_MIN_YEAR, to: CHART_MAX_YEAR }
  let { from, to } = toCenturyBounds({
    from: Math.min(...spans.map(s => s.from)),
    to: Math.max(...spans.map(s => s.to)),
  })
  if (to - from < minSpan) {
    const pad = Math.ceil((minSpan - (to - from)) / 2 / 100) * 100
    from -= pad; to += pad
  }
  return { from: Math.max(CHART_MIN_YEAR, from), to: Math.min(CHART_MAX_YEAR, to) }
}

/** 年 → 横位置（0..width）。範囲の外は端に留める */
export function yearToX(year: number, domain: Span, width: number): number {
  const span = domain.to - domain.from
  if (span <= 0) return 0
  const t = (year - domain.from) / span
  return Math.max(0, Math.min(1, t)) * width
}

/**
 * 目盛りの年。100年刻みを基本に、本数が上限を超えたら刻みを 2・5・10 倍に粗くする。
 * 添付の年表は 100 年ごとに目盛りを打っている。範囲が狭いときだけ細かくはしない
 * （世紀より細かい目盛りは、precision が century の出来事に対して嘘になる）。
 */
export function centuryTicks(domain: Span, maxTicks = 12): number[] {
  const steps = [100, 200, 500, 1000, 2000]
  const span = domain.to - domain.from
  const step = steps.find(s => span / s <= maxTicks) ?? steps[steps.length - 1]!
  const out: number[] = []
  for (let y = Math.ceil(domain.from / step) * step; y <= domain.to; y += step) out.push(y)
  return out
}

/**
 * 横に並べたときに重ならないよう、段（レーン）を割り当てる。
 * 開始位置の順に見て、空いている最初の段に置く。戻り値は items と同じ順。
 *
 * ★ 幅にラベルの分を含めて呼ぶこと。棒だけで判定すると、棒は離れているのに
 *   文字が重なる。
 */
export function assignLanes(items: ReadonlyArray<{ x0: number; x1: number }>): number[] {
  const order = items.map((it, i) => ({ it, i })).sort((a, b) => a.it.x0 - b.it.x0 || a.i - b.i)
  const laneEnd: number[] = []
  const lanes = new Array<number>(items.length).fill(0)
  for (const { it, i } of order) {
    let lane = laneEnd.findIndex(end => end <= it.x0)
    if (lane === -1) { lane = laneEnd.length; laneEnd.push(0) }
    laneEnd[lane] = Math.max(it.x1, it.x0 + 1)
    lanes[i] = lane
  }
  return lanes
}
