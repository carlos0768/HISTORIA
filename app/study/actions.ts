'use server'

import { sql } from '@/lib/db/client'
import { submitAnswer, type SessionKind } from '@/lib/loop/answer'
import { currentUserId } from '@/lib/auth/dal'
import { reportContent, type ReportTarget } from '@/lib/loop/report'

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

/**
 * 設問の誤りを報告する（docs/08-ai-architecture.md §5 層4）
 *
 * ★ 教材側の `report` と同じ処理を呼ぶ。入口が別なのは 'use server' の
 *   ファイル境界の都合だけで、起きることは同じである。
 */
export async function reportItem(input: {
  targetKind: ReportTarget
  targetId: string
  comment: string | null
}): Promise<{ duplicate: boolean }> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const r = await reportContent(sql(), {
    userId,
    targetKind: input.targetKind,
    targetId: input.targetId,
    comment: input.comment,
    now: new Date(),
  })
  return { duplicate: r.duplicate }
}
