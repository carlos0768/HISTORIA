import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createClient, readConfig } from '@/lib/ai/client'
import {
  parseQuery, likePattern, toVectorLiteral, rankHits, research, embedMissing, embedCoverage,
  embedTextOfEvent, QUERY_MAX_CHARS, EMBED_DIMENSIONS, type ResearchHit,
} from './research'

describe('検索語の扱い', () => {
  it('前後と連続する空白を整える', () => {
    expect(parseQuery('  ウマイヤ朝 \n アッバース朝 ')).toEqual({ query: 'ウマイヤ朝 アッバース朝' })
  })
  it('空と長すぎる語は理由つきで断る（例外にしない）', () => {
    expect(parseQuery('   ')).toHaveProperty('error')
    expect(parseQuery('あ'.repeat(QUERY_MAX_CHARS))).toHaveProperty('query')
    expect(parseQuery('あ'.repeat(QUERY_MAX_CHARS + 1))).toHaveProperty('error')
  })
  it('LIKE のメタ文字を無効にする（% で全件一致にならない）', () => {
    expect(likePattern('100%')).toBe('%100\\%%')
    expect(likePattern('a_b')).toBe('%a\\_b%')
  })
})

describe('ベクトルの書式', () => {
  it('pgvector の入力形式にする', () => {
    const v = new Array(EMBED_DIMENSIONS).fill(0)
    v[0] = 0.5
    expect(toVectorLiteral(v)).toMatch(/^\[0\.5,0,0,/)
  })
  it('次元が違えば落とす（DB の文面では呼び出し元が分からない）', () => {
    expect(() => toVectorLiteral([1, 2, 3])).toThrow(/768/)
  })
  it('数値でない要素は落とす', () => {
    const v = new Array(EMBED_DIMENSIONS).fill(0)
    v[3] = Number.NaN
    expect(() => toVectorLiteral(v)).toThrow()
  })
})

describe('並び順', () => {
  const hit = (o: Partial<ResearchHit>): ResearchHit => ({
    kind: 'event', id: o.id ?? 'x', label: o.label ?? 'x', kcKind: null, unitLabels: [],
    yearFrom: null, yearTo: null, precision: null, regionIds: [],
    textMatch: false, similarity: null, ...o,
  })
  it('語の一致 → 類似度の高い順 → 年代順。類似度の無いものは後ろ', () => {
    const r = rankHits([
      hit({ id: 'sim-low', similarity: 0.3 }),
      hit({ id: 'no-sim', yearFrom: -500 }),
      hit({ id: 'text', textMatch: true, similarity: 0.1 }),
      hit({ id: 'sim-high', similarity: 0.9 }),
      hit({ id: 'no-sim-old', yearFrom: -1000 }),
    ])
    expect(r.map(h => h.id)).toEqual(['text', 'sim-high', 'sim-low', 'no-sim-old', 'no-sim'])
  })
})

describe('埋め込みにかける文', () => {
  it('別名も含める（表記ゆれは別名にしか無い）', () => {
    expect(embedTextOfEvent({ label: 'フビライの即位', aliases: ['クビライ'] })).toBe('フビライの即位（クビライ）')
    expect(embedTextOfEvent({ label: 'ハンムラビ法典', aliases: [] })).toBe('ハンムラビ法典')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip
const PGVECTOR = process.env.PGVECTOR !== 'off'
const vectorSuite = TEST_DB_URL && PGVECTOR ? describe : describe.skip

/** 特定の軸だけ立てた単位ベクトル。cos 類似度が手で読める */
function unit(axis: number, second?: number): number[] {
  const v = new Array<number>(EMBED_DIMENSIONS).fill(0)
  v[axis] = 1
  if (second !== undefined) { v[axis] = Math.SQRT1_2; v[second] = Math.SQRT1_2 }
  return v
}

dbSuite('教材の中の「調べる」（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_research_test'))
    await seedMasters(db, SEED_DIR)
    // 地域 id: 10 = メソポタミア・イラン, 11 = アナトリア・シリア, 22 = 中国
    await db`
      INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES
        ('ce.umayyad',  'ウマイヤ朝の成立', '{}', 661, NULL, 'exact', '{11}'),
        ('ce.abbasid',  'アッバース朝の成立', '{アッバース革命}', 750, NULL, 'exact', '{10}'),
        ('ce.hammurabi','ハンムラビ法典', '{ハンムラビ法典の制定}', -1750, NULL, 'century', '{10}'),
        ('ce.qin',      '秦の中国統一', '{始皇帝の統一}', -221, NULL, 'exact', '{22}')`
    await db`
      INSERT INTO kc (id, label, kind, year_from, year_to, year_precision, exam_weight) VALUES
        ('kc.islam.umayyad_vs_abbasid', 'ウマイヤ朝とアッバース朝の違い', 'distinction', 661, 1258, 'century', 1.0),
        ('kc.retired', 'ウマイヤ朝（退役）', 'fact', NULL, NULL, NULL, 1.0)`
    await db`UPDATE kc SET retired = true WHERE id = 'kc.retired'`
    await db`INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES
               ('kc.islam.umayyad_vs_abbasid', 10, false),
               ('kc.islam.umayyad_vs_abbasid', 11, true)`
    await db`INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.umayyad_vs_abbasid', 'wh.2.4.1')`
  }, 120_000)
  afterAll(async () => { await drop() })

  it('語の一致だけで引ける（ベクトルが無くても止まらない）', async () => {
    const hits = await research(db, { query: 'ウマイヤ', vector: null })
    expect(hits.map(h => h.id)).toEqual(['kc.islam.umayyad_vs_abbasid', 'ce.umayyad'])
    expect(hits.every(h => h.textMatch && h.similarity === null)).toBe(true)
  })

  it('別名でも当たる', async () => {
    const hits = await research(db, { query: '始皇帝', vector: null })
    expect(hits.map(h => h.id)).toEqual(['ce.qin'])
  })

  it('退役した KC は出さない', async () => {
    const hits = await research(db, { query: '退役', vector: null })
    expect(hits).toEqual([])
  })

  it('年代・地域・教科書の節を持ち帰る（画面が年表と地図に置くため）', async () => {
    const [kc] = await research(db, { query: 'ウマイヤ朝とアッバース朝', vector: null })
    expect(kc).toMatchObject({
      kind: 'kc', kcKind: 'distinction', yearFrom: 661, yearTo: 1258, precision: 'century',
      unitLabels: [expect.any(String)],
    })
    // 主地域が先頭
    expect(kc!.regionIds).toEqual([11, 10])
    const [ev] = await research(db, { query: 'ハンムラビ', vector: null })
    expect(ev).toMatchObject({ kind: 'event', yearFrom: -1750, yearTo: null, regionIds: [10] })
  })

  it('% を打っても全件にならない', async () => {
    expect(await research(db, { query: '%', vector: null })).toEqual([])
  })

  it('空の語は空を返す', async () => {
    expect(await research(db, { query: '  ', vector: null })).toEqual([])
  })

  it('埋め込みの充足率を数える', async () => {
    const c = await embedCoverage(db)
    expect(c.kc).toEqual({ total: 1, embedded: 0 })
    expect(c.canonEvent).toEqual({ total: 4, embedded: 0 })
  })
})

