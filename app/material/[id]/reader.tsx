'use client'

import { useCallback, useEffect, useRef, useState, useTransition } from 'react'
import Link from 'next/link'
import { Markdown } from '@/components/markdown'
import { markRead } from './actions'

export type SectionProps = {
  id: string
  ord: number
  heading: string
  bodyMd: string
  charCount: number
  hidden: boolean
  hiddenReason: string | null
  kcLabels: string[]
  read: boolean
  requiredMs: number
  estimatedMs: number
}

const mmss = (ms: number) => {
  const s = Math.max(0, Math.round(ms / 1000))
  return `${Math.floor(s / 60)}分${String(s % 60).padStart(2, '0')}秒`
}

const HIDDEN_REASON: Record<string, string> = {
  user_report: '誤りの報告があったため',
  factcheck_flag: '事実確認で疑いが出たため',
  moderation: '表示を控える判断をしたため',
}

/**
 * 1セクションぶんの表示と滞在時間の計測。
 *
 * ★ key={section.id} で毎回作り直す。節を変えたら計測もやり直しになる。
 *   effect の中で setState して初期化すると、描画が二重に走るうえに
 *   「どの節を測っているのか」が状態として曖昧になる。
 * ★ 滞在はタブが見えている間だけ数える。開きっぱなしを読了にしない。
 * ★ スクロール率だけでは判定しない（飛ばしても100%になる）。
 *   明示的な「読み終えた」＋滞在時間の両方を送る（docs/11「読了判定」）。
 */
function SectionPane({
  section, total, isRead, onCounted,
}: {
  section: SectionProps
  total: number
  isRead: boolean
  onCounted: () => void
}) {
  const activeMs = useRef(0)
  const since = useRef<number | null>(null)
  const maxScroll = useRef(0)
  const [shownMs, setShownMs] = useState(0)
  const [note, setNote] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  const stop = useCallback(() => {
    if (since.current !== null) {
      activeMs.current += Date.now() - since.current
      since.current = null
    }
  }, [])
  const start = useCallback(() => {
    if (since.current === null) since.current = Date.now()
  }, [])
  const elapsed = () => activeMs.current + (since.current === null ? 0 : Date.now() - since.current)

  useEffect(() => {
    // 節を開いた瞬間から数え始める
    if (document.visibilityState === 'visible') since.current = Date.now()
    window.scrollTo(0, 0)

    const onVisibility = () => (document.visibilityState === 'visible' ? start() : stop())
    const onScroll = () => {
      const max = document.documentElement.scrollHeight - window.innerHeight
      const pct = max <= 0 ? 1 : Math.min(1, window.scrollY / max)
      maxScroll.current = Math.max(maxScroll.current, pct)
    }
    const tick = window.setInterval(() => setShownMs(elapsed()), 1000)

    document.addEventListener('visibilitychange', onVisibility)
    window.addEventListener('scroll', onScroll, { passive: true })
    onScroll()
    return () => {
      document.removeEventListener('visibilitychange', onVisibility)
      window.removeEventListener('scroll', onScroll)
      window.clearInterval(tick)
      stop()
    }
  }, [start, stop])

  const finish = () => {
    if (pending) return
    stop()
    const dwellMs = activeMs.current
    start()
    startTransition(async () => {
      try {
        const r = await markRead({ sectionId: section.id, dwellMs, scrollPct: maxScroll.current })
        if (r.counted) {
          setNote(null)
          onCounted()
        } else {
          // 数えなかったことを隠さない。何が足りないかを出す
          setNote(
            `滞在 ${mmss(dwellMs)} は読了に足りません（あと ${mmss(r.requiredMs - dwellMs)}）。` +
            '記録は残しましたが、読んだ数には入れていません。',
          )
        }
      } catch (e) {
        setError(e instanceof Error ? e.message : '記録に失敗しました')
      }
    })
  }

  const remaining = section.requiredMs - shownMs

  return (
    <>
      <div className="lv-card">
        <div className="lv-card__pad hs-stack">
          <span className="lv-label">§{section.ord} / {total}</span>
          <p className="lv-title">{section.heading}</p>

          {section.hidden ? (
            <div className="hs-alert">
              <p className="hs-alert__title">このセクションは伏せています</p>
              <p className="lv-caption">
                理由: {HIDDEN_REASON[section.hiddenReason ?? ''] ?? '表示できないため'}
              </p>
            </div>
          ) : (
            <Markdown source={section.bodyMd} />
          )}

          {section.kcLabels.length > 0 && (
            <div className="lv-chips">
              {section.kcLabels.map(l => <span key={l} className="lv-chip">{l}</span>)}
            </div>
          )}
        </div>
      </div>

      <div className="hs-stack">
        <p className="lv-caption">
          この節は {section.charCount.toLocaleString('ja-JP')}字・目安 {mmss(section.estimatedMs)}。
          いま {mmss(shownMs)} 読んでいます
          {isRead || remaining <= 0 ? '' : `（あと ${mmss(remaining)} で読了）`}。
        </p>
        {note && <p className="lv-field-note">{note}</p>}
        {error && <p className="lv-field-note">{error}</p>}

        {isRead ? (
          <p className="lv-caption">この節は読了しています。</p>
        ) : (
          <button
            type="button"
            className="lv-btn lv-btn--primary lv-btn--block"
            disabled={pending || section.hidden}
            onClick={finish}
          >
            {pending ? '記録しています…' : '読み終えた'}
          </button>
        )}
      </div>
    </>
  )
}

/** 教材を1セクションずつ読む */
export function Reader({
  title, totalChars, sections,
}: { title: string; totalChars: number; sections: SectionProps[] }) {
  const [i, setI] = useState(() => {
    const first = sections.findIndex(s => !s.read && !s.hidden)
    return first === -1 ? 0 : first
  })
  const [readIds, setReadIds] = useState<Set<string>>(
    () => new Set(sections.filter(s => s.read).map(s => s.id)),
  )

  const section = sections[i]
  if (!section) {
    return (
      <div className="hs-empty">
        <p className="lv-body">表示できるセクションがありません。</p>
        <Link className="lv-btn" href="/">ホームへ</Link>
      </div>
    )
  }

  const counted = () => {
    setReadIds(prev => new Set(prev).add(section.id))
    // 数えられたときだけ次へ進む。
    // 足りないまま進めると、なぜ読了にならなかったのかが画面から消える
    if (i < sections.length - 1) setI(i + 1)
  }

  return (
    <>
      <div className="hs-stack">
        <span className="lv-label">{title}</span>
        <p className="lv-caption">
          全 {sections.length} 節 / {totalChars.toLocaleString('ja-JP')}字 ・
          読了 {readIds.size} / {sections.length}
        </p>
        <div className="hs-progress">
          {sections.map(s => (
            <span
              key={s.id}
              className={`hs-progress__seg${readIds.has(s.id) ? ' hs-progress__seg--done' : ''}`}
            />
          ))}
        </div>
      </div>

      <SectionPane
        key={section.id}
        section={section}
        total={sections.length}
        isRead={readIds.has(section.id)}
        onCounted={counted}
      />

      <div className="hs-stack">
        <div className="lv-chips">
          <button type="button" className="lv-chip" disabled={i === 0} onClick={() => setI(i - 1)}>
            ← 前の節
          </button>
          <button
            type="button"
            className="lv-chip"
            disabled={i >= sections.length - 1}
            onClick={() => setI(i + 1)}
          >
            次の節 →
          </button>
        </div>
        <Link className="lv-btn lv-btn--block" href="/">ホームへ</Link>
      </div>
    </>
  )
}
