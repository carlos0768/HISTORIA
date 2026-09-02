import { describe, it, expect } from 'vitest'
import { readFileSync } from 'node:fs'
import { applyApprovals, csvPath, APPROVABLE, KC_CSV } from './approve-kc'

const HEAD = 'approve,id,label,kind'
const L = (a: string, id: string) => `${a},${id},ラベル,fact`

describe('KC の承認欄を書き換える', () => {
  it('--all は未記入だけを ○ にする', () => {
    const r = applyApprovals([HEAD, L('', 'kc.a.b'), L('○', 'kc.c.d'), L('×', 'kc.e.f')], { all: true })
    expect(r.lines.slice(1).map(l => l[0])).toEqual(['○', '○', '×'])
    expect(r).toMatchObject({ approved: 1, kept: 2, rejected: 0 })
  })

  it('既に下した判断を上書きしない', () => {
    const r = applyApprovals([HEAD, L('×', 'kc.a.b')], { all: true })
    expect(r.lines[1]![0]).toBe('×')   // ○ に変えない
    expect(r.approved).toBe(0)
  })

  it('--except で挙げたものは空欄のまま残す', () => {
    const r = applyApprovals([HEAD, L('', 'kc.a.b'), L('', 'kc.c.d')],
      { all: true, except: new Set(['kc.c.d']) })
    expect(r.lines.slice(1).map(l => l[0])).toEqual(['○', ','])
  })

  it('--ids は挙げたものだけを ○ にする', () => {
    const r = applyApprovals([HEAD, L('', 'kc.a.b'), L('', 'kc.c.d')],
      { ids: new Set(['kc.a.b']) })
    expect(r.lines.slice(1).map(l => l[0])).toEqual(['○', ','])
  })

  it('--reject は ○ が入っていても × にする（判断のやり直し）', () => {
    const r = applyApprovals([HEAD, L('○', 'kc.a.b')], { reject: new Set(['kc.a.b']) })
    expect(r.lines[1]![0]).toBe('×')
    expect(r.rejected).toBe(1)
  })

  /** 打ち間違いを黙って無視すると「承認したつもり」が起きる */
  it('存在しない id を挙げたら missing に入る', () => {
    const r = applyApprovals([HEAD, L('', 'kc.a.b')], { ids: new Set(['kc.typo.x']) })
    expect(r.missing).toEqual(['kc.typo.x'])
  })

  it('approve 以外の列を1文字も変えない', () => {
    const line = L('', 'kc.a.b') + ',"引用符, を含む",note'
    const r = applyApprovals([HEAD, line], { all: true })
    expect(r.lines[1]).toBe('○' + line.slice(line.indexOf(',')))
  })

  it('空行と見出し行を壊さない', () => {
    const r = applyApprovals([HEAD, L('', 'kc.a.b'), ''], { all: true })
    expect(r.lines[0]).toBe(HEAD)
    expect(r.lines[2]).toBe('')
  })

  it('実データに対して流しても行数が変わらない', () => {
    const lines = readFileSync(KC_CSV, 'utf8').split('\n')
    const r = applyApprovals(lines, { all: true })
    expect(r.lines).toHaveLength(lines.length)
    expect(r.approved + r.kept).toBe(lines.filter((l, i) => i > 0 && l.trim() !== '').length)
  })

  // ★ 承認できる CSV が増えたとき、その1つを足し忘れると
  //   「承認したつもりで DB に何も入らない」という静かな失敗になる。
  //   item.csv を足したとき実際にこれが起きかけた（seedItem は approve が ○ の行しか読まない）。
  it('承認できる CSV は先頭2列が approve,id である', () => {
    for (const name of APPROVABLE) {
      const head = readFileSync(csvPath(name), 'utf8').split('\n')[0]!
      expect(head.startsWith('approve,id,'), `${name}.csv の見出し: ${head}`).toBe(true)
    }
  })

  it('item.csv も同じ道具で承認できる（設問だけ別扱いにしない）', () => {
    expect(APPROVABLE).toContain('item')
    const lines = readFileSync(csvPath('item'), 'utf8').split('\n')
    const r = applyApprovals(lines, { all: true })
    expect(r.lines).toHaveLength(lines.length)
    expect(r.approved + r.kept).toBe(lines.filter((l, i) => i > 0 && l.trim() !== '').length)
  })
})
