/**
 * 誤りの報告 — 層4（利用者による通報）
 *
 * 仕様: docs/08-ai-architecture.md §5 層4、docs/12-nonfunctional.md §7.1
 *
 * ★ 毎回生成なので、人手レビューは物理的に不可能である（docs/08 §5）。
 *   層2（機械照合）と層3（AI による事実確認）を抜けた誤りを拾える最後の網が、
 *   読んでいる本人の「これはおかしい」である。**押しやすさが唯一の設計要件**になる。
 *
 * ★ 理由の記入は任意にする。必須にすると押されない。
 *   「なんか変」しか言えない段階の違和感を捨てないほうが、網として広い。
 *
 * ★ 報告しただけでは本文を伏せない。docs/08 §5 は「報告が付いた段落は即座に
 *   非表示にし、再生成キューへ入れる」としているが、それは**作者が確認したあと**の
 *   処理として管理画面に置く（誤報1件で正しい教材が消えると、いたずらで壊せる）。
 */
import type { Sql } from 'postgres'

export type ReportTarget = 'material_section' | 'item'

/** 自由記述の上限。長文の投稿先ではないので短く切る */
export const COMMENT_MAX = 500

export type ReportInput = {
  userId: string
  targetKind: ReportTarget
  targetId: string
  comment: string | null
  now: Date
}

export type ReportResult = {
  reportId: string
  /** 同じ対象への報告が既にあったか。二重に受けても「受け付けた」と見せる */
  duplicate: boolean
}

/**
 * 報告を1件記録する。
 *
 * ★ 対象が実在することを確かめる。存在しない uuid を投げこまれると
 *   `content_report` にゴミが溜まり、管理画面の未処理件数が意味を失う。
 *   `target_id` は uuid だが、参照先が2つあるため FK を張れない
 *   （docs/schema.sql の `target_kind` + `target_id` はポリモーフィック）。
 *   FK の代わりにここで確かめる、という置き換えである。
 *
 * ★ 読めない対象は報告できない。他人の教材の id を総当たりして
 *   「存在するかどうか」を測られないようにする（可視範囲は material と同じ規則）。
 */
export async function reportContent(db: Sql, input: ReportInput): Promise<ReportResult> {
  const comment = input.comment?.trim() ? input.comment.trim().slice(0, COMMENT_MAX) : null

  return db.begin(async tx => {
    const visible = input.targetKind === 'material_section'
      ? await tx<{ ok: boolean }[]>`
          SELECT true AS ok FROM material_section s JOIN material m ON m.id = s.material_id
           WHERE s.id = ${input.targetId} AND m.status = 'ready'
             AND (m.user_id = ${input.userId} OR m.user_id IS NULL)`
      : await tx<{ ok: boolean }[]>`
          SELECT true AS ok FROM item
           WHERE id = ${input.targetId} AND approved AND NOT hidden
             AND (user_id = ${input.userId} OR user_id IS NULL)`
    if (visible.length === 0) throw new Error('報告する対象が見つかりません')

    // 同じ人が同じ対象を何度も押しても、未処理が積み上がらないようにする
    const prior = await tx<{ id: string }[]>`
      SELECT id FROM content_report
       WHERE user_id = ${input.userId} AND target_kind = ${input.targetKind}
         AND target_id = ${input.targetId} AND status = 'open'`
    if (prior[0]) {
      // 2回目に理由を書いてくれたなら、それは受け取る
      if (comment) {
        await tx`UPDATE content_report SET comment = ${comment} WHERE id = ${prior[0].id}`
      }
      return { reportId: String(prior[0].id), duplicate: true }
    }

    const [row] = await tx<{ id: string }[]>`
      INSERT INTO content_report (user_id, target_kind, target_id, comment, created_at)
      VALUES (${input.userId}, ${input.targetKind}, ${input.targetId}, ${comment}, ${input.now})
      RETURNING id`
    return { reportId: String(row!.id), duplicate: false }
  })
}

export type OpenReport = {
  id: string
  targetKind: ReportTarget
  targetId: string
  comment: string | null
  createdAt: Date
  /** 何が報告されたのか。見出しか設問文の先頭 */
  excerpt: string | null
}

/** 未処理の報告。管理画面（docs/12 §7.1）が読む */
export async function openReports(db: Sql, limit = 50): Promise<OpenReport[]> {
  const rows = await db<{
    id: string; target_kind: ReportTarget; target_id: string
    comment: string | null; created_at: Date; excerpt: string | null
  }[]>`
    SELECT r.id, r.target_kind, r.target_id, r.comment, r.created_at,
           COALESCE(s.heading, i.stem) AS excerpt
      FROM content_report r
      LEFT JOIN material_section s ON r.target_kind = 'material_section' AND s.id = r.target_id
      LEFT JOIN item i            ON r.target_kind = 'item'             AND i.id = r.target_id
     WHERE r.status = 'open'
     ORDER BY r.created_at DESC
     LIMIT ${limit}`
  return rows.map(r => ({
    id: String(r.id), targetKind: r.target_kind, targetId: r.target_id,
    comment: r.comment, createdAt: r.created_at,
    excerpt: r.excerpt === null ? null : r.excerpt.slice(0, 80),
  }))
}

export const REPORT_STATUSES = ['confirmed', 'dismissed', 'fixed'] as const
export type ReportStatus = typeof REPORT_STATUSES[number]

/**
 * 報告を処理する（管理画面から）。
 *
 * ★ `confirmed` にしたときだけ対象を伏せる。`dismissed` は誤報なので何もしない。
 *   ここで初めて本文が消える。押した瞬間ではない。
 */
export async function resolveReport(
  db: Sql, reportId: string, status: ReportStatus,
): Promise<{ hidden: boolean }> {
  return db.begin(async tx => {
    const [r] = await tx<{ target_kind: ReportTarget; target_id: string }[]>`
      UPDATE content_report SET status = ${status}
       WHERE id = ${reportId} AND status = 'open'
       RETURNING target_kind, target_id`
    if (!r) throw new Error('未処理の報告が見つかりません')
    if (status !== 'confirmed') return { hidden: false }

    if (r.target_kind === 'material_section') {
      await tx`UPDATE material_section SET hidden = true, hidden_reason = 'user_report'
                WHERE id = ${r.target_id}`
    } else {
      await tx`UPDATE item SET hidden = true, hidden_reason = 'user_report'
                WHERE id = ${r.target_id}`
    }
    return { hidden: true }
  })
}
