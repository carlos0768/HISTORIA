import { describe, it, expect } from 'vitest'
import { existsSync, readFileSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { TABS } from './ui'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..')

/**
 * モバイルフッタのタブ。
 *
 * ★ 行き止まりのタブを出さない。タブを押して 404 が返ると、
 *   利用者は「壊れている」と判断してアプリごと使うのをやめる。
 *   タブを増やすときに画面を作り忘れたら、ここで落ちる。
 */
describe('タブの行き先', () => {
  it('検索を含む4つ', () => {
    expect(TABS.map(t => t.label)).toEqual(['ホーム', '特訓', '教科書', '検索'])
  })

  it.each(TABS.map(t => [t.label, t.href]))('%s（%s）の画面が実在する', (_label, href) => {
    const rel = href === '/' ? 'page.tsx' : `${href.slice(1)}/page.tsx`
    expect(existsSync(join(ROOT, 'app', rel))).toBe(true)
  })

  it('行き先が重複していない', () => {
    expect(new Set(TABS.map(t => t.href)).size).toBe(TABS.length)
  })

  /** 設定は主要タブにせず、デスクトップのサイドバーから入る。 */
  it('設定はタブではないが、画面は実在する', () => {
    expect(TABS.map(t => t.href)).not.toContain('/settings')
    expect(existsSync(join(ROOT, 'app', 'settings/page.tsx'))).toBe(true)
  })
})

describe('ホームから特訓を始める導線', () => {
  const home = join(ROOT, 'app', 'page.tsx')
  const source = () => readFileSync(home, 'utf8')

  it('ホームにはチャプター一覧と今日の内訳を展開しない', () => {
    const text = source()
    expect(text).not.toContain('<UnitMaterials')
    expect(text).not.toContain('今日の内訳')
  })

  it('勉強するボタンと4種類の学習画面がある', () => {
    const text = source()
    expect(text).toContain('勉強する')
    for (const segment of ['', 'read', 'flashcards', 'quiz', 'map']) {
      const parts = ['app', 'drills', '[drillId]', ...(segment ? [segment] : []), 'page.tsx']
      expect(existsSync(join(ROOT, ...parts))).toBe(true)
    }
  })
})

describe('教科書', () => {
  it('記録ページを置かず、章ごとの文章一覧だけを置く', () => {
    expect(existsSync(join(ROOT, 'app', 'records/page.tsx'))).toBe(false)
    const textbook = readFileSync(join(ROOT, 'app', 'textbook/page.tsx'), 'utf8')
    expect(textbook).toContain('chapters.map')
    expect(textbook).toContain('chapter.articles.map')
    expect(textbook).not.toContain('<Card')
  })
})
