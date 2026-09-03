import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createKcs, createMaterial, createItem } from './fixture'
import { reportContent, openReports, resolveReport, COMMENT_MAX } from './report'
import { materialView } from './material'

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('誤りの報告（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  let userId: string
  const NOW = new Date('2026-09-15T03:00:00Z')
  const UNIT = 'wh.2.1.1'

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_report_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    for (const t of ['content_report', 'response', 'material_read', 'user_activity',
                     'item_kc', 'item', 'material_section', 'material', 'kc_syllabus_unit',
                     'kc_region', 'kc', 'app_user']) {
      await db.unsafe(`DELETE FROM ${t}`)
    }
    userId = await createUser(db, NOW)
  })

  /** 本文を1節だけ持つ教材を作り、その節の id を返す */
  const makeSection = async (body = '本文', owner: string | null = null) => {
    const m = await createMaterial(db, { userId: owner, unitId: UNIT })
    const id = randomUUID()
    await db`
      INSERT INTO material_section (id, material_id, ord, heading, body_md, char_count)
      VALUES (${id}, ${m}, 1, '見出し', ${body}, ${body.length})`
    return { materialId: m, sectionId: id }
  }
  const section = async (owner: string | null = null) => (await makeSection('本文', owner)).sectionId

  it('教材のセクションを報告できる', async () => {
    const id = await section()
    const r = await reportContent(db, {
      userId, targetKind: 'material_section', targetId: id, comment: '年号が違う', now: NOW,
    })
    expect(r.duplicate).toBe(false)
    const open = await openReports(db)
    expect(open).toHaveLength(1)
    expect(open[0]!.comment).toBe('年号が違う')
    expect(open[0]!.targetId).toBe(id)
  })

  /** ★ 理由を必須にすると押されない。空でも受け取る（docs/08 §5 層4） */
  it('理由が空でも受け取る', async () => {
    const id = await section()
    await reportContent(db, {
      userId, targetKind: 'material_section', targetId: id, comment: '   ', now: NOW,
    })
    const open = await openReports(db)
    expect(open).toHaveLength(1)
    expect(open[0]!.comment).toBeNull()
  })

  it('設問も報告できる', async () => {
    await createKcs(db, ['kc.t.a'], UNIT)
    const item = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.a' }], answerKey: 'a', now: NOW })
    await reportContent(db, {
      userId, targetKind: 'item', targetId: item, comment: null, now: NOW,
    })
    expect((await openReports(db))[0]!.targetKind).toBe('item')
  })

  it('長すぎる理由は切り詰める', async () => {
    const id = await section()
    await reportContent(db, {
      userId, targetKind: 'material_section', targetId: id,
      comment: 'あ'.repeat(COMMENT_MAX + 100), now: NOW,
    })
    expect((await openReports(db))[0]!.comment).toHaveLength(COMMENT_MAX)
  })

  /**
   * ★ ポリモーフィックな参照（target_kind + target_id）は FK を張れない。
   *   実在の確認をここでやめると content_report にゴミが溜まり、
   *   管理画面の未処理件数が意味を失う。
   */
  it('存在しない対象は報告できない', async () => {
    await expect(reportContent(db, {
      userId, targetKind: 'material_section',
      targetId: '00000000-0000-4000-8000-000000000000', comment: null, now: NOW,
    })).rejects.toThrow('見つかりません')
    expect(await openReports(db)).toHaveLength(0)
  })

  /** ★ 読めない対象の id を総当たりして「在るかどうか」を測られないようにする */
  it('他人の教材は報告できない', async () => {
    const other = await createUser(db, NOW)
    const id = await section(other)
    await expect(reportContent(db, {
      userId, targetKind: 'material_section', targetId: id, comment: null, now: NOW,
    })).rejects.toThrow('見つかりません')
  })

  it('同じ対象を2回押しても未処理は1件のまま', async () => {
    const id = await section()
    const a = await reportContent(db, {
      userId, targetKind: 'material_section', targetId: id, comment: null, now: NOW,
    })
    const b = await reportContent(db, {
      userId, targetKind: 'material_section', targetId: id, comment: 'あとから理由', now: NOW,
    })
    expect(b.duplicate).toBe(true)
    expect(b.reportId).toBe(a.reportId)
    const open = await openReports(db)
    expect(open).toHaveLength(1)
    expect(open[0]!.comment).toBe('あとから理由')   // 2回目の理由は受け取る
  })

  describe('処理', () => {
    /**
     * ★ 押した瞬間には伏せない。誤報1件で正しい教材が消えると、いたずらで壊せる。
     *   docs/08 §5 の「即座に非表示」は作者が確認したあとの処理として実装する。
     */
    it('報告しただけでは本文を伏せない', async () => {
      const id = await section()
      await reportContent(db, {
        userId, targetKind: 'material_section', targetId: id, comment: null, now: NOW,
      })
      const [row] = await db<{ hidden: boolean }[]>`
        SELECT hidden FROM material_section WHERE id = ${id}`
      expect(row!.hidden).toBe(false)
    })

    it('確認したら伏せる（本文がクライアントへ出なくなる）', async () => {
      const { materialId: m, sectionId } = await makeSection('あぶない本文')
      const r = await reportContent(db, {
        userId, targetKind: 'material_section', targetId: sectionId, comment: null, now: NOW,
      })
      expect((await resolveReport(db, r.reportId, 'confirmed')).hidden).toBe(true)

      const view = await materialView(db, userId, m)
      expect(view!.sections[0]!.hidden).toBe(true)
      expect(view!.sections[0]!.bodyMd).not.toContain('あぶない本文')
      expect(await openReports(db)).toHaveLength(0)
    })

    it('誤報として棄却したときは何も伏せない', async () => {
      const id = await section()
      const r = await reportContent(db, {
        userId, targetKind: 'material_section', targetId: id, comment: null, now: NOW,
      })
      expect((await resolveReport(db, r.reportId, 'dismissed')).hidden).toBe(false)
      const [row] = await db<{ hidden: boolean }[]>`
        SELECT hidden FROM material_section WHERE id = ${id}`
      expect(row!.hidden).toBe(false)
      expect(await openReports(db)).toHaveLength(0)   // 未処理からは消える
    })

    it('同じ報告を2回処理できない', async () => {
      const id = await section()
      const r = await reportContent(db, {
        userId, targetKind: 'material_section', targetId: id, comment: null, now: NOW,
      })
      await resolveReport(db, r.reportId, 'fixed')
      await expect(resolveReport(db, r.reportId, 'fixed')).rejects.toThrow('見つかりません')
    })

    it('確認した設問は出題されなくなる', async () => {
      await createKcs(db, ['kc.t.b'], UNIT)
      const item = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.b' }], answerKey: 'a', now: NOW })
      const r = await reportContent(db, {
        userId, targetKind: 'item', targetId: item, comment: null, now: NOW,
      })
      await resolveReport(db, r.reportId, 'confirmed')
      const [row] = await db<{ hidden: boolean; hidden_reason: string }[]>`
        SELECT hidden, hidden_reason FROM item WHERE id = ${item}`
      expect(row!.hidden).toBe(true)
      expect(row!.hidden_reason).toBe('user_report')
    })
  })
})
