import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { readFileSync } from 'node:fs'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { parseSchema, schemaShape } from './schema-shape'
import { inspect, verdictFor, SEEDED_TABLES, PHASE3_TABLES, PHASE3_COLUMNS } from './inspect'
import { PASTE_LIMIT_KB, deployGuidance } from './dump-sql'

/**
 * 本番の状態を読む道具（scripts/db/check-remote.ts）
 *
 * ★ この道具が生まれた理由: 作者が本番へ docs/schema.sql を貼って
 *   「era がすでに存在する」で止まり、**いまどこまで入っているのかを
 *   知る手段が無かった**（2026-09-03）。
 */

describe('docs/schema.sql の解析', () => {
  const shapes = schemaShape()

  it('51 表を全部拾う', () => {
    expect(shapes).toHaveLength(51)
    expect(new Set(shapes.map(s => s.table)).size).toBe(51)
  })

  it('どの表も列が1つ以上ある', () => {
    for (const s of shapes) {
      expect(s.columns.length, `${s.table} の列が取れていない`).toBeGreaterThan(0)
    }
  })

  it('後から足した列も拾う（app_user.remind_hour）', () => {
    expect(shapes.find(s => s.table === 'app_user')!.columns).toContain('remind_hour')
  })

  /** ★ CHECK や PRIMARY KEY を列として数えない。数えると「欠けている」の誤検出になる */
  it('表制約を列と間違えない', () => {
    const kcCard = shapes.find(s => s.table === 'kc_card')!
    expect(kcCard.columns).toContain('user_id')
    expect(kcCard.columns).not.toContain('PRIMARY')
    expect(kcCard.columns).not.toContain('CHECK')
    for (const s of shapes) {
      for (const c of s.columns) expect(c).toMatch(/^[a-z_][a-z0-9_]*$/)
    }
  })

  it('CHECK の中の括弧に惑わされない', () => {
    // era は CHECK (end_year > start_year) を末尾に持つ
    expect(shapes.find(s => s.table === 'era')!.columns)
      .toEqual(['id', 'label', 'start_year', 'end_year', 'ord'])
  })

  it('IF NOT EXISTS 付きの CREATE TABLE も拾う', () => {
    const s = parseSchema('CREATE TABLE IF NOT EXISTS foo (\n  a int,\n  b text\n);')
    expect(s).toEqual([{ table: 'foo', columns: ['a', 'b'] }])
  })

  /**
   * ★ docs/schema.sql に IF NOT EXISTS が無いことを固定する。
   *   これが「era がすでに存在する」の原因だが、**直さないと決めた**
   *   （IF NOT EXISTS は列が違う表を黙って飛ばし、ずれを隠す）。
   *   誰かが親切心で足したときに、この試験が判断を思い出させる。
   */
  it('docs/schema.sql は冪等ではない（そう決めた）', () => {
    const sql = readFileSync('docs/schema.sql', 'utf8')
    const total = (sql.match(/^CREATE TABLE /gim) ?? []).length
    const guarded = (sql.match(/^CREATE TABLE IF NOT EXISTS /gim) ?? []).length
    expect(total).toBe(51)
    expect(guarded, '既存DBには seed/sql/04_phase3.sql を使う。schema.sql は仕様書のまま').toBe(0)
  })
})

describe('何を流すべきかの判定', () => {
  it('欠けていなければ complete', () => {
    expect(verdictFor(44, [], [])).toBe('complete')
  })

  it('全部欠けていれば empty', () => {
    expect(verdictFor(2, ['a', 'b'], [])).toBe('empty')
  })

  it('04_phase3 の範囲なら phase3', () => {
    expect(PHASE3_COLUMNS).toContain('material_section.embedding')
    expect(verdictFor(51, ['push_subscription', 'ops_log'], [])).toBe('phase3')
    expect(verdictFor(51, [], ['app_user.remind_hour'])).toBe('phase3')
    expect(verdictFor(51, [], ['material_section.embedding'])).toBe('phase3')
    expect(verdictFor(51, ['ops_log'], ['app_user.remind_hour'])).toBe('phase3')
  })

  /** ★ 04_phase3 で埋まらない差分を phase3 と言ってはいけない（流しても直らない） */
  it('範囲外が混ざれば unknown_drift', () => {
    expect(verdictFor(51, ['ops_log', 'response'], [])).toBe('unknown_drift')
    expect(verdictFor(51, [], ['item.elo_b'])).toBe('unknown_drift')
  })
})

