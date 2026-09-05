import { describe, expect, it } from 'vitest'
import { isFrontFacing, shortestLongitudeDelta, spatialDistanceKm, targetRotation } from './geo'

describe('atlas globe math', () => {
  it('裏側の地点をカリングする', () => {
    expect(isFrontFacing([0, 0], [0, 0, 0])).toBe(true)
    expect(isFrontFacing([180, 0], [0, 0, 0])).toBe(false)
  })
  it('日付変更線を最短距離でまたぐ', () => {
    expect(shortestLongitudeDelta(179, -179)).toBe(2)
    expect(spatialDistanceKm([179, 0], [-179, 0])).toBeLessThan(225)
  })
  it('高緯度へカメラを寄せすぎない', () => {
    expect(targetRotation([30, 89])).toEqual([-30, -65, 0])
  })
})
