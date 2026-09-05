/**
 * 事実確認で止まった教材を、作者の判断で配信可能にする
 *
 * ★ **道具は判断しない。判断を記録する。**
 *   docs/02 §5 は KC について「作者が承認して初めて入る」と定めており、
 *   教材も同じ扱いにする。ここにあるのは「作者がこう決めた」を DB に
 *   書き留める手続きだけで、正しいかどうかを推し量る処理は1行も無い。
 *
 * ★ なぜ要るか: `blocked` から抜ける道は `generateMaterial(force)` の
 *   作り直ししか無かった。しかし層3（Gemini）の指摘は**誤りとは限らない**。
 *   2026-09-04 の wh.4.1.3 がそれで、「三部会の招集は1615年以来のことでした」に
 *   対する指摘は、三部会が1614年10月招集・1615年2月閉会であることを踏まえると
 *   誤りとも正しいとも言い切れなかった。作り直せば同じ本文はもう手に入らず、
 *   1本あたり約50円が消える。**読んで、正しいと判断したなら、そのまま出せるべきである。**
 *
 * ★ `approved_by` に `'factcheck'` と書かない。事実確認は通っていない。
 *   docs/schema.sql の item は承認者を `('factcheck','author')` に限っており、
 *   ここは必ず `'author'` である。来歴を偽ると、後から
 *   「機械が通したのか人が通したのか」が二度と分からなくなる。
 */
import type { Sql } from 'postgres'

/** 承認の理由。空では受け付けない。docs/10 §8 の human_edit_log に残す本体である */
export const MAX_NOTE_CHARS = 1000

export type ApprovalSection = {
  ord: number
  heading: string
  charCount: number
  bodyMd: string
}

/** 承認する前に作者が読むもの */
export type ApprovalTarget = {
  id: string
  unitId: string
  unitLabel: string
  title: string
  status: string
  /** NULL = 共有教材（全員が読む）。非NULL = その人だけの教材 */
  userId: string | null
  reason: string | null
  provider: string
  model: string
  promptVersion: string
  generatedAt: Date
  sections: ApprovalSection[]
  itemCount: number
  /** 承認済みの設問数。blocked なら 0 のはずである */
  approvedItemCount: number
  /** 配信すると入れ替わる、いま配信中の教材 */
  supersedes: { id: string; title: string; generatedAt: Date } | null
  /** これまでの人手の記録（docs/10 §8） */
  editLog: unknown[]
}

/**
 * 単元 id から、いま止まっている教材を引く。
 *
 * ★ 作者が手で打つのは `wh.4.1.3` であって uuid ではない。
 *   uuid を要求する道具は、使うたびに SQL を1回書かせることになる。
 */
export async function blockedMaterialsForUnit(
  db: Sql, unitId: string,
): Promise<Array<{ id: string; userId: string | null; generatedAt: Date }>> {
  const rows = await db<{ id: string; user_id: string | null; generated_at: Date }[]>`
    SELECT id, user_id, generated_at FROM material
     WHERE unit_id = ${unitId} AND status = 'blocked'
     ORDER BY generated_at DESC`
  return rows.map(r => ({ id: r.id, userId: r.user_id, generatedAt: r.generated_at }))
}

/** 承認の対象を、本文ごと1回で集める */
export async function approvalTarget(db: Sql, materialId: string): Promise<ApprovalTarget | null> {
  const [m] = await db<{
    id: string; unit_id: string; unit_label: string; title: string; status: string
    user_id: string | null; blocked_reason: string | null; provider: string; model: string
    prompt_version: string; generated_at: Date; human_edit_log: unknown[]
  }[]>`
    SELECT m.id, m.unit_id, u.label AS unit_label, m.title, m.status, m.user_id,
           m.blocked_reason, m.provider, m.model, m.prompt_version, m.generated_at,
           m.human_edit_log
      FROM material m JOIN syllabus_unit u ON u.id = m.unit_id
     WHERE m.id = ${materialId}`
  if (!m) return null

  const sections = await db<{ ord: number; heading: string; char_count: number; body_md: string }[]>`
    SELECT ord, heading, char_count, body_md FROM material_section
     WHERE material_id = ${materialId} ORDER BY ord`

  const [counts] = await db<{ n: string; approved: string }[]>`
    SELECT count(*) AS n, count(*) FILTER (WHERE approved) AS approved
      FROM item WHERE material_id = ${materialId}`

  // 配信すると入れ替わる相手。共有教材は共有教材と、個別教材は同じ人の教材と入れ替わる
  const [current] = await db<{ id: string; title: string; generated_at: Date }[]>`
    SELECT id, title, generated_at FROM material
     WHERE unit_id = ${m.unit_id} AND status = 'ready'
       AND user_id IS NOT DISTINCT FROM ${m.user_id}`

  return {
    id: m.id, unitId: m.unit_id, unitLabel: m.unit_label, title: m.title, status: m.status,
    userId: m.user_id, reason: m.blocked_reason, provider: m.provider, model: m.model,
    promptVersion: m.prompt_version, generatedAt: m.generated_at,
    sections: sections.map(s => ({
      ord: s.ord, heading: s.heading, charCount: s.char_count, bodyMd: s.body_md,
    })),
    itemCount: Number(counts?.n ?? 0),
    approvedItemCount: Number(counts?.approved ?? 0),
    supersedes: current
      ? { id: current.id, title: current.title, generatedAt: current.generated_at }
      : null,
    editLog: Array.isArray(m.human_edit_log) ? m.human_edit_log : [],
  }
}