describe('貼り付けの上限', () => {
  /** ★ 実測 1016KB は通らなかった。上限はそれより十分小さいこと */
  it('1016KB は「貼れない」側に入る', () => {
    expect(PASTE_LIMIT_KB).toBeLessThan(1016)
    expect(PASTE_LIMIT_KB).toBeGreaterThan(0)
  })

  /**
   * ★ **実際に出る文字列**を見る。ソースに語が在るかでは駄目だった:
   *   案内から1行消しても、生成物のヘッダに同じ語があるため落ちなかった（逆対照で判明）。
   */
  it('案内が新規DBと既存DBを分けている', () => {
    const g = deployGuidance(975).join('\n')
    expect(g).toContain('新規の空DB')
    expect(g).toContain('既に流したDB')
    expect(g).toContain('04_phase3.sql')
    // ★ 既存DB向けには「貼らない」と書く（貼ると era で落ちる）
    expect(g).toContain('docs/schema.sql は貼らない')
    expect(g).toContain('check-remote.ts')
  })

  it('大きいときは貼るなと言い、seed-remote を案内する', () => {
    const g = deployGuidance(975).join('\n')
    expect(g).toContain('貼れない')
    expect(g).toContain('seed-remote.ts --apply')
    expect(g).not.toContain('02_seed.sql をエディタに貼る')
  })

  /** ★ 小さければ貼ってよい。上限を理由に常に禁止するのは行き過ぎ */
  it('小さいときは貼ってよいと言う', () => {
    const g = deployGuidance(50).join('\n')
    expect(g).toContain('02_seed.sql をエディタに貼る')
    expect(g).not.toContain('貼れない')
  })

  it('境界で切り替わる', () => {
    expect(deployGuidance(PASTE_LIMIT_KB).join('\n')).toContain('エディタに貼る')
    expect(deployGuidance(PASTE_LIMIT_KB + 1).join('\n')).toContain('貼れない')
  })

  it('生成物の冒頭が seed-remote を案内する', () => {
    const sql = readFileSync('seed/sql/02_seed.sql', 'utf8').slice(0, 1200)
    expect(sql).toContain('seed-remote.ts')
    expect(sql).toContain('04_phase3.sql')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('実DBを読む', () => {
  let db: Sql
  let drop: () => Promise<void>

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_inspect_test'))
  }, 120_000)
  afterAll(async () => { await drop() })

  it('スキーマを流したばかりのDBは complete', async () => {
    const r = await inspect(db)
    expect(r.missingTables).toEqual([])
    expect(r.missingColumns).toEqual([])
    expect(r.verdict).toBe('complete')
    expect(r.expectedTables).toBe(51)
  })

  it('seed を入れていなければ行数は全部0', async () => {
    const r = await inspect(db)
    for (const t of SEEDED_TABLES) {
      expect(r.counts[t], `${t} の行数が取れていない`).toBe(0)
    }
  })

  /**
   * ★ ここが本題。**実際に表を落として検出できること**を見る。
   *   落とすのは 04_phase3.sql が埋められる表にして、判定まで確かめる。
   */
  it('表が欠けていれば見つけ、04_phase3 を案内する', async () => {
    await db.unsafe('DROP TABLE push_subscription')
    try {
      const r = await inspect(db)
      expect(r.missingTables).toEqual(['push_subscription'])
      expect(r.verdict).toBe('phase3')
    } finally {
      await db.unsafe(`CREATE TABLE push_subscription (
        endpoint text PRIMARY KEY,
        user_id uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
        p256dh text NOT NULL, auth text NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now(), last_sent_at timestamptz)`)
    }
  })

  it('列が欠けていれば見つける', async () => {
    await db.unsafe('ALTER TABLE app_user DROP COLUMN remind_hour')
    try {
      const r = await inspect(db)
      expect(r.missingColumns).toEqual(['app_user.remind_hour'])
      expect(r.verdict).toBe('phase3')
    } finally {
      await db.unsafe(
        'ALTER TABLE app_user ADD COLUMN remind_hour smallint CHECK (remind_hour BETWEEN 0 AND 23)')
    }
  })

  /** ★ 04_phase3 で埋まらない表が欠けたら、そう言うこと（流しても直らない） */
  it('範囲外の表が欠けたら unknown_drift と言う', async () => {
    await db.unsafe('DROP TABLE material_read')
    try {
      const r = await inspect(db)
      expect(r.missingTables).toContain('material_read')
      expect(r.verdict).toBe('unknown_drift')
      expect(PHASE3_TABLES as readonly string[]).not.toContain('material_read')
    } finally {
      await db.unsafe(`CREATE TABLE material_read (
        id bigserial PRIMARY KEY,
        user_id uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
        section_id uuid NOT NULL REFERENCES material_section(id) ON DELETE CASCADE,
        dwell_ms int NOT NULL, scroll_pct real,
        read_at timestamptz NOT NULL DEFAULT now())`)
    }
  })

  /**
   * ★ **1行も書かないこと。** 本番に向けて流す道具なので、ここは譲れない。
   *   呼ぶ前と後で全表の行数が一致することを見る。
   */
  it('読むだけで、1行も書かない', async () => {
    const snapshot = async () => {
      const rows = await db<{ table_name: string }[]>`
        SELECT table_name FROM information_schema.tables
         WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
         ORDER BY table_name`
      const out: Record<string, number> = {}
      for (const r of rows) {
        const [c] = await db<{ n: string }[]>`SELECT count(*) AS n FROM ${db(r.table_name)}`
        out[r.table_name] = Number(c!.n)
      }
      return out
    }
    const before = await snapshot()
    await inspect(db)
    await inspect(db)
    expect(await snapshot()).toEqual(before)
    // 表そのものも増減していない
    expect(Object.keys(before)).toHaveLength(51)
  })
})
