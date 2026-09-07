'use client'

import { useState, useTransition, type KeyboardEvent } from 'react'
import Link from 'next/link'
import type { DrillCard } from '@/lib/loop/drill-study'
import { rateFlashcard, revealFlashcard } from '../actions'

const RATINGS = [
  { value: 'unknown', label: 'わからない' },
  { value: 'vague', label: 'あいまい' },
  { value: 'known', label: 'わかった' },
  { value: 'easy', label: '余裕' },
] as const

type Rating = typeof RATINGS[number]['value']

/**
 * フラッシュカード。
 *
 * 表に問題、タップで裏返して答え。裏返したあとに4段階で自己申告する
 * （docs/11-ux.md §3・04b §4.2。ボタンは4つに固定）。
 *
 * ★ 答えはカードをめくったときに初めてサーバーから取る。一覧に答えを
 *   同梱しない（docs/12 §6.1）。めくった時刻はそのまま msSinceReveal の起点になり、
 *   800ms 未満の「わかった／余裕」はサーバー側で q=3 に丸められる。
 * ★ 一度めくったカードは何度でも表裏を行き来できる。起点は最初にめくった時刻のまま。
 */
export function Flashcards({ cards, drillId }: { cards: DrillCard[]; drillId: string }) {
  const [index, setIndex] = useState(0)
  const [answer, setAnswer] = useState<string | null>(null)
  const [flipped, setFlipped] = useState(false)
  const [revealedAt, setRevealedAt] = useState<number | null>(null)
  const [tally, setTally] = useState<Record<Rating, number>>({ unknown: 0, vague: 0, known: 0, easy: 0 })
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()
  const card = cards[index]

  if (!card) {
    const remembered = tally.known + tally.easy
    return (
      <div className="hs-empty">
        <p className="lv-title">カードは終わりです</p>
        <p className="lv-body">{cards.length}枚中 {remembered}枚 わかった</p>
        <p className="lv-caption">
          {RATINGS.map(r => `${r.label} ${tally[r.value]}`).join('・')}
        </p>
        <Link className="lv-btn" href={`/drills/${drillId}`}>勉強方法を選ぶ</Link>
      </div>
    )
  }

  const flip = () => {
    if (pending) return
    if (answer !== null) {
      setFlipped(current => !current)
      return
    }
    setError(null)
    startTransition(async () => {
      try {
        const result = await revealFlashcard({ drillId, itemId: card.id })
        setAnswer(result.answer)
        setRevealedAt(Date.now())
        setFlipped(true)
      } catch (e) {
        setError(e instanceof Error ? e.message : '答えを開けませんでした')
      }
    })
  }

  const onKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault()
      flip()
    }
  }

  const rate = (rating: Rating) => {
    if (revealedAt === null || pending) return
    setError(null)
    startTransition(async () => {
      try {
        await rateFlashcard({
          drillId,
          itemId: card.id,
          rating,
          msSinceReveal: Date.now() - revealedAt,
        })
        setTally(current => ({ ...current, [rating]: current[rating] + 1 }))
        setIndex(current => current + 1)
        setAnswer(null)
        setFlipped(false)
        setRevealedAt(null)
      } catch (e) {
        setError(e instanceof Error ? e.message : '記録できませんでした')
      }
    })
  }

  return (
    <div className="hs-study-session">
      <div className="hs-progress">
        <div className="hs-progress__bar">
          {cards.map((item, n) => (
            <span key={item.id} className={`hs-progress__seg${n < index ? ' hs-progress__seg--done' : ''}`} />
          ))}
        </div>
        <span className="hs-progress__label">{index + 1} / {cards.length}</span>
      </div>

      <div
        className={`hs-fc${flipped ? ' hs-fc--flipped' : ''}${pending && answer === null ? ' hs-fc--loading' : ''}`}
        role="button"
        tabIndex={0}
        aria-pressed={flipped}
        aria-label={flipped ? '表に戻す' : '答えを見る'}
        onClick={flip}
        onKeyDown={onKeyDown}
      >
        <div className="hs-fc__inner">
          <div className="hs-fc__face hs-fc__face--front" aria-hidden={flipped}>
            <span className="lv-label">{card.kcLabel}</span>
            <p className="hs-fc__text">{card.front}</p>
            <span className="hs-fc__hint">{pending && answer === null ? '開いています…' : 'タップして答えを見る'}</span>
          </div>
          <div className="hs-fc__face hs-fc__face--back" aria-hidden={!flipped}>
            <span className="lv-label">答え</span>
            <p className="hs-fc__text" aria-live="polite">{answer ?? ''}</p>
            <span className="hs-fc__hint">タップで問題に戻る</span>
          </div>
        </div>
      </div>

      <div className="hs-rating-grid" aria-label="覚え具合">
        {RATINGS.map(rating => (
          <button
            key={rating.value}
            type="button"
            className={`lv-btn${rating.value === 'known' || rating.value === 'easy' ? ' lv-btn--primary' : ''}`}
            disabled={pending || revealedAt === null}
            onClick={() => rate(rating.value)}
          >
            {rating.label}
          </button>
        ))}
      </div>
      {revealedAt === null && <p className="lv-caption hs-fc__note">カードをめくると覚え具合を選べます。</p>}
      {error && <p className="lv-field-note" role="alert">{error}</p>}
    </div>
  )
}
