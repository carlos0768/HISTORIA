// @vitest-environment jsdom
import { act } from 'react'
import { createRoot, type Root } from 'react-dom/client'
import { afterEach, beforeEach, describe, expect, it } from 'vitest'
import type { ResearchResponse } from '@/lib/loop/research'
import { ResearchResults } from './research-results'

const result: ResearchResponse = {
  ok: true,
  query: 'アッバース朝',
  mode: 'text',
  note: null,
  polities: [],
  sections: [{
    kind: 'section', id: 'section-1', label: 'イスラーム世界の成立', kcKind: null,
    unitLabels: ['イスラーム世界'], yearFrom: 750, yearTo: 1258,
    precision: 'century', regionIds: [10, 11], textMatch: true, similarity: null,
    section: {
      materialId: 'material-1', ord: 2, materialTitle: '教材',
      unitLabel: 'イスラーム世界', snippet: 'アッバース朝は750年に成立した。',
    },
  }],
  hits: [{
    kind: 'event', id: 'event-1', label: 'アッバース朝の成立', kcKind: null,
    unitLabels: [], yearFrom: 750, yearTo: null, precision: 'exact',
    regionIds: [10], textMatch: true, similarity: null,
  }],
}

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

describe('検索結果', () => {
  it('教材・地図・年表を同時に描画して項目を選べる', async () => {
    await act(async () => root.render(<ResearchResults result={result} />))
    await act(async () => { await new Promise(resolve => setTimeout(resolve, 0)) })

    expect(container.textContent).toContain('教材の節 1 件')
    expect(container.querySelector('.lv-map')).not.toBeNull()
    expect(container.querySelector('.hs-chrono')).not.toBeNull()

    const event = Array.from(container.querySelectorAll('button'))
      .find(button => button.textContent?.includes('アッバース朝の成立'))
    expect(event).toBeDefined()
    act(() => event!.click())
    expect(event!.getAttribute('aria-pressed')).toBe('true')
  })
})
