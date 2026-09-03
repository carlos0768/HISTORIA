// @vitest-environment jsdom
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { readFileSync } from 'node:fs'
import { act } from 'react'
import { createRoot, type Root } from 'react-dom/client'
import { CommandPalette, filterCommands, SHORTCUTS, type Command } from './palette'
import { DataTable, TABS, DESK, type Column } from './ui'
import { clampView, zoomAt, MIN_ZOOM, MAX_ZOOM } from './map-workspace'

/**
 * デスクトップの部品（docs/06-desktop.md）
 *
 * ★ 守りたい一線は2つある。
 *   1. **モバイルの見た目を変えないこと。** フッタは3タブのままで、
 *      デスクトップ専用の画面はそこに混ざらない。
 *   2. **⌘K が入力欄の中で発火しないこと。** 書きかけを消してパレットが開くのは事故である。
 */

// ---- next/navigation を差し替える。router.push を数えるため ----
const pushed: string[] = []
vi.mock('next/navigation', () => ({ useRouter: () => ({ push: (h: string) => { pushed.push(h) } }) }))

const COMMANDS: Command[] = [
  { id: 'a', label: 'ホーム', kind: '移動', href: '/' },
  { id: 'b', label: '今日の出題', kind: '移動', href: '/study', keywords: 'とく 問題' },
  { id: 'c', label: 'イスラーム世界の成立', kind: '単元', href: '/drills/new?unit=wh.3.1.1' },
]

let container: HTMLDivElement
let root: Root

beforeEach(() => {
  ;(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true
  pushed.length = 0
  container = document.createElement('div')
  document.body.appendChild(container)
  root = createRoot(container)
})
afterEach(() => {
  act(() => root.unmount())
  container.remove()
})

const key = (k: string, o: Partial<KeyboardEventInit> = {}, target?: EventTarget) => {
  const e = new KeyboardEvent('keydown', { key: k, bubbles: true, cancelable: true, ...o })
  act(() => { (target ?? window).dispatchEvent(e) })
  return e
}

describe('絞り込み', () => {
  it('空なら全部返す', () => {
    expect(filterCommands(COMMANDS, '')).toHaveLength(3)
    expect(filterCommands(COMMANDS, '   ')).toHaveLength(3)
  })

  it('部分一致で絞る', () => {
    expect(filterCommands(COMMANDS, 'イスラーム').map(c => c.id)).toEqual(['c'])
  })

  it('種別でも絞れる', () => {
    expect(filterCommands(COMMANDS, '単元').map(c => c.id)).toEqual(['c'])
  })

  /** ★ label に無い読み方でも見つかること。「とく」で「今日の出題」に辿り着く */
  it('keywords でも見つかる', () => {
    expect(filterCommands(COMMANDS, 'とく').map(c => c.id)).toEqual(['b'])
  })

  it('空白で区切った語を全部含むものだけ残す', () => {
    expect(filterCommands(COMMANDS, '移動 出題').map(c => c.id)).toEqual(['b'])
    expect(filterCommands(COMMANDS, '単元 出題')).toEqual([])
  })
})

describe('コマンドパレット ⌘K', () => {
  const open = () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    key('k', { metaKey: true })
  }

  it('初期描画では何も出さない', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    expect(document.querySelector('.hs-palette')).toBeNull()
  })

  it('⌘K で開き、もう一度で閉じる', () => {
    open()
    expect(document.querySelector('.hs-palette')).not.toBeNull()
    key('k', { metaKey: true })
    expect(document.querySelector('.hs-palette')).toBeNull()
  })

  /** ★ 作者は Mac だが、共用の Windows 機で開くこともある */
  it('Ctrl+K でも開く', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    key('k', { ctrlKey: true })
    expect(document.querySelector('.hs-palette')).not.toBeNull()
  })

  it('修飾キー無しの K では開かない', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    key('k')
    expect(document.querySelector('.hs-palette')).toBeNull()
  })

  /**
   * ★ ここが本題。教材の検索欄や報告の自由記述で ⌘K を押したときに
   *   書きかけが消えてパレットが開く、という事故を防ぐ
   */
  it('入力欄の中では発火しない', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    const input = document.createElement('input')
    document.body.appendChild(input)
    key('k', { metaKey: true }, input)
    expect(document.querySelector('.hs-palette')).toBeNull()
    input.remove()
  })

  it('textarea の中でも発火しない', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    const ta = document.createElement('textarea')
    document.body.appendChild(ta)
    key('k', { metaKey: true }, ta)
    expect(document.querySelector('.hs-palette')).toBeNull()
    ta.remove()
  })

  it('contentEditable の中でも発火しない', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    const div = document.createElement('div')
    div.contentEditable = 'true'
    // jsdom は isContentEditable を実装していないので明示する
    Object.defineProperty(div, 'isContentEditable', { value: true })
    document.body.appendChild(div)
    key('k', { metaKey: true }, div)
    expect(document.querySelector('.hs-palette')).toBeNull()
    div.remove()
  })

  it('Esc で閉じる', () => {
    open()
    key('Escape')
    expect(document.querySelector('.hs-palette')).toBeNull()
  })

  it('打つと絞られる', () => {
    open()
    const input = container.querySelector<HTMLInputElement>('.hs-palette__input')!
    act(() => {
      const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')!.set!
      setter.call(input, 'イスラーム')
      input.dispatchEvent(new Event('input', { bubbles: true }))
    })
    const items = document.querySelectorAll('.hs-palette__item')
    expect(items).toHaveLength(1)
    expect(items[0]!.textContent).toContain('イスラーム世界の成立')
  })

  it('↓↑ で選択が動き、Enter で移動する', () => {
    open()
    key('ArrowDown')
    key('Enter')
    expect(pushed).toEqual(['/study'])
  })

  it('先頭より上には行かない', () => {
    open()
    key('ArrowUp'); key('ArrowUp')
    key('Enter')
    expect(pushed).toEqual(['/'])
  })

  it('末尾より下には行かない', () => {
    open()
    for (let i = 0; i < 10; i++) key('ArrowDown')
    key('Enter')
    expect(pushed).toEqual(['/drills/new?unit=wh.3.1.1'])
  })

  it('見つからないときは「見つかりません」と出し、Enter で何も起きない', () => {
    open()
    const input = container.querySelector<HTMLInputElement>('.hs-palette__input')!
    act(() => {
      const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')!.set!
      setter.call(input, 'そんなものは無い')
      input.dispatchEvent(new Event('input', { bubbles: true }))
    })
    expect(container.textContent).toContain('見つかりません')
    key('Enter')
    expect(pushed).toEqual([])
  })

  it('⌘M で地図へ行く', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    key('m', { metaKey: true })
    expect(pushed).toEqual(['/map'])
  })

  it('⌘⌥I で資料パネルが畳まれ、もう一度で戻る', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    key('i', { metaKey: true, altKey: true })
    expect(document.documentElement.classList.contains('hs-aside-hidden')).toBe(true)
    key('i', { metaKey: true, altKey: true })
    expect(document.documentElement.classList.contains('hs-aside-hidden')).toBe(false)
  })

  /** ★ ブラウザの既定（DevTools・保存など）を奪ったら、必ず打ち消す */
  it('受け取った鍵は既定の動作を止める', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    expect(key('k', { metaKey: true }).defaultPrevented).toBe(true)
    key('Escape')
    expect(key('m', { metaKey: true }).defaultPrevented).toBe(true)
    expect(key('i', { metaKey: true, altKey: true }).defaultPrevented).toBe(true)
  })

  it('受け取らない鍵の既定は奪わない', () => {
    act(() => root.render(<CommandPalette commands={COMMANDS} />))
    expect(key('s', { metaKey: true }).defaultPrevented).toBe(false)
    expect(key('r', { metaKey: true }).defaultPrevented).toBe(false)
  })

  it('割当の一覧を出す（覚えなくても見れば分かる）', () => {
    open()
    for (const s of SHORTCUTS) expect(container.textContent).toContain(s.label)
  })
})

