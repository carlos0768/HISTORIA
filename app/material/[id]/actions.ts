'use server'

import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { recordRead, type ReadResult } from '@/lib/loop/material'

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
