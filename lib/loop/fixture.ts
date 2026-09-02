/** テスト用の最小データ。閉ループを回すのに必要な最小限だけを作る */
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { guessRateFor } from './answer'
import type { ItemFormat } from '@/lib/domain/params'

export async function createUser(db: Sql, now: Date, maxDaily = 80): Promise<string> {
  const id = randomUUID()
  await db`
    INSERT INTO app_user (id, display_name, birth_date, guardian_consent_required,
                          consent_version, consent_at, max_daily_items)
    VALUES (${id}, 'test', '2008-12-08', false, 'v1', ${now}, ${maxDaily})`
  return id
}

export async function createKcs(db: Sql, ids: string[], unitId: string): Promise<void> {
  for (const [i, id] of ids.entries()) {
    await db`
      INSERT INTO kc (id, label, kind, exam_weight)
      VALUES (${id}, ${`KC ${i}`}, 'fact', 1.0)
      ON CONFLICT (id) DO NOTHING`
    await db`INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES (${id}, ${unitId})
             ON CONFLICT DO NOTHING`
  }
}

export async function createDrill(
  db: Sql, userId: string, kcIds: string[], deadline: Date, unitId?: string,
  mode: 'ai_material' | 'self_study' = 'ai_material',
): Promise<string> {
  const id = randomUUID()
  await db`
    INSERT INTO drill (id, user_id, title, deadline, mode)
    VALUES (${id}, ${userId}, '集中特訓', ${deadline}, ${mode})`
  for (const kc of kcIds) {
    await db`INSERT INTO drill_kc (drill_id, kc_id) VALUES (${id}, ${kc})`
  }
  if (unitId) await db`INSERT INTO drill_unit (drill_id, unit_id) VALUES (${id}, ${unitId})`
  return id
}

/** 配信済みの教材を1本。本文は要らない試験のために、節は作らない */
export async function createMaterial(
  db: Sql, o: { userId: string | null; unitId: string; status?: string },
): Promise<string> {
  const id = randomUUID()
  await db`
    INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version, status)
    VALUES (${id}, ${o.userId}, ${o.unitId}, '教材', 'fake', 'fake', 'v1',
            ${o.status ?? 'ready'})`
  return id
}

export async function createItem(
  db: Sql,
  o: {
    userId: string | null
    kcs: Array<{ kcId: string; weight?: number }>
    format?: ItemFormat
    answerKey?: unknown
    now: Date
    approved?: boolean
  },
): Promise<string> {
  const id = randomUUID()
  const format = o.format ?? 'mcq4'
  const approved = o.approved ?? true
  await db`
    INSERT INTO item (id, user_id, format, stem, choices, answer_key, explanation, guess_rate,
                      approved, approved_by, approved_at)
    VALUES (${id}, ${o.userId}, ${format}, '問題文',
            ${db.json([{ key: 'a', text: 'A' }, { key: 'b', text: 'B' },
                       { key: 'c', text: 'C' }, { key: 'd', text: 'D' }])},
            ${db.json((o.answerKey ?? 'a') as never)}, '解説', ${guessRateFor(format)},
            ${approved}, ${approved ? 'factcheck' : null}, ${approved ? o.now : null})`
  for (const k of o.kcs) {
    await db`INSERT INTO item_kc (item_id, kc_id, weight) VALUES (${id}, ${k.kcId}, ${k.weight ?? 1.0})`
  }
  return id
}
