'use server'

import { z } from 'zod'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { submitAnswer } from '@/lib/loop/answer'

const cardInput = z.object({
  drillId: z.string().uuid(),
  itemId: z.string().uuid(),
})

const ratingInput = cardInput.extend({
  rating: z.enum(['unknown', 'vague', 'known', 'easy']),
  msSinceReveal: z.number().int().min(0).max(24 * 3600 * 1000),
})

const choiceInput = cardInput.extend({
  chosen: z.string().min(1).max(8),
  latencyMs: z.number().int().min(0).max(24 * 3600 * 1000),
})

type DrillItemRow = { answer_key: unknown; choices: unknown }

/**
 * 特訓に属し、いま出題してよい item だけを返す。
 * 特訓の外の item id を投げられても答えは出さない。
 */
async function authorizedItem(
  userId: string,
  drillId: string,
  itemId: string,
  format: 'flashcard' | 'mcq4',
): Promise<DrillItemRow> {
  const db = sql()
  const [row] = await db<DrillItemRow[]>`
    SELECT i.answer_key, i.choices
      FROM drill d
      JOIN drill_kc dk ON dk.drill_id = d.id
      JOIN item_kc ik ON ik.kc_id = dk.kc_id
      JOIN item i ON i.id = ik.item_id
     WHERE d.id = ${drillId} AND d.user_id = ${userId} AND d.status = 'active'
       AND i.id = ${itemId} AND i.format = ${format}
       AND i.approved AND NOT i.hidden
       AND (i.user_id = ${userId} OR i.user_id IS NULL)
     LIMIT 1`
  if (!row) throw new Error(format === 'flashcard' ? 'このカードは開けません' : 'この問題は出題できません')
  return row
}

async function authorizedCard(userId: string, drillId: string, itemId: string): Promise<{ answer: string }> {
  const row = await authorizedItem(userId, drillId, itemId, 'flashcard')
  if (typeof row.answer_key !== 'string') throw new Error('このカードは開けません')
  return { answer: row.answer_key }
}

export async function revealFlashcard(input: unknown): Promise<{ answer: string }> {
  const parsed = cardInput.parse(input)
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  return authorizedCard(userId, parsed.drillId, parsed.itemId)
}

export async function rateFlashcard(input: unknown): Promise<void> {
  const parsed = ratingInput.parse(input)
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  await authorizedCard(userId, parsed.drillId, parsed.itemId)
  await submitAnswer(sql(), {
    userId,
    itemId: parsed.itemId,
    sessionKind: 'flashcard',
    drillId: parsed.drillId,
    chosen: parsed.rating,
    latencyMs: null,
    msSinceReveal: parsed.msSinceReveal,
    now: new Date(),
  })
}

export type ChoiceJudged = {
  correct: boolean
  /** 正答の選択肢キー。採点が終わってから初めてクライアントに渡る */
  answerKey: string | null
  explanation: string | null
  /** 誤答のとき、選んだ選択肢がなぜ違うか（choices[].why_wrong。事前生成済み） */
  whyWrong: string | null
  /** SM-2 が決めた次の復習日。KC の重みが小さく SM-2 を呼ばなかったときは null */
  dueAt: Date | null
}

const whyWrongOf = (choices: unknown, key: string): string | null => {
  if (!Array.isArray(choices)) return null
  for (const c of choices) {
    if (c && typeof c === 'object' && (c as { key?: unknown }).key === key) {
      const why = (c as { why_wrong?: unknown }).why_wrong
      return typeof why === 'string' && why.trim() !== '' ? why : null
    }
  }
  return null
}

/**
 * 四択（一問一答モード）の採点。
 *
 * ★ クライアントが送るのは選んだキーだけ。correct は送らせない（docs/12 §6.1）。
 * ★ 採点も SM-2 の更新も submitAnswer に任せる。ここで q を決めない。
 *   四択の q は p_know と反応時間から objectiveGrade が決める（04b §4.1）。
 */
export async function answerDrillChoice(input: unknown): Promise<ChoiceJudged> {
  const parsed = choiceInput.parse(input)
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const item = await authorizedItem(userId, parsed.drillId, parsed.itemId, 'mcq4')

  const r = await submitAnswer(sql(), {
    userId,
    itemId: parsed.itemId,
    sessionKind: 'quiz',
    drillId: parsed.drillId,
    chosen: parsed.chosen,
    latencyMs: parsed.latencyMs,
    now: new Date(),
  })

  return {
    correct: r.correct,
    answerKey: typeof r.answerKey === 'string' ? r.answerKey : null,
    explanation: r.explanation,
    whyWrong: r.correct ? null : whyWrongOf(item.choices, parsed.chosen),
    dueAt: r.updatedKcs.reduce<Date | null>(
      (latest, kc) => (latest === null || kc.dueAt.getTime() > latest.getTime() ? kc.dueAt : latest),
      null,
    ),
  }
}
