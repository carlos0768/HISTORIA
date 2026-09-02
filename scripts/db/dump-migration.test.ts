import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { readFileSync } from 'node:fs'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { buildMigrationSql, MIGRATION_SQL_PATH, NEW_TABLES, NEW_COLUMNS,
         tableBlock, indexStatements } from './dump-migration'
import { SCHEMA_PATH } from './schema'

const schema = readFileSync(SCHEMA_PATH, 'utf8')

describe('後から足した表と列の差分 SQL', () => {
  it('リポジトリに入っている SQL が docs/schema.sql と揃っている', () => {
    // ずれていたら npx tsx scripts/db/dump-migration.ts で作り直す
    expect(readFileSync(MIGRATION_SQL_PATH, 'utf8')).toBe(buildMigrationSql())
  })

  it('足す表と列が docs/schema.sql に実在する', () => {
    for (const t of NEW_TABLES) expect(() => tableBlock(schema, t)).not.toThrow()
    for (const c of NEW_COLUMNS) {
      expect(tableBlock(schema, c.table), `${c.table}.${c.column}`).toContain(c.column)
    }
  })

  /**
   * ★ IF NOT EXISTS が抜けると、本番で「もうある」と言われて途中まで流れて止まる。
   *   表・索引・列の3種類とも見る。
   */
  it('何度流しても同じになる（全ての DDL が IF NOT EXISTS）', () => {
    const sql = buildMigrationSql()
    for (const line of sql.split('\n')) {
      if (/^CREATE TABLE |^CREATE INDEX |^ALTER TABLE .* ADD COLUMN /.test(line)) {
        expect(line, `IF NOT EXISTS が無い: ${line}`).toMatch(/IF NOT EXISTS/)
      }
    }
  })

  it('RLS とポリシーは出さない（03_rls.sql と二重に書かない）', () => {
    const sql = buildMigrationSql()
    expect(sql).not.toContain('ENABLE ROW LEVEL SECURITY')
    expect(sql).not.toContain('CREATE POLICY')
  })

  it('索引の名前が PostgreSQL の自動命名と同じ綴りである', () => {
    // 綴りがずれると IF NOT EXISTS が効かず、同じ索引が2本できる
    expect(indexStatements(schema, 'push_subscription'))
      .toEqual(['CREATE INDEX IF NOT EXISTS push_subscription_user_id_idx ON push_subscription (user_id);'])
    expect(indexStatements(schema, 'ops_log'))
      .toEqual(['CREATE INDEX IF NOT EXISTS ops_log_kind_ran_at_idx ON ops_log (kind, ran_at DESC);'])
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('後から足した表と列の差分 SQL（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>

  beforeAll(async () => { ({ db, drop } = await createTestDb('historia_migration_test')) }, 120_000)
  afterAll(async () => { await drop() })

  /**
   * ★ ここが本題である。createTestDb は docs/schema.sql を流すので、
   *   新しい表と列は**既にある**。そこへ差分を流して落ちないことを見る＝冪等性の実証。
   *   さらに2回流す。1回目で作られ2回目で「もうある」となる経路も同時に通る。
   */
  it('スキーマ適用済みの DB に流しても落ちず、2回流しても同じ', async () => {
    const sql = buildMigrationSql()
      .replace(/^BEGIN;$/m, '').replace(/^COMMIT;$/m, '')   // プール接続では BEGIN を張れない
    const countAll = async () => {
      const [r] = await db<{ t: string; c: string; i: string }[]>`
        SELECT (SELECT count(*) FROM pg_tables WHERE schemaname = 'public'
                  AND tablename IN ('push_subscription', 'ops_log')) AS t,
               (SELECT count(*) FROM information_schema.columns
                 WHERE table_schema = 'public' AND table_name = 'app_user'
                   AND column_name = 'remind_hour') AS c,
               (SELECT count(*) FROM pg_indexes WHERE schemaname = 'public'
                  AND tablename IN ('push_subscription', 'ops_log')) AS i`
      return { t: Number(r!.t), c: Number(r!.c), i: Number(r!.i) }
    }

    const before = await countAll()
    expect(before.t, 'docs/schema.sql に2表が入っている').toBe(2)
    expect(before.c, 'app_user.remind_hour が入っている').toBe(1)

    await db.begin(tx => tx.unsafe(sql))
    expect(await countAll()).toEqual(before)      // 1回目で何も増えない
    await db.begin(tx => tx.unsafe(sql))
    expect(await countAll()).toEqual(before)      // 2回目でも同じ
  }, 120_000)

  /**
   * ★ 表を足しただけでは中身が空である。既にある解答から user_activity を
   *   作り直せないと、これまで毎日やってきた人の連続日数が 0 に見える。
   *   日付が Asia/Tokyo であることも同時に見る（UTC だと1日ずれる）。
   */
  it('user_activity を既存の解答から作り直せる（Asia/Tokyo で・何度流しても同じ）', async () => {
    const [u] = await db<{ id: string }[]>`
      INSERT INTO app_user (id, birth_date, guardian_consent_required, consent_version, consent_at)
      VALUES (gen_random_uuid(), '2008-01-01', false, 'v1', now()) RETURNING id`
    const userId = u!.id
    const [it] = await db<{ id: string }[]>`
      INSERT INTO item (id, user_id, format, stem, answer_key, guess_rate,
                        approved, approved_by, approved_at)
      VALUES (gen_random_uuid(), NULL, 'mcq4', '設問', '"a"'::jsonb, 0.25,
              true, 'author', now())
      RETURNING id`
    // JST 2026-09-15 00:30（UTC では 09-14 15:30）と、同じ日の昼
    for (const t of ['2026-09-14T15:30:00Z', '2026-09-15T04:00:00Z']) {
      await db`
        INSERT INTO response (user_id, item_id, session_kind, chosen, correct, answered_at)
        VALUES (${userId}, ${it!.id}, 'quiz', '"a"'::jsonb, true, ${t})`
    }
    await db`DELETE FROM user_activity WHERE user_id = ${userId}`   // 空から作り直す

    const sql = buildMigrationSql().replace(/^BEGIN;$/m, '').replace(/^COMMIT;$/m, '')
    const read = async () => db<{ d: string; responses: number }[]>`
      SELECT to_char(activity_date, 'YYYY-MM-DD') AS d, responses
        FROM user_activity WHERE user_id = ${userId} ORDER BY activity_date`

    await db.begin(tx => tx.unsafe(sql))
    // 2件とも JST では 9/15。UTC で数えると 9/14 と 9/15 の2行に割れる
    expect(await read()).toEqual([{ d: '2026-09-15', responses: 2 }])

    await db.begin(tx => tx.unsafe(sql))
    expect(await read()).toEqual([{ d: '2026-09-15', responses: 2 }])   // 増えない
  }, 120_000)

  /**
   * ★ 表を落としてから流し、本当に作れることを見る。
   *   「既にあるので何も起きなかった」だけを見ていると、
   *   CREATE TABLE の中身が壊れていても気づけない。
   */
  it('表が無い DB に流すと、docs/schema.sql と同じ形で作られる', async () => {
    const cols = async (t: string) => db<{ name: string; type: string; nullable: string }[]>`
      SELECT column_name AS name, data_type AS type, is_nullable AS nullable
        FROM information_schema.columns
       WHERE table_schema = 'public' AND table_name = ${t}
       ORDER BY ordinal_position`

    const want: Record<string, unknown[]> = {}
    for (const t of NEW_TABLES) want[t] = await cols(t)

    for (const t of NEW_TABLES) await db.unsafe(`DROP TABLE ${t}`)
    const [gone] = await db<{ n: string }[]>`
      SELECT count(*) AS n FROM pg_tables WHERE schemaname = 'public'
         AND tablename IN ('push_subscription', 'ops_log')`
    expect(Number(gone!.n)).toBe(0)

    const sql = buildMigrationSql().replace(/^BEGIN;$/m, '').replace(/^COMMIT;$/m, '')
    await db.begin(tx => tx.unsafe(sql))

    for (const t of NEW_TABLES) expect(await cols(t), t).toEqual(want[t])
  }, 120_000)
})
