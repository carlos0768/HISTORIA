// @vitest-environment jsdom
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { readFileSync } from 'node:fs'
import { act } from 'react'
import { createRoot, type Root } from 'react-dom/client'
import type { AtlasEvent, AtlasStory } from '@/lib/atlas/schema'
import { AtlasWorkspace } from './atlas-workspace'

const story = (name: string): AtlasStory =>
  JSON.parse(readFileSync(`seed/atlas/stories/${name}.json`, 'utf8')) as AtlasStory
const events = readFileSync('seed/atlas/events.ndjson', 'utf8').trim().split('\n')
  .map(line => JSON.parse(line) as AtlasEvent)

const columbus = story('columbus-first-voyage')
const industrial = story('industrial-revolution-spread')
const eventsOf = (s: AtlasStory) => {
  const ids = new Set(s.eventIds)
  return events.filter(event => ids.has(event.id))
}

let container: HTMLDivElement
let root: Root

beforeEach(() => {
  ;(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true
  Object.defineProperty(window, 'matchMedia', {
    configurable: true,
    value: vi.fn(() => ({
      matches: true,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
    })),
  })
  container = document.createElement('div')
  document.body.appendChild(container)
  root = createRoot(container)
})

afterEach(() => {
  act(() => root.unmount())
  container.remove()
  vi.unstubAllGlobals()
})

describe('歴史地球儀の物語検索', () => {
  it('候補を絞ったら選択欄だけでなく地球と説明も先頭候補へ切り替える', async () => {
    const fetchMock = vi.fn(async () => new Response(JSON.stringify({
      story: industrial,
      events: eventsOf(industrial),
      learningHref: '/drills/new?unit=wh.4.1.1',
    }), { status: 200, headers: { 'content-type': 'application/json' } }))
    vi.stubGlobal('fetch', fetchMock)

    await act(async () => {
      root.render(<AtlasWorkspace
        stories={[columbus, industrial]}
        initialStory={columbus}
        initialEvents={eventsOf(columbus)}
        initialLearningHref="/drills/new?unit=wh.3.5.1"
        countries={[]}
      />)
    })

    const input = container.querySelector<HTMLInputElement>('.hs-atlas-search input')!
    act(() => {
      Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')!
        .set!.call(input, '産業革命')
      input.dispatchEvent(new Event('input', { bubbles: true }))
    })
    await act(async () => {
      await vi.waitFor(() => {
        expect(fetchMock).toHaveBeenCalledWith('/api/atlas/stories/story.industrial-revolution-spread')
      })
    })

    await act(async () => {
      await vi.waitFor(() => {
        expect(container.querySelector('.hs-atlas-now strong')?.textContent).toBe('紡績を機械化')
      })
    })

    expect(container.querySelector<HTMLSelectElement>('.hs-atlas-select select')?.value)
      .toBe('story.industrial-revolution-spread')
    expect(container.querySelector('.hs-atlas-steps li strong')?.textContent).toBe('紡績を機械化')
  })
})
