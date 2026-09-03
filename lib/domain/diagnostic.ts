/**
 * 適応的診断テスト（docs/04-weakness-engine.md §5）
 *
 * ★ これは**測定器**であって学習教材ではない。だから全員に同じ物差しを当てる
 *   （共有プール・§5.2）。個人化しない。
 *
 * ★ 測っているのは **12セル（3時代 × 4地域）のθ**であって、個々の KC ではない。
 *   24問で 800〜900 の KC を判定したと表示すれば、実際には測っていないものを
 *   断定することになり、初日に信頼を壊す（§5.5）。
 *   だから診断後も全 KC は `n_eff = 0`（＝status は unknown）のままにする。
 *
 * ────────────────────────────────────────────────
 * 打ち切り条件について、仕様の食い違いを1つ見つけた（正直に書く）
 *
 * §5.3 は打ち切りを
 *   「12問以上 かつ 全12セルで事後SD ≤ 0.35」または「上限24問」
 * と定めている。だが**この2つは両立しない**。
 *
 * 24問を12セルに配ると1セルあたり2問である。四択（g=0.25）1問が
 * θについて持つ情報量は、最も効率のよい p≈0.5 付近でも約 0.14 しかない
 * （下の `information()`）。事後SDを 0.35 にするには精度 1/0.35² ≈ 8.2 が要る。
 * 事前SDを1.0（＝何も知らない）とすると精度1から始まるので、
 * **1セルあたり約50問**必要になる。2問では到底届かない。
 *
 * 事前SDを縮めれば届くが、0.36 未満にすると「最初から目標を満たしている」ことになり、
 * 12問ちょうどで必ず打ち切られる。つまり SD 条件が意味を持つ事前分布は存在しない。
 *
 * **採った方針**: 両方そのまま実装する。事前SDは 1.0（正直に「何も知らない」）に置く。
 * 結果として実際に効くのは上限24問のほうで、SD 条件はほぼ発火しない。
 * 定数は名前を付けて出してあるので、作者が目標SDを緩めれば早期打ち切りが働く。
 * 黙って定数を都合よく決めて「仕様どおり動いています」とは書かない。
 * ────────────────────────────────────────────────
 */

/** 時代は3つ（seed/era.csv） */
export const ERA_IDS = [1, 2, 3] as const
/** 地域の粗グリッドは4つ（region.grid_id・schema.sql の CHECK） */
export const GRID_IDS = [1, 2, 3, 4] as const
/** 3 × 4 = 12 セル */
export const CELL_COUNT = ERA_IDS.length * GRID_IDS.length

/** 打ち切り: これ未満では止めない（§5.3） */
export const MIN_ITEMS = 12
/** 打ち切り: これを超えない。1問25秒想定で最大10分（§5.3） */
export const MAX_ITEMS = 24
/** 打ち切り: 全セルがこのSD以下なら早期に止める（§5.3） */
export const SD_TARGET = 0.35

/** 診断前のθ。やや低めに置いて過大評価を避ける（§5.4） */
export const THETA_0 = -0.5
/** 診断前のSD。1.0 =「何も知らない」 */
export const SD_0 = 1.0

/** セルの識別子。'era:grid' */
export type CellKey = string
export const cellKey = (eraId: number, gridId: number): CellKey => `${eraId}:${gridId}`

export function allCells(): CellKey[] {
  return ERA_IDS.flatMap(e => GRID_IDS.map(g => cellKey(e, g)))
}

export type CellPosterior = {
  /** 事後平均。これが伝播されて各 KC の初期θになる */
  theta: number
  /** 事後標準偏差。小さいほど測れている */
  sd: number
  /** そのセルで何問解いたか */
  answered: number
}

export function initialCells(): Map<CellKey, CellPosterior> {
  return new Map(allCells().map(k => [k, { theta: THETA_0, sd: SD_0, answered: 0 }]))
}

const sigmoid = (x: number): number => 1 / (1 + Math.exp(-x))

/**
 * 正答確率（§5.3）。`p = g + (1-g) * sigmoid(theta - elo_b)`
 *
 * ★ g は当てずっぽうの下限である。四択なら 0.25。
 *   これを入れないと、θがどれだけ低くても p→0 になり、
 *   「まぐれ当たり」を実力の証拠として読んでしまう。
 */
export function pCorrect(theta: number, eloB: number, guessRate: number): number {
  return guessRate + (1 - guessRate) * sigmoid(theta - eloB)
}

/**
 * この1問がθについて持つ情報量（Fisher 情報量）。
 *
 * ★ 仕様の `4 * p * (1-p)` は g=0 のときの形である。
 *   当てずっぽうがある四択では p が 0.25 を下回らないため、
 *   その式は「難しすぎる問題ほど情報がある」と誤って評価する。
 *   ここでは g を含めた本来の形 `(dp/dθ)² / (p(1-p))` を使う。
 *   g=0 のとき `(σ(1-σ))² / (σ(1-σ)) = σ(1-σ) = p(1-p)` となり、
 *   仕様の式と比例する（定数4の違いは argmax に影響しない）。
 */
