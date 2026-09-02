import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { REGION_SHAPES, regionShape, unknownCountryCodes } from './regions'
import {
  COUNTRY_PATHS, COUNTRY_NAMES, GRATICULE_PATH, EQUATOR_PATH,
  MAP_LAT, MAP_LON, project, MAP_WIDTH, MAP_HEIGHT,
} from './basemap'
import { SEED_DIR } from '@/scripts/db/seed'
import { parseCsv } from '@/scripts/db/csv'

const seedRegions = parseCsv(readFileSync(join(SEED_DIR, 'region.csv'), 'utf8'))

describe('地図の地域表', () => {
  it('seed/region.csv と id・名前が一致する（ずれると地図が別の場所を指す）', () => {
    expect(REGION_SHAPES).toHaveLength(seedRegions.length)
    for (const r of seedRegions) {
      const shape = regionShape(Number(r.id))
      expect(shape, `id=${r.id} (${r.label}) がありません`).toBeDefined()
      expect(shape!.label).toBe(r.label)
    }
  })

  it('親子の関係が seed と一致する', () => {
    const hasChildren = new Set(seedRegions.filter(r => r.parent_label).map(r => r.parent_label))
    for (const s of REGION_SHAPES) {
      expect(s.isParent, `${s.label} の isParent`).toBe(hasChildren.has(s.label))
    }
  })

  it('すべての地域が国を持つ（空の地域は地図に何も出ない）', () => {
    for (const s of REGION_SHAPES) {
      expect(s.countries.length, `${s.label} の国が0件`).toBeGreaterThan(0)
    }
  })

  it('基図に存在しない国コードを指していない', () => {
    expect(unknownCountryCodes()).toEqual([])
  })

  it('親地域が子の和集合になっている', () => {
    const byLabel = new Map(REGION_SHAPES.map(s => [s.label, s]))
    const kids = new Map<string, string[]>()
    for (const r of seedRegions.filter(x => x.parent_label)) {
      kids.set(r.parent_label!, [...(kids.get(r.parent_label!) ?? []), r.label!])
    }
    for (const [parent, children] of kids) {
      const want = new Set(children.flatMap(c => byLabel.get(c)!.countries))
      expect(new Set(byLabel.get(parent)!.countries), `${parent}`).toEqual(want)
    }
  })

  it('葉の地域どうしで国が重複しない（同じ国が2色に塗られない）', () => {
    const seen = new Map<string, string>()
    for (const s of REGION_SHAPES.filter(x => !x.isParent)) {
      for (const c of s.countries) {
        expect(seen.get(c), `${COUNTRY_NAMES[c]} が ${seen.get(c)} と ${s.label} に重複`).toBeUndefined()
        seen.set(c, s.label)
      }
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

  it('国のパスが閉じた輪の連なりで、図の範囲に収まる', () => {
    const codes = Object.keys(COUNTRY_PATHS)
    expect(codes.length).toBeGreaterThan(150)
    for (const [code, d] of Object.entries(COUNTRY_PATHS)) {
      expect(d.startsWith('M'), code).toBe(true)
      expect(d.split('M').filter(Boolean).every(r => r.endsWith('Z')), code).toBe(true)
    }
    for (const n of Object.values(COUNTRY_PATHS).join('').matchAll(/(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/g)) {
      expect(Number(n[1])).toBeGreaterThanOrEqual(0)
      expect(Number(n[1])).toBeLessThanOrEqual(MAP_WIDTH)
      expect(Number(n[2])).toBeGreaterThanOrEqual(0)
      expect(Number(n[2])).toBeLessThanOrEqual(MAP_HEIGHT)
    }
  })

  it('日付変更線をまたぐ横断線が残っていない', () => {
    let crossing = 0
    for (const d of Object.values(COUNTRY_PATHS)) {
      for (const ring of d.split('M').filter(Boolean)) {
        const pts = ring.replace(/Z$/, '').split('L').map(s => s.split(',').map(Number))
        for (let i = 1; i < pts.length; i++) {
          if (Math.abs(pts[i]![0]! - pts[i - 1]![0]!) > MAP_WIDTH / 2) crossing++
        }
      }
    }
    expect(crossing).toBe(0)
  })

  it('経緯線と赤道が引かれている', () => {
    expect(GRATICULE_PATH.split('M').filter(Boolean).length).toBeGreaterThan(10)
    expect(EQUATOR_PATH).toContain(`L${MAP_WIDTH},`)
  })
})
