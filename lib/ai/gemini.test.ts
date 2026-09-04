import { describe, it, expect, vi } from 'vitest'
import { createGeminiProvider, GeminiBlockedError, SchemaViolationError, EMBED_DIMENSIONS } from './gemini'
import { materialJsonSchema, toGeminiSchema, verdictJsonSchema, MaterialOutput, bodyCharCount, isCharCountOutOfRange } from './schema'
import type { Claim } from './types'
import { fetchWithRetry, RateLimitedError, ProviderHttpError, BACKOFF_MS } from './http'

/** docs/07 §5.3 を満たす最小の教材 */
function validMaterial() {
  return {
    title: '古代オリエント世界',
    sections: Array.from({ length: 7 }, (_, i) => ({
      ord: i + 1, heading: `見出し${i + 1}`, body_md: 'あ'.repeat(500), kc_ids: ['kc.a.b'],
    })),
    flashcards: Array.from({ length: 10 }, (_, i) => ({
      front: `問${i}`, back: '答', kc_ids: ['kc.a.b'],
    })),
    mcqs: Array.from({ length: 6 }, (_, i) => ({
      stem: `設問${i}`,
      choices: (['a', 'b', 'c', 'd'] as const).map(k => ({ key: k, text: k, why_wrong: k === 'a' ? '' : '誤り' })),
      answer_key: 'a' as const, explanation: '解説', kc_ids: ['kc.a.b'],
    })),
    // claims はスキーマ下限（6件）を満たす必要がある。
    // 空や少数を許すと層2・層3 が素通りするため、契約として下限を持たせてある
    claims: Array.from({ length: 12 }, (_, i) => ({
      kind: (['year', 'person', 'event', 'causal', 'place'] as const)[i % 5]!,
      text: `検証できる主張${i + 1}`,
      section_ord: (i % 7) + 1,
    })),
  }
}

const geminiOk = (payload: unknown, usage = { promptTokenCount: 500, candidatesTokenCount: 9000 }) =>
  new Response(JSON.stringify({
    candidates: [{ content: { parts: [{ text: JSON.stringify(payload) }] }, finishReason: 'STOP' }],
    usageMetadata: usage,
  }), { status: 200 })

const prompt = { system: 'SYS', user: 'USER', promptVersion: 'material_v1' }

describe('§7 リトライ', () => {
  const sleep = vi.fn(async (_ms: number) => {})

  it('429 は指数バックオフ 2s/4s/8s で3回まで', async () => {
    sleep.mockClear()
    const f = vi.fn(async () => new Response('rate', { status: 429 }))
    await expect(
      fetchWithRetry('https://x', {}, { provider: 'gemini', fetchImpl: f as unknown as typeof fetch, sleep }),
    ).rejects.toBeInstanceOf(RateLimitedError)
    expect(f).toHaveBeenCalledTimes(3)
    // 最後の試行の後には待たない
    expect(sleep.mock.calls.map(c => c[0])).toEqual([BACKOFF_MS[0], BACKOFF_MS[1]])
  })

  it('5xx も再試行する', async () => {
    const f = vi.fn(async () => new Response('boom', { status: 503 }))
    await expect(
      fetchWithRetry('https://x', {}, { provider: 'gemini', fetchImpl: f as unknown as typeof fetch, sleep }),
    ).rejects.toBeInstanceOf(ProviderHttpError)
    expect(f).toHaveBeenCalledTimes(3)
  })

  it('4xx は再試行しない（同じ 400 が返るだけで無料枠を捨てる）', async () => {
    const f = vi.fn(async () => new Response('bad schema', { status: 400 }))
    await expect(
      fetchWithRetry('https://x', {}, { provider: 'gemini', fetchImpl: f as unknown as typeof fetch, sleep }),
    ).rejects.toBeInstanceOf(ProviderHttpError)
    expect(f).toHaveBeenCalledTimes(1)
  })

  it('途中で成功したらそこで止まる', async () => {
    let n = 0
    const f = vi.fn(async () => (++n < 2 ? new Response('r', { status: 429 }) : new Response('{}', { status: 200 })))
    const res = await fetchWithRetry('https://x', {}, { provider: 'gemini', fetchImpl: f as unknown as typeof fetch, sleep })
    expect(res.ok).toBe(true)
    expect(f).toHaveBeenCalledTimes(2)
  })
})

