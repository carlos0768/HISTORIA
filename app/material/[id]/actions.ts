'use server'

import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { recordRead, type ReadResult } from '@/lib/loop/material'
import { reportContent, type ReportTarget } from '@/lib/loop/report'
import { recordView } from '@/lib/loop/video'

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

/**
 * 動画の視聴を記録する（docs/09b-video.md §6.1）
 *
 * ★ 再生を押した時点で1件入れる。視聴時間の追跡はしない。
 *   iframe の中の再生位置は同一生成元ポリシーで読めず、
 *   読むには YouTube の IFrame API を読みこむことになる。それは
 *   「実行時に YouTube を呼ばない」（V1）と 2クリック（V3）の両方に反する。
 *   したがって watched_sec は 0 で記録し、**p_know は動かさない**。
 *   視聴を学習イベントとして数えるのは、時間が測れるようになってからにする。
 */
export async function watchVideo(input: {
  videoId: string
  watchedSec: number
}): Promise<{ counted: boolean }> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const r = await recordView(sql(), {
    userId, videoId: input.videoId, watchedSec: input.watchedSec, now: new Date(),
  })
  return { counted: r.counted }
}
