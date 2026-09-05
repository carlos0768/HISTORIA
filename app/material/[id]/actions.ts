'use server'

import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { recordRead, type ReadResult } from '@/lib/loop/material'
import { reportContent, type ReportTarget } from '@/lib/loop/report'
import { recordView, retrievalAfterVideo, type RetrievalItem } from '@/lib/loop/video'
import { submitAnswer } from '@/lib/loop/answer'
import { createClient, type Client } from '@/lib/ai/client'
import { BudgetExceededError } from '@/lib/ai/budget'
import { assertNoIdentifiers } from '@/lib/ai/redact'
import { parseQuery, research, embedCoverage, type ResearchResponse } from '@/lib/loop/research'

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

/**
 * 教材の中の「調べる」（docs/11-ux.md §4.1）
 *
 * ★ 検索語は**利用者が入れた語そのもの**を埋め込みの API へ送る。
 *   docs/08 §4.1 が自由入力を送らないとしているのは学習データの話で、
 *   ここは「範囲指定の自然文」と同じ例外である（同 §4.1 の但し書き）。
 *   それでも上限（QUERY_MAX_CHARS）と UUID の検査は通し、画面には送る旨を先に書く。
 *
 * ★ 意味で引けないときは語の一致だけで引き、**そう言う**。
 *   鍵が無い（フェイクの埋め込みは意味を持たない）／PGVECTOR=off／
 *   支出上限／埋め込みがまだ空、のどれでも検索そのものは止めない。
 *
 * ★ 個人の情報は返さない。kc と canon_event は全員が同じものを読む正典である。
 */
export async function researchTextbook(rawQuery: string): Promise<ResearchResponse> {
  const userId = await currentUserId()
  if (!userId) throw new Error('ユーザーが特定できません')

  const parsed = parseQuery(typeof rawQuery === 'string' ? rawQuery : '')
  if ('error' in parsed) return { ok: false, error: parsed.error }
  const { query } = parsed

  const db = sql()
  const now = new Date()
  let vector: number[] | null = null
  let note: string | null = null

  /**
   * ★ **設定の誤りで画面を落とさない。**
   *   `createClient` は `assertConfig` を呼び、環境変数の組み合わせが
   *   おかしいと例外を投げる（生成と検証が同じプロバイダ／モデル id と
   *   プロバイダの食い違い）。ここはそれを受けていなかったので、
   *   **Vercel の環境変数を1つ間違えるだけで「うまくいきませんでした」**になり、
   *   しかも理由がどこにも出なかった。
   *
   *   この関数の他の失敗（鍵が無い・pgvector が無い・予算上限・埋め込みの失敗）は
   *   すべて「語の一致だけで引く」に落として note で理由を出している。
   *   設定の誤りだけが致命的である理由は無い。同じ扱いにする。
   */
  let client: Client | null = null
  try {
    client = createClient()
  } catch (e) {
    note = `AI の設定が正しくないため、語の一致だけで引いています（${
      e instanceof Error ? e.message : String(e)}）`
  }

  if (client === null) {
    // note は設定済み。埋め込みは作らない
  } else if (client.embedProviderName.startsWith('fake')) {
    note = 'AI の鍵が無いため、語の一致だけで引いています。'
  } else if (process.env.PGVECTOR === 'off') {
    note = 'このデータベースには pgvector が無いため、語の一致だけで引いています。'
  } else {
    try {
      assertNoIdentifiers(query)
    } catch {
      return { ok: false, error: '検索語に識別子（UUID）が含まれています。語だけを入れてください。' }
    }
    try {
      const out = await client.embed({ db, texts: [query], now })
      vector = out.vectors[0] ?? null
    } catch (e) {
      note = e instanceof BudgetExceededError
        ? '今月の AI 支出が上限に達しているため、語の一致だけで引いています。'
        : '意味の近さでは引けなかったため、語の一致だけで引いています。'
    }
  }

  const hits = await research(db, { query, vector })
  const mode = vector === null ? 'text' : 'hybrid'

  // ベクトルは作れたのに近傍が1件も無い＝索引がまだ空。黙って「語の一致だけ」の顔をしない
  if (mode === 'hybrid' && hits.every(h => h.similarity === null)) {
    const c = await embedCoverage(db)
    if (c.kc.embedded === 0 && c.canonEvent.embedded === 0) {
      note = '埋め込みの索引がまだ作られていないため、語の一致だけで引けています（npm run db:embed-index）。'
    }
  }

  return { ok: true, query, mode, note, hits }
}
