// @vitest-environment jsdom
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { act } from 'react'
import { createRoot, type Root } from 'react-dom/client'
import type { DrillCard } from '@/lib/loop/drill-study'

/**
 * 特訓のフラッシュカード（app/drills/[drillId]/flashcards/flashcards.tsx）を
 * **本物の DOM に載せて**確かめる。字面ではなく、React が実際に何を描いたかを見る。
 *
 * ★ 守るべき一線: **次のカードの答えの面を先に見せない。**
 *   カードは Y 軸に 0.45 秒かけて回る作りなので、札の要素を使い回すと
 *   「中身は次のカードに入れ替わったのに、裏返しを戻す回転だけが残る」時間が生まれ、
 *   答えを見る前に次のカードの答えの面が正面を向いてしまう。
 *   jsdom は CSS の遷移を描かないので、回転が起きる**条件**のほうを見る。
 *   すなわち、次のカードの札が前のカードと同じ要素かどうか。作り直されていれば
 *   遷移の始点が無く、回転は一度も起こらない。
 */

const actions = vi.hoisted(() => ({
  revealFlashcard: vi.fn(),
  rateFlashcard: vi.fn(),
}))
vi.mock('@/app/drills/[drillId]/actions', () => actions)

const { Flashcards } = await import('@/app/drills/[drillId]/flashcards/flashcards')

const CARDS: DrillCard[] = [
  { id: 'card-1', front: 'Renaissance', kcLabel: 'ルネサンス' },
  { id: 'card-2', front: 'Reformation', kcLabel: '宗教改革' },
]
const ANSWER: Record<string, string> = {
  'card-1': 'ルネサンス（文芸復興）',
  'card-2': '宗教改革',
}

let container: HTMLDivElement
let root: Root

beforeEach(() => {
  ;(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true
  actions.revealFlashcard.mockImplementation(
    async ({ itemId }: { itemId: string }) => ({ answer: ANSWER[itemId] }),
  )
  actions.rateFlashcard.mockResolvedValue(undefined)
  container = document.createElement('div')
  document.body.appendChild(container)
  root = createRoot(container)
})

afterEach(() => {
  act(() => root.unmount())
  container.remove()
  vi.clearAllMocks()
})

const cardEl = () => container.querySelector('.hs-fc') as HTMLElement
const faceText = (side: 'front' | 'back') =>
  (container.querySelector(`.hs-fc__face--${side} .hs-fc__text`) as HTMLElement).textContent
const button = (label: string) =>
  Array.from(container.querySelectorAll('button')).find(b => b.textContent === label) as HTMLButtonElement

const mount = async () => {
  await act(async () => { root.render(<Flashcards cards={CARDS} drillId="11111111-1111-4111-8111-111111111111" />) })
}
const flip = async () => { await act(async () => { cardEl().click() }) }
const rate = async (label: string) => { await act(async () => { button(label).click() }) }

describe('フラッシュカードのめくりと送り', () => {
  it('めくると答えが裏の面に載る', async () => {
    await mount()
    expect(faceText('front')).toBe('Renaissance')
    expect(faceText('back')).toBe('')

    await flip()
    expect(cardEl().className).toContain('hs-fc--flipped')
    expect(faceText('back')).toBe('ルネサンス（文芸復興）')
  })

  it('答えを出したまま次へ送っても、次のカードは表のまま・答えは空で現れる', async () => {
    await mount()
    await flip()
    await rate('わかった')

    expect(faceText('front')).toBe('Reformation')
    expect(cardEl().className).not.toContain('hs-fc--flipped')
    // 次のカードの答えはまだサーバーから取っていない
    expect(faceText('back')).toBe('')
    expect(actions.revealFlashcard).toHaveBeenCalledTimes(1)
  })

  it('次のカードは札ごと作り直される（裏返しを戻す回転を描かせない）', async () => {
    await mount()
    const first = cardEl()
    await flip()
    expect(cardEl()).toBe(first) // めくるだけなら同じ札。ここは回転してよい

    await rate('わかった')
    // ★ ここが本題。使い回すと hs-fc--flipped が外れる 0.45 秒のあいだ、
    //   次のカードの答えの面が正面を向く。
    expect(cardEl()).not.toBe(first)
  })

  it('送ったあとの札は、めくるまで覚え具合を選べない', async () => {
    await mount()
    await flip()
    await rate('わかった')
    for (const label of ['わからない', 'あいまい', 'わかった', '余裕']) {
      expect(button(label).disabled).toBe(true)
    }
  })
})
