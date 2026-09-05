/**
 * 動いているデータベースの状態を読む（scripts/db/check-remote.ts の中身）
 *
 * ★ CLI と分けてあるのは試験のためである。`check-remote.ts` は
 *   process.env を読んで標準出力に書く殻で、判定はここに置く。
 *   `lib/push/cron-auth.ts` を `app/api/cron/route.ts` から切り出したのと同じ形。
 *
 * ★ **読み取りしかしない。** CREATE も ALTER も INSERT も書かない。
 *   本番に向けて何度呼んでも、行は1件も動かない（試験がそれを見ている）。
 */
import type { Sql } from 'postgres'
import { schemaShape, type TableShape } from './schema-shape'

/** seed が入っているかを見る表。ここが0なら画面は空回りする */
export const SEEDED_TABLES = [
  'era', 'region', 'syllabus_unit', 'kc', 'kc_region',
  'canon_event', 'person', 'item', 'video',
] as const

/**
 * 04_phase3.sql が埋められる差分。
 *
 * ★ `scripts/db/dump-migration.ts` の NEW_TABLES / NEW_COLUMNS と同じ内容を指す。
 *   ここで手書きしているのは「この差分ファイルで足りるか」を判定するためだけで、
 *   期待する表の一覧そのものは docs/schema.sql から読む（二重管理しない）。
 */
export const PHASE3_TABLES = ['push_subscription', 'ops_log'] as const
export const PHASE3_COLUMNS = [
  'app_user.remind_hour', 'canon_event.embedding', 'material_section.embedding',
] as const

export type Verdict = 'complete' | 'empty' | 'phase3' | 'unknown_drift'

export type Inspection = {
  expectedTables: number
  missingTables: string[]
  missingColumns: string[]
  /** 何を流せばよいか */
  verdict: Verdict
  /** 表名 → 行数。表が無いものは含まれない */
  counts: Record<string, number>
}

/** 欠けているものから、次に流すべきものを決める */
export function verdictFor(
  expectedTables: number, missingTables: readonly string[], missingColumns: readonly string[],
): Verdict {
  if (missingTables.length === 0 && missingColumns.length === 0) return 'complete'
  if (missingTables.length === expectedTables) return 'empty'
  const byPhase3 = missingTables.every(t => (PHASE3_TABLES as readonly string[]).includes(t))
    && missingColumns.every(c => (PHASE3_COLUMNS as readonly string[]).includes(c))
  return byPhase3 ? 'phase3' : 'unknown_drift'
}

export async function inspect(db: Sql, expected: TableShape[] = schemaShape()): Promise<Inspection> {
  const live = await db<{ table_name: string; column_name: string }[]>`
    SELECT table_name, column_name
      FROM information_schema.columns
     WHERE table_schema = 'public'`

  const byTable = new Map<string, Set<string>>()
  for (const r of live) {
    if (!byTable.has(r.table_name)) byTable.set(r.table_name, new Set())
    byTable.get(r.table_name)!.add(r.column_name)
  }

  const missingTables: string[] = []
  const missingColumns: string[] = []
  for (const t of expected) {
    const cols = byTable.get(t.table)
    if (!cols) { missingTables.push(t.table); continue }
    for (const c of t.columns) if (!cols.has(c)) missingColumns.push(`${t.table}.${c}`)
  }

  const counts: Record<string, number> = {}
  for (const t of SEEDED_TABLES) {
    if (!byTable.has(t)) continue
    const [row] = await db<{ n: string }[]>`SELECT count(*) AS n FROM ${db(t)}`
    counts[t] = Number(row?.n ?? 0)
  }

  return {
    expectedTables: expected.length,
    missingTables, missingColumns,
    verdict: verdictFor(expected.length, missingTables, missingColumns),
    counts,
  }
}
