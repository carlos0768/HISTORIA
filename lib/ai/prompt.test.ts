import { describe, it, expect } from 'vitest'
import {
  renderMaterialPrompt, loadPrompt, parsePromptFile,
  MATERIAL_PROMPT_VERSION, type UnitFacts,
} from './prompt'
import type { AnonymizedContext } from './types'

const facts: UnitFacts = {
  unitLabel: '古代オリエント世界',
  subject: 'world_history',
  parentLabels: ['諸地域の歴史的特質の形成', '古代オリエントと地中海世界'],
  eraLabel: '前近代（〜1500年）',
  yearFrom: -3000,
  yearTo: -330,
  regionLabels: ['メソポタミア・イラン', 'エジプト・北アフリカ'],
}

const ctx: AnonymizedContext = {
  unitId: 'wh.2.1.1',
  unitLabel: '古代オリエント世界',
  weakKcs: [
    { kcId: 'kc.orient.egypt_kingdom_periods', label: 'エジプト3王国の区別', kind: 'distinction', band: 'low' },
    { kcId: 'kc.orient.hammurabi_code_principle', label: 'ハンムラビ法典', kind: 'fact', band: 'high' },
  ],
  targetCharCount: 3500,
}

describe('§5 プロンプトの版管理', () => {
  it('prompts/material_v1.md を読める', () => {
    const t = loadPrompt(MATERIAL_PROMPT_VERSION)
    expect(t.system.length).toBeGreaterThan(200)
    expect(t.user.length).toBeGreaterThan(500)
  })

  it('システムプロンプトに仕様の「絶対に守ること」が含まれる', () => {
    const { system } = loadPrompt()
    expect(system).toContain('事実の正確性を最優先する')
    expect(system).toContain('候補KCリストの id からのみ選ぶ')
    // 未成年向けフィルタとの衝突を避ける一文（docs/08 §9）
    expect(system).toContain('歴史的事実として中立に記述する')
  })

  it('ユーザープロンプトに7セクション構成と distractor の規則が含まれる', () => {
    const { user } = loadPrompt()
    expect(user).toContain('§4 同時代の他地域では何が起きていたか')
    expect(user).toContain('★必須。省略禁止')
    expect(user).toContain('【悪い distractor（禁止）】')
  })

  it('## SYSTEM / ## USER が無いファイルは落とす', () => {
    expect(() => parsePromptFile('ただの文章')).toThrow(/## SYSTEM/)
  })

  it('前書きの HTML コメントは本文に混ぜない', () => {
    const t = parsePromptFile('<!-- メモ -->\n## SYSTEM\nS\n## USER\nU')
    expect(t.system).toBe('S')
    expect(t.user).toBe('U')
    expect(t.system).not.toContain('メモ')
  })
})

describe('§5.2 差し込み', () => {
  const r = renderMaterialPrompt(ctx, facts)

  it('未置換の {{...}} が残らない', () => {
    expect(r.user).not.toMatch(/\{\{/)
    expect(r.system).not.toMatch(/\{\{/)
  })

  it('単元・時代・地域が入る', () => {
    expect(r.user).toContain('古代オリエント世界')
    expect(r.user).toContain('世界史探究')
    expect(r.user).toContain('前近代（〜1500年）')
    expect(r.user).toContain('メソポタミア・イラン・エジプト・北アフリカ')
    expect(r.user).toContain('-3000')
  })

  it('候補KCが1行ずつ展開される', () => {
    expect(r.user).toContain('kc.orient.egypt_kingdom_periods | distinction | エジプト3王国の区別')
    expect(r.user).toContain('kc.orient.hammurabi_code_principle | fact | ハンムラビ法典')
    expect(r.user).not.toContain('{{#each')
    expect(r.user).not.toContain('{{/each}}')
  })

  it('弱い KC ほど exam_weight が高く出る（弱点に寄せて書かせる）', () => {
    const weak = r.user.match(/egypt_kingdom_periods.*exam_weight=([\d.]+)/)![1]
    const strong = r.user.match(/hammurabi_code_principle.*exam_weight=([\d.]+)/)![1]
    expect(Number(weak)).toBeGreaterThan(Number(strong))
  })

  it('prompt_version を返す（material.prompt_version に記録する）', () => {
    expect(r.promptVersion).toBe('material_v2')
  })

  it('親単元が無くても落ちない', () => {
    const r2 = renderMaterialPrompt(ctx, { ...facts, parentLabels: [], regionLabels: [], yearFrom: null, yearTo: null })
    expect(r2.user).toContain('（なし）')
    expect(r2.user).toContain('不明')
    expect(r2.user).not.toMatch(/\{\{/)
  })

  it('候補KCが空でも {{#each}} が残らない', () => {
    const r3 = renderMaterialPrompt({ ...ctx, weakKcs: [] }, facts)
    expect(r3.user).not.toMatch(/\{\{/)
  })
})

describe('§4 個人識別情報がプロンプトに載らない', () => {
  it('UUID が混ざったら組み立ての時点で落とす', () => {
    const bad = { ...ctx, unitLabel: 'x 550e8400-e29b-41d4-a716-446655440000' }
    expect(() => renderMaterialPrompt(bad, { ...facts, unitLabel: bad.unitLabel })).toThrow(/UUID/)
  })

  it('禁止キーを持つ文脈は渡せない', () => {
    const bad = { ...ctx, userId: 'x' } as unknown as AnonymizedContext
    expect(() => renderMaterialPrompt(bad, facts)).toThrow(/個人識別情報/)
  })

  it('生の習得度は本文に出ない（帯に丸めてから重みにする）', () => {
    const r4 = renderMaterialPrompt(ctx, facts)
    expect(r4.user).not.toContain('p_know')
    expect(r4.user).not.toContain('low')
    expect(r4.user).not.toContain('high')
  })
})
