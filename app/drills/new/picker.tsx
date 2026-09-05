'use client'

import { useMemo, useState, useTransition } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import type { UnitTreeNode } from '@/lib/pipeline/drill'
import { createDrillAction, type CreateResult } from '../actions'

/**
 * 章立てから範囲を選ぶ（docs/07 §8.1 ルートA）。LLM を使わない。
 *
 * ★ KC が0件の節も隠さずに出す。隠すと「教科書にあるのに出てこない」と映り、
 *   何が足りないのかが分からなくなる。選べないことと理由を書く。
 */
export function RangePicker({
  tree, defaultDeadline, initialUnitId,
}: { tree: UnitTreeNode[]; defaultDeadline: string; initialUnitId?: string }) {
  const router = useRouter()
  const [selected, setSelected] = useState<Set<string>>(() => {
    if (!initialUnitId) return new Set()
    const selectable = tree.some(part => part.children.some(chapter =>
      chapter.children.some(section => section.id === initialUnitId && section.kcCount > 0)))
    return selectable ? new Set([initialUnitId]) : new Set()
  })
  const [open, setOpen] = useState<Set<string>>(() => new Set(tree.filter(n => n.kcCount > 0).map(n => n.id)))
  const [title, setTitle] = useState('')
  const [deadline, setDeadline] = useState(defaultDeadline)
  const [result, setResult] = useState<CreateResult | null>(null)
  const [pending, startTransition] = useTransition()

  /** 選べる節（KC が1件以上ある節）だけを id で引けるようにしておく */
  const leaves = useMemo(() => {
    const m = new Map<string, UnitTreeNode>()
    const walk = (n: UnitTreeNode) => {
      if (n.children.length === 0) m.set(n.id, n)
      else n.children.forEach(walk)
    }
    tree.forEach(walk)
    return m
  }, [tree])

  const kcCount = useMemo(
    () => [...selected].reduce((n, id) => n + (leaves.get(id)?.kcCount ?? 0), 0),
    [selected, leaves],
  )

  const toggleLeaf = (id: string) => {
    setResult(null)
    setSelected(prev => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  /** 章をまとめて入れる・外す。全部入っていれば外す */
  const toggleChapter = (node: UnitTreeNode) => {
    const ids = node.children.filter(c => c.kcCount > 0).map(c => c.id)
    if (ids.length === 0) return
    setResult(null)
    setSelected(prev => {
      const next = new Set(prev)
      const allOn = ids.every(id => next.has(id))
      ids.forEach(id => (allOn ? next.delete(id) : next.add(id)))
      return next
    })
  }

  const toggleOpen = (id: string) =>
    setOpen(prev => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })

  const submit = (confirm: boolean) => {
    if (pending) return
    startTransition(async () => {
      const r = await createDrillAction({ title, unitIds: [...selected], deadline, confirm })
      setResult(r)
      if (r.ok) router.push('/')
    })
  }

  return (
    <>
      <div className="hs-stack">
        <span className="lv-label">範囲</span>
        {tree.map(part => (
          <div key={part.id} className="lv-card">
            <div className="lv-card__pad hs-stack">
              <button
                type="button"
                className="hs-tree__toggle"
                aria-expanded={open.has(part.id)}
                onClick={() => toggleOpen(part.id)}
              >
                <span className="lv-heading">{part.label}</span>
                <span className="lv-caption">
                  {part.kcCount === 0 ? 'KC なし' : `${part.kcCount} KC`}
                  {open.has(part.id) ? ' −' : ' ＋'}
                </span>
              </button>

              {open.has(part.id) && part.children.map(ch => (
                <div key={ch.id} className="hs-tree__chapter">
                  <button
                    type="button"
                    className="hs-tree__row"
                    disabled={ch.kcCount === 0}
                    onClick={() => toggleChapter(ch)}
                  >
                    <span className="lv-list__value">{ch.label}</span>
                    <span className="lv-caption">{ch.kcCount} KC</span>
                  </button>

                  {ch.children.map(sec => {
                    const on = selected.has(sec.id)
                    const empty = sec.kcCount === 0
                    return (
                      <button
                        key={sec.id}
                        type="button"
                        className={`hs-tree__row hs-tree__row--leaf${on ? ' lv-list__row--active' : ''}`}
                        disabled={empty}
                        aria-pressed={on}
                        onClick={() => toggleLeaf(sec.id)}
                      >
                        <span className="lv-check">
                          <span className={`lv-check__box${on ? ' lv-check__box--on' : ''}`}>{on ? '✓' : ''}</span>
                        </span>
                        <span className="lv-list__value">{sec.label}</span>
                        <span className="lv-caption">{empty ? 'KC 未登録' : `${sec.kcCount} KC`}</span>
                      </button>
                    )
                  })}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      <div className="lv-card">
        <div className="lv-card__pad hs-stack">
          <span className="lv-label">この特訓</span>
          <input
            className="lv-field"
            placeholder="題名（例: 古代オリエントの総復習）"
            value={title}
            onChange={e => { setTitle(e.target.value); setResult(null) }}
          />
          <label className="lv-caption" htmlFor="deadline">締切</label>
          <input
            id="deadline"
            type="date"
            className="lv-field"
            value={deadline}
            onChange={e => { setDeadline(e.target.value); setResult(null) }}
          />
          <p className="lv-caption">
            {selected.size} 節 / {kcCount} KC を選んでいます
          </p>

          {result && !result.ok && result.reason === 'error' && (
            <p className="lv-field-note">{result.message}</p>
          )}

          {/* 重複は黙って作らない。何とどれだけ重なるかを見せてから決めさせる（docs/05 §5.3） */}
          {result && !result.ok && result.reason === 'overlap' && (
            <div className="hs-alert">
              <p className="hs-alert__title">
                すでにやっている範囲と {Math.round(result.overlap.ratio * 100)}% 重なっています
              </p>
              <p className="lv-body">
                {result.overlap.withTitles.join('・')} と {result.overlap.sharedKcCount} KC が同じです。
              </p>
              <p className="lv-caption">同じ知識を2回学習することになります。それでも作りますか？</p>
              <button
                type="button"
                className="lv-btn lv-btn--block"
                disabled={pending}
                onClick={() => submit(true)}
              >
                重複を承知で作る
              </button>
            </div>
          )}

          <button
            type="button"
            className="lv-btn lv-btn--primary lv-btn--block"
            disabled={pending || selected.size === 0 || title.trim() === ''}
            onClick={() => submit(false)}
          >
            {pending ? '作っています…' : 'この範囲で作る'}
          </button>
          <Link className="lv-btn lv-btn--block" href="/">やめる</Link>
        </div>
      </div>
    </>
  )
}
