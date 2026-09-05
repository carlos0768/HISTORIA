'use server'

import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { isAdmin } from '@/lib/auth/admin'
import { resolveReport, type ReportStatus, REPORT_STATUSES } from '@/lib/loop/report'
import { resumeBudget } from '@/lib/loop/admin'
import {
  approveMaterial, approvalTarget, type ApprovalResult, type ApprovalTarget,
} from '@/lib/loop/approve'
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

/**
 * 止まった教材の中身を読む（承認する前に確かめるため）
 *
 * ★ 一覧と一緒に本文まで送らない。blocked が30本あれば7万字を毎回
 *   画面へ運ぶことになり、作者が実際に読む1本のために残り29本を運ぶ。
 *   押したときに1本だけ取りに行く。
 */
export async function blockedDetailAction(materialId: string): Promise<ApprovalTarget | null> {
  await requireAdmin()
  return approvalTarget(sql(), materialId)
}

/**
 * 事実確認で止まった教材を、作者の判断で配信可能にする（docs/02 §5 / docs/10 §8）
 *
 * ★ 判断そのものはここに書かない。理由の検査も状態の検査も
 *   lib/loop/approve.ts が持つ。画面と道具（scripts/db/approve-material.ts）で
 *   規則が二重になると、片方だけ緩い抜け道ができる。
 */
export async function approveMaterialAction(
  materialId: string, note: string,
): Promise<ApprovalResult> {
  await requireAdmin()
  const r = await approveMaterial(sql(), { materialId, note, now: new Date() })
  if (r.approved) revalidatePath('/admin')
  return r
}
