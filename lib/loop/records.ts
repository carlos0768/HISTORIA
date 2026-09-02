/**
 * 記録タブ — 弱点の一覧と「なぜ弱点なのか」の根拠
 *
 * 仕様: docs/11-ux.md §9 ／ docs/04-weakness-engine.md §4.3
 *
 * ★ 根拠を出せない弱点判定は出さない。docs/04 §4.3 が
 *   「受験生は自分の弱点判定に納得できないと使うのをやめる」としており、
 *   さらに**作者がアルゴリズムの誤りを見つける唯一の手段**でもある。
 *   数字だけを並べて「弱い」と言い切る画面にはしない。
 *
 * ★ 根拠は `v_weakness_evidence` から作る。このビューは 2026-09-02 に
 *   `security_invoker = true` へ直したもので、RLS を素通りしない。
 *   つまり**他人の解答履歴は入ってこない**（それ以前は漏れていた）。
 */
import type { Sql } from 'postgres'
import {
  mastery, masteryStatus, type KcState, type MasteryStatus,
} from '@/lib/domain/weakness'
import { computeStreak, jstDate, type Streak } from '@/lib/domain/streak'

/** 保持率の推定を出す基準日数。SM-2 の interval に対する経過日数で見る */
const DAY_MS = 86_400_000

export type Evidence = {
  /** 画面にそのまま出す1行 */
  text: string
}

export type WeakKc = {
  kcId: string
  label: string
  status: MasteryStatus
  /** 0〜1。低いほど弱い */
  mastery: number
  /** 直近の教材。無ければ null（「教材を読む」を出さない） */
  materialId: string | null
  evidence: Evidence[]
}

type Row = {
  kc_id: string
  label: string
  p_know: number | null
  theta: number | null
  n_eff: number | null
  n_obs: number | null
  last_seen_at: Date | null
  interval_days: number | null
  last_review_at: Date | null
  suspended: boolean | null
  distinct_correct_days: number
  has_non_flashcard_correct: boolean
  attempts: number
  wrong: number
  /** 誤答で最も多く選ばれた選択肢とその回数 */
  top_wrong: string | null
  top_wrong_n: number
  last_correct_at: Date | null
  material_id: string | null
}

const toState = (r: Row): KcState => ({
  pKnow: r.p_know ?? 0.3,
  theta: r.theta ?? 0,
  nEff: r.n_eff ?? 0,
  nObs: r.n_obs ?? 0,
  lastSeenAt: r.last_seen_at,
})

/** 「最後に正解してから N 日（保持率の推定 M%）」の M。SM-2 の interval に対する減衰 */
function retention(lastCorrectAt: Date | null, intervalDays: number | null, now: Date): number | null {
  if (!lastCorrectAt || !intervalDays || intervalDays <= 0) return null
  const days = (now.getTime() - lastCorrectAt.getTime()) / DAY_MS
  // docs/04b の忘却曲線と同じ形（interval を「保持率9割の点」とみなす指数減衰）
  return Math.exp(Math.log(0.9) * (days / intervalDays))
}

/**
 * 根拠を組み立てる。
 *
 * ★ 作れなかった根拠は**書かない**。「データがありません」と並べても意味がなく、
 *   むしろ根拠の行数が水増しされて信用を落とす。
 */
export function buildEvidence(r: Row, now: Date): Evidence[] {
  const out: Evidence[] = []

  // 1. 何問中何問を間違えたか。特定の誤答に偏っていればそれを名指しする
  if (r.attempts > 0 && r.wrong > 0) {
    const base = `${r.attempts}問中${r.wrong}問で誤答`
    out.push({
      text: r.top_wrong && r.top_wrong_n >= 2
        ? `${base}。うち${r.top_wrong_n}回は「${r.top_wrong}」を選択`
        : base,
    })
  }

  // 2. 最後に正解してからの経過と、そこからの保持率の推定
  if (r.last_correct_at) {
    const days = Math.floor((now.getTime() - r.last_correct_at.getTime()) / DAY_MS)
    const ret = retention(r.last_correct_at, r.interval_days, now)
    out.push({
      text: ret === null
        ? `最後に正解してから${days}日`
        : `最後に正解してから${days}日（保持率の推定 ${Math.round(ret * 100)}%）`,
    })
  } else if (r.attempts > 0) {
    out.push({ text: 'まだ一度も正解していない' })
  }

  // 3. 別日での正解が何回あるか（docs/04 の「まぐれ当たり」を除く条件）
  if (r.distinct_correct_days === 0) {
    if (r.attempts > 0) out.push({ text: '別日での正解がまだ無い' })
  } else if (r.distinct_correct_days <= 2) {
    out.push({ text: `別日での正解が${r.distinct_correct_days}回のみ` })
  }

  // 4. 暗記カードでしか正解していない場合は、それを明示する
  if (r.distinct_correct_days > 0 && !r.has_non_flashcard_correct) {
    out.push({ text: '正解はすべて暗記カード（四択・並べ替えでは未正解）' })
  }

  return out
}

