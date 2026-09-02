/**
 * SM-2 間隔反復 — KC 単位
 *
 * 仕様: docs/04b-spaced-repetition.md §3
 *
 * item 単位ではなく KC 単位で状態を持つ。設問が毎回生成されると
 * 昨日の item は今日存在せず、item 単位では n が永久に 0 のまま
 * 間隔が 1 日から伸びないため（§1.2）。
 */

/** 間隔の上限（日）。これを超えると事実上「二度と出ない」ため頭打ちにする（§3） */
export const MAX_INTERVAL_DAYS = 365
/** EF の下限。SM-2 原典の値 */
export const MIN_EF = 1.3
/** この回数の誤答で leech として出題を止める（§7） */
export const LEECH_THRESHOLD = 8
/** 締切の何日前までに最後の復習を終えるか（§3） */
export const DEADLINE_BUFFER_DAYS = 3

export type KcCard = {
  n: number
  ef: number
  intervalDays: number
  dueAt: Date
  lapses: number
  suspended: boolean
  lastReviewAt: Date | null
}

export function newKcCard(now: Date): KcCard {
  return { n: 0, ef: 2.5, intervalDays: 0, dueAt: now, lapses: 0, suspended: false, lastReviewAt: null }
}

/** SM-2 の評価値。0〜5 の整数（§4 で本アプリの入力から導出する） */
export type Grade = 0 | 1 | 2 | 3 | 4 | 5

export type Sm2Input = {
  card: KcCard
  q: Grade
  /** その KC を含む特訓の締切。無ければ null */
  deadline: Date | null
  /** 「今日」。呼び出し側が渡す（テスト可能にするため now() を内部で呼ばない） */
  today: Date
  /**
   * [-0.05, +0.05] のゆらぎ。復習が同じ日に山積みになるのを防ぐ。
   * 再計算で due_at がぶれないよう response.id を種にした決定的な値を渡す（§3）。
   */
  jitter?: number
}

export type Sm2Result = {
  card: KcCard
  /** 締切クランプが働いたか。response.clamped に記録する */
  clamped: boolean
}

const DAY_MS = 86_400_000

function addDays(d: Date, days: number): Date {
  return new Date(d.getTime() + days * DAY_MS)
}

/**
 * response.id から [-0.05, +0.05] の決定的なゆらぎを作る。
 * Math.random を使わないのは、sched_version を上げて response を再生したとき
 * due_at が前回と変わってしまうと再現性が失われるため（§3・§9）。
 */
export function jitterFromSeed(seed: number | string): number {
  const s = String(seed)
  let h = 2166136261
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i)
    h = Math.imul(h, 16777619)
  }
  return ((h >>> 0) / 0xffffffff) * 0.1 - 0.05
}

/**
 * SM-2 の1回分の更新。
 *
 * 引数の card は変更せず、新しい card を返す（response からの再生を単純にするため）。
 */
export function sm2Update({ card, q, deadline, today, jitter = 0 }: Sm2Input): Sm2Result {
  let n = card.n
  let lapses = card.lapses
  let interval: number

  if (q >= 3) {
    // 正答。n は「連続正答回数」なので、間隔は更新“前”の n で決める
    if (n === 0) interval = 1
    else if (n === 1) interval = 6
    else interval = Math.round(card.intervalDays * card.ef)
    n += 1
  } else {
    n = 0
    lapses += 1
    interval = 1
  }

  // EF は正誤にかかわらず毎回更新する（SM-2 原典どおり）
  const ef = Math.max(MIN_EF, card.ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))

  interval = Math.min(interval, MAX_INTERVAL_DAYS)

  const naturalDue = addDays(today, Math.round(interval * (1 + jitter)))
  const hardDue = deadline ? addDays(deadline, -DEADLINE_BUFFER_DAYS) : null

  let dueAt: Date
  let intervalDays: number
  let clamped = false

  if (hardDue && naturalDue.getTime() > hardDue.getTime()) {
    // 締切前に必ず一度復習させる。
    // このとき interval も ef も更新しない。クランプは学習者の想起能力ではなく
    // 締切の都合で早めているだけなので、それを難易度の情報として扱うと
    // 締切が近いほど EF が下がるという誤った学習になる（§6）。
    const tomorrow = addDays(today, 1)
    dueAt = hardDue.getTime() > tomorrow.getTime() ? hardDue : tomorrow
    intervalDays = card.intervalDays
    clamped = true
  } else {
    dueAt = naturalDue
    intervalDays = interval
  }

  return {
    card: {
      n,
      // クランプ時は EF も据え置く
      ef: clamped ? card.ef : ef,
      intervalDays,
      dueAt,
      lapses,
      suspended: card.suspended || lapses >= LEECH_THRESHOLD,
      lastReviewAt: today,
    },
    clamped,
  }
}

/**
 * 忘却曲線。docs/04b §6。
 * 間隔 I の設計上、次の復習時点での想起確率が 0.9 になるように SM-2 は間隔を決めている。
 */
export function retrievability(intervalDays: number, elapsedDays: number): number {
  if (intervalDays <= 0) return elapsedDays <= 0 ? 1 : 0
  return Math.pow(0.9, elapsedDays / intervalDays)
}
