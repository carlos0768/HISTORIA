import { describe, it, expect } from 'vitest'
import { existsSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { TABS } from './ui'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..')

/**
 * フッタの3タブ（docs/11-ux.md §9）
 *
 * ★ 行き止まりのタブを出さない。タブを押して 404 が返ると、
 *   利用者は「壊れている」と判断してアプリごと使うのをやめる。
 *   タブを増やすときに画面を作り忘れたら、ここで落ちる。
 */
describe('タブの行き先', () => {
  it('docs/11 §9 のとおり3つ', () => {
    expect(TABS.map(t => t.label)).toEqual(['ホーム', '特訓', '記録'])
  })

  it.each(TABS.map(t => [t.label, t.href]))('%s（%s）の画面が実在する', (_label, href) => {
    const rel = href === '/' ? 'page.tsx' : `${href.slice(1)}/page.tsx`
    expect(existsSync(join(ROOT, 'app', rel))).toBe(true)
  })

  it('行き先が重複していない', () => {
    expect(new Set(TABS.map(t => t.href)).size).toBe(TABS.length)
  })

  /**
   * ★ 設定をタブに足さない。docs/11 §9 は3タブと定めている。
   *   足すとモバイルのフッタが4つになり、意匠の前提（1つあたりの幅）が崩れる。
   *   デスクトップのサイドバーと記録タブの末尾から入る。
   */
  it('設定はタブではないが、画面は実在する', () => {
    expect(TABS.map(t => t.href)).not.toContain('/settings')
    expect(existsSync(join(ROOT, 'app', 'settings/page.tsx'))).toBe(true)
  })
})
