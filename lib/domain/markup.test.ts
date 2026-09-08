import { describe, expect, it } from 'vitest'
import { MAX_IMPORTANT_CHARS, bodyTextLength, importantMarkProblems, stripImportant } from './markup'

describe('重要箇所のマーク ==語句==', () => {
  it('記号だけを落とし、語句は残す', () => {
    expect(stripImportant('二足歩行が==先==で、脳は==後==です')).toBe('二足歩行が先で、脳は後です')
  })
  it('空・改行またぎ・=== は解釈しない（そのまま残る）', () => {
    expect(stripImportant('====')).toBe('====')
    expect(stripImportant('==あ\nい==')).toBe('==あ\nい==')
    expect(stripImportant('===あ===')).toBe('=あ=')
  })
  it('字数はマークの記号を除いて数える。** はこれまでどおり数える', () => {
    expect(bodyTextLength('==重要==')).toBe(2)
    expect(bodyTextLength('**強調**')).toBe(6)
    expect(bodyTextLength('あ'.repeat(250) + '==い==')).toBe(251)
  })
  it('文・句は長さで落とす（囲むのは単語である）', () => {
    expect(importantMarkProblems('==ウェストファリア条約==')).toEqual([])
    expect(importantMarkProblems(`==${'あ'.repeat(MAX_IMPORTANT_CHARS + 1)}==`))
      .toContainEqual(expect.stringContaining('単語ではなく文・句'))
  })
  it('付け方の誤りを列挙する', () => {
    expect(importantMarkProblems('==正しい==と**強調**')).toEqual([])
    expect(importantMarkProblems('==閉じていない')).toHaveLength(1)
    expect(importantMarkProblems('==あ==、===い===')).toContainEqual(expect.stringContaining('==='))
    expect(importantMarkProblems('**太字の==中==**')).toContainEqual(expect.stringContaining('交差'))
    expect(importantMarkProblems('==開いて**閉じ==る**')).toContainEqual(expect.stringContaining('交差'))
  })
})
