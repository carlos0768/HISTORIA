/**
 * 配信中の教材の本文に、**重要箇所のマーク（==語句==）だけ**を反映する SQL を書き出す
 *
 *   npx tsx scripts/db/material-marks-sql.ts > /tmp/marks.sql          # seed/material/*.json 全部
 *   npx tsx scripts/db/material-marks-sql.ts wh.4.1.3 wh.4.4.1           # 単元を指定
 *   psql '<Direct connection>' -f /tmp/marks.sql                          # または SQL Editor に貼る
 *
 * ★ なぜ本文の投入器（material-sql.ts / -compact.ts）を流し直さないのか。
 *   あちらは**新しい版として入れ直す**。旧版は superseded になり、節の id が変わる。
 *   読了記録（material_read）は節の id に紐づくので、**読み進めた記録が新しい版に
 *   引き継がれない**。マークは本文の文字を1字も変えない注記（docs/07 §2.1）なので、
 *   節の id・設問・埋め込み（マークを除いた文で作るので有効なまま）を保ったまま
 *   `body_md` だけを書き換えれば足りる。
 *
 * ★ **本文が seed と違う節には触れない。** 更新条件に「いまの本文の md5 が、
 *   マークを外した seed の本文と一致する」を入れる。誤りの報告で本文を直した節や、
 *   別の版が入っている節を、seed で上書きして戻してしまわないため。
 *   既にマーク入りの本文とも一致させるので、**何度流しても同じ**になる。
 *
 * ★ 対象は共有教材（user_id IS NULL）で配信中（status = 'ready'）のものだけ。
 *   個人向けに API で生成した教材は seed から来ていないので触らない。
 *
 * ★ 来歴を残す（docs/10 §8）。material.human_edit_log に action = 'mark_important' と
 *   ファイルの sha を書く。同じ sha の記録が既にあれば足さない（何度流しても増えない）。
 */
import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { createHash } from 'node:crypto'
import { parseMaterialOutput } from '@/lib/ai/schema'
import { AUTHORED_DIR } from '@/lib/ai/authored'
import { IMPORTANT_RE, bodyTextLength, importantMarkProblems, stripImportant } from '@/lib/domain/markup'

export type MarkedSection = { ord: number; bodyMd: string }
export type MarkedUnit = { unitId: string; sha: string; sections: MarkedSection[] }

/** 文字列リテラル。単引用符を倍にする（Postgres の標準） */
const lit = (s: string) => `'${s.replaceAll("'", "''")}'`
const md5 = (s: string) => createHash('md5').update(s, 'utf8').digest('hex')

/** seed/material から読む。スキーマ違反やマークの付け方の誤りがあれば投げる */
export function readMarkedUnits(only: readonly string[] = [], dir = AUTHORED_DIR): MarkedUnit[] {
  const files = readdirSync(dir).filter(f => f.endsWith('.json'))
    .map(f => f.replace(/\.json$/, ''))
    .filter(u => only.length === 0 || only.includes(u)).sort()
  return files.map(unitId => {
    const text = readFileSync(join(dir, `${unitId}.json`), 'utf8')
    const parsed = parseMaterialOutput(JSON.parse(text))
    if (!parsed.success) throw new Error(`${unitId}: スキーマに反しています。check-material.ts を先に通してください`)
    for (const s of parsed.data.sections) {
      const problems = importantMarkProblems(s.body_md)
      if (problems.length > 0) throw new Error(`${unitId} §${s.ord} のマーク: ${problems.join(' / ')}`)
    }
    return {
      unitId,
      sha: createHash('sha256').update(text).digest('hex').slice(0, 12),
      sections: parsed.data.sections.map(s => ({ ord: s.ord, bodyMd: s.body_md })),
    }
  })
}

/**
 * @returns マーク入りの節だけを更新する SQL。マークの無い節（§1・§7 など）は送らない
 */
export function buildMarksSql(units: readonly MarkedUnit[]): { sql: string; sections: number; marks: number } {
  const out: string[] = []
  const say = (s = '') => out.push(s)
  let sections = 0, marks = 0

  say('-- 配信中の教材に重要箇所のマークを反映する（scripts/db/material-marks-sql.ts が生成）')
  say('-- ★ 本文が seed と一致する節だけを更新する。違う節は触らない（下の確認用 SELECT で分かる）')
  say('BEGIN;')
  for (const u of units) {
    const counted = u.sections.map(s => ({ ...s, marks: [...s.bodyMd.matchAll(IMPORTANT_RE)].length }))
    const marked = counted.filter(s => s.marks > 0)
    if (marked.length === 0) continue
    const n = marked.reduce((a, s) => a + s.marks, 0)
    say('')
    say(`-- ${u.unitId}  マーク ${n} 箇所 / ${marked.length} 節`)
    for (const s of marked) {
      const plain = stripImportant(s.bodyMd)
      say(`UPDATE material_section s SET body_md = ${lit(s.bodyMd)}, char_count = ${bodyTextLength(s.bodyMd)}`)
      say(`  FROM material m`)
      say(`  WHERE m.id = s.material_id AND m.unit_id = ${lit(u.unitId)} AND m.user_id IS NULL AND m.status = 'ready'`)
      say(`    AND s.ord = ${s.ord} AND md5(s.body_md) IN (${lit(md5(plain))}, ${lit(md5(s.bodyMd))});`)
    }
    // 来歴。同じ sha の記録が既にあれば足さない
    say(`UPDATE material SET human_edit_log = human_edit_log || jsonb_build_array(jsonb_build_object(`)
    say(`    'at', now()::text, 'by', 'author', 'action', 'mark_important',`)
    say(`    'source', 'seed/material', 'sha256_12', ${lit(u.sha)}, 'marks', ${n}))`)
    say(`  WHERE unit_id = ${lit(u.unitId)} AND user_id IS NULL AND status = 'ready'`)
    say(`    AND NOT (human_edit_log @> ${lit(JSON.stringify([{ action: 'mark_important', sha256_12: u.sha }]))}::jsonb)`)
    say(`    AND EXISTS (SELECT 1 FROM material_section s WHERE s.material_id = material.id AND s.body_md LIKE '%==%');`)
    sections += marked.length
    marks += n
  }
  say('')
  say('COMMIT;')
  say('')
  say('-- 確認用。marked が sections より小さい単元は、本文が seed と違う節がある')
  say(`SELECT m.unit_id, count(*) AS sections,`)
  say(`       count(*) FILTER (WHERE s.body_md LIKE '%==%') AS marked`)
  say(`  FROM material m JOIN material_section s ON s.material_id = m.id`)
  say(` WHERE m.user_id IS NULL AND m.status = 'ready'`)
  say(`   AND m.unit_id IN (${units.map(u => lit(u.unitId)).join(', ')})`)
  say(` GROUP BY m.unit_id ORDER BY m.unit_id;`)
  return { sql: out.join('\n') + '\n', sections, marks }
}

if (process.argv[1]?.endsWith('material-marks-sql.ts')) {
  const only = process.argv.slice(2).filter(a => !a.startsWith('--'))
  const units = readMarkedUnits(only)
  if (units.length === 0) {
    console.error(`${AUTHORED_DIR} に教材がありません。`)
    process.exit(1)
  }
  const { sql, sections, marks } = buildMarksSql(units)
  process.stdout.write(sql)
  console.error(`${units.length} 単元 / ${sections} 節 / マーク ${marks} 箇所（${(sql.length / 1024).toFixed(0)}KB）`)
  console.error('  psql の Direct connection か Supabase の SQL Editor で流す。最後の SELECT で marked を確かめる')
}