export type ApprovalResult =
  | { approved: true; materialId: string; items: number; supersededId: string | null }
  | { approved: false; reason: string }

/**
 * 止まっている教材を配信可能にする。
 *
 * ★ 理由を必ず書かせる。docs/10 §8 は「人間による編集・監修の痕跡がログとして必要」
 *   として `human_edit_log` を置いている。理由の無い承認はその痕跡にならないし、
 *   何より**半年後の自分が「なぜ機械の指摘を退けたのか」を思い出せない**。
 *
 * ★ フェイクで作った教材は承認しない。中身はモデルが書いたものですらなく、
 *   `lib/ai/fake.ts` が組み立てた「あ」の羅列である。作者の署名を付けて
 *   配信してよいものが1つも無い。
 *
 * ★ blocked 以外は動かさない。`superseded` を生き返らせる操作は別物であり
 *   （新しい版を降ろすことになる）、この関数の名前では表せない。
 */
export async function approveMaterial(
  db: Sql, args: { materialId: string; note: string; now: Date },
): Promise<ApprovalResult> {
  const note = args.note.trim()
  if (note.length === 0) {
    return { approved: false, reason: '承認の理由を書いてください（human_edit_log に残ります）' }
  }
  if (note.length > MAX_NOTE_CHARS) {
    return { approved: false, reason: `理由は ${MAX_NOTE_CHARS} 字までにしてください` }
  }

  return db.begin(async tx => {
    // ★ 行を押さえてから読む。読んだあとに別の経路が同じ単元へ ready を入れると、
    //   一意索引（material_one_shared_ready_per_unit）で落ちる
    const [m] = await tx<{
      id: string; user_id: string | null; unit_id: string; status: string
      provider: string; blocked_reason: string | null
    }[]>`
      SELECT id, user_id, unit_id, status, provider, blocked_reason
        FROM material WHERE id = ${args.materialId} FOR UPDATE`

    if (!m) return { approved: false, reason: '教材が見つかりません' }
    if (m.status === 'ready') return { approved: false, reason: 'この教材はすでに配信できます' }
    if (m.status !== 'blocked') {
      return {
        approved: false,
        reason: `配信可能にできるのは事実確認で止まった教材だけです（いまの状態: ${m.status}）`,
      }
    }
    if (m.provider.startsWith('fake:')) {
      return {
        approved: false,
        reason: 'この教材は鍵が無いまま作られた偽物です（provider が fake:）。'
          + '中身はモデルの出力ですらないので、作り直してください。',
      }
    }

    // 同じ単元で配信できる教材は1本だけ（docs/schema.sql の一意索引2本）。
    // 共有教材は共有教材だけを、個別教材は同じ人の教材だけを退ける
    const [old] = await tx<{ id: string }[]>`
      UPDATE material SET status = 'superseded'
       WHERE unit_id = ${m.unit_id} AND status = 'ready'
         AND user_id IS NOT DISTINCT FROM ${m.user_id}
      RETURNING id`

    const entry = {
      at: args.now.toISOString(),
      by: 'author',
      action: 'approve_blocked',
      note,
      // ★ 何を退けた上での承認かを、この1件だけ読めば分かるようにする。
      //   blocked_reason 列は作り直しで上書きされうるが、ログは積むだけである
      blocked_reason: m.blocked_reason,
    }

    await tx`
      UPDATE material
         SET status = 'ready',
             supersedes_id = ${old?.id ?? null},
             human_edit_log = human_edit_log || ${tx.json([entry] as never)}::jsonb
       WHERE id = ${args.materialId}`

    // ★ 設問も一緒に開ける。教材だけ ready にしても、設問は approved = false のまま
    //   出題されない（docs/schema.sql の item_diagnostic_pool と出題側の条件）。
    //   「配信可能にした」と言いながら問題が1問も出ない、が起きる
    const items = await tx<{ id: string }[]>`
      UPDATE item SET approved = true, approved_by = 'author', approved_at = ${args.now}
       WHERE material_id = ${args.materialId} AND NOT approved
      RETURNING id`

    return {
      approved: true, materialId: args.materialId,
      items: items.length, supersededId: old?.id ?? null,
    }
  }) as Promise<ApprovalResult>
}
