// @vitest-environment jsdom
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { act } from 'react'
import { createRoot, type Root } from 'react-dom/client'
import { readFileSync } from 'node:fs'
import { ErrorScreen } from './error-screen'

/**
 * 例外を受け止める画面を **DOM で** 確かめる
 *
 * ★ 守るべき一線は3つ。
 *   1. **押せるやり直しが在る。** 手書きのエラー画面で最もありがちな失敗は
 *      「ボタンは在るが onClick を書き忘れていて何も起きない」である。
 *      字面では気づけないので、本物の DOM で押して数える。
 *   2. **digest を出す。** 本番では error.message が総称に置き換わるので、
 *      これが無いと作者は Vercel のログを引けない。
 *   3. **遷移リンクを置かない。** 未認証の人を `/` へ送ると proxy.ts が
 *      404 を返す（docs/10 G2）。行き止まりに送るくらいなら出さない。
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

describe('ErrorScreen', () => {
  it('日本語で、何が起きたかと打てる手を出す', () => {
    act(() => root.render(<ErrorScreen retry={() => {}} />))
    expect(container.textContent).toContain('うまくいきませんでした')
    expect(container.textContent).toContain('もう一度ためす')
    // ★ Next の素の画面はこれを出していた。それを置き換えるのが目的である
    expect(container.textContent).not.toContain('Application error')
    expect(container.textContent).not.toContain('server-side exception')
  })

  it('「もう一度ためす」を押すと retry が実際に呼ばれる', () => {
    // ★ 逆対照。onClick を書き忘れた死にボタンだと 0 のまま落ちる
    let tried = 0
    act(() => root.render(<ErrorScreen retry={() => { tried++ }} />))

    const buttons = container.querySelectorAll('button')
    expect(buttons).toHaveLength(1)
    act(() => { buttons[0]!.click() })
    expect(tried).toBe(1)
  })

  it('digest を渡すと出る（作者がログを引ける）', () => {
    act(() => root.render(<ErrorScreen digest="1a2b3c4d5e" retry={() => {}} />))
    expect(container.textContent).toContain('1a2b3c4d5e')
    expect(container.textContent).toContain('識別番号')
  })

  it('digest が無いときは見出しごと出さない', () => {
    // 空の「識別番号」だけが残ると、何かを控えるべきなのかが分からない
    act(() => root.render(<ErrorScreen retry={() => {}} />))
    expect(container.textContent).not.toContain('識別番号')
    expect(container.querySelector('code')).toBeNull()
  })

  it('遷移リンクを1つも置かない', () => {
    // ★ 逆対照。「ホームへ」を足すと落ちる。未認証の人には proxy.ts が
    //   404 を返すので（docs/10 G2）、押せるのに行き止まりになる
    act(() => root.render(<ErrorScreen digest="x" retry={() => {}} />))
    expect(container.querySelectorAll('a')).toHaveLength(0)
  })
})

/**
 * ★ app/** は vitest の include に無い（vitest.config.ts）ので、
 *   殻のほうは字面で見る。ここで見たいのは Next 16 の破壊的変更を
 *   踏んでいないことだけである。
 *   Next 16.3 で prop 名が `reset` から `retry` に変わっており
 *   （docs .../file-conventions/error.md の版歴 `v16.3.0 retry prop became stable`）、
 *   `reset` のまま書くと undefined を呼んで、エラー画面自身が落ちる。
 */
describe('app/error.tsx と app/global-error.tsx の殻', () => {
  const errorTsx = readFileSync('app/error.tsx', 'utf8')
  const globalTsx = readFileSync('app/global-error.tsx', 'utf8')

  /**
   * ★ 注記を落としてから読む。どちらのファイルも「reset ではない」と
   *   **理由を書いてある**ので、素の字面を見ると注記のほうに当たってしまう。
   *   見たいのはコードである。
   */
  const code = (src: string) => src.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '')

  it('どちらも Client Component である（境界の必須条件）', () => {
    expect(errorTsx.startsWith("'use client'")).toBe(true)
    expect(globalTsx.startsWith("'use client'")).toBe(true)
  })

  it('prop は retry であって reset ではない', () => {
    // ★ 逆対照。どちらかを reset に書き換えると落ちる
    for (const [name, src] of [['error.tsx', errorTsx], ['global-error.tsx', globalTsx]] as const) {
      expect(code(src), name).toContain('retry')
      expect(code(src), name).not.toMatch(/\breset\b/)
    }
    // 殻の役割の違い。error.tsx は渡すだけ、global-error.tsx は自分で押す
    expect(errorTsx).toContain('retry={retry}')
    expect(globalTsx).toContain('retry()')
  })

  it('global-error は <html> と <body> を自前で持つ', () => {
    // 無いと build か実行時に落ちる（作法書 error.md「Global Error」）
    expect(globalTsx).toContain('<html')
    expect(globalTsx).toContain('<body')
  })

  it('global-error は .lv-* のクラスに頼らない（globals.css が届かない）', () => {
    // ★ 逆対照。className="lv-btn" などを書くと落ちる。
    //   作法書が「global-error は自前の document を描くので global styles を含まない」
    //   と明記しており、クラスを当てても無地の画面が出るだけになる
    expect(globalTsx).not.toMatch(/className=["'][^"']*\blv-/)
    expect(globalTsx).not.toMatch(/className=["'][^"']*\bhs-/)
  })
})
