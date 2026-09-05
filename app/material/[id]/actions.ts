'use server'

import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { recordRead, type ReadResult } from '@/lib/loop/material'
import { reportContent, type ReportTarget } from '@/lib/loop/report'
import { recordView, retrievalAfterVideo, type RetrievalItem } from '@/lib/loop/video'
import { submitAnswer } from '@/lib/loop/answer'

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

/**
 * 視聴後の retrieval を取りに行く（docs/09b-video.md V6・§6.2）
 *
 * ★ **押されてから呼ぶ。** 教材を開いた時点で全動画ぶんの設問を引くと、
 *   一度も再生されない動画のために毎回問い合わせることになる。
 *
 * ★ 2問そろわなければ空が返る（`retrievalAfterVideo` の設計）。
 *   画面はそのとき何も描かない。1問だけ出して数を埋めない。
 *
 * ★ 正答も解説もここでは返さない。採点は `answerRetrieval` が行う（docs/12 §6.1）。
 */
export async function videoRetrieval(videoId: string): Promise<RetrievalItem[]> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  return retrievalAfterVideo(sql(), userId, videoId)
}

/**
 * retrieval の1問を採点する。
 *
 * ★ `session_kind='video_retrieval'` で記録する。型は前から通っていたが、
 *   呼び出し元が無かった（配線の抜け）。これで docs/09b V6 が閉じる。
 *
 * ★ ここは**測定ではなく練習**なので、正誤をその場で返す。
 *   診断テスト（`app/diagnostic/actions.ts`）が正誤を返さないのと逆の扱いで、
 *   理由も逆である。あちらは途中で諦めさせないため、こちらは
 *   間違えたまま次へ進ませないため。
 */
export async function answerRetrieval(input: {
  itemId: string
  chosen: string
  latencyMs: number
}): Promise<{ correct: boolean; explanation: string | null }> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')
  const r = await submitAnswer(sql(), {
    userId, itemId: input.itemId, sessionKind: 'video_retrieval',
    chosen: input.chosen, latencyMs: input.latencyMs, now: new Date(),
  })
  return { correct: r.correct, explanation: r.explanation }
}