describe('§1.1 リクエストの形', () => {
  it('AI Studio 系のエンドポイントを叩く（Vertex AI を経由しない）', async () => {
    let url = ''
    const f = vi.fn(async (u: string) => { url = u; return geminiOk(validMaterial()) })
    const p = createGeminiProvider({
      apiKey: 'K', model: 'gemini-3.6-flash', embedModel: 'gemini-embedding-001',
      fetchImpl: f as unknown as typeof fetch,
    })
    await p.generate({ prompt, schema: materialJsonSchema(), maxOutputTokens: 12_000 })
    expect(url).toContain('generativelanguage.googleapis.com')
    expect(url).not.toContain('aiplatform.googleapis.com')
    expect(url).toContain('/models/gemini-3.6-flash:generateContent')
  })

  it('鍵はヘッダで送る（URL に載せない）', async () => {
    let url = ''
    let headers: Record<string, string> = {}
    const f = vi.fn(async (u: string, init: RequestInit) => {
      url = u; headers = init.headers as Record<string, string>
      return geminiOk(validMaterial())
    })
    const p = createGeminiProvider({
      apiKey: 'SECRET', model: 'm', embedModel: 'e', fetchImpl: f as unknown as typeof fetch,
    })
    await p.generate({ prompt, schema: materialJsonSchema(), maxOutputTokens: 100 })
    expect(headers['x-goog-api-key']).toBe('SECRET')
    expect(url).not.toContain('SECRET')
  })

  it('responseSchema と maxOutputTokens を必ず送る', async () => {
    let body: Record<string, unknown> = {}
    const f = vi.fn(async (_u: string, init: RequestInit) => {
      body = JSON.parse(init.body as string); return geminiOk(validMaterial())
    })
    const p = createGeminiProvider({ apiKey: 'K', model: 'm', embedModel: 'e', fetchImpl: f as unknown as typeof fetch })
    await p.generate({ prompt, schema: materialJsonSchema(), maxOutputTokens: 12_345 })
    const cfg = body.generationConfig as Record<string, unknown>
    expect(cfg.responseMimeType).toBe('application/json')
    expect(cfg.responseSchema).toBeTruthy()
    expect(cfg.maxOutputTokens).toBe(12_345)
    expect(body.systemInstruction).toEqual({ parts: [{ text: 'SYS' }] })
  })
})

describe('スキーマの変換', () => {
  const g = toGeminiSchema(materialJsonSchema()) as Record<string, unknown>

  it('OpenAPI 3.0 の部分集合に無いキーワードを落とす', () => {
    const s = JSON.stringify(g)
    expect(s).not.toContain('additionalProperties')
    expect(s).not.toContain('$schema')
  })
  it('通ることが分かっているキーワードは残す', () => {
    const s = JSON.stringify(g)
    expect(s).toContain('"required"')
    expect(s).toContain('"minItems"')
    expect(s).toContain('"maxLength"')
    expect(s).toContain('"enum"')
  })
  it('propertyOrdering を足す（順序が揺れると出力品質が落ちる）', () => {
    expect(Array.isArray(g.propertyOrdering)).toBe(true)
    expect(g.propertyOrdering).toContain('sections')
  })
})

