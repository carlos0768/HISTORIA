import { describe, it, expect } from 'vitest'
import { isFake } from './fake-warning'
import { createFakeProvider } from '@/lib/ai/fake'
import { createClient, type AiConfig } from '@/lib/ai/client'

/**
 * 「鍵が無いまま作った偽の教材」を見分けられることの試験。
 *
 * ★ ここが破れると、受験生が**でたらめを覚えて、気づかない**。
 *   このアプリで最悪の壊れ方なので、実行時の設定と保存された記録の両方を見る。
 */

const cfg = (o: Partial<AiConfig> = {}): AiConfig => ({
  genProvider: 'gemini', genModel: 'gemini-3.6-flash',
  verifyProvider: 'anthropic', verifyModel: 'claude-sonnet-5',
  embedModel: 'gemini-embedding-001',
  ...o,
})

describe('偽物の見分け', () => {
  it('フェイクのプロバイダは fake: を名乗る', () => {
    expect(createFakeProvider('gemini').name).toBe('fake:gemini')
    expect(createFakeProvider('anthropic').name).toBe('fake:anthropic')
  })

  /**
   * ★ 記録に残る名前が「使いたかったもの」ではなく「実際に使われたもの」であること。
   *   config.genProvider を記録すると、鍵が無くても 'gemini' と書かれてしまい、
   *   後から偽物だと分からなくなる。
   */
  it('鍵が無いとき、記録される名前が fake: になる', () => {
    const c = createClient(cfg())
    expect(c.usingFake).toBe(true)
    expect(c.genProviderName).toBe('fake:gemini')
    expect(c.verifyProviderName).toBe('fake:anthropic')
  })

  it('鍵があれば本物の名前になる', () => {
    const c = createClient(cfg({ geminiApiKey: 'g', anthropicApiKey: 'a' }))
    expect(c.usingFake).toBe(false)
    expect(c.genProviderName).toBe('gemini')
    expect(c.verifyProviderName).toBe('anthropic')
  })

  /** ★ 片方だけでも偽物が混ざる。検証が偽なら「確認済み」が嘘になる */
  it('片方の鍵しか無ければ、その片方だけが偽物になる', () => {
    const c = createClient(cfg({ geminiApiKey: 'g' }))
    expect(c.usingFake).toBe(true)
    expect(c.genProviderName).toBe('gemini')
    expect(c.verifyProviderName).toBe('fake:anthropic')
  })

  it('isFake は fake: で始まる記録だけを偽物と言う', () => {
    expect(isFake('fake:gemini')).toBe(true)
    expect(isFake('gemini')).toBe(false)
    expect(isFake(null)).toBe(false)
    expect(isFake(undefined)).toBe(false)
    // ★ 部分一致で拾わない。'my-fake-provider' は偽物ではない
    expect(isFake('my-fake-provider')).toBe(false)
  })
})
