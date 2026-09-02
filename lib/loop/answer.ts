/**
 * 解答の記録と状態更新 — 閉ループの中核
 *
 * 仕様: docs/04 §1.1・§4、docs/04b §3.1・§9、docs/12 §6.1
 *
 * ★ 正答はクライアントに配らない。correct はここでサーバーが決める（docs/12 §6.1）。
 * ★ response への記録が先、導出テーブルの更新は後。1トランザクションで両方を書く。
 *   response が唯一の真実であり、kc_card も user_kc_state もそこから再生成できる
 *   必要がある（docs/03 §2.2）。
 */
import type { Sql } from 'postgres'
import { sm2Update, jitterFromSeed, newKcCard, type KcCard, type Grade } from '@/lib/domain/sm2'
import { updateKcState, initialKcState, type KcState } from '@/lib/domain/weakness'
import { objectiveGrade, flashcardGrade, type FlashcardButton } from '@/lib/domain/grading'
import { ALGO_VERSION, SCHED_VERSION, GUESS, MISCONCEPTION_HITS, type ItemFormat } from '@/lib/domain/params'
import { jstDate } from '@/lib/domain/streak'

/** SM-2 を呼ぶ最小の重み。これ未満の KC はその設問が主に問うていない（04b §3.1） */
export const SM2_MIN_WEIGHT = 0.5

export type SessionKind = 'diagnostic' | 'flashcard' | 'quiz' | 'checktest' | 'video_retrieval' | 'import'

export type SubmitInput = {
  userId: string
  itemId: string
  sessionKind: SessionKind
  drillId?: string | null
  /** クライアントが送るのは選択だけ。correct は送らせない */
  chosen: unknown
  latencyMs: number | null
  /** フラッシュカードのみ。答えを表示してからの経過 ms */
  msSinceReveal?: number | null
  now: Date
}

export type SubmitResult = {
  responseId: string
  correct: boolean
  /** 採点後に初めて返す。ここまで一度もクライアントに出していない */
  answerKey: unknown
  explanation: string | null
  updatedKcs: Array<{ kcId: string; q: Grade; clamped: boolean; dueAt: Date }>
}

type ItemRow = {
  id: string
  format: ItemFormat
  answer_key: unknown
  explanation: string | null
  guess_rate: number
  approved: boolean
  hidden: boolean
  user_id: string | null
}

/** answer_key と chosen の突き合わせ。形式ごとに比較の意味が違う */
export function isCorrect(format: ItemFormat, answerKey: unknown, chosen: unknown): boolean {
  if (format === 'order') {
    if (!Array.isArray(answerKey) || !Array.isArray(chosen)) return false
    return answerKey.length === chosen.length && answerKey.every((v, i) => v === chosen[i])
  }
  if (format === 'flashcard') {
    // 自己申告。ボタンが 'known' | 'easy' なら正答扱い（q の算出は別途 §4.2）
    return chosen === 'known' || chosen === 'easy'
  }
  return JSON.stringify(answerKey) === JSON.stringify(chosen)
}

/** 誤答時に選ばれた選択肢キー。misconception の検出に使う */
function distractorKey(chosen: unknown): string | null {
  if (typeof chosen === 'string') return chosen
  if (typeof chosen === 'number') return String(chosen)
  return null
}

/**
 * 解答を1件記録し、その設問に紐づく KC の状態を更新する。
 *
 * 順序が重要である（04b §9）。
 *   1. item を読む（answer_key はここで初めてサーバー内に出る）
 *   2. correct を決める
 *   3. response を書く
 *   4. p_know_before を読んで q を決める  ← 更新“前”の値
 *   5. user_kc_state と kc_card を更新する
 * 4 と 5 が入れ替わると、同じ応答から違う q が出て再現性が失われる。
 */
