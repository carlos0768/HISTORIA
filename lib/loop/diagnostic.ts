/**
 * 適応的診断テストの進行（docs/04-weakness-engine.md §5）
 *
 * ★ **新しい表を作らない。** セッションの状態は `response`（`session_kind='diagnostic'`）
 *   から毎回導出する。最大24問なので、事後分布を1問目から数え直しても安い。
 *   表を増やすと、途中で閉じたセッションを掃除する仕組みまで要ることになる。
 *
 * ★ 出題プールは共有プール（`item.user_id IS NULL`）だけ（§5.2）。
 *   サインアップ直後にはそのユーザー用の設問が1問も無いので、
 *   生成を待たせずに始められるのはここだけである。
 *
 * ★ 共有プールは日々の出題（app/study）とも共用している。
 *   診断で最大24問を消費するぶん、その日の新規出題が減る。
 *   408問中24問なので影響は小さいが、二重使用であることは意識しておく。
 */
import type { Sql } from 'postgres'
import {
  cellKey, initialCells, selectNext, updateCell, shouldStop, summarize, pCorrect,
  MAX_ITEMS, type CellKey, type CellPosterior, type Candidate, type DiagnosticResult,
} from '@/lib/domain/diagnostic'
import { submitAnswer } from './answer'
import { ALGO_VERSION } from '@/lib/domain/params'

/**
 * KC がどのセルに属するか（§5.3「`kc.era_id` × `kc_region.is_primary` の `region.grid_id`」）
 *
 * ★ era も primary の region も無い KC は、どのセルにも入らない。
 *   出題からも伝播からも外す。無理に1セルへ押しこむと、
 *   そのセルのθが「たまたま分類できなかったもの」で汚れる。
 */
const KC_CELL_SQL = `
  SELECT k.id AS kc_id, k.era_id, r.grid_id
    FROM kc k
    JOIN kc_region kr ON kr.kc_id = k.id AND kr.is_primary
    JOIN region r     ON r.id = kr.region_id
   WHERE NOT k.retired AND k.era_id IS NOT NULL`

export type DiagnosticState = {
  /** 何問答えたか */
  answered: number
  cells: Map<CellKey, CellPosterior>
  /** もう出した item。同じ問題を2度出さない */
  seen: Set<string>
  done: boolean
}

type AnsweredRow = {
  item_id: string
  correct: boolean
  guess_rate: number
  elo_b: number
  era_id: number
  grid_id: number
}

/**
 * これまでの解答から、いまの事後分布を組み立て直す。
 *
 * ★ **解いた順に**再生する。順序を変えると事後分布が変わる
 *   （更新が非線形なので）。`answered_at` で並べる。
 *
 * ★ 1つの item が複数のセルに跨るときは、最初のセルだけを使う。
 *   跨る item を全セルに反映すると、1問で複数セルの SD が縮み、
 *   「測っていないのに測ったことになる」。
 */
export async function diagnosticState(db: Sql, userId: string): Promise<DiagnosticState> {
  const rows = await db<AnsweredRow[]>`
    SELECT DISTINCT ON (r.id) r.item_id, r.correct, i.guess_rate, i.elo_b, c.era_id, c.grid_id
      FROM response r
      JOIN item i ON i.id = r.item_id
      JOIN item_kc ik ON ik.item_id = i.id
      JOIN (${db.unsafe(KC_CELL_SQL)}) c ON c.kc_id = ik.kc_id
     WHERE r.user_id = ${userId} AND r.session_kind = 'diagnostic'
     ORDER BY r.id, c.era_id, c.grid_id`
  // ★ `ORDER BY r.id` が「解いた順」になっている。response.id は bigserial なので
  //   採番の順＝INSERT の順＝解いた順である（docs/schema.sql）。
  //   answered_at で並べ直す必要はない。むしろ answered_at は呼び出し側が渡す値なので、
  //   同じミリ秒に2件入ると順序が決まらない。id のほうが確実である。

  const seen = new Set<string>()
  const cells = initialCells()
  let answered = 0
  for (const r of rows) {
    if (seen.has(r.item_id)) continue
    seen.add(r.item_id)
    answered++
    const key = cellKey(r.era_id, r.grid_id)
    const cell = cells.get(key)
    if (cell) cells.set(key, updateCell(cell, r.correct, r.elo_b, r.guess_rate))
  }
  return { answered, cells, seen, done: shouldStop(answered, cells) }
}

export type DiagnosticQuestion = {
  itemId: string
  stem: string
  choices: unknown
  /** 何問目か（1始まり） */
  index: number
  /** 上限。進捗の分母 */
  total: number
  /** Elo 較正に渡す。クライアントには出さない */
  expectedP: number
}

/**
 * 次の1問を返す。終わっていれば null。
 *
 * ★ **正答も解説も返さない**（docs/12 §6.1）。採点は submitAnswer が行う。
 */