/**
 * 弱点の一覧。弱い順に返す。
 *
 * ★ `mastered` は返さない。記録タブは「これから何をするか」を見る画面であり、
 *   できているものを並べても行動が変わらない。
 */
export async function weakKcs(
  db: Sql, userId: string, now: Date, limit = 20,
): Promise<WeakKc[]> {
  const rows = await db<Row[]>`
    WITH ev AS (
      SELECT kc_id,
             count(*)::int                                   AS attempts,
             count(*) FILTER (WHERE NOT correct)::int         AS wrong,
             max(answered_at) FILTER (WHERE correct)          AS last_correct_at,
             count(DISTINCT date(answered_at)) FILTER (WHERE correct)::int
                                                             AS distinct_correct_days,
             bool_or(correct AND format <> 'flashcard')       AS has_non_flashcard_correct
        FROM v_weakness_evidence
       WHERE user_id = ${userId}
       GROUP BY kc_id
    ),
    top_wrong AS (
      SELECT DISTINCT ON (kc_id) kc_id, chosen #>> '{}' AS top_wrong, count(*)::int AS top_wrong_n
        FROM v_weakness_evidence
       WHERE user_id = ${userId} AND NOT correct AND jsonb_typeof(chosen) = 'string'
       GROUP BY kc_id, chosen
       ORDER BY kc_id, count(*) DESC, chosen
    )
    SELECT kc.id AS kc_id, kc.label,
           s.p_know, s.theta, s.n_eff, s.n_obs, s.last_seen_at,
           c.interval_days, c.last_review_at, c.suspended,
           coalesce(ev.attempts, 0)              AS attempts,
           coalesce(ev.wrong, 0)                 AS wrong,
           coalesce(ev.distinct_correct_days, 0) AS distinct_correct_days,
           coalesce(ev.has_non_flashcard_correct, false) AS has_non_flashcard_correct,
           ev.last_correct_at,
           tw.top_wrong, coalesce(tw.top_wrong_n, 0) AS top_wrong_n,
           (SELECT m.id FROM material m
              JOIN kc_syllabus_unit ksu ON ksu.unit_id = m.unit_id AND ksu.kc_id = kc.id
             WHERE (m.user_id = ${userId} OR m.user_id IS NULL) AND m.status = 'ready'
             ORDER BY m.generated_at DESC LIMIT 1) AS material_id
      FROM kc
      JOIN user_kc_state s ON s.user_id = ${userId} AND s.kc_id = kc.id
      LEFT JOIN kc_card   c ON c.user_id = ${userId} AND c.kc_id = kc.id
      LEFT JOIN ev        ON ev.kc_id = kc.id
      LEFT JOIN top_wrong tw ON tw.kc_id = kc.id`

  const out: WeakKc[] = []
  for (const r of rows) {
    if (r.suspended) continue
    const state = toState(r)
    const m = mastery(state, r.interval_days ?? 0, now)
    const status = masteryStatus(state, m, {
      distinctCorrectDays: r.distinct_correct_days,
      hasNonFlashcardCorrect: r.has_non_flashcard_correct,
    })
    if (status === 'mastered') continue
    out.push({
      kcId: r.kc_id, label: r.label, status, mastery: m,
      materialId: r.material_id,
      evidence: buildEvidence(r, now),
    })
  }
  // 弱い順。同点なら観測が多い方（＝根拠が厚い方）を先に出す
  out.sort((a, b) => a.mastery - b.mastery || b.evidence.length - a.evidence.length)
  return out.slice(0, limit)
}

export type { Streak } from '@/lib/domain/streak'

/**
 * 学習を続けた日数。
 *
 * ★ `user_activity` から数える（docs/11-ux.md §7 の明文）。
 *   以前は `response` を直接数えていたが、それだと
 *   (a) 教材を読んだだけの日を落とすかどうかを SQL に埋めることになり、
 *   (b) 日付が UTC のままで、日本時間の深夜0〜9時に解いた分が前日に落ちていた。
 *   `user_activity` は `submitAnswer` と `recordRead` が Asia/Tokyo の日付で書く。
 *
 * ★ 「その日に1問以上解いた」で成立する（docs/11-ux.md §7.1）。
 *   `sections_read` だけの日は数えない。教材を読むのは学習だが、
 *   仕様が数えると決めているのは出題への解答である。
 *
 * ★ 連続の計算そのものは lib/domain/streak.ts にある（DB を持ちこまない）。
 */
export async function streak(db: Sql, userId: string, now: Date): Promise<Streak> {
  const rows = await db<{ d: string }[]>`
    SELECT to_char(activity_date, 'YYYY-MM-DD') AS d
      FROM user_activity
     WHERE user_id = ${userId} AND responses > 0
     ORDER BY activity_date DESC`
  return computeStreak(rows.map(r => r.d), jstDate(now))
}
