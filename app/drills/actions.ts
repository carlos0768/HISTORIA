'use server'

import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { createClient } from '@/lib/ai/client'
import { createDrill, checkOverlap, kcsForUnits, type OverlapWarning } from '@/lib/pipeline/drill'
import { generateMaterial } from '@/lib/pipeline/generate'

async function requireUser(): Promise<string> {
  const id = await currentUserId()
  if (!id) throw new Error('ユーザーが特定できません')
  return id
}

export type CreateResult =
  | { ok: true; drillId: string; kcCount: number }
  | { ok: false; reason: 'overlap'; overlap: OverlapWarning }
  | { ok: false; reason: 'error'; message: string }

/**
 * 範囲を確定して特訓を作る（docs/07 §8.1 ルートA）。
 *
 * ★ 重複が閾値を超えたら作らずに差し戻す。黙って作ると同じ知識を2回学習させる。
 *   confirm を明示的に受け取ったときだけ作る（docs/05 §5.3）。
 */
export async function createDrillAction(input: {
  title: string
  unitIds: string[]
  deadline: string
  confirm?: boolean
}): Promise<CreateResult> {
  const userId = await requireUser()
  const db = sql()

  const title = input.title.trim()
  if (!title) return { ok: false, reason: 'error', message: '題名を入れてください' }
  if (input.unitIds.length === 0) return { ok: false, reason: 'error', message: '範囲を選んでください' }

  const deadline = new Date(`${input.deadline}T00:00:00+09:00`)
  if (Number.isNaN(deadline.getTime())) {
    return { ok: false, reason: 'error', message: '締切の日付が読めません' }
  }

  try {
    if (!input.confirm) {
      const kcIds = await kcsForUnits(db, input.unitIds)
      const overlap = await checkOverlap(db, userId, kcIds)
      if (overlap) return { ok: false, reason: 'overlap', overlap }
    }
    const r = await createDrill(db, { userId, title, unitIds: input.unitIds, deadline })
    revalidatePath('/')
    return { ok: true, drillId: r.drillId, kcCount: r.kcCount }
  } catch (e) {
    return { ok: false, reason: 'error', message: e instanceof Error ? e.message : '作成に失敗しました' }
  }
}

export type GenerateResult =
  | { ok: true; materialId: string }
  | { ok: false; status: 'blocked' | 'failed'; reason: string; materialId?: string }

/**
 * 単元1つ分の教材を作る。
 *
 * ★ blocked はエラーではない。事実確認を通らなかったという結果であり、
 *   理由を添えて画面に出す（作者判断 Q4 / docs/08 §5 層5）。
 */
export async function generateMaterialAction(input: {
  unitId: string
  force?: boolean
}): Promise<GenerateResult> {
  const userId = await requireUser()
  const db = sql()
  const ai = createClient()

  const r = await generateMaterial(db, ai, {
    userId, unitId: input.unitId, now: new Date(), force: input.force,
  })
  revalidatePath('/')

  if (r.status === 'ready') return { ok: true, materialId: r.materialId }
  if (r.status === 'blocked') {
    return { ok: false, status: 'blocked', reason: r.reason, materialId: r.materialId }
  }
  return { ok: false, status: 'failed', reason: r.reason }
}
