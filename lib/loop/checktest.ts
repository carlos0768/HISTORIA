/**
 * 確認テスト — 出題の組み立てと合否
 *
 * 仕様: docs/06-assessment.md §2（層化抽出）／§3（合否）
 *
 * ★ ランダムで引かない。docs/06 §2.1 が理由を4つ挙げている。
 *   なかでも致命的なのは**カバレッジが保証されないこと**で、
 *   48KC から20問をランダムに引くと同じ8KCに偏り、
 *   「範囲を仕上げたか」という問いに答えられなくなる。測定器として無意味になる。
 *
 * ★ 弱点層だけからも引かない（0.7 : 0.3）。習得済みの層を測らないと
 *   「仕上げた」と言えないうえ、忘却を検出できない。
 */
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { mastery, masteryStatus, type KcState, type MasteryStatus } from '@/lib/domain/weakness'
import {
  verdict, canRetest, rawScore, RETEST_COOLDOWN_DAYS, type Verdict,
} from '@/lib/domain/assessment'

/** 出題数は範囲の35%。ただし10〜25問に収める（docs/06 §2.2） */
export const TEST_RATIO = 0.35
export const TEST_MIN = 10
export const TEST_MAX = 25
/** 弱い方から60%を弱点層とし、そこから7割を出す */
export const WEAK_POOL_RATIO = 0.6
export const WEAK_PICK_RATIO = 0.7
/** 14日以内に解いた設問は避ける（docs/04b §5） */
export const REUSE_COOLDOWN_DAYS = 14

export const testSize = (kcCount: number): number =>
  Math.min(TEST_MAX, Math.max(TEST_MIN, Math.ceil(kcCount * TEST_RATIO)))

type Ranked = { kcId: string; mastery: number }

/** Fisher-Yates。元の配列を壊さない */
function shuffled<T>(xs: readonly T[], rand: () => number): T[] {
  const a = [...xs]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    [a[i], a[j]] = [a[j]!, a[i]!]
  }
  return a
}

/**
 * 層化抽出で KC を選ぶ。
 *
 * ★ 決定的にする（乱数を引数で受ける）。出題が実行ごとに変わると、
 *   「同じ状態で同じテストが出るか」を試験できない。
 */
export function pickKcs(ranked: Ranked[], n: number, rand: () => number = Math.random): string[] {
  if (ranked.length === 0) return []
  const sorted = [...ranked].sort((a, b) => a.mastery - b.mastery)
  const cut = Math.ceil(sorted.length * WEAK_POOL_RATIO)
  const weak = sorted.slice(0, cut)
  const strong = sorted.slice(cut)

  const wantWeak = Math.round(n * WEAK_PICK_RATIO)
  const take = (pool: Ranked[], k: number): string[] =>
    shuffled(pool, rand).slice(0, k).map(x => x.kcId)

  const picked = [...take(weak, wantWeak), ...take(strong, n - wantWeak)]
  // 片方の層が薄いときは、もう片方で埋める。人数合わせのために出題数を削らない
  if (picked.length < n) {
    const chosen = new Set(picked)
    for (const r of sorted) {
      if (picked.length >= n) break
      if (!chosen.has(r.kcId)) { picked.push(r.kcId); chosen.add(r.kcId) }
    }
  }
  return picked
}

type KcRow = {
  kc_id: string
  p_know: number | null
  theta: number | null
  n_eff: number | null
  n_obs: number | null
  last_seen_at: Date | null
  interval_days: number | null
  distinct_correct_days: number
  has_non_flashcard_correct: boolean
}

const toState = (r: KcRow): KcState => ({
  pKnow: r.p_know ?? 0.3, theta: r.theta ?? 0,
  nEff: r.n_eff ?? 0, nObs: r.n_obs ?? 0, lastSeenAt: r.last_seen_at,
})

const statusOf = (r: KcRow, now: Date): MasteryStatus =>
  masteryStatus(toState(r), mastery(toState(r), r.interval_days ?? 0, now), {
    distinctCorrectDays: r.distinct_correct_days,
    hasNonFlashcardCorrect: r.has_non_flashcard_correct,
  })

/**
 * 特訓の KC を、現在の mastery つきで読む。
 *
 * ★ mode='ai_material' のときは「教材が出来ている KC」に絞る（docs/06 §2.2）。
 *   まだ教材を配っていない範囲を出すと、読んでいないものを問うことになる。
 *   自学（self_study）は教材が無いのが前提なので、範囲全体から出す。
 */
