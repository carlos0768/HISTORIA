'use client'

import { useEffect, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'

/**
 * コマンドパレット ⌘K とキー割当（docs/design/litverse-desktop-system.dc.html 03）
 *
 * ★ リポジトリに `keydown` を使うコードは1つも無かった。ここが最初である。
 *   だから「押した鍵を誰が受けるか」の規則をここで決めておく。
 *
 * ★ **入力欄の中では発火しない。** 教材の検索欄や報告の自由記述で
 *   ⌘K を押したら、書きかけが消えてパレットが開く——のは事故である。
 *   ただしパレット自身の入力欄は例外（Esc で閉じる・↑↓ で選ぶ）。
 *
 * ★ Ctrl も受ける。作者は Mac だが、共用の Windows 機で開くこともある。
 *   `metaKey || ctrlKey` で両方を通す。
 *
 * ★ モバイルには出さない。1440px 未満ではそもそも描かない
 *   （キーボードが無い端末に「⌘K」と書いても意味が無い）。
 *   ただし**鍵の待ち受けは常に付ける**。外付けキーボードを繋いだ iPad は
 *   幅が広くなるので、幅で切ると急に効かなくなる。
 */

export type Command = {
  id: string
  label: string
  /** 右端に出す種別。「本文」「用語」「移動」など */
  kind: string
  href: string
  /** 検索に使う語。label に無い読み方などを足す */
  keywords?: string
}

/** キー割当（設計系 03 の表） */
export const SHORTCUTS = [
  { id: 'search', label: 'さがす', keys: '⌘ K' },
  { id: 'map', label: '地図を開く', keys: '⌘ M' },
  { id: 'aside', label: '資料パネル切替', keys: '⌘ ⌥ I' },
  { id: 'mark', label: '蛍光ペン', keys: '⌘ ⇧ H' },
] as const

/**
 * いま入力中か。
 *
 * ★ contentEditable も見る。input と textarea だけ見て済ませると、
 *   将来リッチな入力を足したときに黙って壊れる。
 */
function isTyping(el: EventTarget | null): boolean {
  if (!(el instanceof HTMLElement)) return false
  if (el.isContentEditable) return true
  const tag = el.tagName
  return tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT'
}

/** 素朴な部分一致。語を空白で割って全部含むものを残す */
export function filterCommands(commands: readonly Command[], query: string): Command[] {
  const words = query.trim().toLowerCase().split(/\s+/).filter(Boolean)
  if (words.length === 0) return [...commands]
  return commands.filter(c => {
    const hay = `${c.label} ${c.kind} ${c.keywords ?? ''}`.toLowerCase()
    return words.every(w => hay.includes(w))
  })
}

export function CommandPalette({ commands }: { commands: readonly Command[] }) {
  const router = useRouter()
  const [open, setOpen] = useState(false)
  const [query, setQuery] = useState('')
  const [cursor, setCursor] = useState(0)
  const inputRef = useRef<HTMLInputElement>(null)

  const hits = filterCommands(commands, query)
  // ★ 絞り込みで候補が減ったとき、選択位置がはみ出したままにしない。
  //   useEffect で setCursor すると余計な再描画が1回入る（lint も止める）ので、
  //   描くときに丸める。状態は「どこを選んだか」だけを持つ
  const active = Math.min(cursor, Math.max(0, hits.length - 1))

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      const mod = e.metaKey || e.ctrlKey

      // ★ パレットが開いているあいだは、その中の操作を優先する
      if (open) {
        if (e.key === 'Escape') { e.preventDefault(); setOpen(false); return }
        if (e.key === 'ArrowDown') {
          e.preventDefault(); setCursor(c => Math.min(c + 1, Math.max(0, hits.length - 1))); return
        }
        if (e.key === 'ArrowUp') { e.preventDefault(); setCursor(c => Math.max(0, c - 1)); return }
        if (e.key === 'Enter') {
          e.preventDefault()
          const hit = hits[active]
          if (hit) { setOpen(false); router.push(hit.href) }
          return
        }
      }

      // ★ 入力中は割当を効かせない（上の Esc / ↑↓ / Enter はパレット自身の欄なので別）
      if (isTyping(e.target)) return
      if (!mod) return

      if (e.key.toLowerCase() === 'k') {
        e.preventDefault()
        setOpen(v => !v); setQuery(''); setCursor(0)
        return
      }
      if (e.key.toLowerCase() === 'm' && !e.shiftKey && !e.altKey) {
        e.preventDefault(); router.push('/map'); return
      }
      // ⌘⌥I: 資料パネルの切替。DevTools の割当と重なるので preventDefault する
      if (e.altKey && e.key.toLowerCase() === 'i') {
        e.preventDefault()
        document.documentElement.classList.toggle('hs-aside-hidden')
        return
      }
      // ⌘⇧H: 蛍光ペン。選択範囲に印を付ける
      if (e.shiftKey && e.key.toLowerCase() === 'h') {
        e.preventDefault(); highlightSelection()
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [open, hits, active, router])

  useEffect(() => { if (open) inputRef.current?.focus() }, [open])

  if (!open) return null

  return (
    <div className="hs-palette__backdrop" role="dialog" aria-modal="true" aria-label="さがす"
         onMouseDown={e => { if (e.target === e.currentTarget) setOpen(false) }}>
      <div className="hs-palette">
        <input
          ref={inputRef} className="hs-palette__input" type="text"
          value={query}
          onChange={e => { setQuery(e.target.value); setCursor(0) }}
          placeholder="単元・年表・画面をさがす" aria-label="さがす"
          autoComplete="off" spellCheck={false}
        />
        {hits.length === 0 ? (
          <p className="hs-palette__empty">見つかりません。</p>
        ) : (
          <ul className="hs-palette__list">
            {hits.map((c, i) => (
              <li key={c.id}>
                <button
                  type="button"
                  className={`hs-palette__item${i === active ? ' hs-palette__item--active' : ''}`}
                  onMouseEnter={() => setCursor(i)}
                  onClick={() => { setOpen(false); router.push(c.href) }}
                >
                  <span>{c.label}</span>
                  <span className="hs-palette__kind">{c.kind}</span>
                </button>
              </li>
            ))}
          </ul>
        )}
        <div className="hs-palette__hint">
          {SHORTCUTS.map(s => (
            <span key={s.id}>{s.label} <kbd className="hs-kbd">{s.keys}</kbd></span>
          ))}
        </div>
      </div>
    </div>
  )
}

/**
 * 選択範囲に蛍光ペン（⌘⇧H）。
 *
 * ★ 保存しない。読んでいるあいだの目印であって、注釈の機能ではない。
 *   保存するなら「誰の・どの版の本文に対する印か」を決める必要があり、
 *   毎回生成の教材ではその版が次に開いたときには無い（docs/07 §3.1）。
 *   印だけ残って本文が変わっているのは、無いより悪い。
 */
function highlightSelection() {
  const sel = window.getSelection()
  if (!sel || sel.isCollapsed || sel.rangeCount === 0) return
  const range = sel.getRangeAt(0)
  // ★ 複数の要素にまたがる選択は包めない（surroundContents が投げる）。
  //   そのときは何もしない。例外で画面を壊さない
  try {
    const mark = document.createElement('mark')
    mark.className = 'lv-mark'
    range.surroundContents(mark)
    sel.removeAllRanges()
  } catch { /* またがる選択。何もしない */ }
}
