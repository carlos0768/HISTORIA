import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'

/**
 * 招待コードを発行する道具が、在る列だけを名指ししていること
 *
 * ★ なぜ要るのか。2026-09-03、作者が本番でコードを発行したところ
 *   発行そのものは通ったのに、そのあとの一覧で
 *   `column "issued_at" does not exist` で落ちた。`issued_by` と
 *   取り違えており、**`--issue` の無い「一覧だけ」は最初から一度も
 *   通っていなかった。**
 *
 * ★ この道具は実 DB が要るので、単体では走らせられない。
 *   代わりに「書いてある列が docs/schema.sql に在るか」を見る。
 *   取り違えはここで全部捕まる。
 *
 * ★ 道具そのものは import しない。issue-invite.ts は読み込んだ瞬間に
 *   DATABASE_URL を見て process.exit(1) する形なので、import すると
 *   試験の側が終わる。字面で見る。
 */

const SCHEMA = readFileSync('docs/schema.sql', 'utf8')

/** docs/schema.sql から1つの表の列名を読む */
function columnsOf(table: string): string[] {
  const m = SCHEMA.match(new RegExp(`CREATE TABLE ${table} \\(([\\s\\S]*?)\\n\\);`))
  if (!m) throw new Error(`docs/schema.sql に ${table} が無い`)
  return m[1]!.split('\n')
    .map(l => l.trim())
    .filter(l => l && !l.startsWith('--'))
    // 列の行だけ。制約（PRIMARY KEY (...) / CHECK (...) など）は落とす
    .filter(l => /^[a-z_]+\s/.test(l) && !/^(primary|foreign|unique|check|constraint)\b/i.test(l))
    .map(l => l.split(/\s/)[0]!)
}

describe('scripts/db/issue-invite.ts', () => {
  const src = readFileSync('scripts/db/issue-invite.ts', 'utf8')
  const cols = columnsOf('invite_code')

  it('前提: docs/schema.sql の invite_code に issued_at は無い', () => {
    expect(cols).toEqual(['code', 'issued_by', 'used_by', 'used_at', 'expires_at', 'created_at'])
    expect(cols).not.toContain('issued_at')
  })

  it('SQL が名指しする invite_code の列が全部実在する', () => {
    // ★ 文ごとに切る。SELECT から貪欲に拾うと、前に在る
    //   `SELECT to_regclass('public.invite_code') ...`（別の文）から
    //   ここまでを1つとみなしてしまう。SQL は全てテンプレートリテラルに
    //   入っているので、そこで区切る
    const stmts = src.split('`').filter((_, i) => i % 2 === 1)
      .filter(q => q.includes('FROM invite_code'))
    expect(stmts.length, 'invite_code を読む文が1つも無い').toBeGreaterThan(0)

    const known = new Set([...cols, 'SELECT', 'FROM', 'ORDER', 'BY', 'WHERE', 'AND', 'IS',
                           'NULL', 'AS', 'count', 'invite_code'])
    for (const stmt of stmts) {
      for (const id of stmt.match(/[a-zA-Z_][a-zA-Z0-9_]*/g) ?? []) {
        expect(known.has(id), `${id} は invite_code に無い列である`).toBe(true)
      }
    }
  })

  it('issued_at を書いていない（取り違えの再発防止）', () => {
    // ★ 逆対照。created_at を issued_at に戻すと落ちる
    expect(src.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, ''))
      .not.toContain('issued_at')
  })
})
