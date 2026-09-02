import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { readFileSync, writeFileSync, mkdtempSync, cpSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { buildSeedSql, SEED_SQL_PATH } from './dump-sql'
import { seedAll, SEED_DIR } from './seed'
import { readCsv } from './csv'

/**
 * postgres.js はプール接続での BEGIN / COMMIT を拒む（UNSAFE_TRANSACTION）。
 * psql や Supabase の SQL エディタでは問題なく通るので、
 * ここでは同じ原子性を db.begin で与えて中身だけを流す。
 */
const applySeedSql = (db: Sql, sql: string) =>
  db.begin(tx => tx.unsafe(sql.replace(/^BEGIN;$/m, '').replace(/^COMMIT;$/m, '')))

/** seed を写して item.csv だけ全件承認にした一時ディレクトリを作る */
function approvedItemsDir(): string {
  const dir = mkdtempSync(join(tmpdir(), 'historia-dumpsql-item-'))
  cpSync(SEED_DIR, dir, { recursive: true })
  const p = join(dir, 'item.csv')
  const lines = readFileSync(p, 'utf8').split('\n')
  // 先頭列が approve。空欄の行だけを ○ にする（既に判断がある行は触らない）
  writeFileSync(p, lines.map((l, i) => (i > 0 && l.startsWith(',') ? '○' + l : l)).join('\n'))
  return dir
}

describe('Supabase 用の SQL', () => {
  it('リポジトリに入っている SQL が CSV と揃っている', () => {
    // ずれていたら npx tsx scripts/db/dump-sql.ts で作り直す
    expect(readFileSync(SEED_SQL_PATH, 'utf8')).toBe(buildSeedSql().sql)
  })

  it('承認済みの KC が全件入る', () => {
    const { sql, counts } = buildSeedSql()
    const rows = readCsv(`${SEED_DIR}/kc.csv`)
    const approved = rows.filter(r => r.approve === '○')
    expect(approved.length).toBeGreaterThan(0)
    expect(counts.kc).toBe(approved.length)
    for (const k of approved) {
      expect(sql, `承認済みの ${k.id} が含まれていない`).toContain(k.id!)
    }
  })

  /**
   * ★ 承認制そのものの検査は、実データではもう示せない。
   *   2026-09-02 に作者が408件すべてを承認したため、未承認の行が0件になった。
   *   実データで `filter(r => r.approve !== '○')` を回すと対象が空になり、
   *   ループの中が一度も走らない——承認制が壊れても気づけない試験になる。
   *   承認を落とした写しを作って、そちらで「除外されること」を確かめる。
   */
  it('承認欄が空の KC は含めない（作者承認制 docs/02 §5）', () => {
    const dir = mkdtempSync(join(tmpdir(), 'historia-dumpsql-'))
    cpSync(SEED_DIR, dir, { recursive: true })
    const lines = readFileSync(join(dir, 'kc.csv'), 'utf8').split('\n')
    // 先頭2件の承認を外す
    const dropped = [1, 2].map(i => {
      lines[i] = lines[i]!.replace(/^○,/, ',')
      return lines[i]!.split(',')[1]!
    })
    writeFileSync(join(dir, 'kc.csv'), lines.join('\n'))

    const { sql, counts } = buildSeedSql(dir)
    for (const id of dropped) {
      expect(sql, `未承認の ${id} が含まれている`).not.toContain(id)
    }
    expect(counts.skipped).toBe(2)
    // 残りは入っている（承認を外した2件だけが落ちる）
    expect(counts.kc).toBe(readCsv(`${SEED_DIR}/kc.csv`).filter(r => r.approve === '○').length - 2)
  })

  /**
   * ★ 共有設問が SQL に入らないと、貼っても1問も出題されない。
   *   KC と正典だけ入れて「今日やること」が空のままになる、という静かな失敗になる
   *   （実際 dump-sql.ts は長らく item を1行も出していなかった）。
   *   item.csv は起草中で承認欄が空なので、承認を入れた写しで確かめる。
   */
  it('承認済みの共有設問と item_kc が SQL に入る', () => {
    const dir = approvedItemsDir()
    const { sql, counts } = buildSeedSql(dir)
    const rows = readCsv(join(dir, 'item.csv'))
    expect(rows.length).toBeGreaterThan(0)
    expect(counts.item).toBe(rows.length)
    expect(sql).toContain('INSERT INTO item (')
    expect(sql).toContain('INSERT INTO item_kc (')
    // 設問文がそのまま入っていること（本文が落ちると空の設問が配信される）
    expect(sql).toContain(rows[0]!.stem!)
  })

  it('承認欄が空の共有設問は含めない（作者承認制 docs/02 §5）', () => {
    // 実データ（起草中＝全件空欄）をそのまま使う
    const { sql, counts } = buildSeedSql()
    expect(counts.item).toBe(0)
    expect(sql).not.toContain('INSERT INTO item (')
  })

  it('単引用符を含む文字列を壊さない', () => {
    const { sql } = buildSeedSql()
    // 生成器は '' でエスケープする。閉じられていない引用符が無いことを見る
    for (const line of sql.split('\n')) {
      const quotes = (line.match(/'/g) ?? []).length
      expect(quotes % 2, `引用符が閉じていない: ${line.slice(0, 80)}`).toBe(0)
    }
  })

  it('トランザクションで囲まれている（途中で落ちても半端に入らない）', () => {
    const { sql } = buildSeedSql()
    expect(sql).toContain('BEGIN;')
    expect(sql.trimEnd().split('\n').filter(l => l === 'COMMIT;')).toHaveLength(1)
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('Supabase 用の SQL（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>

  beforeAll(async () => { ({ db, drop } = await createTestDb('historia_dumpsql_test')) }, 120_000)
  afterAll(async () => { await drop() })

  it('空のデータベースに流れ、tsx のローダーと同じ結果になる', async () => {
    const { sql, counts } = buildSeedSql()
    await applySeedSql(db, sql)

    const q = async (t: string) => {
      const r = await db<{ n: string }[]>`SELECT count(*) AS n FROM ${db(t)}`
      return Number(r[0]!.n)
    }
    expect(await q('era')).toBe(counts.era)
    expect(await q('region')).toBe(counts.region)
    expect(await q('syllabus_unit')).toBe(counts.syllabusUnit)
    expect(await q('kc')).toBe(counts.kc)
    expect(await q('kc_region')).toBe(counts.kcRegion)
    expect(await q('kc_syllabus_unit')).toBe(counts.kc)

    // ★ SQL とローダーが同じものを入れることを確かめる。
    //   ずれると「貼ったのに動かない」が起きる
    const before = await db<Record<string, unknown>[]>`SELECT * FROM kc ORDER BY id`
    const counts2 = await seedAll(db, SEED_DIR)
    expect(counts2.kc).toBe(counts.kc)
    const after = await db<Record<string, unknown>[]>`SELECT * FROM kc ORDER BY id`
    expect(after).toEqual(before)
  })

  /**
   * ★ choices が jsonb の**配列**として入ることを実DBで確かめる。
   *   JSON 文字列のまま入れると jsonb のスカラ文字列になり、
   *   出題の SQL（jsonb_array_elements）が
   *   「cannot get array length of a scalar」で落ちる。tsx のローダーで実際に踏んだ穴で、
   *   件数を数えるだけの試験では見つからない。
   */
  it('貼った SQL の設問が、出題の SQL でそのまま読める', async () => {
    const dir = approvedItemsDir()
    const { sql, counts } = buildSeedSql(dir)
    await applySeedSql(db, sql)

    const [n] = await db<{ n: string }[]>`SELECT count(*) AS n FROM item WHERE user_id IS NULL`
    expect(Number(n!.n)).toBe(counts.item)
    const [l] = await db<{ n: string }[]>`SELECT count(*) AS n FROM item_kc`
    expect(Number(l!.n)).toBe(counts.item)

    // app/study/page.tsx と同じ読み方をする
    const rows = await db<{ id: string; choices: { key: string; text: string }[] }[]>`
      SELECT i.id,
             (SELECT jsonb_agg(jsonb_build_object('key', c->>'key', 'text', c->>'text')
                               ORDER BY c->>'key')
                FROM jsonb_array_elements(i.choices) c) AS choices
        FROM item i
       WHERE i.user_id IS NULL AND i.approved AND NOT i.hidden
       LIMIT 5`
    expect(rows).toHaveLength(5)
    for (const r of rows) {
      expect(r.choices, `${r.id} の選択肢が配列になっていない`).toHaveLength(4)
      expect(r.choices.map(c => c.key)).toEqual(['a', 'b', 'c', 'd'])
      for (const c of r.choices) expect(c.text.length).toBeGreaterThan(0)
    }

    // 正答はサーバー側にだけある（docs/12 §6.1）。jsonb のスカラ文字列で入る
    const [k] = await db<{ key: string }[]>`
      SELECT answer_key #>> '{}' AS key FROM item WHERE user_id IS NULL LIMIT 1`
    expect(['a', 'b', 'c', 'd']).toContain(k!.key)
  }, 120_000)

  it('二度流しても件数が増えない', async () => {
    const { sql, counts } = buildSeedSql()
    await applySeedSql(db, sql)
    const [n] = await db<{ n: string }[]>`SELECT count(*) AS n FROM kc_region`
    expect(Number(n!.n)).toBe(counts.kcRegion)
  })
})
