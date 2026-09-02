// @vitest-environment jsdom
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { act } from 'react'
import { createRoot, type Root } from 'react-dom/client'
import { VideoEmbed } from './video-embed'

/**
 * 2クリック埋め込みを **DOM で** 確かめる（docs/09b-video.md §5.1・V3）
 *
 * ★ なぜ本文の読み取りでは足りないのか。
 *   `lib/loop/video.test.ts` は video-embed.tsx の**字面**を読んで
 *   「iframe が `{playing ? (` の中に在る」ことを見ている。これは
 *   「そう書いてある」ことしか言えない。React が実際に何を描いたかは見ていない。
 *   ここでは本物の DOM に載せ、`document` を数える。
 *
 * ★ 守るべき一線: **初期描画で iframe を1つも出さない。**
 *   youtube-nocookie でも `yt-remote-device-id` を localStorage に置くため、
 *   開いただけで端末に識別子が残る。利用者は未成年なので緩めない（§1 制約2）。
 */

const PROPS = {
  videoId: 'dQw4w9WgXcQ',
  title: 'ローマ帝国の成立',
  channelTitle: '映像授業 Try IT（トライイット）',
  startSec: 42,
  label: 'このセクションの理解を助ける動画',
}

let container: HTMLDivElement
let root: Root

beforeEach(() => {
  // React 19 の act はこの旗を見る。立てないと警告が出て挙動が変わる
  ;(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true
  container = document.createElement('div')
  document.body.appendChild(container)
  root = createRoot(container)
})

afterEach(() => {
  act(() => root.unmount())
  container.remove()
})

/**
 * 文書のどこかに YouTube へ**通信しに行く**ものが在るか。
 *
 * ★ 属性の値を無差別に見てはいけない。再生ボタンの `aria-label` に
 *   「YouTube で再生します」と書いてあり（押すと何が起きるかを先に伝えるため）、
 *   文字列一致だと読み上げ用の文まで拾ってしまう。ここで見たいのは
 *   **取得を発生させる属性**だけなので、URL を載せる属性に限る。
 */
const URL_ATTRS = ['src', 'srcset', 'href', 'poster', 'action', 'data-src', 'formaction']

function youtubeRefs(): string[] {
  const hits: string[] = []
  for (const el of Array.from(document.querySelectorAll('*'))) {
    for (const attr of Array.from(el.attributes)) {
      if (!URL_ATTRS.includes(attr.name)) continue
      if (/youtube|ytimg|googlevideo/i.test(attr.value)) hits.push(`${el.tagName}[${attr.name}]=${attr.value}`)
    }
  }
  return hits
}

describe('2クリック埋め込みを DOM で見る（docs/09b V3）', () => {
  it('初期描画に iframe が1つも無い', () => {
    act(() => root.render(<VideoEmbed {...PROPS} />))
    expect(document.querySelectorAll('iframe')).toHaveLength(0)
  })

  it('初期描画で youtube.com へ繋ぐ属性が1つも無い（サムネの ytimg だけ）', () => {
    act(() => root.render(<VideoEmbed {...PROPS} />))
    const refs = youtubeRefs()
    // サムネイルは i.ytimg.com。これは画像であって埋め込みではない
    expect(refs).toHaveLength(1)
    expect(refs[0]).toContain('https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg')
    expect(refs.join(' ')).not.toContain('youtube-nocookie')
    expect(refs.join(' ')).not.toContain('youtube.com')
  })

  it('サムネイルは遅延読み込みで、押せる導線が1つある', () => {
    act(() => root.render(<VideoEmbed {...PROPS} />))
    const img = container.querySelector('img')
    expect(img?.getAttribute('loading')).toBe('lazy')
    const buttons = container.querySelectorAll('button')
    expect(buttons).toHaveLength(1)
    // なぜ出ているのかと、押すと何が起きるのかが読める（§7・§5.1）
    expect(container.textContent).toContain('このセクションの理解を助ける動画')
    expect(container.textContent).toContain('再生すると YouTube（Google）に情報が送信されます')
  })

  it('押して初めて youtube-nocookie の iframe が入る', () => {
    let played = 0
    act(() => root.render(<VideoEmbed {...PROPS} onPlay={() => { played++ }} />))
    expect(document.querySelectorAll('iframe')).toHaveLength(0)

    const button = container.querySelector('button')!
    act(() => { button.click() })

    const frames = document.querySelectorAll('iframe')
    expect(frames).toHaveLength(1)
    const src = frames[0]!.getAttribute('src')!
    expect(src.startsWith('https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?')).toBe(true)
    expect(played).toBe(1)
  })

  it('押したあとも自動再生しない。頭出しと関連動画の抑制は効かせる', () => {
    act(() => root.render(<VideoEmbed {...PROPS} />))
    act(() => { container.querySelector('button')!.click() })

    const src = document.querySelector('iframe')!.getAttribute('src')!
    const q = new URL(src).searchParams
    expect(src).not.toContain('autoplay')
    expect(q.get('start')).toBe('42')
    expect(q.get('rel')).toBe('0')
    expect(q.get('playsinline')).toBe('1')
  })

  it('押す前にサムネイルを消してしまわない（押さないと何も見えない、にはしない）', () => {
    act(() => root.render(<VideoEmbed {...PROPS} />))
    expect(container.querySelector('img')).not.toBeNull()
  })
})

/**
 * 逆対照（この検査が本当に効いているのか）
 *
 * ★ 上の検査は「iframe が無い」ことを主張する。**無いことの主張は、
 *   検査が壊れていても通る。** 検査そのものが差を見分けられることを、
 *   わざと最初から iframe を出す部品で確かめる。
 *   これが落ちなくなったら、上の6件は何も守っていない。
 */
describe('逆対照: 最初から埋め込む部品なら落ちること', () => {
  function EagerEmbed() {
    return (
      <iframe
        src="https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?start=42"
        title="わざと最初から出す"
      />
    )
  }

  it('初期描画の iframe 数の検査が、この部品を見分ける', () => {
    act(() => root.render(<EagerEmbed />))
    expect(document.querySelectorAll('iframe')).toHaveLength(1)
    expect(youtubeRefs().join(' ')).toContain('youtube-nocookie')
  })
})
