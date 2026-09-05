import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, seedKc, SEED_DIR } from '@/scripts/db/seed'
import { createClient, type AiConfig } from '@/lib/ai/client'
import { ensureBudgetRow, periodOf } from '@/lib/ai/budget'
import { generateMaterial } from '@/lib/pipeline/generate'
import { createDrill } from '@/lib/pipeline/drill'
import { createUser } from './fixture'
import { materialView, recordRead, drillMaterials } from './material'
import { estimatedReadMs, requiredDwellMs, countsAsRead } from '@/lib/domain/reading'

describe('読了の判定（docs/11）', () => {
  it('3,500字の推定読了時間は約7分（docs/07 §2 と一致する）', () => {
    expect(estimatedReadMs(3500)).toBe(420_000)
  })
  it('推定読了時間の60%を境にする', () => {
    expect(requiredDwellMs(3500)).toBe(252_000)
    expect(countsAsRead(251_999, 3500)).toBe(false)
    expect(countsAsRead(252_000, 3500)).toBe(true)
  })
  it('スクロールだけで通らない（滞在0は数えない）', () => {
    expect(countsAsRead(0, 500)).toBe(false)
  })
  it('空のセクションは滞在0でも読了とする（閾値が0になる）', () => {
    expect(countsAsRead(0, 0)).toBe(true)
  })
})

