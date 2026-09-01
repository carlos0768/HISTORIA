/**
 * 解答 → SM-2 の評価値 q への写像
 *
 * 仕様: docs/04b-spaced-repetition.md §4
 *
 * SM-2 は「6段階の自己評価」を前提にしているが、本アプリの入力は
 * 四択・一問一答・フラッシュカードである。さらに SM-2 には guess が無く、
 * 四択の当てずっぽう正解がそのまま q=4 として間隔を ×EF 伸ばしてしまう。
 * p_know と結合することで、新しいパラメータを1つも増やさずに補正する。
 */
import type { Grade } from './sm2'
import { MEDIAN_LATENCY_MS, FAST_ANSWER_MS, type ItemFormat } from './params'

export type ObjectiveInput = {
  correct: boolean
  latencyMs: number | null
  /** 更新“前”の p_know。更新後を渡すと同じ応答から違う q が出て再現性が失われる（§9） */
  pKnowBefore: number
  /** 同じ誤選択肢を2回以上選んでいるか */
  misconceptionHit: boolean
  format: ItemFormat
  /** そのユーザーのその形式の中央値。無ければ形式別の初期値を使う（§4.3） */
  medianLatencyMs?: number
}

/**
 * 客観形式（四択・一問一答・正誤判定・並べ替え）の q（§4.1）。
 *
 * q = 3 + round(2 * p_know_before) の意味:
 *   モデルが「知っている」と信じていた KC の正解 → 強い証拠（q=5）
 *   モデルが「知らない」と信じていた KC の正解 → 推測の疑い（q=3 に留める）
 * q=3 は間隔を伸ばすが EF を -0.14 するため、まぐれ当たりが続いても伸びが自然に鈍化する。
 */
export function objectiveGrade(i: ObjectiveInput): Grade {
  if (i.correct) {
    let q = 3 + Math.round(2 * i.pKnowBefore)
    const median = i.medianLatencyMs ?? MEDIAN_LATENCY_MS[i.format]
    if (i.latencyMs !== null && i.latencyMs > 1.5 * median) {
      q = Math.max(3, q - 1) // 時間がかかった＝想起に苦労した
    }
    return q as Grade
  }
  if (i.misconceptionHit) return 0
  if (i.latencyMs !== null && i.latencyMs < FAST_ANSWER_MS) return 1 // 即答の誤り＝当てずっぽう/ケアレス
  return 2
}

/** フラッシュカードの自己申告。UIのボタンは4つに固定する（§4.2） */
export const FLASHCARD_BUTTONS = ['unknown', 'vague', 'known', 'easy'] as const
export type FlashcardButton = (typeof FLASHCARD_BUTTONS)[number]

const FLASHCARD_GRADE: Record<FlashcardButton, Grade> = {
  unknown: 1, // わからない
  vague: 3,   // あいまい
  known: 4,   // わかった
  easy: 5,    // 余裕
}

/** 答えを表示してからこの時間未満で「わかった／余裕」を押したら丸める */
export const SELF_DECEPTION_MS = 800

/**
 * フラッシュカードの q（§4.2）。
 * 答えを見てから 800ms 未満で「わかった／余裕」は、読む時間が物理的に足りていないので
 * q=3 に丸める（自己欺瞞への耐性）。
 */
export function flashcardGrade(button: FlashcardButton, msSinceReveal: number | null): Grade {
  const q = FLASHCARD_GRADE[button]
  if (q >= 4 && msSinceReveal !== null && msSinceReveal < SELF_DECEPTION_MS) return 3
  return q
}