vectorSuite('近傍検索（pgvector）', () => {
  let db: Sql
  let drop: () => Promise<void>

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_research_vec_test'))
    await seedMasters(db, SEED_DIR)
    await db`
      INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids, embedding) VALUES
        ('ce.a', '出来事A', '{}', 100, NULL, 'exact', '{10}', ${toVectorLiteral(unit(0))}::vector),
        ('ce.b', '出来事B', '{}', 200, NULL, 'exact', '{11}', ${toVectorLiteral(unit(0, 1))}::vector),
        ('ce.c', '出来事C', '{}', 300, NULL, 'exact', '{22}', ${toVectorLiteral(unit(2))}::vector),
        ('ce.none', '埋め込み無し', '{}', 400, NULL, 'exact', '{}', NULL)`
    await db`
      INSERT INTO kc (id, label, kind, exam_weight, embedding) VALUES
        ('kc.a', '知識A', 'fact', 1.0, ${toVectorLiteral(unit(1))}::vector)`
  }, 120_000)
  afterAll(async () => { await drop() })

  it('類似度の高い順に返し、類似度を隠さない', async () => {
    const hits = await research(db, { query: 'なにか', vector: unit(0) })
    // 類似度 0 の2件（ce.c と kc.a）は年代のある方が先
    expect(hits.map(h => h.id)).toEqual(['ce.a', 'ce.b', 'ce.c', 'kc.a'])
    expect(hits[0]!.similarity).toBeCloseTo(1, 5)
    expect(hits[1]!.similarity).toBeCloseTo(Math.SQRT1_2, 5)
    expect(hits[2]!.similarity).toBeCloseTo(0, 5)
    expect(hits[3]!.similarity).toBeCloseTo(0, 5)
    expect(hits.every(h => !h.textMatch)).toBe(true)
  })

  it('埋め込みが無い行は近傍では出ないが、語が一致すれば出る', async () => {
    const byVec = await research(db, { query: 'なにか', vector: unit(0) })
    expect(byVec.map(h => h.id)).not.toContain('ce.none')
    const byText = await research(db, { query: '埋め込み無し', vector: unit(0) })
    expect(byText[0]).toMatchObject({ id: 'ce.none', textMatch: true, similarity: null })
  })

  it('語の一致は類似度が低くても先頭に来る', async () => {
    // 出来事C は unit(2) で、検索ベクトル unit(0) との類似度は 0
    const hits = await research(db, { query: '出来事C', vector: unit(0) })
    expect(hits[0]).toMatchObject({ id: 'ce.c', textMatch: true })
    expect(hits[0]!.similarity).toBeCloseTo(0, 5)
  })

  it('件数の上限を守る', async () => {
    const hits = await research(db, { query: 'なにか', vector: unit(0), limit: 2 })
    expect(hits).toHaveLength(2)
  })

  it('空の行だけを埋め、埋まっている行には触れない（何度流しても同じ）', async () => {
    // 既定の向き（生成 Claude / 検証 Gemini）。鍵が無いのでフェイクの Gemini が埋め込む
    const client = createClient(readConfig({} as unknown as NodeJS.ProcessEnv))
    expect(client.usingFake).toBe(true)
    expect(client.embedProviderName).toBe('fake:gemini')
    const before = await db<{ e: string }[]>`SELECT embedding::text AS e FROM canon_event WHERE id = 'ce.a'`

    const r1 = await embedMissing(db, client, { now: new Date('2026-09-04T00:00:00Z'), batch: 1 })
    expect(r1).toMatchObject({ kc: 0, canonEvent: 1 })
    expect(r1.model).toContain('fake')
    expect(await embedCoverage(db)).toEqual({
      kc: { total: 1, embedded: 1 }, canonEvent: { total: 4, embedded: 4 },
    })
    // 既に入っていたものはそのまま
    const after = await db<{ e: string }[]>`SELECT embedding::text AS e FROM canon_event WHERE id = 'ce.a'`
    expect(after).toEqual(before)
    // 埋めた行は 768 次元で入っている
    const [dim] = await db<{ n: number }[]>`SELECT vector_dims(embedding) AS n FROM canon_event WHERE id = 'ce.none'`
    expect(dim!.n).toBe(EMBED_DIMENSIONS)

    const r2 = await embedMissing(db, client, { now: new Date('2026-09-04T00:00:00Z') })
    expect(r2).toMatchObject({ kc: 0, canonEvent: 0, model: null })
  })
})