describe('資料テーブル', () => {
  type Row = { id: string; year: number; name: string }
  const rows: Row[] = [
    { id: '1', year: 1867, name: '大政奉還' },
    { id: '2', year: 1868, name: '戊辰戦争' },
  ]
  const columns: Column<Row>[] = [
    { key: 'year', label: '年', numeric: true, width: '90px', render: r => r.year },
    { key: 'name', label: '出来事', render: r => r.name },
  ]

  it('行と見出しを出す', () => {
    act(() => root.render(<DataTable columns={columns} rows={rows} rowKey={r => r.id} />))
    expect(container.querySelectorAll('tbody tr')).toHaveLength(2)
    expect(container.querySelectorAll('th')).toHaveLength(2)
    expect(container.textContent).toContain('大政奉還')
  })

  /** ★ 数字は等幅・右寄せ。桁が揺れると並べて読み比べられない */
  it('数字の列に印を付ける', () => {
    act(() => root.render(<DataTable columns={columns} rows={rows} rowKey={r => r.id} />))
    const num = container.querySelectorAll('.hs-table__cell--num')
    // 見出し1 + 本体2
    expect(num).toHaveLength(3)
  })

  it('列幅を CSS 変数で渡す', () => {
    act(() => root.render(<DataTable columns={columns} rows={rows} rowKey={r => r.id} />))
    const table = container.querySelector<HTMLElement>('.hs-table')!
    expect(table.style.getPropertyValue('--hs-table-cols')).toBe('90px 1fr')
  })

  it('空なら表そのものを出さない', () => {
    act(() => root.render(<DataTable columns={columns} rows={[]} rowKey={r => r.id} empty="ありません" />))
    expect(container.querySelector('table')).toBeNull()
    expect(container.textContent).toContain('ありません')
  })

  /** ★ 横溢れは自前で受ける。画面ごと横スクロールさせない */
  it('横スクロールの器で包む', () => {
    act(() => root.render(<DataTable columns={columns} rows={rows} rowKey={r => r.id} />))
    expect(container.querySelector('.hs-table__scroll')).not.toBeNull()
  })
})

