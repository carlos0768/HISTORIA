'use server'

import { sql } from '@/lib/db/client'
import { submitAnswer, type SessionKind } from '@/lib/loop/answer'
import { currentUserId } from '@/lib/auth/dal'

/**
 * 解答を受け取って採点する。
 *
 * ★ クライアントが送るのは chosen だけである。correct は送らせない。
 *   正答はこの応答で初めてクライアントに渡る（docs/12 §6.1）。
 */
export async function submit(input: {
  itemId: string
  chosen: unknown
  latencyMs: number | null
  msSinceReveal?: number | null
  sessionKind?: SessionKind
  drillId?: string | null
}) {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const r = await submitAnswer(sql(), {
    userId,
    itemId: input.itemId,
    sessionKind: input.sessionKind ?? 'quiz',
    drillId: input.drillId ?? null,
    chosen: input.chosen,
    latencyMs: input.latencyMs,
    msSinceReveal: input.msSinceReveal ?? null,
    now: new Date(),
  })
  return {
    correct: r.correct,
    answerKey: r.answerKey,
    explanation: r.explanation,
    dueAt: r.updatedKcs[0]?.dueAt ?? null,
  }
}