async function drillKcs(db: Sql, userId: string, drillId: string, mode: string): Promise<KcRow[]> {
  return db<KcRow[]>`
    SELECT dk.kc_id, s.p_know, s.theta, s.n_eff, s.n_obs, s.last_seen_at, c.interval_days,
           (SELECT count(DISTINCT date(r.answered_at))
              FROM response r JOIN item_kc ik ON ik.item_id = r.item_id
             WHERE r.user_id = ${userId} AND ik.kc_id = dk.kc_id AND r.correct)::int
             AS distinct_correct_days,
           EXISTS (SELECT 1 FROM response r
                     JOIN item_kc ik ON ik.item_id = r.item_id
                     JOIN item i ON i.id = r.item_id
                    WHERE r.user_id = ${userId} AND ik.kc_id = dk.kc_id AND r.correct
                      AND i.format <> 'flashcard') AS has_non_flashcard_correct
      FROM drill_kc dk
      LEFT JOIN user_kc_state s ON s.user_id = ${userId} AND s.kc_id = dk.kc_id
      LEFT JOIN kc_card       c ON c.user_id = ${userId} AND c.kc_id = dk.kc_id
     WHERE dk.drill_id = ${drillId}
       AND (${mode}::text <> 'ai_material'
            OR EXISTS (SELECT 1 FROM kc_syllabus_unit ksu
                         JOIN material m ON m.unit_id = ksu.unit_id
                        WHERE ksu.kc_id = dk.kc_id AND m.status = 'ready'
                          AND (m.user_id = ${userId} OR m.user_id IS NULL)
                          AND m.unit_id IN (SELECT unit_id FROM drill_unit
                                             WHERE drill_id = ${drillId})))`
}

export type BuildResult =
  | { ok: true; testId: string; itemIds: string[] }
  | { ok: false; reason: 'cooldown' | 'no_items'; nextAt?: Date }

/**
 * 確認テストを作る。
 *
 * ★ 中断できない（docs/11 §10 の画面9）。作った時点で item_ids を固定し、
 *   途中でやめても同じ問題が残る。作り直せると「解けるまで引き直す」ができてしまい、
 *   測定にならない。
 */
export async function buildCheckTest(
  db: Sql, userId: string, drillId: string, now: Date, rand: () => number = Math.random,
): Promise<BuildResult> {
  const [last] = await db<{ started_at: Date }[]>`
    SELECT started_at FROM check_test
     WHERE user_id = ${userId} AND drill_id = ${drillId} AND finished_at IS NOT NULL
     ORDER BY started_at DESC LIMIT 1`
  if (last && !canRetest(last.started_at, now)) {
    return {
      ok: false, reason: 'cooldown',
      nextAt: new Date(last.started_at.getTime() + RETEST_COOLDOWN_DAYS * 86_400_000),
    }
  }

  const [d] = await db<{ mode: string }[]>`
    SELECT mode FROM drill WHERE id = ${drillId} AND user_id = ${userId}`
  if (!d) return { ok: false, reason: 'no_items' }

  const kcs = await drillKcs(db, userId, drillId, d.mode)
  if (kcs.length === 0) return { ok: false, reason: 'no_items' }

  const ranked = kcs.map(r => ({ kcId: r.kc_id, mastery: mastery(toState(r), r.interval_days ?? 0, now) }))
  const picked = pickKcs(ranked, testSize(kcs.length), rand)

  // KC ごとに1問。14日以内に解いた設問は避ける（docs/04b §5）
  const cutoff = new Date(now.getTime() - REUSE_COOLDOWN_DAYS * 86_400_000)
  const itemIds: string[] = []
  const used = new Set<string>()
  for (const kcId of picked) {
    const [it] = await db<{ id: string }[]>`
      SELECT i.id FROM item i
        JOIN item_kc ik ON ik.item_id = i.id
       WHERE ik.kc_id = ${kcId} AND i.approved
         AND (i.user_id = ${userId} OR i.user_id IS NULL)
         AND NOT (i.id = ANY(${itemIds}))
         AND NOT EXISTS (SELECT 1 FROM response r
                          WHERE r.item_id = i.id AND r.user_id = ${userId}
                            AND r.answered_at >= ${cutoff})
       ORDER BY random() LIMIT 1`
    if (it && !used.has(it.id)) { itemIds.push(it.id); used.add(it.id) }
  }
  if (itemIds.length === 0) return { ok: false, reason: 'no_items' }

  // ★ 出題順を混ぜる（docs/06 §2.2 の shuffle）。picked は弱点層→習得層の順に
  //   並んでいるので、そのまま出すと「前半が難しく後半が易しい」と読めてしまう。
  //   難易度の配列が見えると、後半で手を抜いても点が取れると分かる。
  const order = shuffled(itemIds, rand)

  const testId = randomUUID()
  await db`
    INSERT INTO check_test (id, user_id, drill_id, item_ids, total, started_at)
    VALUES (${testId}, ${userId}, ${drillId}, ${order}, ${order.length}, ${now})`
  return { ok: true, testId, itemIds: order }
}