export async function submitAnswer(db: Sql, input: SubmitInput): Promise<SubmitResult> {
  return db.begin(async tx => {
    const items = await tx<ItemRow[]>`
      SELECT id, format, answer_key, explanation, guess_rate, approved, hidden, user_id
        FROM item WHERE id = ${input.itemId}`
    const item = items[0]
    if (!item) throw new Error(`item が見つかりません: ${input.itemId}`)
    if (!item.approved || item.hidden) throw new Error(`出題が承認されていません: ${input.itemId}`)
    if (item.user_id !== null && item.user_id !== input.userId) {
      throw new Error('他のユーザーの設問には解答できません')
    }

    const correct = isCorrect(item.format, item.answer_key, input.chosen)

    // 紐づく KC と重み
    const kcs = await tx<{ kc_id: string; weight: number; base_difficulty: number }[]>`
      SELECT ik.kc_id, ik.weight, k.base_difficulty
        FROM item_kc ik JOIN kc k ON k.id = ik.kc_id
       WHERE ik.item_id = ${item.id}`

    // --- 3. response を書く（唯一の真実。これが先） ---
    const inserted = await tx<{ id: string }[]>`
      INSERT INTO response (user_id, item_id, session_kind, drill_id, correct, chosen, latency_ms, answered_at)
      VALUES (${input.userId}, ${item.id}, ${input.sessionKind}, ${input.drillId ?? null},
              ${correct}, ${tx.json(input.chosen as never)}, ${input.latencyMs}, ${input.now})
      RETURNING id`
    const responseId = String(inserted[0]!.id)

    await tx`
      UPDATE item SET observed_total = observed_total + 1,
                      observed_correct = observed_correct + ${correct ? 1 : 0}
       WHERE id = ${item.id}`

    // --- 3b. その日の活動を数える（ストリークの土台・docs/11-ux.md §7）---
    // ★ response と同じトランザクションで書く。別にすると「解答は入ったが
    //   その日の記録が無い」状態が生まれ、連続日数が理由もなく途切れる。
    // ★ 日付は Asia/Tokyo。UTC で入れると日本時間の深夜0〜9時が前日に落ちる。
    await tx`
      INSERT INTO user_activity (user_id, activity_date, responses)
      VALUES (${input.userId}, ${jstDate(input.now)}, 1)
      ON CONFLICT (user_id, activity_date)
        DO UPDATE SET responses = user_activity.responses + 1`

    const dk = correct ? null : distractorKey(input.chosen)
    const updatedKcs: SubmitResult['updatedKcs'] = []

    for (const { kc_id, weight, base_difficulty } of kcs) {
      // --- 4. 更新“前”の状態を読む ---
      const stRows = await tx<
        { p_know: number; theta: number; n_eff: number; n_obs: number; last_seen_at: Date | null }[]
      >`SELECT p_know, theta, n_eff, n_obs, last_seen_at
          FROM user_kc_state WHERE user_id = ${input.userId} AND kc_id = ${kc_id}`
      const prior = stRows[0]
      const state: KcState = prior
        ? {
            pKnow: prior.p_know, theta: prior.theta, nEff: prior.n_eff,
            nObs: prior.n_obs, lastSeenAt: prior.last_seen_at,
          }
        : await (async () => {
            const w = await tx<{ exam_weight: number }[]>`SELECT exam_weight FROM kc WHERE id = ${kc_id}`
            // exam_weight は 1.0 が標準。0〜2 を 0〜1 に正規化して事前分布に使う
            return initialKcState(Math.min(1, Math.max(0, (w[0]?.exam_weight ?? 1) / 2)))
          })()

      // 誤概念の判定は q の算出に要るので先に見る
      let misconceptionHit = false
      if (dk) {
        const m = await tx<{ hits: number }[]>`
          INSERT INTO misconception (user_id, kc_id, distractor_key, hits, last_at)
          VALUES (${input.userId}, ${kc_id}, ${dk}, 1, ${input.now})
          ON CONFLICT (user_id, kc_id, distractor_key)
          DO UPDATE SET hits = misconception.hits + 1, last_at = ${input.now}, resolved_at = NULL
          RETURNING hits`
        misconceptionHit = Number(m[0]!.hits) >= MISCONCEPTION_HITS
      }

      const q: Grade =
        item.format === 'flashcard'
          ? flashcardGrade(input.chosen as FlashcardButton, input.msSinceReveal ?? null)
          : objectiveGrade({
              correct,
              latencyMs: input.latencyMs,
              pKnowBefore: state.pKnow, // ← 更新前
              misconceptionHit,
              format: item.format,
            })

      // --- 5a. マスタリー層 ---
      const next = updateKcState(state, {
        correct, latencyMs: input.latencyMs, format: item.format,
        weight, baseDifficulty: base_difficulty, answeredAt: input.now,
      })
      await tx`
        INSERT INTO user_kc_state (user_id, kc_id, theta, p_know, n_obs, n_eff, last_seen_at,
                                   first_correct_at, algo_version, updated_at)
        VALUES (${input.userId}, ${kc_id}, ${next.theta}, ${next.pKnow}, ${next.nObs}, ${next.nEff},
                ${input.now}, ${correct ? input.now : null}, ${ALGO_VERSION}, ${input.now})
        ON CONFLICT (user_id, kc_id) DO UPDATE SET
          theta = EXCLUDED.theta, p_know = EXCLUDED.p_know, n_obs = EXCLUDED.n_obs,
          n_eff = EXCLUDED.n_eff, last_seen_at = EXCLUDED.last_seen_at,
          first_correct_at = COALESCE(user_kc_state.first_correct_at, EXCLUDED.first_correct_at),
          algo_version = EXCLUDED.algo_version, updated_at = EXCLUDED.updated_at`

      // --- 5b. スケジュール層。weight が小さい KC は SM-2 を呼ばない（04b §3.1） ---
      if (weight < SM2_MIN_WEIGHT) continue

      const cardRows = await tx<
        { n: number; ef: number; interval_days: number; due_at: Date; lapses: number;
          suspended: boolean; last_review_at: Date | null }[]
      >`SELECT n, ef, interval_days, due_at, lapses, suspended, last_review_at
          FROM kc_card WHERE user_id = ${input.userId} AND kc_id = ${kc_id}`
      const card: KcCard = cardRows[0]
        ? {
            n: cardRows[0].n, ef: cardRows[0].ef, intervalDays: cardRows[0].interval_days,
            dueAt: cardRows[0].due_at, lapses: cardRows[0].lapses,
            suspended: cardRows[0].suspended, lastReviewAt: cardRows[0].last_review_at,
          }
        : newKcCard(input.now)

      // その KC を含む active な特訓のうち最も早い締切
      const dl = await tx<{ deadline: Date }[]>`
        SELECT min(d.deadline)::timestamptz AS deadline
          FROM drill d JOIN drill_kc dk ON dk.drill_id = d.id
         WHERE d.user_id = ${input.userId} AND d.status = 'active' AND dk.kc_id = ${kc_id}`

      const r = sm2Update({
        card, q, deadline: dl[0]?.deadline ?? null, today: input.now,
        jitter: jitterFromSeed(`${responseId}:${kc_id}`),
      })

      await tx`
        INSERT INTO kc_card (user_id, kc_id, n, ef, interval_days, due_at, last_review_at,
                             lapses, suspended, sched_version)
        VALUES (${input.userId}, ${kc_id}, ${r.card.n}, ${r.card.ef}, ${r.card.intervalDays},
                ${r.card.dueAt}, ${r.card.lastReviewAt}, ${r.card.lapses}, ${r.card.suspended},
                ${SCHED_VERSION})
        ON CONFLICT (user_id, kc_id) DO UPDATE SET
          n = EXCLUDED.n, ef = EXCLUDED.ef, interval_days = EXCLUDED.interval_days,
          due_at = EXCLUDED.due_at, last_review_at = EXCLUDED.last_review_at,
          lapses = EXCLUDED.lapses, suspended = EXCLUDED.suspended,
          sched_version = EXCLUDED.sched_version`

      await tx`UPDATE response SET q = ${q}, clamped = ${r.clamped} WHERE id = ${responseId}`
      updatedKcs.push({ kcId: kc_id, q, clamped: r.clamped, dueAt: r.card.dueAt })
    }

    // 誤概念が解消したら閉じる
    if (correct) {
      await tx`
        UPDATE misconception SET resolved_at = ${input.now}
         WHERE user_id = ${input.userId} AND resolved_at IS NULL
           AND kc_id IN ${tx(kcs.map(k => k.kc_id))}
           AND EXISTS (SELECT 1 FROM user_kc_state s
                        WHERE s.user_id = misconception.user_id AND s.kc_id = misconception.kc_id
                          AND s.p_know >= 0.85)`
    }

    return {
      responseId,
      correct,
      answerKey: item.answer_key, // 採点が終わってから初めて返す
      explanation: item.explanation,
      updatedKcs,
    }
  }) as Promise<SubmitResult>
}

/** guess_rate は形式から決まる。item 生成時にこれを入れる */
export const guessRateFor = (format: ItemFormat): number => GUESS[format]
