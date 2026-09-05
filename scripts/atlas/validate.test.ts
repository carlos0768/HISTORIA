import { describe, expect, it } from 'vitest'
import { validateAtlas } from './validate'

describe('atlas seed validator', () => {
  it('ゴールデン物語と全イベントを検証する', () => {
    const result = validateAtlas()
    expect(result.events).toBeGreaterThanOrEqual(15)
    expect(result.stories).toBeGreaterThanOrEqual(2)
    expect(result.steps).toBeGreaterThanOrEqual(15)
  })
  it('リリース目標未達を通常検証と混同しない', () => {
    expect(() => validateAtlas(undefined, true)).toThrow('75物語')
  })
})
