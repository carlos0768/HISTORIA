// @vitest-environment jsdom
import { act } from 'react'
import { createRoot, type Root } from 'react-dom/client'
import { afterEach, beforeEach, describe, expect, it } from 'vitest'
import { Markdown } from './markdown'

/**
 * 教材本文の描画を **DOM で** 確かめる。
 * 重要箇所のマーク `==語句==` は受験生の画面に直接出るものなので、
 * 「赤くなる要素が出る」「記号が画面に残らない」「閉じ忘れは消えずにそのまま出る」を見る。
 */
let container: HTMLDivElement
let root: Root

beforeEach(() => {
  ;(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true
  container = document.createElement('div')
  document.body.appendChild(container)
  root = createRoot(container)
})

afterEach(() => {
  act(() => root.unmount())
  container.remove()
})

const render = (source: string) => {
  act(() => root.render(<Markdown source={source} />))
  return container
}

describe('重要箇所のマーク ==語句==', () => {
  it('<mark class="hs-important"> になり、記号は画面に残らない', () => {
    const el = render('二足歩行が==先==で、脳の大型化は==後==です。')
    const marks = [...el.querySelectorAll('mark.hs-important')].map(m => m.textContent)
    expect(marks).toEqual(['先', '後'])
    expect(el.textContent).toBe('二足歩行が先で、脳の大型化は後です。')
  })
  it('箇条書きと見出しの中でも効く', () => {
    const el = render('### 見出しの==要==\n\n- 猿人 → ==礫石器==\n- 原人 → ==火==')
    expect([...el.querySelectorAll('mark')].map(m => m.textContent)).toEqual(['要', '礫石器', '火'])
    expect(el.querySelectorAll('li')).toHaveLength(2)
  })
  it('用語の中の = を壊さない（ローマ=カトリックなど）', () => {
    const el = render('==ローマ=カトリック==と==東方正教会==の分裂')
    expect([...el.querySelectorAll('mark')].map(m => m.textContent))
      .toEqual(['ローマ=カトリック', '東方正教会'])
    expect(el.textContent).toBe('ローマ=カトリックと東方正教会の分裂')
  })
  it('強調と並んでも互いを壊さない', () => {
    const el = render('**強調**と==重要==を同じ行に')
    expect(el.querySelector('strong')?.textContent).toBe('強調')
    expect(el.querySelector('mark')?.textContent).toBe('重要')
  })
  it('閉じていない・空のマークはそのまま文字として出す（黙って消さない）', () => {
    const el = render('==閉じていない\n\n====')
    expect(el.querySelectorAll('mark')).toHaveLength(0)
    expect(el.textContent).toBe('==閉じていない' + '====')
  })
  it('=== は内側の = ごとマークにし、余った = は文字として残す（lib/domain/markup.ts と同じ解釈）', () => {
    const el = render('===あ===')
    expect(el.querySelector('mark')?.textContent).toBe('=あ')
    expect(el.textContent).toBe('=あ=')
  })
  it('HTML として解釈しない', () => {
    const el = render('==<script>alert(1)</script>==')
    expect(el.querySelector('script')).toBeNull()
    expect(el.querySelector('mark')?.textContent).toBe('<script>alert(1)</script>')
  })
})
