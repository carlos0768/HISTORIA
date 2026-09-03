'use client'

import { useState, useTransition } from 'react'

/**
 * 視聴後の retrieval（docs/09b-video.md V6・§6.2）
 *
 * ★ 動画は**見ただけでは身につかない**。見た直後に思い出す操作を1回挟むと、
 *   同じ視聴時間でも定着が変わる。それがこの2問の唯一の存在理由である。
 *
 * ★ **押してからしか出さない。** 再生していない動画の下に問題が並んでいると、
 *   本文を読む邪魔になるだけで、retrieval にもなっていない
 *   （思い出す対象をまだ見ていない）。
 *
 * ★ **2問そろわなければ何も出さない。** `retrievalAfterVideo` が
 *   足りなければ空を返す設計になっている（§6.2）。1問だけ出して
 *   数を埋めると、関係の薄い設問が混ざって retrieval の意味が消える。
 *
 * ★ 正誤はその場で出す。ここは測定ではなく練習なので、
 *   間違えたまま次へ進ませない（診断テストとは逆の扱い）。
 */
export type RetrievalItem = { id: string; stem: string; choices: { key: string; text: string }[] }

type Judged = { correct: boolean; explanation: string | null }

export function VideoRetrieval({
  items, answer,
}: {
  items: readonly RetrievalItem[]
  answer: (input: { itemId: string; chosen: string; latencyMs: number })
    => Promise<{ correct: boolean; explanation: string | null }>
}) {
  const [i, setI] = useState(0)
  const [judged, setJudged] = useState<Judged | null>(null)
  const [chosen, setChosen] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [startedAt, setStartedAt] = useState(() => Date.now())
  const [done, setDone] = useState(false)
  const [pending, start] = useTransition()

  // ★ 2問そろっていなければ、そもそも呼び出し側が空配列を渡す（§6.2）
  if (items.length === 0 || done) {
    return done
      ? <p className="lv-caption hs-video__note">思い出せました。本文に戻ってください。</p>
      : null
  }

  const item = items[i]!

  const send = (key: string) => {
    if (pending || judged) return
    setChosen(key)
    setError(null)
    start(async () => {
      try {
        setJudged(await answer({ itemId: item.id, chosen: key, latencyMs: Date.now() - startedAt }))
      } catch (e) {
        setChosen(null)
        setError(e instanceof Error ? e.message : '記録できませんでした')
      }
    })
  }

  const next = () => {
    if (i + 1 < items.length) {
      setI(i + 1); setJudged(null); setChosen(null); setStartedAt(Date.now())
    } else {
      setDone(true)
    }
  }

  return (
    <div className="hs-video__quiz">
      <span className="lv-label">見たあとに1つ思い出す（{i + 1} / {items.length}）</span>
      <p className="lv-body">{item.stem}</p>

      {item.choices.map(c => (
        <button
          key={c.key} type="button"
          className={`lv-btn lv-btn--block${
            judged && c.key === chosen ? (judged.correct ? ' hs-choice--correct' : ' hs-choice--wrong') : ''
          }`}
          disabled={pending || judged !== null}
          onClick={() => send(c.key)}
        >
          {c.text}
        </button>
      ))}

      {judged && (
        <>
          <p className="lv-body">{judged.correct ? '正解です。' : 'ここが抜けていました。'}</p>
          {judged.explanation && <p className="lv-caption">{judged.explanation}</p>}
          <button type="button" className="lv-btn lv-btn--block" onClick={next}>
            {i + 1 < items.length ? '次の問題' : '本文に戻る'}
          </button>
        </>
      )}
      {error && <p className="lv-field-note" role="status">{error}</p>}
    </div>
  )
}
