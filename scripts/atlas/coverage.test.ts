import { describe, expect, it } from 'vitest'
import { atlasCoverage } from './coverage'

describe('atlas coverage report', () => {
  it('75節を母数に校閲状況を可視化する', async () => {
    const coverage = await atlasCoverage()
    expect(coverage.eventCount).toBeGreaterThanOrEqual(3000)
    expect(coverage.leafUnitCount).toBe(75)
    expect(coverage.storyUnitCount).toBeGreaterThanOrEqual(2)
    expect(coverage.missingStoryUnits.length).toBe(coverage.leafUnitCount - coverage.storyUnitCount)
  })
})
