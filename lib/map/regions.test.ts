import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { REGION_SHAPES, regionShape, unknownCountryCodes } from './regions'
import {
  COUNTRY_PATHS, COUNTRY_NAMES, MICRO_PINS,
  GRATICULE_PATH, SPHERE_PATH, BORDERS_PATH, MAP_WIDTH, MAP_HEIGHT,
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
  const inBounds = (d: string) => {
    for (const n of d.matchAll(/(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/g)) {
      if (Number(n[1]) < -1 || Number(n[1]) > MAP_WIDTH + 1) return false
      if (Number(n[2]) < -1 || Number(n[2]) > MAP_HEIGHT + 1) return false
    }
    return true
  }

  it('国のパスが閉じた輪の連なりで、図の範囲に収まる', () => {
    const codes = Object.keys(COUNTRY_PATHS)
    expect(codes.length).toBeGreaterThan(150)
    for (const [code, d] of Object.entries(COUNTRY_PATHS)) {
      expect(d.startsWith('M'), code).toBe(true)
      expect(d.split('M').filter(Boolean).every(r => r.endsWith('Z')), code).toBe(true)
      expect(inBounds(d), `${code} が図からはみ出している`).toBe(true)
    }
  })

  it('球の輪郭・経緯線・国境が引かれ、図の範囲に収まる', () => {
    expect(SPHERE_PATH.length).toBeGreaterThan(100)
    expect(GRATICULE_PATH.split('M').filter(Boolean).length).toBeGreaterThan(10)
    expect(BORDERS_PATH.length).toBeGreaterThan(1000)
    for (const [name, d] of [['球', SPHERE_PATH], ['経緯線', GRATICULE_PATH], ['国境', BORDERS_PATH]] as const) {
      expect(inBounds(d), `${name} が図からはみ出している`).toBe(true)
    }
  })

  it('極小国の点が図の中にあり、国土と重複しない', () => {
    expect(MICRO_PINS.length).toBeGreaterThan(20)
    for (const p of MICRO_PINS) {
      expect(p.x).toBeGreaterThanOrEqual(0)
      expect(p.x).toBeLessThanOrEqual(MAP_WIDTH)
      expect(p.y).toBeGreaterThanOrEqual(0)
      expect(p.y).toBeLessThanOrEqual(MAP_HEIGHT)
      // 国土で描けているものを点にしない（二重に出る）
      expect(COUNTRY_PATHS[p.id], `${COUNTRY_NAMES[p.id]} が国土と点の両方にある`).toBeUndefined()
    }
  })

  it('マルタ・バーレーン・シンガポールが点で出る（110m の国土では消える大きさ）', () => {
    const pinned = new Set(MICRO_PINS.map(p => p.id))
    for (const code of ['470', '048', '702']) {
      expect(pinned.has(code), `${COUNTRY_NAMES[code]} の点がありません`).toBe(true)
    }
  })
})
