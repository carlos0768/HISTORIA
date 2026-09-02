/**
 * 連続学習日数（ストリーク）
 *
 * 仕様: docs/11-ux.md §7.1
 *
 *   連続日数のカウントは「その日に1問以上解いた」で成立する（1問でよい）。
 *   1日空いた場合は「ストリーク保護」を月2回まで自動適用する。
 *   3日以上空いた場合はリセットするが、「これまでの最長記録: 24日」を残す。
 *
 * ★ 仕様は「1日空き」と「3日以上空き」しか書いておらず、**2日空きが未定義**である。
 *   保護が1日ぶんしか埋めないと解くと「3日以上でリセット」が言葉として無意味になる
 *   （2日空きの行き先が決まらない）。両方の明文が同時に真になる唯一の読み方は
 *   「保護は2日ぶんまでの穴を埋める。3日以上は埋めない」なので、そちらを採る。
 *
 * ★ 日付は **Asia/Tokyo** で数える。UTC で数えると日本時間の深夜0〜9時に解いた分が
 *   前日に入り、「日付が変わる前に1問やった」が連続に効かない。
 *   `lib/ai/budget.ts` の `periodOf` と同じ作法にそろえる。
 */

/** 保護を使える回数（暦月あたり） */
export const PROTECT_PER_MONTH = 2
/** 保護1回で埋められる空白の日数の上限 */
export const MAX_BRIDGE_DAYS = 2

const DAY_MS = 86_400_000
const JST_OFFSET_MS = 9 * 60 * 60 * 1000

/** Asia/Tokyo の暦日を 'YYYY-MM-DD' で返す */
export function jstDate(d: Date): string {
  return new Date(d.getTime() + JST_OFFSET_MS).toISOString().slice(0, 10)
}

/** 'YYYY-MM-DD' を、日数の足し引きができる数値にする（UTC 正午基準で夏時間の影響を受けない） */
const stamp = (day: string): number => Date.parse(`${day}T00:00:00Z`)
const fromStamp = (t: number): string => new Date(t).toISOString().slice(0, 10)

export type Streak = {
  /** いま何日続いているか */
  current: number
  /** これまでの最長 */
  longest: number
  /** 学習した日の総数 */
  days: number
  /** 今月あと何回、保護が使えるか */
  protectionsLeft: number
}

/**
 * 学習した日の一覧から連続日数を出す。
 *
 * @param days   学習した日（'YYYY-MM-DD'・Asia/Tokyo）。順不同・重複可
 * @param today  今日（'YYYY-MM-DD'・Asia/Tokyo）
 *
 * ★ 今日まだ解いていなくても連続は途切れていない。その日が終わるまで確定しないためである。
 */
export function computeStreak(days: readonly string[], today: string): Streak {
  const set = new Set(days)
  if (set.size === 0) {
    return { current: 0, longest: 0, days: 0, protectionsLeft: PROTECT_PER_MONTH }
  }

  // ---- いまの連続 ----
  // 使った保護は「埋めた空白の最初の日」が属する月で数える。
  const used = new Map<string, number>()
  const month = (day: string) => day.slice(0, 7)
  const canProtect = (firstGapDay: string): boolean =>
    (used.get(month(firstGapDay)) ?? 0) < PROTECT_PER_MONTH
  const spend = (firstGapDay: string) => {
    const m = month(firstGapDay)
    used.set(m, (used.get(m) ?? 0) + 1)
  }

  let cursor = stamp(today)
  // 今日がまだなら昨日から見る（今日ぶんは空白として数えない）
  if (!set.has(fromStamp(cursor))) cursor -= DAY_MS
  let current = 0
  for (;;) {
    if (set.has(fromStamp(cursor))) {
      current++
      cursor -= DAY_MS
      continue
    }
    // 空白。何日続くかを数える
    let gap = 0
    let probe = cursor
    while (gap <= MAX_BRIDGE_DAYS && !set.has(fromStamp(probe))) {
      gap++
      probe -= DAY_MS
    }
    // これより前に学習した日が無ければ、そこが始まり（空白ではなく末端）
    const earliest = stamp([...set].sort()[0]!)
    if (probe < earliest) break
    if (gap > MAX_BRIDGE_DAYS || !canProtect(fromStamp(cursor - (gap - 1) * DAY_MS))) break
    spend(fromStamp(cursor - (gap - 1) * DAY_MS))
    cursor = probe
  }

  // ---- 最長 ----
  // ★ 保護を当てはめずに数える。保護は「いまの連続を守る」ための救済であって、
  //   記録を水増しするものではない。実際に毎日やった最長を残す。
  const asc = [...set].sort()
  let longest = 0
  let run = 0
  let prev: number | null = null
  for (const day of asc) {
    const t = stamp(day)
    run = prev !== null && t - prev === DAY_MS ? run + 1 : 1
    longest = Math.max(longest, run)
    prev = t
  }

  return {
    current,
    longest: Math.max(longest, current),
    days: set.size,
    protectionsLeft: Math.max(0, PROTECT_PER_MONTH - (used.get(month(today)) ?? 0)),
  }
}