describe('地図の表示範囲', () => {
  const W = 1320, H = 680

  it('全体表示は左上が原点', () => {
    expect(clampView({ x: 0, y: 0, z: 1 }, W, H)).toEqual({ x: 0, y: 0, z: 1 })
  })

  /** ★ これが無いと、勢いよくドラッグした地図が画面外へ出て戻せなくなる */
  it('地図の外へは出られない', () => {
    const v = clampView({ x: -500, y: -500, z: 1 }, W, H)
    expect(v.x).toBe(0)
    expect(v.y).toBe(0)
    const w = clampView({ x: 9999, y: 9999, z: 2 }, W, H)
    expect(w.x).toBe(W - W / 2)
    expect(w.y).toBe(H - H / 2)
  })

  it('倍率は範囲で止まる', () => {
    expect(clampView({ x: 0, y: 0, z: 0.1 }, W, H).z).toBe(MIN_ZOOM)
    expect(clampView({ x: 0, y: 0, z: 999 }, W, H).z).toBe(MAX_ZOOM)
  })

  /** ★ カーソルの下にあるものが、拡大しても動かないこと */
  it('指した点を軸に拡大する', () => {
    const v0 = { x: 0, y: 0, z: 1 }
    const v1 = zoomAt(v0, W, H, 2, 0.5, 0.5)
    expect(v1.z).toBe(2)
    // 中心を軸にしたので、拡大後の中心も地図の中心のまま
    expect(v1.x + (W / v1.z) / 2).toBeCloseTo(W / 2, 6)
    expect(v1.y + (H / v1.z) / 2).toBeCloseTo(H / 2, 6)
  })

  it('拡大しても範囲の外へは出ない', () => {
    let v = { x: 0, y: 0, z: 1 }
    for (let i = 0; i < 20; i++) v = zoomAt(v, W, H, 1.4, 1, 1)
    expect(v.z).toBeLessThanOrEqual(MAX_ZOOM)
    expect(v.x).toBeLessThanOrEqual(W - W / v.z + 1e-9)
    expect(v.y).toBeLessThanOrEqual(H - H / v.z + 1e-9)
    expect(v.x).toBeGreaterThanOrEqual(0)
  })

  it('縮小して戻ると全体に戻る', () => {
    let v = zoomAt({ x: 0, y: 0, z: 1 }, W, H, 4, 0.3, 0.7)
    v = zoomAt(v, W, H, 1 / 100, 0.3, 0.7)
    expect(v.z).toBe(MIN_ZOOM)
    expect(v.x).toBe(0)
    expect(v.y).toBe(0)
  })
})

describe('モバイルを変えていないこと', () => {
  /** ★ components/nav.test.ts と対になる防壁。デスクトップの画面をタブに混ぜない */
  it('タブは3つのまま', () => {
    expect(TABS).toHaveLength(3)
    expect(TABS.map(t => t.href)).toEqual(['/', '/drills', '/records'])
  })

  /**
   * ★ ここは型でも守られている。`TABS.map(t => t.href)` の型は
   *   `'/' | '/drills' | '/records'` に固定されるので、DESK の href を
   *   `Set.has()` に渡すと **tsc が落ちる**（重なりが無いことの証明になる）。
   *   実行時にも見ておくのは、どちらかを `string[]` に緩めたときのためである。
   */
  it('デスクトップの画面はタブに入っていない', () => {
    const tabHrefs = new Set<string>(TABS.map(t => t.href))
    for (const d of DESK) expect(tabHrefs.has(d.href), `${d.href} がタブに入っている`).toBe(false)
  })

  /**
   * ★ 50m の基図（約1MB）を静的に import している場所が無いこと。
   *   1か所でも静的に import すると、地図を開かない読者にも毎回送られる。
   *
   *   実測（2026-09-03・next build）: 50m は単独の chunk（1012KB）に分かれ、
   *   **どの経路の manifest にも載っていない**（＝初回の読み込みには入らない）。
   *   本文の地図が使う 110m は lib/map/basemap.ts（166KB）のまま据え置き。
   */
  it('50m の基図は動的 import からしか読まれない', () => {
    const loader = readFileSync('app/map/loader.tsx', 'utf8')
    expect(loader).toContain("import('@/lib/map/basemap-50m')")
    expect(loader).not.toMatch(/^import .* from '@\/lib\/map\/basemap-50m'/m)
    // 他のどのファイルからも静的 import されていない
    const ws = readFileSync('components/map-workspace.tsx', 'utf8')
    expect(ws).not.toContain('basemap-50m')
    const embedded = readFileSync('components/world-map.tsx', 'utf8')
    expect(embedded).not.toContain('basemap-50m')
  })

  /** ★ 教材に埋まっている地図は静止のまま。パン・ズームを足すと読書に影響が出る */
  it('教材の地図にイベントを足していない', () => {
    const embedded = readFileSync('components/world-map.tsx', 'utf8')
    expect(embedded).not.toContain('onPointer')
    expect(embedded).not.toContain('onWheel')
    expect(embedded).not.toContain('useState')
    expect(embedded).not.toContain("'use client'")
  })
})
