import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { createAuthoredProvider, AuthoredMaterialError } from './authored'
import { createClient, type AiConfig } from './client'
import { TARGET_CHARS, type MaterialOutput } from './schema'

/**
 * 手で書いた教材を流し込むプロバイダ（docs/08 §5）
 *
 * ★ ここが守るのは1つだけ: **生成を差し替えても、検証は差し替わらないこと。**
 *   書いた側が確かめたらそれは自己検証で、層3が消える。消えても画面には何も出ない。
 */

/** スキーマを満たす最小の教材 */
function material(over: Partial<MaterialOutput> = {}): MaterialOutput {
  const per = Math.floor(TARGET_CHARS / 7)
  return {
    title: '手で書いた単元',
    sections: Array.from({ length: 7 }, (_, i) => ({
      ord: i + 1, heading: `§${i + 1}`,
      body_md: 'あ'.repeat(i === 6 ? TARGET_CHARS - per * 6 : per),
      kc_ids: ['kc.a.b'],
    })),
    flashcards: Array.from({ length: 10 }, (_, i) => ({
      front: `問${i}`, back: '答', kc_ids: ['kc.a.b'],
    })),
    mcqs: Array.from({ length: 6 }, (_, i) => ({
      stem: `設問${i}`,
      choices: (['a', 'b', 'c', 'd'] as const).map(k => ({
        key: k, text: k, why_wrong: k === 'a' ? '' : '同時代の別の事象と取り違えています',
      })),
      answer_key: 'a' as const, explanation: '解説', kc_ids: ['kc.a.b'],
    })),
    claims: Array.from({ length: 12 }, (_, i) => ({
      kind: (['year', 'person', 'event', 'causal', 'place'] as const)[i % 5]!,
      text: `検証できる主張${i + 1}`, section_ord: (i % 7) + 1,
    })),
    ...over,
  }
}

describe('手で書いた教材のプロバイダ', () => {
  let dir: string
  beforeAll(() => {
    dir = mkdtempSync(join(tmpdir(), 'historia-authored-'))
    writeFileSync(join(dir, 'wh.1.1.1.json'), JSON.stringify(material()))
    writeFileSync(join(dir, 'broken.json'), JSON.stringify({ title: 'これだけ' }))
    writeFileSync(join(dir, 'toomany.json'), JSON.stringify(material({
      flashcards: Array.from({ length: 20 }, (_, i) => ({
        front: `問${i}`, back: '答', kc_ids: ['kc.a.b'],
      })),
    })))
  })
  afterAll(() => { rmSync(dir, { recursive: true, force: true }) })

  const gen = (unitId: string) => createAuthoredProvider({ unitId, dir })

  it('ファイルを読んで教材として返す', async () => {
    const r = await gen('wh.1.1.1').generate<MaterialOutput>({
      prompt: { system: '', user: '', promptVersion: 'material_v2' },
      schema: {}, maxOutputTokens: 32000,
    })
    expect(r.value.sections).toHaveLength(7)
    expect(r.model).toBe('claude-code')
  })

  /**
   * ★ 0 を返す。API を呼んでいないのに数を入れると、ai_spend の元帳が
   *   実費と食い違う。遮断器は元帳しか見ないので、嘘は上限の意味を壊す
   */
  it('トークンは 0 で返す（元帳に嘘を積まない）', async () => {
    const r = await gen('wh.1.1.1').generate<MaterialOutput>({
      prompt: { system: '', user: '', promptVersion: 'material_v2' },
      schema: {}, maxOutputTokens: 32000,
    })
    expect(r.usage).toEqual({ inputTokens: 0, outputTokens: 0 })
  })

  it('実プロバイダと同じ検査を通す（件数超過は切り詰める）', async () => {
    const r = await gen('toomany').generate<MaterialOutput>({
      prompt: { system: '', user: '', promptVersion: 'material_v2' },
      schema: {}, maxOutputTokens: 32000,
    })
    expect(r.value.flashcards).toHaveLength(14)
  })

  it('スキーマに反するファイルは投げる', async () => {
    await expect(gen('broken').generate({
      prompt: { system: '', user: '', promptVersion: 'material_v2' },
      schema: {}, maxOutputTokens: 32000,
    })).rejects.toThrow(AuthoredMaterialError)
  })

  it('ファイルが無ければ投げる', async () => {
    await expect(gen('wh.9.9.9').generate({
      prompt: { system: '', user: '', promptVersion: 'material_v2' },
      schema: {}, maxOutputTokens: 32000,
    })).rejects.toThrow(AuthoredMaterialError)
  })

  /**
   * ★ **これがこのファイルの主題である。** 呼ばれたら、生成側が検証を担ったということ。
   *   そのとき層3は消えているが、教材は普通に配信される。だから型ではなく
   *   実行時にも落ちるようにしてある
   */
  it('検証を求められたら落ちる（自己検証への退化を止める）', async () => {
    await expect(gen('wh.1.1.1').verify([], 16000)).rejects.toThrow(/生成と検証を分けられていません/)
  })

  it('埋め込みも作らない', async () => {
    await expect(gen('wh.1.1.1').embed(['x'])).rejects.toThrow(AuthoredMaterialError)
  })
})

describe('生成プロバイダの差し替え（createClient の overrides）', () => {
  const base: AiConfig = {
    genProvider: 'anthropic', genModel: 'claude-code',
    verifyProvider: 'gemini', verifyModel: 'gemini-3.6-flash',
    embedModel: 'gemini-embedding-001',
  }
  const authored = createAuthoredProvider({ unitId: 'wh.1.1.1' })

  it('生成だけが差し替わる。検証はフェイクのまま（鍵が無いので）', () => {
    const ai = createClient(base, {}, { gen: authored })
    expect(ai.genProviderName).toBe('authored')
    expect(ai.verifyProviderName).toBe('fake:gemini')
  })

  /**
   * ★ 埋め込みの候補から外す。GEN_PROVIDER=gemini のときだけ実行時に落ちる、
   *   という設定次第の壊れ方をここで止める
   */
  it('差し替えた生成側へ埋め込みを回さない（GEN_PROVIDER=gemini でも）', () => {
    const cfg: AiConfig = { ...base, genProvider: 'gemini', genModel: 'gemini-3.6-flash',
                            verifyProvider: 'anthropic', verifyModel: 'claude-opus-5' }
    const ai = createClient(cfg, {}, { gen: authored })
    expect(ai.genProviderName).toBe('authored')
    expect(ai.embedProviderName).not.toBe('authored')
  })

  it('検証側は差し替えられない（overrides に口が無い）', () => {
    // 型の上で verify を差し替える手段が無いことを、契約として書き留める
    const ai = createClient(base, {}, { gen: authored })
    expect(ai.verifyProviderName).not.toBe('authored')
  })
})
