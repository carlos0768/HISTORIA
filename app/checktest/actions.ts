'use server'

import { redirect } from 'next/navigation'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { submitAnswer } from '@/lib/loop/answer'
import { gradeCheckTest } from '@/lib/loop/checktest'

/**
 * 確認テストの1問に答える。
 *
 * ★ 正誤をここでは返さない。docs/06 §6.2 は誤答の解説を**結果画面**でまとめて出す
 *   構成にしている。1問ごとに正誤を返すと、外した時点で「もうだめだ」と分かり、
 *   残りを投げやりに答える。測定として弱くなる。
 *   （日々の出題 app/study は逆で、即時の正誤提示が retrieval practice の前提である）
 */
export async function answerCheckTest(input: {
  itemId: string
  chosen: unknown
  latencyMs: number | null
}): Promise<void> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  await submitAnswer(sql(), {
    userId,
    itemId: input.itemId,
    sessionKind: 'checktest',
    drillId: null,
    chosen: input.chosen,
    latencyMs: input.latencyMs,
    msSinceReveal: null,
    now: new Date(),
  })
}

/** 採点して結果画面へ送る */
export async function finishCheckTest(testId: string): Promise<void> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const r = await gradeCheckTest(sql(), userId, testId, new Date())
  if (!r) throw new Error('確認テストが見つかりません')
  redirect(`/checktest/result/${testId}`)
}
