/**
 * AnonymizedContext を組み立てる唯一の入口
 *
 * 仕様: docs/08-ai-architecture.md §4.2
 *
 * この関数を通さない文脈を LLM クライアントに渡せないようにする。
 * クライアントの引数型が AnonymizedContext に限定されているので、
 * 個人識別情報を含む値は型検査で弾かれる。
 */
import type { Sql } from 'postgres'
import type { AnonymizedContext, MasteryBand } from './types'

/** 数値の習得度を3段階に丸める。生の数値は送らない（§4.1） */
export function toBand(mastery: number): MasteryBand {
  if (mastery < 0.6) return 'low'
  if (mastery < 0.85) return 'mid'
  return 'high'
}

/** 教材の目標文字数。docs/07 §2（3,500字 ±15%） */
export const TARGET_CHARS = 3500

export async function buildGenerationContext(
  db: Sql,
  userId: string,
  unitId: string,
  opts: { limit?: number; targetCharCount?: number } = {},
): Promise<AnonymizedContext> {
  const limit = opts.limit ?? 12

  const unit = await db<{ label: string }[]>`SELECT label FROM syllabus_unit WHERE id = ${unitId}`
  if (!unit[0]) throw new Error(`syllabus_unit が見つかりません: ${unitId}`)

  const rows = await db<
    { kc_id: string; label: string; kind: string; p_know: number | null; confused: string[] | null }[]
  >`
    SELECT k.id AS kc_id, k.label, k.kind, s.p_know,
           (SELECT array_agg(m.distractor_key)
              FROM misconception m
             WHERE m.user_id = ${userId} AND m.kc_id = k.id AND m.resolved_at IS NULL) AS confused
      FROM kc k
      JOIN kc_syllabus_unit ksu ON ksu.kc_id = k.id AND ksu.unit_id = ${unitId}
      LEFT JOIN user_kc_state s ON s.user_id = ${userId} AND s.kc_id = k.id
     WHERE NOT k.retired
     ORDER BY coalesce(s.p_know, 0.25) ASC, k.exam_weight DESC
     LIMIT ${limit}`

  return {
    unitId,
    unitLabel: unit[0].label,
    // ★ ここで user_id を落とす。以降の経路に個人識別情報は存在しない
    weakKcs: rows.map(r => ({
      kcId: r.kc_id,
      label: r.label,
      kind: r.kind,
      band: toBand(r.p_know ?? 0.25),
      ...(r.confused && r.confused.length > 0 ? { confusedWith: r.confused } : {}),
    })),
    targetCharCount: opts.targetCharCount ?? TARGET_CHARS,
  }
}

/** 個人識別情報が混入していないことを実行時にも確かめる（型の裏を取る） */
const FORBIDDEN_KEYS = [
  'userId', 'user_id', 'email', 'displayName', 'display_name',
  'birthDate', 'birth_date', 'guardianEmail', 'guardian_email',
  'answeredAt', 'answered_at', 'streak', 'pKnow', 'p_know', 'theta', 'nEff', 'n_eff',
]

export function assertAnonymized(ctx: unknown, path = 'context'): void {
  if (ctx === null || typeof ctx !== 'object') return
  if (Array.isArray(ctx)) {
    ctx.forEach((v, i) => assertAnonymized(v, `${path}[${i}]`))
    return
  }
  for (const [k, v] of Object.entries(ctx)) {
    if (FORBIDDEN_KEYS.includes(k)) {
      throw new Error(`プロンプトに個人識別情報が含まれています: ${path}.${k}（docs/08 §4）`)
    }
    assertAnonymized(v, `${path}.${k}`)
  }
}

/** UUID らしき文字列がプロンプト本文に混ざっていないか */
const UUID_RE = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i

export function assertNoIdentifiers(prompt: string): void {
  if (UUID_RE.test(prompt)) {
    throw new Error('プロンプトに UUID が含まれています（docs/08 §4）')
  }
}
