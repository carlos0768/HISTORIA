/**
 * 集中特訓の作成
 *
 * 仕様: docs/05-scheduler.md §5.3、docs/07-content-pipeline.md §8.1
 *
 * 範囲指定は章立てから選ぶ（ルートA）。自然文で指定するルートBは MVP では作らない。
 */
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { overlapRatio, OVERLAP_WARN_RATIO } from '@/lib/domain/scheduler'

export type OverlapWarning = {
  ratio: number
  sharedKcCount: number
  withTitles: string[]
}

/** 選んだ節に属する KC を集める。節の下位は無いので直接引く */
export async function kcsForUnits(db: Sql, unitIds: string[]): Promise<string[]> {
  if (unitIds.length === 0) return []
  const rows = await db<{ kc_id: string }[]>`
    SELECT DISTINCT ku.kc_id FROM kc_syllabus_unit ku
      JOIN kc k ON k.id = ku.kc_id AND NOT k.retired
     WHERE ku.unit_id IN ${db(unitIds)}
     ORDER BY ku.kc_id`
  return rows.map(r => r.kc_id)
}

/**
 * 既存の active な特訓との重複を調べる（§5.3）。
 * 40%を超えたら作成前に警告する。同じ知識を2回学習させる必要はない。
 */
export async function checkOverlap(db: Sql, userId: string, kcIds: string[]): Promise<OverlapWarning | null> {
  if (kcIds.length === 0) return null
  const rows = await db<{ kc_id: string; title: string }[]>`
    SELECT DISTINCT dk.kc_id, d.title
      FROM drill d JOIN drill_kc dk ON dk.drill_id = d.id
     WHERE d.user_id = ${userId} AND d.status = 'active'`
  const existing = new Set(rows.map(r => r.kc_id))
  const ratio = overlapRatio(kcIds, existing)
  if (ratio <= OVERLAP_WARN_RATIO) return null

  const shared = kcIds.filter(id => existing.has(id))
  const titles = [...new Set(rows.filter(r => shared.includes(r.kc_id)).map(r => r.title))]
  return { ratio, sharedKcCount: shared.length, withTitles: titles }
}

export async function createDrill(
  db: Sql,
  args: { userId: string; title: string; unitIds: string[]; deadline: Date; mode?: 'ai_material' | 'self_study' },
): Promise<{ drillId: string; kcCount: number }> {
  const kcIds = await kcsForUnits(db, args.unitIds)
  if (kcIds.length === 0) throw new Error('選んだ範囲に KC がありません')

  const drillId = randomUUID()
  await db.begin(async tx => {
    await tx`
      INSERT INTO drill (id, user_id, title, deadline, mode)
      VALUES (${drillId}, ${args.userId}, ${args.title}, ${args.deadline}, ${args.mode ?? 'ai_material'})`
    for (const unitId of args.unitIds) {
      await tx`INSERT INTO drill_unit (drill_id, unit_id) VALUES (${drillId}, ${unitId})`
    }
    for (const kcId of kcIds) {
      await tx`INSERT INTO drill_kc (drill_id, kc_id) VALUES (${drillId}, ${kcId})`
    }
  })
  return { drillId, kcCount: kcIds.length }
}

export type UnitTreeNode = {
  id: string
  label: string
  level: number
  subject: string
  kcCount: number
  children: UnitTreeNode[]
}

/** 章立てを木で返す。範囲選択のUIに使う */
export async function unitTree(db: Sql): Promise<UnitTreeNode[]> {
  const rows = await db<
    { id: string; parent_id: string | null; label: string; level: number; subject: string; kc_count: string }[]
  >`
    SELECT u.id, u.parent_id, u.label, u.level, u.subject,
           (SELECT count(*) FROM kc_syllabus_unit ku
             JOIN kc k ON k.id = ku.kc_id AND NOT k.retired
            WHERE ku.unit_id = u.id) AS kc_count
      FROM syllabus_unit u ORDER BY u.level, u.ord, u.id`

  const byId = new Map<string, UnitTreeNode>()
  const roots: UnitTreeNode[] = []
  for (const r of rows) {
    byId.set(r.id, {
      id: r.id, label: r.label, level: r.level, subject: r.subject,
      kcCount: Number(r.kc_count), children: [],
    })
  }
  for (const r of rows) {
    const node = byId.get(r.id)!
    if (r.parent_id) byId.get(r.parent_id)?.children.push(node)
    else roots.push(node)
  }
  // 親の KC 数は子の合計にする（節にしか KC は付かない）
  const rollup = (n: UnitTreeNode): number => {
    if (n.children.length === 0) return n.kcCount
    n.kcCount = n.children.reduce((s, c) => s + rollup(c), 0)
    return n.kcCount
  }
  roots.forEach(rollup)
  return roots
}
