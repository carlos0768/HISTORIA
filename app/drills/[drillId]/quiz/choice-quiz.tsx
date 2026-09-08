'use client'

import { useState, useTransition } from 'react'
import Link from 'next/link'
import type { DrillQuizItem } from '@/lib/loop/drill-study'
import { answerDrillChoice, type ChoiceJudged } from '../actions'

const KIND_LABEL: Record<DrillQuizItem['kind'], string> = {
  review: '復習',
  new: 'はじめて',
  ahead: '先取り',
}

const DAY_MS = 86_400_000

/** 次の復習日を「n日後」で言う。同日なら「今日」 */
function dueLabel(dueAt: Date, now: Date): string {
  const days = Math.round((dueAt.getTime() - now.getTime()) / DAY_MS)
  if (days <= 0) return '今日'
  if (days === 1) return '明日'
  return `${days}日後`
}

/**
 * 特訓の一問一答（四択）。
 *
 * ★ このコンポーネントは正答を知らない。answer_key は採点結果と一緒に
 *   サーバーから返ってきて初めて手に入る（docs/12 §6.1）。
 * ★ 1画面1問。解答後は即座に正誤と解説を出す（docs/11-ux.md §3）。
 */
export function ChoiceQuiz({ items, drillId }: { items: DrillQuizItem[]; drillId: string }) {
  const [index, setIndex] = useState(0)
  const [startedAt, setStartedAt] = useState(() => Date.now())
  const [chosen, setChosen] = useState<string | null>(null)
  const [judged, setJudged] = useState<ChoiceJudged | null>(null)
  const [correctCount, setCorrectCount] = useState(0)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()
  const item = items[index]

  if (!item) {
    return (
      <div className="hs-empty">
        <p className="lv-title">一問一答は終わりです</p>
        <p className="lv-body">{items.length}問中 {correctCount}問 正解</p>
        <Link className="lv-btn" href={`/drills/${drillId}`}>勉強方法を選ぶ</Link>
      </div>
    )
  }

  const answer = (key: string) => {
    if (judged || pending) return
    setChosen(key)
    setError(null)
    startTransition(async () => {
      try {
        const result = await answerDrillChoice({
          drillId,
          itemId: item.id,
          chosen: key,
          latencyMs: Date.now() - startedAt,
        })
        setJudged(result)
        if (result.correct) setCorrectCount(count => count + 1)
      } catch (e) {
        setChosen(null)
        setError(e instanceof Error ? e.message : '採点できませんでした')
      }
    })
  }

  const next = () => {
    setIndex(current => current + 1)
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
    <div className="hs-study-session">
      <div className="hs-progress">
        <div className="hs-progress__bar">
          {items.map((it, n) => (
            <span key={it.id} className={`hs-progress__seg${n < index ? ' hs-progress__seg--done' : ''}`} />
          ))}
        </div>
        <span className="hs-progress__label">{index + 1} / {items.length}</span>
      </div>

      <div className="hs-titlerow">
        <span className="lv-label">{item.kcLabel}</span>
        <span className="lv-caption">{KIND_LABEL[item.kind]}</span>
      </div>
      <p className="lv-body hs-quiz__stem">{item.stem}</p>

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

      {error && <p className="lv-field-note" role="alert">{error}</p>}

      {judged && (
        <div className="lv-card" aria-live="polite">
          <div className="lv-card__pad hs-stack">
            <p className="lv-heading">{judged.correct ? '正解' : '不正解'}</p>
            {judged.whyWrong && <p className="lv-body">{judged.whyWrong}</p>}
            {judged.explanation && <p className="lv-body">{judged.explanation}</p>}
            {judged.dueAt && (
              <p className="lv-caption">次の復習: {dueLabel(new Date(judged.dueAt), new Date())}</p>
            )}
            <button type="button" className="lv-btn lv-btn--primary lv-btn--block" onClick={next}>
              {index + 1 < items.length ? '次へ' : '終わる'}
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
