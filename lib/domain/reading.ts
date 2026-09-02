/**
 * 読了の判定
 *
 * 仕様: docs/11-ux.md §「読了判定」、docs/07-content-pipeline.md §2
 *
 * ★ スクロール率だけで判定しない。飛ばしても 100% になるためである。
 *   明示的な「読み終えた」ボタン ＋ 滞在時間の両方を見る。
 */

/** 日本語の黙読速度（字/分）。docs/07 §2 が「毎分500字で約7分」としている */
export const CHARS_PER_MIN = 500

/** 推定読了時間のこの割合以上の滞在で、初めて学習イベントとして数える */
export const READ_DWELL_RATIO = 0.6

/** そのセクションを読み切るのにかかる推定時間（ミリ秒） */
export function estimatedReadMs(charCount: number): number {
  return Math.round((Math.max(0, charCount) / CHARS_PER_MIN) * 60_000)
}

/** 学習イベントとして数えるのに必要な滞在時間（ミリ秒） */
export function requiredDwellMs(charCount: number): number {
  return Math.round(estimatedReadMs(charCount) * READ_DWELL_RATIO)
}

/**
 * 滞在時間が足りているか。
 * 足りない記録も material_read には残す（イベントは削らない）。数えないだけである。
 */
export function countsAsRead(dwellMs: number, charCount: number): boolean {
  return dwellMs >= requiredDwellMs(charCount)
}