const cfg: AiConfig = {
  genProvider: 'gemini', genModel: 'gemini-3.6-flash',
  verifyProvider: 'anthropic', verifyModel: 'claude-sonnet-5',
  embedModel: 'gemini-embedding-001',
}

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('教材の閲覧と読了（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const DEADLINE = new Date('2026-12-01T00:00:00Z')
  const UNIT = 'wh.2.1.1'
  let userId: string

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_material_test'))
    await seedMasters(db, SEED_DIR)
    await seedKc(db, SEED_DIR, { requireApproval: false })
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await db`TRUNCATE material_section_kc, material_section, material_read, material,
             item_kc, item, response, user_kc_state, kc_card, misconception,
             generation_job, ai_spend, drill_kc, drill_unit, drill, app_user
             RESTART IDENTITY CASCADE`
    await db`DELETE FROM ai_budget`
    await ensureBudgetRow(db, periodOf(NOW))
    userId = await createUser(db, NOW)
  })

  /**
   * 学習の記録を与えて、この利用者の教材が共有ではなく個別になるようにする。
   * p_know を既定より上げると band が変わり、isDefaultContext が false になる。
   */
  const makePersonalized = async (uid: string) => {
    const kcs = await db<{ id: string }[]>`
      SELECT kc_id AS id FROM kc_syllabus_unit WHERE unit_id = ${UNIT} ORDER BY kc_id LIMIT 2`
    for (const k of kcs) {
      await db`INSERT INTO user_kc_state (user_id, kc_id, p_know, n_obs, n_eff)
               VALUES (${uid}, ${k.id}, 0.9, 5, 4)
               ON CONFLICT (user_id, kc_id) DO UPDATE SET p_know = 0.9`
    }
  }

  /** 個別教材（user_id 非NULL）を作る */
  const genPersonal = async (uid: string) => {
    await makePersonalized(uid)
    const r = await generateMaterial(db, createClient(cfg), { userId: uid, unitId: UNIT, now: NOW })
    if (r.status !== 'ready') throw new Error(`ready ではありません: ${r.status}`)
    return r.materialId
  }

  const genReady = async () => {
    const r = await generateMaterial(db, createClient(cfg), { userId, unitId: UNIT, now: NOW })
    if (r.status !== 'ready') throw new Error(`ready ではありません: ${r.status}`)
    return r.materialId
  }

  describe('materialView', () => {
    it('7セクションを ord 順に返し、KC の名前を添える', async () => {
      const id = await genReady()
      const v = (await materialView(db, userId, id))!
      expect(v.status).toBe('ready')
      expect(v.sections.map(s => s.ord)).toEqual([1, 2, 3, 4, 5, 6, 7])
      expect(v.sections[0]!.kcLabels.length).toBeGreaterThan(0)
      expect(v.sections[0]!.bodyMd.length).toBeGreaterThan(0)
      expect(v.unitLabel).toBeTruthy()
    })

    it('最初は1つも読了していない', async () => {
      const v = (await materialView(db, userId, await genReady()))!
      expect(v.readCount).toBe(0)
      expect(v.sections.every(s => !s.read)).toBe(true)
    })

    it('geo の KC が付いたセクションだけ地図の地域を返す', async () => {
      const id = await genReady()
      // ★ 「この節には geo の KC が無い」という前提に寄りかからない。
      //   seed に geo の KC が増えると前提が黙って崩れる（60→408件のときに実際に崩れた）。
      //   geo の紐づけを明示的に外してから測る。
      await db`DELETE FROM material_section_kc msk
                USING kc k, material_section s
                WHERE msk.kc_id = k.id AND k.kind = 'geo'
                  AND msk.section_id = s.id AND s.material_id = ${id}`
      const v = (await materialView(db, userId, id))!
      expect(v.sections.every(s => s.geoRegionIds.length === 0)).toBe(true)

      // このセクションに geo の KC を足すと、その KC の地域が返る
      const [geo] = await db<{ id: string }[]>`
        SELECT k.id FROM kc k WHERE k.kind = 'geo' ORDER BY k.id LIMIT 1`
      await db`INSERT INTO material_section_kc (section_id, kc_id)
               VALUES (${v.sections[0]!.id}, ${geo!.id}) ON CONFLICT DO NOTHING`

      const after = (await materialView(db, userId, id))!
      expect(after.sections[0]!.geoRegionIds.length).toBeGreaterThan(0)
      expect(after.sections[1]!.geoRegionIds).toEqual([])

      // 返る id が地図の地域表に実在すること
      const { regionShape } = await import('@/lib/map/regions')
      for (const rid of after.sections[0]!.geoRegionIds) {
        expect(regionShape(rid), `region ${rid} の枠がありません`).toBeDefined()
      }
    })

    it('他人の個別教材は見えない', async () => {
      const mine = await genPersonal(userId)
      const other = await createUser(db, NOW)
      expect(await materialView(db, other, mine)).toBeNull()
    })

    it('共有教材は誰でも読める（生成した本人でなくても）', async () => {
      const id = await genReady()
      const [m] = await db<{ user_id: string | null }[]>`
        SELECT user_id FROM material WHERE id = ${id}`
      expect(m!.user_id).toBeNull()   // 学習履歴が無いので共有として保存される

      const other = await createUser(db, NOW)
      const v = await materialView(db, other, id)
      expect(v).not.toBeNull()
      expect(v!.sections).toHaveLength(7)
    })

    it('存在しない id は null', async () => {
      expect(await materialView(db, userId, '00000000-0000-4000-8000-000000000000')).toBeNull()
    })

    // 作者判断 Q4: 事実確認を通らなければユニットごと配信しない
    it('blocked の教材は本文を1文字も返さない', async () => {
      const ai = createClient(cfg, { wrongClaims: ['ウェストファリア条約は1658年'] })
      const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
      expect(r.status).toBe('blocked')
      if (r.status !== 'blocked') return
      const v = (await materialView(db, userId, r.materialId))!
      expect(v.status).toBe('blocked')
      expect(v.sections).toEqual([])
      expect(v.blockedReason).toBeTruthy()
    })

    it('伏せたセクションは見出しだけ返して本文を返さない', async () => {
      const id = await genReady()
      const [s] = await db<{ id: string }[]>`
        SELECT id FROM material_section WHERE material_id = ${id} ORDER BY ord LIMIT 1`
      await db`UPDATE material_section SET hidden = true, hidden_reason = 'user_report'
                WHERE id = ${s!.id}`
      const v = (await materialView(db, userId, id))!
      expect(v.sections[0]!.hidden).toBe(true)
      expect(v.sections[0]!.bodyMd).toBe('')
      expect(v.sections[0]!.heading).toBeTruthy()
    })
  })

  describe('recordRead', () => {
    it('滞在が足りなければ記録は残すが読了に数えない', async () => {
      const id = await genReady()
      const v = (await materialView(db, userId, id))!
      const s = v.sections[0]!
      const r = await recordRead(db, {
        userId, sectionId: s.id, dwellMs: s.requiredMs - 1, scrollPct: 1, now: NOW,
      })
      expect(r.counted).toBe(false)
      expect(r.readCount).toBe(0)

      // イベント自体は消さない
      const [row] = await db<{ n: string }[]>`
        SELECT count(*) AS n FROM material_read WHERE section_id = ${s.id}`
      expect(Number(row!.n)).toBe(1)
      expect((await materialView(db, userId, id))!.sections[0]!.read).toBe(false)
    })

    it('滞在が足りれば読了に数える', async () => {
      const id = await genReady()
      const v = (await materialView(db, userId, id))!
      const s = v.sections[0]!
      const r = await recordRead(db, {
        userId, sectionId: s.id, dwellMs: s.requiredMs, scrollPct: 0.9, now: NOW,
      })
      expect(r.counted).toBe(true)
      expect(r.readCount).toBe(1)
      expect(r.total).toBe(7)
      expect((await materialView(db, userId, id))!.readCount).toBe(1)
    })

    it('SQL 側と JS 側の閾値が一致する（境界の1ミリ秒で割れない）', async () => {
      const id = await genReady()
      const v = (await materialView(db, userId, id))!
      for (const s of v.sections.slice(0, 3)) {
        const below = await recordRead(db, { userId, sectionId: s.id, dwellMs: s.requiredMs - 1, scrollPct: null, now: NOW })
        expect(below.counted).toBe(false)
        const exact = await recordRead(db, { userId, sectionId: s.id, dwellMs: s.requiredMs, scrollPct: null, now: NOW })
        expect(exact.counted).toBe(true)
      }
      // 3件が SQL 側でも数えられている
      expect((await materialView(db, userId, id))!.readCount).toBe(3)
    })

    it('他人の個別教材のセクションには記録できない', async () => {
      const mine = await genPersonal(userId)
      const v = (await materialView(db, userId, mine))!
      const other = await createUser(db, NOW)
      await expect(recordRead(db, {
        userId: other, sectionId: v.sections[0]!.id, dwellMs: 999_999, scrollPct: null, now: NOW,
      })).rejects.toThrow('見つかりません')
    })

    it('共有教材の読了は誰でも記録できる', async () => {
      const id = await genReady()
      const v = (await materialView(db, userId, id))!
      const other = await createUser(db, NOW)
      const r = await recordRead(db, {
        userId: other, sectionId: v.sections[0]!.id,
        dwellMs: v.sections[0]!.requiredMs, scrollPct: null, now: NOW,
      })
      expect(r.counted).toBe(true)
      // 読了は利用者ごと。他人が読んでも自分の読了数は増えない
      expect((await materialView(db, userId, id))!.readCount).toBe(0)
      expect((await materialView(db, other, id))!.readCount).toBe(1)
    })

    it('伏せたセクションには記録できない', async () => {
      const id = await genReady()
      const v = (await materialView(db, userId, id))!
      await db`UPDATE material_section SET hidden = true, hidden_reason = 'factcheck_flag'
                WHERE id = ${v.sections[0]!.id}`
      await expect(recordRead(db, {
        userId, sectionId: v.sections[0]!.id, dwellMs: 999_999, scrollPct: null, now: NOW,
      })).rejects.toThrow('表示していません')
    })

    it('桁違いの滞在時間は丸めて入れる（int を溢れさせない）', async () => {
      const id = await genReady()
      const v = (await materialView(db, userId, id))!
      await recordRead(db, {
        userId, sectionId: v.sections[0]!.id, dwellMs: 9e12, scrollPct: 5, now: NOW,
      })
      const [row] = await db<{ dwell_ms: number; scroll_pct: number }[]>`
        SELECT dwell_ms, scroll_pct FROM material_read WHERE section_id = ${v.sections[0]!.id}`
      expect(row!.dwell_ms).toBe(24 * 3600 * 1000)
      expect(row!.scroll_pct).toBe(1)
    })
  })

  describe('drillMaterials', () => {
    it('まだ生成していない単元は none で並ぶ', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '古代オリエント', unitIds: ['wh.2.1.1', 'wh.2.1.2'], deadline: DEADLINE,
      })
      const rows = await drillMaterials(db, userId, drillId)
      expect(rows.map(r => r.unitId)).toEqual(['wh.2.1.1', 'wh.2.1.2'])
      expect(rows.every(r => r.status === 'none' && r.materialId === null)).toBe(true)
      expect(rows[0]!.unitLabel).toBeTruthy()
    })

    it('他人の特訓IDから単元を見られない', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '古代オリエント', unitIds: [UNIT], deadline: DEADLINE,
      })
      const other = await createUser(db, NOW)
      expect(await drillMaterials(db, other, drillId)).toEqual([])
    })

    it('配信できる教材があれば ready と読了数を返す', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '古代オリエント', unitIds: [UNIT], deadline: DEADLINE,
      })
      const id = await genReady()
      const v = (await materialView(db, userId, id))!
      await recordRead(db, { userId, sectionId: v.sections[0]!.id, dwellMs: v.sections[0]!.requiredMs, scrollPct: null, now: NOW })

      const [row] = await drillMaterials(db, userId, drillId)
      expect(row!.status).toBe('ready')
      expect(row!.materialId).toBe(id)
      expect(row!.sectionCount).toBe(7)
      expect(row!.readCount).toBe(1)
    })

    it('配信不可を隠さない（blocked と理由を返す）', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '古代オリエント', unitIds: [UNIT], deadline: DEADLINE,
      })
      const ai = createClient(cfg, { wrongClaims: ['ウェストファリア条約は1658年'] })
      await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })

      const [row] = await drillMaterials(db, userId, drillId)
      expect(row!.status).toBe('blocked')
      expect(row!.blockedReason).toContain('1658年')
    })

    it('同じ単元に blocked と ready があれば ready を選ぶ', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '古代オリエント', unitIds: [UNIT], deadline: DEADLINE,
      })
      const bad = createClient(cfg, { wrongClaims: ['ウェストファリア条約は1658年'] })
      await generateMaterial(db, bad, { userId, unitId: UNIT, now: NOW })
      // blocked から抜けるには作り直しが要る（冪等の短絡を飛ばす）
      const again = await generateMaterial(db, createClient(cfg), {
        userId, unitId: UNIT, now: NOW, force: true,
      })
      expect(again.status).toBe('ready')
      if (again.status !== 'ready') return
      const readyId = again.materialId

      const [row] = await drillMaterials(db, userId, drillId)
      expect(row!.status).toBe('ready')
      expect(row!.materialId).toBe(readyId)
    })

    it('他人の個別教材は混ざらない', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '古代オリエント', unitIds: [UNIT], deadline: DEADLINE,
      })
      const other = await createUser(db, NOW)
      await genPersonal(other)

      const [row] = await drillMaterials(db, userId, drillId)
      expect(row!.status).toBe('none')
    })

    it('共有教材は自分が作っていなくても ready で出る', async () => {
      const { drillId } = await createDrill(db, {
        userId, title: '古代オリエント', unitIds: [UNIT], deadline: DEADLINE,
      })
      const other = await createUser(db, NOW)
      const r = await generateMaterial(db, createClient(cfg), { userId: other, unitId: UNIT, now: NOW })
      expect(r.status).toBe('ready')

      const [row] = await drillMaterials(db, userId, drillId)
      expect(row!.status).toBe('ready')
      expect(row!.sectionCount).toBe(7)
    })
  })
})
