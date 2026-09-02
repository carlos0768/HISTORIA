'use server'

import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { recordRead, type ReadResult } from '@/lib/loop/material'
import { reportContent, type ReportTarget } from '@/lib/loop/report'

/**
 * セクションの読了を記録する。
 *
 * ★ 滞在時間はクライアントが測る。足りなくても記録は残し、数えないだけである
 *   （docs/11「読了判定」）。クライアントの自己申告を信じないのではなく、
 *   信じたうえで閾値の判定はサーバー側で持つ。
 */
export async function markRead(input: {
  sectionId: string
  dwellMs: number
  scrollPct: number | null
}): Promise<ReadResult> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const r = await recordRead(sql(), {
    userId,
    sectionId: input.sectionId,
    dwellMs: input.dwellMs,
    scrollPct: input.scrollPct,
    now: new Date(),
  })
  revalidatePath('/')
  return r
}

/**
 * 誤りを報告する（docs/08-ai-architecture.md §5 層4）
 *
 * ★ 教材の節と設問の両方をここで受ける。押す場所は違うが、
 *   起きることは同じなので入口を分けない。
 * ★ 押しても本文はその場で消えない。伏せるのは作者が確認したあとである
 *   （lib/loop/report.ts の resolveReport）。
 */
export async function report(input: {
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