export function information(theta: number, eloB: number, guessRate: number): number {
  const s = sigmoid(theta - eloB)
  const p = guessRate + (1 - guessRate) * s
  const dp = (1 - guessRate) * s * (1 - s)
  const v = p * (1 - p)
  return v <= 0 ? 0 : (dp * dp) / v
}

/**
 * そのセルをどれだけ測りたいか（§5.3 の `facet_uncertainty`）。
 *
 * ★ 分散をそのまま使う。SD ではない。
 *   分散は「情報量を足せば減る」量であり、情報量との積が
 *   「この1問でどれだけ不確かさが減るか」の見積りになる。
 *   SD を使うと、まだ1問も出していないセルへの偏りが弱くなる。
 */
export const facetUncertainty = (c: CellPosterior): number => c.sd * c.sd

export type Candidate = {
  itemId: string
  cell: CellKey
  eloB: number
  guessRate: number
}

/**
 * 次の1問を選ぶ（§5.3）。
 *
 *   next = argmax_i  facet_uncertainty(cell(i)) * information(i)
 *
 * ★ 同点のときは itemId の辞書順で決める。乱数を使わない。
 *   同じ答え方をした2人に別の問題が出ると、診断の結果を比べられなくなる
 *   （共有プールにした意味が薄れる）。
 */
export function selectNext(
  candidates: readonly Candidate[],
  cells: ReadonlyMap<CellKey, CellPosterior>,
): Candidate | null {
  let best: Candidate | null = null
  let bestScore = -Infinity
  for (const c of candidates) {
    const cell = cells.get(c.cell)
    if (!cell) continue
    const score = facetUncertainty(cell) * information(cell.theta, c.eloB, c.guessRate)
    if (score > bestScore || (score === bestScore && best && c.itemId < best.itemId)) {
      best = c
      bestScore = score
    }
  }
  return best
}

/**
 * 1問の解答でセルの事後分布を更新する。
 *
 * ★ 正規近似のオンライン更新（カルマンフィルタと同じ形）。
 *   精度（分散の逆数）に情報量を足し、平均を残差の向きへ動かす。
 *   MCMC も EM も要らないし、24問という規模では差が出ない。
 *
 * ★ θを ±4 で止める。止めないと、全問正解の人のθが発散して
 *   伝播先の KC が全部「もう知っている」になる。24問では
 *   そこまで測れていないので、測れた範囲に丸める。
 */
export const THETA_LIMIT = 4

export function updateCell(
  cell: CellPosterior, correct: boolean, eloB: number, guessRate: number,
): CellPosterior {
  const s = sigmoid(cell.theta - eloB)
  const p = guessRate + (1 - guessRate) * s
  const dp = (1 - guessRate) * s * (1 - s)
  const v = p * (1 - p)
  if (v <= 0 || dp === 0) return { ...cell, answered: cell.answered + 1 }

  const info = (dp * dp) / v
  const precision = 1 / (cell.sd * cell.sd) + info
  const sd = Math.sqrt(1 / precision)
  // 残差 (y - p) を、傾き dp/dθ と分散 v で割ってスコア関数にする
  const score = ((correct ? 1 : 0) - p) * dp / v
  const theta = Math.max(-THETA_LIMIT, Math.min(THETA_LIMIT, cell.theta + score / precision))
  return { theta, sd, answered: cell.answered + 1 }
}

/**
 * 打ち切るか（§5.3）。
 *
 *   「12問以上 かつ 全12セルで事後SD ≤ 0.35」または「上限24問」
 */
export function shouldStop(
  answered: number, cells: ReadonlyMap<CellKey, CellPosterior>,
): boolean {
  if (answered >= MAX_ITEMS) return true
  if (answered < MIN_ITEMS) return false
  return [...cells.values()].every(c => c.sd <= SD_TARGET)
}

/**
 * 事前分布の SD を与えたとき、SD 条件が発火しうるかを判定する。
 *
 * ★ 仕様の食い違い（冒頭）を**機械で見える形にする**ための関数である。
 *   画面からは使わない。試験と、将来 SD_TARGET を触るときの根拠に使う。
 *   1セルあたりに要る最小の問題数を、最も効率のよい情報量で見積もる。
 */
export function itemsNeededPerCell(sd0 = SD_0, target = SD_TARGET): number {
  if (sd0 <= target) return 0
  // 情報量の上限は θ = elo_b（p が最も 0.5 に近い）のとき
  const best = information(0, 0, 0.25)
  const need = 1 / (target * target) - 1 / (sd0 * sd0)
  return Math.ceil(need / best)
}

export type DiagnosticResult = {
  /** セルごとのθ。各 KC の初期値になる（§5.4） */
  cells: Map<CellKey, CellPosterior>
  answered: number
  /** 1問も出せなかったセル。「測っていない」ことを画面に書くために要る */
  unmeasured: CellKey[]
}

export function summarize(
  cells: ReadonlyMap<CellKey, CellPosterior>, answered: number,
): DiagnosticResult {
  return {
    cells: new Map(cells),
    answered,
    unmeasured: [...cells.entries()].filter(([, c]) => c.answered === 0).map(([k]) => k),
  }
}
