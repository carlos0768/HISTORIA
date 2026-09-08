import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, seedCanonEvent, seedPerson, SEED_DIR } from '@/scripts/db/seed'
import { loadTerms, termLinker, resetTermLinker, TERMS_TTL_MS } from './terms'

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('本文の語彙の読み込み（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_terms_test'))
    await seedMasters(db, SEED_DIR)
    await seedCanonEvent(db, SEED_DIR, { requireApproval: false })
    await seedPerson(db, SEED_DIR, { requireApproval: false })
  }, 120_000)
  afterAll(async () => { await drop() })

  it('person と canon_event の label と aliases を、人物を先にして読む', async () => {
    const terms = await loadTerms(db)
    const firstEvent = terms.findIndex(t => t.kind === 'event')
    expect(firstEvent).toBeGreaterThan(0)
    expect(terms.slice(0, firstEvent).every(t => t.kind === 'person')).toBe(true)
    expect(terms).toContainEqual({ kind: 'person', label: 'キュロス2世', aliases: ['キュロス大王'] })
    expect(terms.some(t => t.kind === 'event' && t.label === 'ハンムラビ法典')).toBe(true)
  })

  it('道具はプロセス内で使い回し、TTL を過ぎたら読み直す', async () => {
    resetTermLinker()
    const t0 = 1_000
    const a = termLinker(db, t0)
    const b = termLinker(db, t0 + TERMS_TTL_MS - 1)
    expect(b).toBe(a)
    const c = termLinker(db, t0 + TERMS_TTL_MS)
    expect(c).not.toBe(a)
    expect((await c).find('ハンムラビ王はハンムラビ法典を制定した').map(t => t.label))
      .toEqual(['ハンムラビ', 'ハンムラビ法典'])
    resetTermLinker()
  })
})
