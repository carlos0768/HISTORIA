/**
 * 推定パラメータ
 *
 * 仕様: docs/04-weakness-engine.md §9
 *
 * ★ ここの値を変えたら algo_version を上げ、response から user_kc_state を
 *   再計算すること。値だけ差し替えて既存の状態を残す運用は禁止する（§9）。
 *   管理画面から変更してよい設定にこれらを置かない（docs/12 §7.2）。
 */

export const ALGO_VERSION = 1
export const SCHED_VERSION = 1

/**
 * 出題形式。guess はこの形式から決まる定数であり、データから推定しない（§1）。
 * ★ 値は docs/schema.sql の item.format の CHECK と一致させること。
 */
export const ITEM_FORMATS = ['mcq4', 'cloze', 'tf', 'order', 'flashcard'] as const
export type ItemFormat = (typeof ITEM_FORMATS)[number]

/** 当てずっぽうで当たる確率。選択肢数の逆数、または提案値（§9） */
export const GUESS: Record<ItemFormat, number> = {
  mcq4: 0.25,      // 四択。選択肢4つの逆数
  tf: 0.5,         // 正誤判定。選択肢2つの逆数
  cloze: 0.05,     // 一問一答・穴埋め
  order: 0.05,     // 並べ替え
  flashcard: 0.02,
}

/** 知っているのに間違える確率 */
export const SLIP_NORMAL = 0.1
/** 即答の誤答はケアレス寄りとみなす */
export const SLIP_FAST = 0.25
/** 即答と判定する閾値（ms） */
export const FAST_ANSWER_MS = 1500
/** 遭遇しただけで習得に至る確率 */
export const T_LEARN = 0.1

/** Elo の K 係数。観測数で減衰させ、初期は速く動き後で安定する */
export const ELO_K_BASE = 0.6
export const ELO_K_DECAY = 0.05
/** 診断前の能力値。やや低めに置いて過大評価を避ける（§5.4） */
export const THETA_0 = -0.5

/** これ未満は「未測定」。弱点として表示しない（§2） */
export const N_EFF_UNKNOWN = 1.5
export const MASTERY_WEAK = 0.6
export const MASTERY_MASTERED = 0.85
/** mastered に必要な実効証拠量 */
export const N_EFF_MASTERED = 3

/** 同じ誤選択肢をこの回数選んだら誤概念とみなす（§3） */
export const MISCONCEPTION_HITS = 2

/** 形式別の想定解答時間の中央値（ms）。応答100件を超えたら実測値に切り替える（04b §4.3） */
export const MEDIAN_LATENCY_MS: Record<ItemFormat, number> = {
  mcq4: 12_000,
  cloze: 10_000,
  tf: 8_000,
  order: 15_000,
  flashcard: 6_000,
}
/** この件数を超えたらそのユーザーの実測中央値に切り替える */
export const LATENCY_SWITCH_N = 100
