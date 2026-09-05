import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser } from './fixture'
import { approveMaterial, approvalTarget, blockedMaterialsForUnit, MAX_NOTE_CHARS } from './approve'
import { blockedMaterials } from './admin'

/**
 * 作者が blocked の教材を配信可能にする経路（docs/02 §5 / docs/10 §8）
 *
 * ★ ここが間違うと、静かに悪い方へ倒れる:
 *   - 設問を開け忘れる → 「配信した」のに1問も出ない
 *   - approved_by に 'factcheck' と書く → 機械が通したことになり来歴が嘘になる
 *   - 退ける相手を間違える → 一意索引で落ちるか、他人の教材を降ろす
 *   どれも画面上は「成功しました」と出る。だから実 DB で1つずつ確かめる。
 */

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('止まった教材を作者が配信可能にする（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  let userId: string
  const NOW = new Date('2026-09-15T11:00:00Z')
  const UNIT = 'wh.2.1.1'

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_approve_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    for (const t of ['item_kc', 'item', 'material_section_kc', 'material_section',
                     'material', 'generation_job', 'app_user']) {
      await db.unsafe(`DELETE FROM ${t}`)
    }
    userId = await createUser(db, NOW)
  })

  /** 教材1本。既定は「事実確認で止まった共有教材」 */
  const material = async (o: {
    status?: string; owner?: string | null; provider?: string; reason?: string | null
    unitId?: string; sections?: number
  } = {}) => {
    const id = randomUUID()
    await db`
      INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version,
                            status, blocked_reason, generated_at)
      VALUES (${id}, ${o.owner ?? null}, ${o.unitId ?? UNIT}, '教材',
              ${o.provider ?? 'anthropic'}, 'claude-opus-5', 'v1',
              ${o.status ?? 'blocked'},
              ${o.reason === undefined ? '「三部会の招集は1615年以来」— 1614年である疑い' : o.reason},
              ${NOW})`
    for (let ord = 1; ord <= (o.sections ?? 2); ord++) {
      await db`
        INSERT INTO material_section (id, material_id, ord, heading, body_md, char_count)
        VALUES (${randomUUID()}, ${id}, ${ord}, ${`§${ord}`}, '本文', 2)`
    }
    return id
  }

  /** その教材の設問。blocked の教材なので既定は未承認 */
  const item = async (materialId: string, approved = false) => {
    const id = randomUUID()
    await db`
      INSERT INTO item (id, user_id, material_id, format, stem, choices, answer_key,
                        guess_rate, approved, approved_by, approved_at, created_at)
      VALUES (${id}, ${userId}, ${materialId}, 'mcq4', '問題文',
              ${db.json([{ key: 'a', text: 'A' }, { key: 'b', text: 'B' },
                         { key: 'c', text: 'C' }, { key: 'd', text: 'D' }])},
              ${db.json('a')}, 0.25,
              ${approved}, ${approved ? 'factcheck' : null}, ${approved ? NOW : null}, ${NOW})`
    return id
  }

  const statusOf = async (id: string) => {
    const [r] = await db<{ status: string }[]>`SELECT status FROM material WHERE id = ${id}`
    return r!.status
  }

  it('blocked を ready にし、設問も一緒に開ける', async () => {
    const id = await material()
    await item(id); await item(id)

    const r = await approveMaterial(db, { materialId: id, note: '本文の記述は正しい', now: NOW })

    expect(r).toMatchObject({ approved: true, items: 2, supersededId: null })
    expect(await statusOf(id)).toBe('ready')

    // ★ 教材だけ開けても出題されない。設問が閉じたままなら「配信した」は嘘になる
    const rows = await db<{ approved: boolean; approved_by: string; approved_at: Date }[]>`
      SELECT approved, approved_by, approved_at FROM item WHERE material_id = ${id}`
    expect(rows).toHaveLength(2)
    for (const x of rows) {
      expect(x.approved).toBe(true)
      expect(x.approved_at).toEqual(NOW)
      // ★ 事実確認は通っていない。'factcheck' と書けば来歴が嘘になる
      expect(x.approved_by).toBe('author')
    }
  })

  it('承認したものは管理ビューの「配信できなかった教材」から消える', async () => {
    const id = await material()
    expect(await blockedMaterials(db)).toHaveLength(1)
    await approveMaterial(db, { materialId: id, note: '正しいと判断した', now: NOW })
    expect(await blockedMaterials(db)).toHaveLength(0)
  })

  it('いま配信中の教材を退けてから入れ替える（一意索引に触れない）', async () => {
    const old = await material({ status: 'ready', reason: null })
    const id = await material()

    const r = await approveMaterial(db, { materialId: id, note: 'こちらを出す', now: NOW })

    expect(r).toMatchObject({ approved: true, supersededId: old })
    expect(await statusOf(old)).toBe('superseded')
    expect(await statusOf(id)).toBe('ready')

    // 来歴として「何を降ろしたか」も残す
    const [m] = await db<{ supersedes_id: string }[]>`
      SELECT supersedes_id FROM material WHERE id = ${id}`
    expect(m!.supersedes_id).toBe(old)
  })

  it('共有教材の承認で、同じ単元の個別教材を降ろさない', async () => {
    // 誰かが自分用に作り直した ready があり、共有版が止まっている
    const personal = await material({ status: 'ready', owner: userId, reason: null })
    const shared = await material()

    await approveMaterial(db, { materialId: shared, note: '共有版も出す', now: NOW })

    expect(await statusOf(personal)).toBe('ready')
    expect(await statusOf(shared)).toBe('ready')
  })

  it('理由が空なら承認しない', async () => {
    const id = await material()
    const r = await approveMaterial(db, { materialId: id, note: '   ', now: NOW })
    expect(r.approved).toBe(false)
    expect(await statusOf(id)).toBe('blocked')
  })

  it('理由が長すぎれば承認しない', async () => {
    const id = await material()
    const r = await approveMaterial(db, {
      materialId: id, note: 'あ'.repeat(MAX_NOTE_CHARS + 1), now: NOW,
    })
    expect(r.approved).toBe(false)
    expect(await statusOf(id)).toBe('blocked')
  })

  it('判断を human_edit_log に積む（何を退けた上での承認かごと）', async () => {
    const id = await material()
    await approveMaterial(db, { materialId: id, note: '1614年10月招集で正しい', now: NOW })

    const [m] = await db<{ human_edit_log: Array<Record<string, unknown>> }[]>`
      SELECT human_edit_log FROM material WHERE id = ${id}`
    expect(m!.human_edit_log).toHaveLength(1)
    expect(m!.human_edit_log[0]).toMatchObject({
      by: 'author',
      action: 'approve_blocked',
      note: '1614年10月招集で正しい',
      blocked_reason: '「三部会の招集は1615年以来」— 1614年である疑い',
    })
    // 消さずに積む。2回目の判断があれば2件になる
    expect(m!.human_edit_log[0]!.at).toBe(NOW.toISOString())
  })

  it('すでに配信できる教材は何もしない', async () => {
    const id = await material({ status: 'ready', reason: null })
    const r = await approveMaterial(db, { materialId: id, note: '念のため', now: NOW })
    expect(r).toMatchObject({ approved: false })
    expect(await statusOf(id)).toBe('ready')
  })

  it('generating / failed / superseded は動かさない', async () => {
    for (const status of ['generating', 'failed', 'superseded']) {
      const id = await material({ status, reason: null })
      const r = await approveMaterial(db, { materialId: id, note: '出したい', now: NOW })
      expect(r.approved, status).toBe(false)
      expect(await statusOf(id)).toBe(status)
    }
  })

  it('フェイクで作った教材は承認しない', async () => {
    const id = await material({ provider: 'fake:anthropic' })
    const r = await approveMaterial(db, { materialId: id, note: '出したい', now: NOW })
    expect(r).toMatchObject({ approved: false })
    expect(await statusOf(id)).toBe('blocked')
  })

  it('見つからない教材は静かに失敗する', async () => {
    const r = await approveMaterial(db, { materialId: randomUUID(), note: 'x', now: NOW })
    expect(r).toMatchObject({ approved: false })
  })

  it('承認する前に読むもの（本文・理由・入れ替わる相手）を1回で返す', async () => {
    const old = await material({ status: 'ready', reason: null })
    const id = await material({ sections: 3 })
    await item(id); await item(id, true)

    const t = await approvalTarget(db, id)
    expect(t).not.toBeNull()
    expect(t!.status).toBe('blocked')
    expect(t!.userId).toBeNull()
    expect(t!.reason).toContain('1615年')
    expect(t!.provider).toBe('anthropic')
    expect(t!.sections.map(s => s.ord)).toEqual([1, 2, 3])
    expect(t!.sections[0]!.bodyMd).toBe('本文')
    expect(t!.itemCount).toBe(2)
    expect(t!.approvedItemCount).toBe(1)
    expect(t!.supersedes).toMatchObject({ id: old })
    expect(t!.editLog).toEqual([])
  })

  it('単元 id から止まっている教材を引ける（uuid を手で打たずに済む）', async () => {
    const a = await material()
    await material({ status: 'ready', unitId: UNIT, owner: userId, reason: null })
    await material({ unitId: 'wh.2.1.2' })

    const rows = await blockedMaterialsForUnit(db, UNIT)
    expect(rows.map(r => r.id)).toEqual([a])
  })
})