export async function nextQuestion(
  db: Sql, userId: string,
): Promise<{ question: DiagnosticQuestion | null; state: DiagnosticState }> {
  const state = await diagnosticState(db, userId)
  if (state.done) return { question: null, state }

  const pool = await db<{
    item_id: string; era_id: number; grid_id: number; elo_b: number; guess_rate: number
  }[]>`
    SELECT DISTINCT ON (i.id)
           i.id AS item_id, c.era_id, c.grid_id, i.elo_b, i.guess_rate
      FROM item i
      JOIN item_kc ik ON ik.item_id = i.id
      JOIN (${db.unsafe(KC_CELL_SQL)}) c ON c.kc_id = ik.kc_id
     WHERE i.user_id IS NULL AND i.approved AND NOT i.hidden
     ORDER BY i.id, c.era_id, c.grid_id`

  const candidates: Candidate[] = pool
    .filter(r => !state.seen.has(r.item_id))
    .map(r => ({
      itemId: r.item_id, cell: cellKey(r.era_id, r.grid_id),
      eloB: r.elo_b, guessRate: r.guess_rate,
    }))

  const pick = selectNext(candidates, state.cells)
  // ★ プールが尽きたら終わりにする。「問題がありません」で止めない
  if (!pick) return { question: null, state: { ...state, done: true } }

  const [item] = await db<{ stem: string; choices: unknown }[]>`
    SELECT stem, choices FROM item WHERE id = ${pick.itemId}`
  const cell = state.cells.get(pick.cell)!
  return {
    question: {
      itemId: pick.itemId,
      stem: item!.stem,
      choices: item!.choices,
      index: state.answered + 1,
      total: MAX_ITEMS,
      expectedP: pCorrect(cell.theta, pick.eloB, pick.guessRate),
    },
    state,
  }
}

/**
 * 1問答える。
 *
 * ★ `expectedP` はサーバーが計算して渡す。クライアントから受け取らない
 *   （受け取ると Elo を任意に歪められる）。
 */
export async function answerDiagnostic(
  db: Sql, userId: string, itemId: string, chosen: unknown, latencyMs: number | null, now: Date,
): Promise<{ correct: boolean; done: boolean; answered: number }> {
  // ★ その時点の期待値をサーバー側で作り直す。画面から渡された値は使わない
  const before = await diagnosticState(db, userId)
  const [meta] = await db<{ elo_b: number; guess_rate: number; era_id: number; grid_id: number }[]>`
    SELECT DISTINCT ON (i.id) i.elo_b, i.guess_rate, c.era_id, c.grid_id
      FROM item i
      JOIN item_kc ik ON ik.item_id = i.id
      JOIN (${db.unsafe(KC_CELL_SQL)}) c ON c.kc_id = ik.kc_id
     WHERE i.id = ${itemId} AND i.user_id IS NULL AND i.approved AND NOT i.hidden
     ORDER BY i.id, c.era_id, c.grid_id`
  if (!meta) throw new Error('診断で出せる設問ではありません')

  const cell = before.cells.get(cellKey(meta.era_id, meta.grid_id))
  const expectedP = cell ? pCorrect(cell.theta, meta.elo_b, meta.guess_rate) : null

  const r = await submitAnswer(db, {
    userId, itemId, sessionKind: 'diagnostic', chosen, latencyMs, expectedP, now,
  })
  const after = await diagnosticState(db, userId)
  return { correct: r.correct, done: after.done, answered: after.answered }
}

/**
 * 診断を終えて、各 KC の初期θを与える（§5.4）。
 *
 *   theta(kc) = theta_0(cell of kc)
 *   n_eff(kc) = 0                        ← 変えない
 *
 * ★ `p_know` は事前分布のまま置く（§5.4 の `p_know_0`）。θだけを入れる。
 *   θは出題順の並べ替えに使い、`n_eff = 0` なので mastery の判定には効かない。
 *   つまり「弱点」としては誰も断定されない（§5.5）。
 *
 * ★ 1問も出せなかったセルの KC には**行を作らない**。
 *   θ = -0.5 の行を全 KC に作ると、「測った」と「測っていない」の区別が消える。
 */
export async function finishDiagnostic(
  db: Sql, userId: string, now: Date,
): Promise<DiagnosticResult & { seeded: number }> {
  const state = await diagnosticState(db, userId)
  const result = summarize(state.cells, state.answered)

  const measured = [...state.cells.entries()].filter(([, c]) => c.answered > 0)
  if (measured.length === 0) return { ...result, seeded: 0 }

  let seeded = 0
  for (const [key, cell] of measured) {
    const [eraId, gridId] = key.split(':').map(Number)
    const rows = await db`
      INSERT INTO user_kc_state (user_id, kc_id, theta, p_know, n_obs, n_eff,
                                 algo_version, updated_at)
      SELECT ${userId}, c.kc_id, ${cell.theta},
             -- 事前分布（§5.4）: 0.15 + 0.25 * norm(exam_weight) を 0.10〜0.45 に丸める
             least(0.45, greatest(0.10, 0.15 + 0.25 * least(1, greatest(0, k.exam_weight / 2)))),
             0, 0, ${ALGO_VERSION}, ${now}
        FROM (${db.unsafe(KC_CELL_SQL)}) c
        JOIN kc k ON k.id = c.kc_id
       WHERE c.era_id = ${eraId!} AND c.grid_id = ${gridId!}
      -- ★ 既に状態がある KC は上書きしない。診断をやり直しても、
      --   その後の学習で積み上がった推定を消さない
      ON CONFLICT (user_id, kc_id) DO NOTHING
      RETURNING kc_id`
    seeded += rows.length
  }
  return { ...result, seeded }
}

/** 診断を終えているか。ホームの出し分けに使う（docs/11-ux.md:80） */
export async function hasDiagnostic(db: Sql, userId: string): Promise<boolean> {
  const [row] = await db<{ n: string }[]>`
    SELECT count(*) AS n FROM response
     WHERE user_id = ${userId} AND session_kind = 'diagnostic'`
  return Number(row?.n ?? 0) > 0
}
