'use client'

import { useState, useTransition } from 'react'
import Link from 'next/link'
import { submit } from './actions'

export type Choice = { key: string; text: string }
export type QuizItem = { id: string; stem: string; choices: Choice[]; kcLabel: string }

type Judged = { correct: boolean; answerKey: unknown; explanation: string | null }

/**
 * 出題と採点。
 *
 * ★ このコンポーネントは正答を知らない。answer_key はサーバーから
 *   採点結果と一緒に返ってきて初めて手に入る（docs/12 §6.1）。
 */
export function Quiz({ items }: { items: QuizItem[] }) {
  const [i, setI] = useState(0)
  const [startedAt, setStartedAt] = useState(() => Date.now())
  const [chosen, setChosen] = useState<string | null>(null)
  const [judged, setJudged] = useState<Judged | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  const item = items[i]
  if (!item) {
    return (
      <div className="hs-empty">
        <p className="lv-title">今日の分は終わりです</p>
        <Link className="lv-btn" href="/">ホームへ</Link>
      </div>
    )
  }

  const answer = (key: string) => {
    if (judged || pending) return
    setChosen(key)
    setError(null)
    startTransition(async () => {
      try {
        // 送るのは選んだキーだけ。correct は送らない
        const r = await submit({ itemId: item.id, chosen: key, latencyMs: Date.now() - startedAt })
        setJudged({ correct: r.correct, answerKey: r.answerKey, explanation: r.explanation })
      } catch (e) {
        setError(e instanceof Error ? e.message : '採点に失敗しました')
        setChosen(null)
      }
    })
  }

  const next = () => {
    setI(i + 1)
    setChosen(null)
    setJudged(null)
    setError(null)
    setStartedAt(Date.now())
  }

  const classOf = (key: string) => {
    if (!judged) return 'hs-choice'
    if (key === judged.answerKey) return 'hs-choice hs-choice--correct'
    if (key === chosen) return 'hs-choice hs-choice--wrong'
    return 'hs-choice'
  }

  return (
    <div style={{ display: 'grid', gap: 'var(--lv-space-4)' }}>
      <div className="hs-progress">
        <div className="hs-progress__bar">
          {items.map((it, n) => (
            <span key={it.id} className={`hs-progress__seg${n < i ? ' hs-progress__seg--done' : ''}`} />
          ))}
        </div>
        <span className="hs-progress__label">{i + 1} / {items.length}</span>
      </div>

      <span className="lv-label">{item.kcLabel}</span>
      <p className="lv-body">{item.stem}</p>

      <div>
        {item.choices.map(c => (
          <button
            key={c.key}
            type="button"
            className={classOf(c.key)}
            onClick={() => answer(c.key)}
            disabled={!!judged || pending}
            aria-pressed={chosen === c.key}
          >
            <span className="hs-choice__key">{c.key}</span>
            <span>{c.text}</span>
          </button>
        ))}
      </div>

      {error && <p className="lv-field-note">{error}</p>}

      {judged && (
        <div className="lv-card">
          <div className="lv-card__pad hs-stack">
            <p className="lv-heading">{judged.correct ? '正解' : '不正解'}</p>
            {judged.explanation && <p className="lv-body">{judged.explanation}</p>}
            <button type="button" className="lv-btn lv-btn--primary lv-btn--block" onClick={next}>
              {i + 1 < items.length ? '次へ' : '終わる'}
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
