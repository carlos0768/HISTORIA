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

const recallInput = cardInput.extend({
  answer: z.string().max(300),
  latencyMs: z.number().int().min(0).max(24 * 3600 * 1000),
})

async function authorizedCard(
  userId: string,
  drillId: string,
  itemId: string,
): Promise<{ answer: string }> {
  const db = sql()
  const [row] = await db<{ answer_key: unknown }[]>`
    SELECT i.answer_key
      FROM drill d
      JOIN drill_kc dk ON dk.drill_id = d.id
      JOIN item_kc ik ON ik.kc_id = dk.kc_id
      JOIN item i ON i.id = ik.item_id
     WHERE d.id = ${drillId} AND d.user_id = ${userId} AND d.status = 'active'
       AND i.id = ${itemId} AND i.format = 'flashcard'
       AND i.approved AND NOT i.hidden
       AND (i.user_id = ${userId} OR i.user_id IS NULL)
     LIMIT 1`
  if (!row || typeof row.answer_key !== 'string') throw new Error('このカードは開けません')
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

const normalizeAnswer = (value: string) => value
  .normalize('NFKC')
  .toLocaleLowerCase('ja-JP')
  .replace(/[\s\p{P}\p{S}]+/gu, '')

export async function answerRecall(input: unknown): Promise<{ correct: boolean; answer: string }> {
  const parsed = recallInput.parse(input)
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const card = await authorizedCard(userId, parsed.drillId, parsed.itemId)
  const correct = normalizeAnswer(parsed.answer) === normalizeAnswer(card.answer)

  await submitAnswer(sql(), {
    userId,
    itemId: parsed.itemId,
    sessionKind: 'quiz',
    drillId: parsed.drillId,
    chosen: correct ? 'known' : 'unknown',
    latencyMs: parsed.latencyMs,
    msSinceReveal: 1000,
    now: new Date(),
  })

  return { correct, answer: card.answer }
}
