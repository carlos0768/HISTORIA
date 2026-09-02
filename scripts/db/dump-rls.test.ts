import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { buildRlsSql, RLS_SQL_PATH, rlsTables, policyStatements } from './dump-rls'
import { SCHEMA_PATH } from './schema'

const schema = readFileSync(SCHEMA_PATH, 'utf8')

describe('RLS の差分 SQL', () => {
  it('リポジトリに入っている SQL が docs/schema.sql と揃っている', () => {
    // ずれていたら npx tsx scripts/db/dump-rls.ts で作り直す
    expect(readFileSync(RLS_SQL_PATH, 'utf8')).toBe(buildRlsSql())
  })

  /**
   * ★ これが今回いちばん効く試験である。
   *   Supabase は public に作った表へ anon / authenticated の ALL を既定で付ける。
   *   だから「RLS を掛け忘れた表」は素通りではなく、誰でも書き換えられる穴になる。
   *   2026-09-02 に本番で 19 表がこの状態だった。表を1つ足して RLS を書き忘れると
   *   同じことが起きるので、機械で数える。
   */
  it('public の全ての表で RLS を有効にしている（1つの例外も許さない）', () => {
    const created = [...schema.matchAll(/^CREATE TABLE (\w+) \(/gm)].map(m => m[1]!)
    const guarded = new Set(rlsTables(schema))
    const naked = created.filter(t => !guarded.has(t))
    expect(naked, `RLS を有効にしていない表がある: ${naked.join(', ')}`).toEqual([])
    expect(created.length).toBeGreaterThan(40)
  })

  it('ポリシーは全て TO authenticated（anon に素通りさせない）', () => {
    const bad = policyStatements(schema)
      .filter(p => !/\bTO authenticated\b/.test(p.sql))
      .map(p => p.name)
    expect(bad, `PUBLIC 向けのポリシーがある: ${bad.join(', ')}`).toEqual([])
  })

  it('response を読むビューは security_invoker である（RLS の素通りを防ぐ）', () => {
    // 既定は「定義者の権限で実行」。付け忘れると anon キーで全員の解答履歴が読める
    expect(schema).toMatch(/CREATE VIEW v_weakness_evidence WITH \(security_invoker = true\)/)
  })

  it('絶対に読ませない表にはポリシーを書かない', () => {
    // invite_code が読めれば招待制が崩れ、past_exam が読めれば本文が外に出る
    const withPolicy = new Set(policyStatements(schema).map(p => p.table))
    for (const t of ['invite_code', 'past_exam', 'past_exam_element', 'past_exam_kc',
                     'item', 'item_kc', 'ai_budget', 'ai_spend', 'app_setting', 'ops_log',
                     'kc_proposal', 'kc_merge', 'channel_allowlist']) {
      expect(withPolicy.has(t), `${t} にポリシーが増えている`).toBe(false)
    }
  })

  it('何度当てても同じになる書き方（DROP IF EXISTS → CREATE）', () => {
    const sql = buildRlsSql()
    for (const p of policyStatements(schema)) {
      expect(sql).toContain(`DROP POLICY IF EXISTS ${p.name} ON ${p.table};`)
    }
  })
})
