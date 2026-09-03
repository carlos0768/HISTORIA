/**
 * docs/schema.sql が要求する表と列を読み取る
 *
 * ★ 表の一覧を手で持たない。`scripts/db/dump-migration.ts` の `NEW_TABLES` は
 *   手書きの一覧で、表を足すたびに2箇所を直すことになる。あれは「差分を出す」
 *   という別の目的があるので残すが、ここでは**仕様書そのものを読む**。
 *   schema.sql に表を足せば、この道具は何もせずに追随する。
 *
 * ★ 完全な SQL パーサは書かない。schema.sql は自分たちが書いた1つのファイルで、
 *   `CREATE TABLE <名前> (` から対応する `);` までという形が守られている。
 *   その形だけを前提にする（崩れたら試験が落ちる）。
 */
import { readFileSync } from 'node:fs'

export type TableShape = { table: string; columns: string[] }

/** 列定義ではない行（CHECK / PRIMARY KEY / UNIQUE / FOREIGN KEY など） */
const NOT_A_COLUMN = /^(CHECK|PRIMARY|UNIQUE|FOREIGN|CONSTRAINT|EXCLUDE|LIKE)\b/i

/**
 * 行コメントを落とす。**列を切り出す前に**やらなければならない。
 *
 * ★ ここを間違えた（2026-09-03）。最初はカンマで切ったあとに `--` を落としていたが、
 *   コメントの中にカンマが入っていると先に切れてしまう。実際に
 *   `choices jsonb, -- [{key,text,why_wrong}, ...]` の `text` が
 *   `item` の列として数えられ、「item.text が欠けている」と誤検出した。
 *
 * ★ 文字列リテラルの中の `--` は落とさない。schema.sql の CHECK には
 *   `IN ('user_report', …)` のような列挙があり、将来ハイフンを含む値が来ても壊れないようにする。
 */
export function stripLineComments(sql: string): string {
  let out = '', inStr = false
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i]!
    if (inStr) {
      out += c
      if (c === "'") inStr = sql[i + 1] === "'" ? (out += sql[++i], true) : false
      continue
    }
    if (c === "'") { inStr = true; out += c; continue }
    if (c === '-' && sql[i + 1] === '-') {
      // 行末まで飛ばす。改行そのものは残す（行の対応を崩さない）
      while (i < sql.length && sql[i] !== '\n') i++
      out += '\n'
      continue
    }
    out += c
  }
  return out
}

/**
 * `CREATE TABLE` を拾って、表ごとの列名を返す。
 *
 * ★ `CREATE TABLE IF NOT EXISTS` も受ける。schema.sql には今は無いが、
 *   将来足されたときに黙って無視すると「欠けている」と誤検出する。
 */
export function parseSchema(rawSql: string): TableShape[] {
  // ★ 先にコメントを落とす（上の注記のとおり、切ったあとでは間に合わない）
  const sql = stripLineComments(rawSql)
  const shapes: TableShape[] = []
  const re = /^CREATE TABLE (?:IF NOT EXISTS )?([a-z_][a-z0-9_]*)\s*\(/gim
  for (const m of sql.matchAll(re)) {
    const table = m[1]!
    // 対応する閉じ括弧まで。入れ子（CHECK の中の括弧）を数える
    let depth = 0, i = m.index! + m[0].length - 1, end = -1
    for (; i < sql.length; i++) {
      if (sql[i] === '(') depth++
      else if (sql[i] === ')') { depth--; if (depth === 0) { end = i; break } }
    }
    if (end < 0) continue

    const body = sql.slice(m.index! + m[0].length, end)
    const columns: string[] = []
    let depth2 = 0, cur = ''
    for (const ch of body) {
      if (ch === '(') depth2++
      else if (ch === ')') depth2--
      if (ch === ',' && depth2 === 0) { columns.push(cur); cur = '' } else cur += ch
    }
    columns.push(cur)

    shapes.push({
      table,
      columns: columns
        .map(c => c.replace(/\s+/g, ' ').trim())
        .filter(c => c.length > 0 && !NOT_A_COLUMN.test(c))
        .map(c => c.split(/\s+/)[0]!)
        .filter(c => /^[a-z_][a-z0-9_]*$/.test(c)),
    })
  }
  return shapes
}

export function schemaShape(path = 'docs/schema.sql'): TableShape[] {
  return parseSchema(readFileSync(path, 'utf8'))
}
