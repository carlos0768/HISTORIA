/**
 * 弱点推定 — BKT 風ベイズ更新 ＋ Elo（θ のみ）
 *
 * 仕様: docs/04-weakness-engine.md §1, §2, §3
 *
 * BKT の4パラメータをデータから推定せず、出題形式から決まる定数にする。
 * これで縮退問題も推定コストも消える（§1）。
 */
import {
  GUESS, SLIP_NORMAL, SLIP_FAST, FAST_ANSWER_MS, T_LEARN,
  ELO_K_BASE, ELO_K_DECAY, THETA_0,
  N_EFF_UNKNOWN, N_EFF_MASTERED, MASTERY_WEAK, MASTERY_MASTERED,
  type ItemFormat,
} from './params'
import { retrievability } from './sm2'

export type KcState = {
  pKnow: number
  theta: number
  /** 実効証拠量。推測で当たった分を割り引く（§1.2） */
  nEff: number
  /** 素の観測数。Elo の K 減衰に使う */
  nObs: number
  lastSeenAt: Date | null
}

export type MasteryStatus = 'unknown' | 'weak' | 'shaky' | 'mastered'

/** 冷スタートの事前分布（§5.4）。頻出＝先に習う＝既知の確率が高い、という弱い事前情報 */
export function initialKcState(examWeightNormalized: number): KcState {
  const p = 0.15 + 0.25 * examWeightNormalized
  return {
    pKnow: Math.min(0.45, Math.max(0.1, p)),
    theta: THETA_0,
    nEff: 0,
    nObs: 0,
    lastSeenAt: null,
  }
}

const sigmoid = (x: number) => 1 / (1 + Math.exp(-x))

export type ResponseFacts = {
  correct: boolean
  latencyMs: number | null
  format: ItemFormat
  /** item_kc.weight。この KC がその設問でどれだけ主題か */
  weight: number
  /** KC の基準難易度。item 難易度は較正できないのでこれを代用する（§1.1） */
  baseDifficulty: number
  answeredAt: Date
}

/** 誤答かつ即答はケアレス寄りとみなす（§1.1） */
export function slipRate(correct: boolean, latencyMs: number | null): number {
  return !correct && latencyMs !== null && latencyMs < FAST_ANSWER_MS ? SLIP_FAST : SLIP_NORMAL
}

/**
 * 1つの KC の状態を1応答で更新する。
 * 引数の state は変更せず、新しい state を返す。
 */
export function updateKcState(state: KcState, f: ResponseFacts): KcState {
  const g = GUESS[f.format]
  const sl = slipRate(f.correct, f.latencyMs)

  // --- P(習得) のベイズ更新 ---
  let num: number
  let den: number
  if (f.correct) {
    num = state.pKnow * (1 - sl)
    den = num + (1 - state.pKnow) * g
  } else {
    num = state.pKnow * sl
    den = num + (1 - state.pKnow) * (1 - g)
  }
  const post = den === 0 ? state.pKnow : num / den

  // --- 遭遇による学習 ---
  const pKnow = post + (1 - post) * T_LEARN

  // --- Elo。学習者 θ のみ更新する。
  //     item 難易度 b は毎回生成では観測が溜まらず較正が原理的に成立しない（§1）
  const pExp = g + (1 - g) * sigmoid(state.theta - f.baseDifficulty)
  const ku = ELO_K_BASE / (1 + ELO_K_DECAY * state.nObs)
  const theta = state.theta + f.weight * ku * ((f.correct ? 1 : 0) - pExp)

  // --- 実効証拠量。四択で正解しても 0.75 しか増えない。
  //     四択を回すだけで習得度が上がる報酬ハックを防ぐ（§1.2）
  const nEff = state.nEff + (f.correct ? f.weight * (1 - g) : f.weight)

  return { pKnow, theta, nEff, nObs: state.nObs + 1, lastSeenAt: f.answeredAt }
}

/** 忘却を織り込んだ現在の習得度（§2） */
export function mastery(state: KcState, intervalDays: number, now: Date): number {
  if (!state.lastSeenAt) return state.pKnow
  const elapsedDays = (now.getTime() - state.lastSeenAt.getTime()) / 86_400_000
  return state.pKnow * retrievability(intervalDays, elapsedDays)
}

export type MasteryEvidence = {
  /** 別日に正解した日数。同一セッションの連続正解を習得と見なさない（分散学習の原則） */
  distinctCorrectDays: number
  /** フラッシュカード以外での正解があるか。「わかった」連打で100%になるのを防ぐ */
  hasNonFlashcardCorrect: boolean
}

/**
 * マスタリーの4状態（§2）。
 *
 * 'unknown' を設けるのが決定的に重要である。これが無いと初回の確認テストで
 * 「弱点120件」が並んでホームが破綻し、逆に四択を数回回すだけで全KCが
 * mastered になって1日ノルマが0になる。どちらもリリース初日に起きる。
 */
export function masteryStatus(state: KcState, m: number, ev: MasteryEvidence): MasteryStatus {
  if (state.nEff < N_EFF_UNKNOWN) return 'unknown'
  if (m < MASTERY_WEAK) return 'weak'
  if (m < MASTERY_MASTERED) return 'shaky'
  // mastered は追加条件を全て満たしたときだけ
  if (state.nEff >= N_EFF_MASTERED && ev.distinctCorrectDays >= 2 && ev.hasNonFlashcardCorrect) {
    return 'mastered'
  }
  return 'shaky'
}