describe('応答の検証 — モデルがスキーマを守る保証は無い', () => {
  const mk = (payload: unknown) => {
    const f = vi.fn(async () => geminiOk(payload))
    return createGeminiProvider({ apiKey: 'K', model: 'm', embedModel: 'e', fetchImpl: f as unknown as typeof fetch })
  }

  it('セクションが7つ無ければ落とす', async () => {
    const bad = { ...validMaterial(), sections: validMaterial().sections.slice(0, 5) }
    await expect(mk(bad).generate({ prompt, schema: {}, maxOutputTokens: 100 }))
      .rejects.toBeInstanceOf(SchemaViolationError)
  })

  it('フラッシュカードの裏が30字を超えたら落とす', async () => {
    const m = validMaterial()
    m.flashcards[0]!.back = 'あ'.repeat(31)
    await expect(mk(m).generate({ prompt, schema: {}, maxOutputTokens: 100 }))
      .rejects.toBeInstanceOf(SchemaViolationError)
  })

  it('選択肢が4つ無ければ落とす', async () => {
    const m = validMaterial()
    m.mcqs[0]!.choices = m.mcqs[0]!.choices.slice(0, 3) as never
    await expect(mk(m).generate({ prompt, schema: {}, maxOutputTokens: 100 }))
      .rejects.toBeInstanceOf(SchemaViolationError)
  })

  it('JSON でなければ落とす', async () => {
    const f = vi.fn(async () => new Response(JSON.stringify({
      candidates: [{ content: { parts: [{ text: 'これは JSON ではない' }] }, finishReason: 'STOP' }],
    }), { status: 200 }))
    const p = createGeminiProvider({ apiKey: 'K', model: 'm', embedModel: 'e', fetchImpl: f as unknown as typeof fetch })
    await expect(p.generate({ prompt, schema: {}, maxOutputTokens: 100 }))
      .rejects.toBeInstanceOf(SchemaViolationError)
  })

  it('正しい教材は通り、usage を返す', async () => {
    const r = await mk(validMaterial()).generate({ prompt, schema: {}, maxOutputTokens: 100 })
    expect(r.usage).toEqual({ inputTokens: 500, outputTokens: 9000 })
    expect(MaterialOutput.safeParse(r.value).success).toBe(true)
  })
})

describe('§9 拒否と打ち切り', () => {
  it('promptFeedback.blockReason があれば拒否として落とす', async () => {
    const f = vi.fn(async () => new Response(JSON.stringify({ promptFeedback: { blockReason: 'SAFETY' } }), { status: 200 }))
    const p = createGeminiProvider({ apiKey: 'K', model: 'm', embedModel: 'e', fetchImpl: f as unknown as typeof fetch })
    await expect(p.generate({ prompt, schema: {}, maxOutputTokens: 100 }))
      .rejects.toBeInstanceOf(GeminiBlockedError)
  })

  it('MAX_TOKENS で切れた出力をパースしようとしない', async () => {
    const f = vi.fn(async () => new Response(JSON.stringify({
      candidates: [{ content: { parts: [{ text: '{"title":"途中で' }] }, finishReason: 'MAX_TOKENS' }],
    }), { status: 200 }))
    const p = createGeminiProvider({ apiKey: 'K', model: 'm', embedModel: 'e', fetchImpl: f as unknown as typeof fetch })
    await expect(p.generate({ prompt, schema: {}, maxOutputTokens: 100 }))
      .rejects.toThrow(/MAX_TOKENS/)
  })
})

describe('埋め込み', () => {
  it('次元を 768 に指定して送る（既定の 3072 は vector(768) に入らない）', async () => {
    let body: Record<string, unknown> = {}
    const f = vi.fn(async (_u: string, init: RequestInit) => {
      body = JSON.parse(init.body as string)
      return new Response(JSON.stringify({ embeddings: [{ values: [1] }, { values: [2] }] }), { status: 200 })
    })
    const p = createGeminiProvider({ apiKey: 'K', model: 'm', embedModel: 'e', fetchImpl: f as unknown as typeof fetch })
    await p.embed(['a', 'b'])
    const reqs = body.requests as Array<Record<string, unknown>>
    expect(reqs).toHaveLength(2)
    for (const r of reqs) expect(r.outputDimensionality).toBe(EMBED_DIMENSIONS)
  })

  it('件数が合わなければ落とす（黙って詰めない）', async () => {
    const f = vi.fn(async () => new Response(JSON.stringify({ embeddings: [{ values: [1, 2] }] }), { status: 200 }))
    const p = createGeminiProvider({ apiKey: 'K', model: 'm', embedModel: 'e', fetchImpl: f as unknown as typeof fetch })
    await expect(p.embed(['a', 'b'])).rejects.toThrow(/件数/)
  })
})

/**
 * ★ **役割の分離は、このファイルの仕事ではない。**
 *
 *   2026-09-04 まで、ここには「Gemini に検証はさせない」という試験があり、
 *   `verify()` が必ず例外を投げることを固定していた。向きが
 *   「生成 Claude / 検証 Gemini」へ入れ替わった瞬間、**製品が動かなくなった**
 *   （作者が実際に踏んだ: 「anthropic は生成に使わない設定です」）。
 *
 *   自己検証への退化を防ぐのは `client.ts` の `assertConfig` である。
 *   そちらに「生成と検証が同じプロバイダなら起動時に落とす」試験がある。
 *   **片方のプロバイダの口を塞いで防ぐのは、不変条件を間違った層に置いていた。**
 */
