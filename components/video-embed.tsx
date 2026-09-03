'use client'

import { useState } from 'react'
import { VideoRetrieval, type RetrievalItem } from './video-retrieval'

/**
 * YouTube の2クリック埋め込み（docs/09b-video.md §5.1・V3）
 *
 * ★ **初期描画で iframe を出してはならない。** youtube-nocookie でも
 *   localStorage に `yt-remote-device-id` を置くため、開いただけで
 *   端末に識別子が残る。押されて初めて注入する。
 *   利用者は未成年なので、ここは緩めない（§1 制約2）。
 *
 * ★ サムネイルは i.ytimg.com から。CSP は proxy.ts:74 が既に許している
 *   （`img-src 'self' data: https://i.ytimg.com`）。
 *
 * ★ 自動再生しない。`autoplay` は付けない。`rel=0` で終了後の関連動画を
 *   同一チャンネル内に限り、`playsinline=1` で全画面へ飛ばさない（学習から離脱させない）。
 *
 * ★ ラベルを必ず付ける（§7）。「なぜこの動画が出ているのか」を書かずに
 *   サムネイルだけ並べると、動画そのものが目的化する。
 */
export function VideoEmbed({
  videoId, title, channelTitle, startSec, label, onPlay, retrieval,
}: {
  videoId: string
  title: string
  channelTitle: string
  startSec: number
  /** 「このセクションの理解を助ける動画」など、出している理由 */
  label: string
  onPlay?: () => void
  /**
   * 視聴後の retrieval（docs/09b V6）。渡さなければ出さない。
   *
   * ★ 押されてから取りに行く。教材を開いた時点で全動画ぶんの設問を引くと、
   *   一度も再生されない動画のために毎回問い合わせることになる。
   * ★ 2問そろわなければ `fetch` が空を返し、その場合は何も描かない。
   */
  retrieval?: {
    fetch: (videoId: string) => Promise<RetrievalItem[]>
    answer: (input: { itemId: string; chosen: string; latencyMs: number })
      => Promise<{ correct: boolean; explanation: string | null }>
  }
}) {
  const [playing, setPlaying] = useState(false)
  const [items, setItems] = useState<RetrievalItem[]>([])

  const src = `https://www.youtube-nocookie.com/embed/${videoId}` +
    `?start=${startSec}&rel=0&modestbranding=1&playsinline=1`

  return (
    <figure className="hs-video">
      <figcaption className="hs-video__note">{label}</figcaption>
      <div className="hs-video__frame">
        {playing ? (
          <iframe
            src={src}
            title={title}
            className="hs-video__thumb"
            allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            referrerPolicy="strict-origin-when-cross-origin"
            allowFullScreen
          />
        ) : (
          <>
            {/* next/image を使わない。外部ホストの許可を next.config に足すことになり、
                CSP と2箇所で同じことを書く羽目になる。素の img で足りる */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              className="hs-video__thumb"
              src={`https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`}
              alt=""
              loading="lazy"
            />
            <button
              type="button"
              className="hs-video__play"
              aria-label={`${title} を再生（YouTube で再生します）`}
              onClick={() => {
                setPlaying(true)
                onPlay?.()
                // ★ 押されてから取りに行く。2問そろわなければ空が返り、何も描かない
                retrieval?.fetch(videoId).then(setItems).catch(() => { /* 出さないだけ */ })
              }}
            >
              ▶
            </button>
          </>
        )}
      </div>
      <p className="hs-video__note">
        {title}（{channelTitle}）
      </p>
      {!playing && (
        <p className="hs-video__note">
          再生すると YouTube（Google）に情報が送信されます
        </p>
      )}

      {/* ★ 押してからしか出さない。再生していない動画の下に問題が並ぶと、
           本文を読む邪魔になるうえ、思い出す対象をまだ見ていないので
           retrieval にもなっていない（docs/09b V6） */}
      {playing && retrieval && items.length > 0 && (
        <VideoRetrieval items={items} answer={retrieval.answer} />
      )}
    </figure>
  )
}
