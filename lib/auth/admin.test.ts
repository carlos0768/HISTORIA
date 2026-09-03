import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { readFileSync } from 'node:fs'
import { adminUserId, isAdmin } from './admin'

/**
 * 管理者の判定（docs/12 §7.1）
 *
 * ★ ここで守りたいのは「**開いてはいけない人に開かない**」ことだけである。
 *   環境変数の取り違えや、null 同士の比較で通ってしまう書き方を潰す。
 */

const ADMIN = '11111111-1111-4111-8111-111111111111'
const OTHER = '22222222-2222-4222-8222-222222222222'

let saved: string | undefined
beforeEach(() => { saved = process.env.ADMIN_USER_ID; delete process.env.ADMIN_USER_ID })
afterEach(() => {
  if (saved === undefined) delete process.env.ADMIN_USER_ID
  else process.env.ADMIN_USER_ID = saved
})

describe('管理者の判定', () => {
  it('一致すれば管理者', () => {
    process.env.ADMIN_USER_ID = ADMIN
    expect(isAdmin(ADMIN)).toBe(true)
  })

  it('別人は管理者ではない', () => {
    process.env.ADMIN_USER_ID = ADMIN
    expect(isAdmin(OTHER)).toBe(false)
  })

  /** ★ 既定は閉。入れ忘れた本番で誰かが開けてしまう、を防ぐ */
  it('未設定なら誰も管理者ではない', () => {
    expect(adminUserId()).toBeNull()
    expect(isAdmin(ADMIN)).toBe(false)
    expect(isAdmin(OTHER)).toBe(false)
  })

  /**
   * ★ null === null で通ってしまう書き方をしていないこと。
   *   未設定かつ未ログインは、最も起きやすい組み合わせである
   */
  it('未設定かつ未ログインでも通さない', () => {
    expect(isAdmin(null)).toBe(false)
  })

  it('設定済みでも未ログインなら通さない', () => {
    process.env.ADMIN_USER_ID = ADMIN
    expect(isAdmin(null)).toBe(false)
  })

  it('空白だけの設定は未設定と同じに扱う', () => {
    process.env.ADMIN_USER_ID = '   '
    expect(adminUserId()).toBeNull()
    expect(isAdmin('   ')).toBe(false)
  })

  it('前後の空白は落として比べる（貼りつけの事故を拾う）', () => {
    process.env.ADMIN_USER_ID = ` ${ADMIN} `
    expect(isAdmin(ADMIN)).toBe(true)
  })
})

describe('管理画面の関門', () => {
  const page = readFileSync('app/admin/page.tsx', 'utf8')

  /**
   * ★ リダイレクトではなく 404（docs/10 G2）。
   *   /login へ飛ばすと「管理画面が在る」ことを教えてしまう
   */
  it('一致しなければ notFound() を呼ぶ（redirect ではない）', () => {
    expect(page).toContain('notFound()')
    expect(page).not.toContain("redirect('/login')")
  })

  it('判定は lib/auth/admin.ts に任せている（画面で env を直接読まない）', () => {
    expect(page).toContain('isAdmin')
    expect(page).not.toContain('process.env.ADMIN_USER_ID')
  })

  /** タブに足すと components/nav.test.ts が落ちる。足していないこと */
  it('タブには足していない（TABS は components/ui.tsx）', () => {
    const ui = readFileSync('components/ui.tsx', 'utf8')
    const tabs = ui.slice(ui.indexOf('export const TABS'), ui.indexOf('export type TabKey'))
    expect(tabs).not.toContain('/admin')
  })
})