describe('§5 層3 検証', () => {
  const verdictOk = (verdicts: unknown, usage = { promptTokenCount: 1200, candidatesTokenCount: 400 }) =>
    new Response(JSON.stringify({
      candidates: [{ content: { parts: [{ text: JSON.stringify({ verdicts }) }] }, finishReason: 'STOP' }],
      usageMetadata: usage,
    }), { status: 200 })

  const claims: Claim[] = [
    { type: 'year', text: 'ウェストファリア条約は1648年' },
    { type: 'person', text: 'ハンムラビ法典を制定したのはハンムラビ王' },
  ]

  const provider = (fetchImpl: typeof fetch) =>
    createGeminiProvider({ apiKey: 'K', model: 'm', embedModel: 'e', fetchImpl })

  it('判定用のスキーマと maxOutputTokens を送る', async () => {
    let body: Record<string, unknown> = {}
    const f = vi.fn(async (_u: string, init?: RequestInit) => {
      body = JSON.parse(String(init!.body))
      return verdictOk([{ index: 0, status: 'ok' }, { index: 1, status: 'ok' }])
    }) as unknown as typeof fetch

    await provider(f).verify(claims, 4000)
    const gc = body.generationConfig as Record<string, unknown>
    expect(gc.maxOutputTokens).toBe(4000)
    expect(gc.responseSchema).toEqual(toGeminiSchema(verdictJsonSchema()))
    // ★ 事実の判定は揺らさない。生成（0.4）より低くする
    expect(gc.temperature).toBe(0)
  })

  it('判定が返らなかった主張を ok にしない（unverifiable にする）', async () => {
    // ★ 検証されていないものは「正しいと分かった」ではない。
    //   ここを ok に倒すと、未検証の記述が配信される
    const f = vi.fn(async () => verdictOk([{ index: 0, status: 'ok' }])) as unknown as typeof fetch
    const r = await provider(f).verify(claims, 4000)
    expect(r.verdicts.map(v => v.status)).toEqual(['ok', 'unverifiable'])
    expect(r.verdicts[1]!.reason).toMatch(/判定を返しませんでした/)
    expect(r.usage).toEqual({ inputTokens: 1200, outputTokens: 400 })
  })

  it('安全側の判定で止められたら落とす（黙って通さない）', async () => {
    const f = vi.fn(async () => new Response(
      JSON.stringify({ promptFeedback: { blockReason: 'SAFETY' } }), { status: 200 },
    )) as unknown as typeof fetch
    await expect(provider(f).verify(claims, 4000)).rejects.toThrow(/拒否/)
  })

  it('出力が上限で切れたら落とす', async () => {
    const f = vi.fn(async () => new Response(JSON.stringify({
      candidates: [{ content: { parts: [{ text: '{"verd' }] }, finishReason: 'MAX_TOKENS' }],
    }), { status: 200 })) as unknown as typeof fetch
    await expect(provider(f).verify(claims, 10)).rejects.toThrow(/MAX_TOKENS/)
  })

  it('主張が0件なら API を呼ばない', async () => {
    const f = vi.fn(async () => verdictOk([])) as unknown as typeof fetch
    const r = await provider(f).verify([], 4000)
    expect(r.verdicts).toEqual([])
    expect(f).not.toHaveBeenCalled()
  })
})

describe('§2 文字数', () => {
  it('本文の文字数を数える', () => {
    expect(bodyCharCount(validMaterial() as never)).toBe(3500)
  })
  it('受け入れ範囲はプロンプトの指示範囲（3,050〜4,500）と一致する', () => {
    expect(isCharCountOutOfRange(3500)).toBe(false)
    expect(isCharCountOutOfRange(3050)).toBe(false)
    expect(isCharCountOutOfRange(4500)).toBe(false)
    expect(isCharCountOutOfRange(3049)).toBe(true)
    expect(isCharCountOutOfRange(4501)).toBe(true)
  })

  it('各節を上限いっぱいで書いた教材を落とさない（自分の指示に従った出力を捨てない）', () => {
    const maxs = [250, 350, 2200, 600, 500, 300, 300]
    expect(isCharCountOutOfRange(maxs.reduce((a, b) => a + b))).toBe(false)
  })
})
