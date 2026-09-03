'use server'

import { redirect } from 'next/navigation'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { answerDiagnostic, nextQuestion, finishDiagnostic } from '@/lib/loop/diagnostic'

/**
 * 診断テストの解答（docs/04-weakness-engine.md §5）
 *
 * ★ **正誤をその場で返さない。** 診断は測定であって練習ではない。
 *   途中で「7問連続で間違えている」と分かると、そこで閉じる人が出る。
 *   結果は最後にまとめて、しかも弱点として断定しない形で見せる（§5.5）。
 *
 * ★ 期待正答率（Elo 較正に使う）はサーバー側で作り直す。
 *   クライアントから受け取ると、Elo を任意に歪められる。
 */
export async function answerDiagnosticAction(input: {
  itemId: string
  chosen: unknown
  latencyMs: number | null
}): Promise<{ done: boolean; answered: number }> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const r = await answerDiagnostic(
    sql(), userId, input.itemId, input.chosen, input.latencyMs, new Date(),
  )
  // ★ correct は返さない（上記）
  return { done: r.done, answered: r.answered }
}

export type NextQuestion = {
  itemId: string
  stem: string
  choices: { key: string; text: string }[]
  index: number
  total: number
}

/** 次の1問を取りに行く。終わっていれば null */
export async function nextDiagnosticAction(): Promise<NextQuestion | null> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const { question } = await nextQuestion(sql(), userId)
  if (!question) return null
  return {
    itemId: question.itemId,
    stem: question.stem,
    // ★ expectedP を渡さない。較正の内部値であり、画面には要らない
    choices: (question.choices as { key: string; text: string }[] | null) ?? [],
    index: question.index,
    total: question.total,
  }
}

/** 診断を締めて結果へ。伝播（§5.4）はここで起きる */
export async function finishDiagnosticAction(): Promise<never> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  await finishDiagnostic(sql(), userId, new Date())
  redirect('/diagnostic/result')
}
