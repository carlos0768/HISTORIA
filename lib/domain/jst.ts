/**
 * 日本時間の暦日と時刻
 *
 * ★ この置き場所を作った理由。`jstDate` は lib/domain/streak.ts に在ったが、
 *   リマインドは「いま日本時間で何時か」を要る（lib/loop/remind.ts）。
 *   時刻の道具を「連続日数」の module から import すると、読んだ人が
 *   「リマインドはストリークの一部なのか？」と誤解する。時間の扱いだけを分ける。
 *
 * ★ Intl.DateTimeFormat を使わない。tz データベースは実行環境で版が違いうるが、
 *   日本標準時は 1951 年以降ずっと UTC+9 固定で夏時間が無い。定数の加算で足りるし、
 *   そのほうが試験で意図を書ける（lib/ai/budget.ts の periodOf と同じ作法）。
 */

export const JST_OFFSET_MS = 9 * 60 * 60 * 1000

/** Asia/Tokyo の暦日を 'YYYY-MM-DD' で返す */
export function jstDate(d: Date): string {
  return new Date(d.getTime() + JST_OFFSET_MS).toISOString().slice(0, 10)
}

/** Asia/Tokyo の時（0〜23）を返す */
export function jstHour(d: Date): number {
  return new Date(d.getTime() + JST_OFFSET_MS).getUTCHours()
}

/**
 * その日本時間の暦日が始まった瞬間（UTC の Date）。
 *
 * ★ 「今日すでに送ったか」の判定に要る。`last_sent_at` は timestamptz なので、
 *   日本時間の 0:00 に対応する UTC の瞬間と比べなければ、
 *   深夜0〜9時に送ったぶんが前日扱いになる。
 */
export function jstDayStart(day: string): Date {
  return new Date(Date.parse(`${day}T00:00:00Z`) - JST_OFFSET_MS)
}
