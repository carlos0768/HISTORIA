import type { AtlasPosition } from './schema'

const radians = (degrees: number) => degrees * Math.PI / 180

/** 投影中心から90度以内だけを表面として描く。 */
export function isFrontFacing(point: AtlasPosition, rotation: [number, number, number]): boolean {
  const center: AtlasPosition = [-rotation[0], -rotation[1]]
  const lat1 = radians(center[1]); const lat2 = radians(point[1])
  const delta = radians(shortestLongitudeDelta(center[0], point[0]))
  const cosine = Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2) * Math.cos(delta)
  return cosine >= 0
}

/** 日付変更線をまたぐときも長い方向へ回さない差分。 */
export function shortestLongitudeDelta(from: number, to: number): number {
  return ((to - from + 540) % 360) - 180
}

export function targetRotation(point: AtlasPosition): [number, number, number] {
  return [-point[0], -Math.max(-50, Math.min(65, point[1])), 0]
}

export function spatialDistanceKm(a: AtlasPosition, b: AtlasPosition): number {
  const lat1 = radians(a[1]); const lat2 = radians(b[1])
  const dLat = lat2 - lat1
  const dLon = radians(shortestLongitudeDelta(a[0], b[0]))
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2
  return 6371 * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h))
}
