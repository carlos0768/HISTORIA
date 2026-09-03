'use server'

import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { isAdmin } from '@/lib/auth/admin'
import { resolveReport, type ReportStatus, REPORT_STATUSES } from '@/lib/loop/report'
import { resumeBudget } from '@/lib/loop/admin'
import { setCap, periodOf } from '@/lib/ai/budget'

/**
 * 管理画面の操作（docs/12-nonfunctional.md §7.2）
 *
 * ★ 関門を**操作ごとに**書く。画面側の notFound() だけに頼らない。
 *   Server Action は URL を知っていれば画面を経由せず直接叩ける。
 *   「画面が出ないから安全」は Server Action には当てはまらない。
 */
async function requireAdmin(): Promise<string> {
  const userId = await currentUserId()
  if (!isAdmin(userId)) throw new Error('権限がありません')
  return userId!
}

/** 誤り報告を処理する。confirmed のときだけ本文が伏せられる（docs/08 §5 層4） */
export async function resolveReportAction(
  reportId: string, status: ReportStatus,
): Promise<{ hidden: boolean }> {
  await requireAdmin()
  if (!REPORT_STATUSES.includes(status)) throw new Error('不正な状態です')
  const r = await resolveReport(sql(), reportId, status)
  revalidatePath('/admin')
  return r
}

/**
 * 遮断器を解除する。
 *
 * ★ 上限は動かさない（docs/12 §7.2）。上限に達して止まったのに
 *   解除と同時に上限も上がるなら、遮断器は何も守っていない。
 */
export async function resumeBudgetAction(): Promise<{ resumed: boolean }> {
  await requireAdmin()
  const r = await resumeBudget(sql(), periodOf(new Date()))
  revalidatePath('/admin')
  return r
}

/** 当月の上限額を変える（docs/12 §7.2 の「変更してよい」側） */
export async function setCapAction(capJpy: number): Promise<{ ok: boolean; message: string }> {
  await requireAdmin()
  if (!Number.isFinite(capJpy) || capJpy <= 0) {
    return { ok: false, message: '上限は正の数で指定してください' }
  }
  await setCap(sql(), periodOf(new Date()), capJpy)
  revalidatePath('/admin')
  return { ok: true, message: `当月の上限を ${capJpy.toLocaleString('ja-JP')} 円にしました` }
}