export type GradeResult = {
  verdict: Verdict
  rawScore: number
  correct: number
  total: number
  progressAfter: number
  /** 落とした KC。翌日のキュー先頭に来る（docs/06 §3.2） */
  missedKcs: Array<{ kcId: string; label: string }>
}

/**
 * 採点して確定させる。
 *
 * ★ 解答そのものは submitAnswer が既に記録している（弱点の更新もそこで済む）。
 *   ここでやるのは「このテストが対象とした KC 集合」に対する合否だけである。
 *   同じ数字を2つの式で計算しない（docs/06 §3.1）。
 */
export async function gradeCheckTest(
  db: Sql, userId: string, testId: string, now: Date,
): Promise<GradeResult | null> {
  const [t] = await db<{ item_ids: string[]; total: number; drill_id: string; started_at: Date }[]>`
    SELECT item_ids, total, drill_id, started_at FROM check_test
     WHERE id = ${testId} AND user_id = ${userId}`
  if (!t) return null

  // ★ 期間で挟む。設問は14日後には再出題されうるので、item_id だけで拾うと
  //   前回の確認テストの解答が今回の点に混ざる。素点が total を超えることさえある。
  const [score] = await db<{ correct: string }[]>`
    SELECT count(*) FILTER (WHERE r.correct) AS correct
      FROM response r
     WHERE r.user_id = ${userId} AND r.item_id = ANY(${t.item_ids})
       AND r.session_kind = 'checktest'
       AND r.answered_at >= ${t.started_at} AND r.answered_at <= ${now}`

  // 分母は「このテストが出題対象とした KC」。特訓全体ではない（docs/06 §3.1）
  const tested = await db<KcRow[]>`
    SELECT DISTINCT ON (ik.kc_id) ik.kc_id,
           s.p_know, s.theta, s.n_eff, s.n_obs, s.last_seen_at, c.interval_days,
           (SELECT count(DISTINCT date(r.answered_at))
              FROM response r JOIN item_kc ik2 ON ik2.item_id = r.item_id
             WHERE r.user_id = ${userId} AND ik2.kc_id = ik.kc_id AND r.correct)::int
             AS distinct_correct_days,
           EXISTS (SELECT 1 FROM response r
                     JOIN item_kc ik2 ON ik2.item_id = r.item_id
                     JOIN item i2 ON i2.id = r.item_id
                    WHERE r.user_id = ${userId} AND ik2.kc_id = ik.kc_id AND r.correct
                      AND i2.format <> 'flashcard') AS has_non_flashcard_correct
      FROM item_kc ik
      LEFT JOIN user_kc_state s ON s.user_id = ${userId} AND s.kc_id = ik.kc_id
      LEFT JOIN kc_card       c ON c.user_id = ${userId} AND c.kc_id = ik.kc_id
     WHERE ik.item_id = ANY(${t.item_ids})`

  const statuses = tested.map(r => statusOf(r, now))
  const v = verdict(statuses)
  const progressAfter = statuses.filter(s => s === 'mastered').length / (statuses.length || 1)
  const correct = Number(score?.correct ?? 0)

  await db`
    UPDATE check_test
       SET raw_score = ${correct}, verdict = ${v},
           progress_after = ${progressAfter}, finished_at = ${now}
     WHERE id = ${testId} AND user_id = ${userId}`

  const missedKcs = await db<{ kcId: string; label: string }[]>`
    SELECT DISTINCT kc.id AS "kcId", kc.label
      FROM response r
      JOIN item_kc ik ON ik.item_id = r.item_id
      JOIN kc ON kc.id = ik.kc_id
     WHERE r.user_id = ${userId} AND r.item_id = ANY(${t.item_ids})
       AND r.session_kind = 'checktest' AND NOT r.correct
       AND r.answered_at >= ${t.started_at} AND r.answered_at <= ${now}
     ORDER BY kc.label`

  return { verdict: v, rawScore: rawScore(correct, t.total), correct, total: t.total, progressAfter, missedKcs }
}
