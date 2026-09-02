import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { REGION_SHAPES, regionShape } from './regions'
import { LAND_PATH, MAP_LAT, MAP_LON, project, MAP_WIDTH, MAP_HEIGHT } from './basemap'
import { SEED_DIR } from '@/scripts/db/seed'
import { parseCsv } from '@/scripts/db/csv'

const seedRegions = parseCsv(readFileSync(join(SEED_DIR, 'region.csv'), 'utf8'))

describe('地図の地域表', () => {
  it('seed/region.csv と id・名前が一致する（ずれると別の場所を指す）', () => {
    expect(REGION_SHAPES).toHaveLength(seedRegions.length)
    for (const r of seedRegions) {
      const shape = regionShape(Number(r.id))
      expect(shape, `id=${r.id} (${r.label}) の枠がありません`).toBeDefined()
      expect(shape!.label).toBe(r.label)
    }
  })

  it('親子の関係が seed と一致する', () => {
    const hasChildren = new Set(seedRegions.filter(r => r.parent_label).map(r => r.parent_label))
    for (const s of REGION_SHAPES) {
      expect(s.isParent, `${s.label} の isParent`).toBe(hasChildren.has(s.label))
    }
  })

  it('枠が west<east / south<north になっている', () => {
    for (const s of REGION_SHAPES) {
      const [w, so, e, n] = s.box
      expect(w, `${s.label}: 経度`).toBeLessThan(e)
      expect(so, `${s.label}: 緯度`).toBeLessThan(n)
    }
  })

  it('枠が図の範囲に収まっている', () => {
    for (const s of REGION_SHAPES) {
      const [w, so, e, n] = s.box
      expect(w).toBeGreaterThanOrEqual(MAP_LON[0])
      expect(e).toBeLessThanOrEqual(MAP_LON[1])
      expect(so).toBeGreaterThanOrEqual(MAP_LAT[0])
      expect(n).toBeLessThanOrEqual(MAP_LAT[1])
    }
  })

  it('子の枠が親の枠に収まっている', () => {
    const byLabel = new Map(REGION_SHAPES.map(s => [s.label, s]))
    for (const r of seedRegions.filter(x => x.parent_label)) {
      const child = byLabel.get(r.label!)!
      const parent = byLabel.get(r.parent_label!)!
      expect(child.box[0], `${child.label} ⊂ ${parent.label}`).toBeGreaterThanOrEqual(parent.box[0])
      expect(child.box[1], `${child.label} ⊂ ${parent.label}`).toBeGreaterThanOrEqual(parent.box[1])
      expect(child.box[2], `${child.label} ⊂ ${parent.label}`).toBeLessThanOrEqual(parent.box[2])
      expect(child.box[3], `${child.label} ⊂ ${parent.label}`).toBeLessThanOrEqual(parent.box[3])
    }
  })
})

describe('基図', () => {
  it('投影が図の四隅に対応する', () => {
    expect(project(MAP_LON[0], MAP_LAT[1])).toEqual({ x: 0, y: 0 })
    expect(project(MAP_LON[1], MAP_LAT[0])).toEqual({ x: MAP_WIDTH, y: MAP_HEIGHT })
  })

  it('範囲外の緯度は端に丸める（図からはみ出さない）', () => {
    expect(project(0, 90).y).toBe(0)
    expect(project(0, -90).y).toBe(MAP_HEIGHT)
  })

  it('陸地のパスが閉じた輪の連なりになっている', () => {
    expect(LAND_PATH.startsWith('M')).toBe(true)
    const rings = LAND_PATH.split('M').filter(Boolean)
    expect(rings.length).toBeGreaterThan(50)
    expect(rings.every(r => r.endsWith('Z'))).toBe(true)
    // 座標が figures の範囲に収まっていること
    for (const n of LAND_PATH.matchAll(/(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/g)) {
      expect(Number(n[1])).toBeGreaterThanOrEqual(0)
      expect(Number(n[1])).toBeLessThanOrEqual(MAP_WIDTH)
      expect(Number(n[2])).toBeGreaterThanOrEqual(0)
      expect(Number(n[2])).toBeLessThanOrEqual(MAP_HEIGHT)
    }
  })
})
