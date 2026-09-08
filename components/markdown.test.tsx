// @vitest-environment jsdom
import { act } from 'react'
import { createRoot, type Root } from 'react-dom/client'
import { afterEach, beforeEach, describe, expect, it } from 'vitest'
import { Markdown } from './markdown'

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

describe('教材本文の人物・出来事のリンク（docs/11 §4.2）', () => {
  it('渡された語を「調べる」へのリンクにする。強調の中でも、箇条書きの中でも', async () => {
    await act(async () => root.render(<Markdown source={source} terms={terms} />))

    const links = Array.from(container.querySelectorAll('a.hs-term'))
    expect(links.map(a => a.textContent)).toEqual(['ハンムラビ', 'ハンムラビ法典', 'キュロス大王'])
    expect(links.map(a => a.getAttribute('href'))).toEqual([
      '/research?q=%E3%83%8F%E3%83%B3%E3%83%A0%E3%83%A9%E3%83%93',
      '/research?q=%E3%83%8F%E3%83%B3%E3%83%A0%E3%83%A9%E3%83%93%E6%B3%95%E5%85%B8',
      '/research?q=%E3%82%AD%E3%83%A5%E3%83%AD%E3%82%B92%E4%B8%96',
    ])
    // 種別は class と title で分かる
    expect(links[0]!.className).toContain('hs-term--person')
    expect(links[1]!.className).toContain('hs-term--event')
    expect(links[2]!.getAttribute('title')).toBe('人物「キュロス2世」を調べる')
    // 強調の中のリンクは強調のまま
    expect(container.querySelector('strong a.hs-term')?.textContent).toBe('ハンムラビ法典')
  })

  it('同じ語は初出だけリンクにし、2度目は文字のまま残す', async () => {
    await act(async () => root.render(<Markdown source={source} terms={terms} />))
    const p = container.querySelector('p.lv-body')!
    expect(p.textContent).toBe('ハンムラビ王はハンムラビ法典を制定した。ハンムラビの死後、王朝は衰えた。')
    expect(p.querySelectorAll('a').length).toBe(2)
  })

  it('語が無ければ本文はただの文字のまま', async () => {
    await act(async () => root.render(<Markdown source={source} />))
    expect(container.querySelectorAll('a').length).toBe(0)
    expect(container.textContent).toContain('ハンムラビ王は')
  })

  it('本文に無い記法はそのまま文字として出す（リンクを足しても消さない）', async () => {
    await act(async () => root.render(<Markdown source={'ハンムラビ *法典* を'} terms={terms} />))
    expect(container.textContent).toBe('ハンムラビ *法典* を')
  })
})
