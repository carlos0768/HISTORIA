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
  it('=== は内側だけをマークにし、余った = は文字として残す（lib/domain/markup.ts と同じ解釈）', () => {
    const el = render('===あ===')
    expect(el.querySelector('mark')?.textContent).toBe('あ')
    expect(el.textContent).toBe('=あ=')
  })
  it('HTML として解釈しない', () => {
    const el = render('==<script>alert(1)</script>==')
    expect(el.querySelector('script')).toBeNull()
    expect(el.querySelector('mark')?.textContent).toBe('<script>alert(1)</script>')
  })
})

/**
 * 本文の人物・出来事のリンク（docs/11 §4.2）。
 * 押せる語が本文の意味を変えないこと、重要箇所（朱）のマークを壊さないことを見る。
 */
const source = [
  '### 1 メソポタミア',
  '',
  'ハンムラビ王は**ハンムラビ法典**を制定した。ハンムラビの死後、王朝は衰えた。',
  '',
  '- キュロス大王が新バビロニアを滅ぼす',
].join('\n')

const terms = [
  { text: 'ハンムラビ', kind: 'person' as const, label: 'ハンムラビ' },
  { text: 'ハンムラビ法典', kind: 'event' as const, label: 'ハンムラビ法典' },
  { text: 'キュロス大王', kind: 'person' as const, label: 'キュロス2世' },
]

describe('人物・出来事のリンク', () => {
  it('渡された語を「調べる」へのリンクにする。強調の中でも、箇条書きの中でも', () => {
    act(() => root.render(<Markdown source={source} terms={terms} />))

    const links = [...container.querySelectorAll('a.hs-term')]
    expect(links.map(a => a.textContent)).toEqual(['ハンムラビ', 'ハンムラビ法典', 'キュロス大王'])
    // 飛び先は日本語版 Wikipedia。別名で出ていても正典の label（＝記事名）で引く
    expect(links.map(a => a.getAttribute('href'))).toEqual([
      'https://ja.wikipedia.org/wiki/Special:Search?search=%E3%83%8F%E3%83%B3%E3%83%A0%E3%83%A9%E3%83%93&go=Go',
      'https://ja.wikipedia.org/wiki/Special:Search?search=%E3%83%8F%E3%83%B3%E3%83%A0%E3%83%A9%E3%83%93%E6%B3%95%E5%85%B8&go=Go',
      'https://ja.wikipedia.org/wiki/Special:Search?search=%E3%82%AD%E3%83%A5%E3%83%AD%E3%82%B92%E4%B8%96&go=Go',
    ])
    // 別のタブで開く。読んでいた節と滞在時間の計測を切らないため
    expect(links.every(a => a.getAttribute('target') === '_blank')).toBe(true)
    expect(links.every(a => a.getAttribute('rel') === 'noreferrer')).toBe(true)
    // 種別は class と title で分かる
    expect(links[0]!.className).toContain('hs-term--person')
    expect(links[1]!.className).toContain('hs-term--event')
    expect(links[2]!.getAttribute('title')).toBe('人物「キュロス2世」を Wikipedia で開く（新しいタブ）')
    // 強調の中のリンクは強調のまま
    expect(container.querySelector('strong a.hs-term')?.textContent).toBe('ハンムラビ法典')
  })

  it('同じ語は初出だけリンクにし、2度目は文字のまま残す', () => {
    act(() => root.render(<Markdown source={source} terms={terms} />))
    const p = container.querySelector('p.lv-body')!
    expect(p.textContent).toBe('ハンムラビ王はハンムラビ法典を制定した。ハンムラビの死後、王朝は衰えた。')
    expect(p.querySelectorAll('a')).toHaveLength(2)
  })

  it('重要箇所のマークを壊さない。朱の中の語もリンクになる', () => {
    act(() => root.render(
      <Markdown source={'==ハンムラビ法典==は同害復讐が原則'} terms={terms} />,
    ))
    const mark = container.querySelector('mark.hs-important')!
    expect(mark.textContent).toBe('ハンムラビ法典')
    expect(mark.querySelector('a.hs-term')?.textContent).toBe('ハンムラビ法典')
    // 記号は画面に残らない
    expect(container.textContent).toBe('ハンムラビ法典は同害復讐が原則')
  })

  it('語が無ければ本文はただの文字のまま', () => {
    act(() => root.render(<Markdown source={source} />))
    expect(container.querySelectorAll('a')).toHaveLength(0)
    expect(container.textContent).toContain('ハンムラビ王は')
  })

  it('本文に無い記法はそのまま文字として出す（リンクを足しても消さない）', () => {
    act(() => root.render(<Markdown source={'ハンムラビ *法典* を'} terms={terms} />))
    expect(container.textContent).toBe('ハンムラビ *法典* を')
  })
})
