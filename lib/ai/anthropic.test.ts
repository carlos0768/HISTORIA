import { describe, it, expect, vi } from 'vitest'
import Anthropic from '@anthropic-ai/sdk'
import { createAnthropicProvider, VerifyFailedError, GenerateFailedError } from './anthropic'
import { materialJsonSchema, bodyCharCount } from './schema'
import type { Claim } from './types'

const claims: Claim[] = [
  { type: 'year', text: 'ウェストファリア条約は1648年' },
  { type: 'person', text: 'ハンムラビ法典を制定したのはハンムラビ王' },
]

/**
 * SDK のクライアントを差し替えて、送っているリクエストを捕まえる。
 * ★ generate は `messages.stream(...).finalMessage()` を使う（出力が 16,000 で
 *   非ストリームだと1リクエストの時間上限に当たりうるため）。両方を持たせる。
 */
function fakeClient(reply: unknown, capture?: { params?: Record<string, unknown> }) {
  const record = (params: Record<string, unknown>) => {
    if (capture) capture.params = params
  }
  return {
    messages: {
      create: vi.fn(async (params: Record<string, unknown>) => {
        record(params)
        return reply
      }),
      stream: vi.fn((params: Record<string, unknown>) => {
        record(params)
        return { finalMessage: async () => reply }
      }),
    },
  } as unknown as Anthropic
}

/** docs/07 §5.3 を満たす最小の教材（gemini.test.ts と同じ形） */
function validMaterial() {
  return {
    title: 'フランス革命とナポレオン',
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
    claims: Array.from({ length: 12 }, (_, i) => ({
      kind: (['year', 'person', 'event', 'causal', 'place'] as const)[i % 5]!,
      text: `検証できる主張${i + 1}`,
      section_ord: (i % 7) + 1,
    })),
  }
}

const genReply = (payload: unknown, extra: Record<string, unknown> = {}) => ({
  stop_reason: 'end_turn',
  content: [
    // adaptive thinking の思考ブロックが混ざる。text だけを取れているかを見る
    { type: 'thinking', thinking: '…' },
    { type: 'text', text: JSON.stringify(payload) },
  ],
  usage: { input_tokens: 3000, output_tokens: 9500 },
  ...extra,
})

const genPrompt = { system: 'SYS', user: 'USER', promptVersion: 'material_v2' }

const okReply = (verdicts: unknown) => ({
  stop_reason: 'end_turn',
  content: [{ type: 'text', text: JSON.stringify({ verdicts }) }],
  usage: { input_tokens: 1200, output_tokens: 400 },
})

describe('§5 層3 リクエストの形', () => {
  it('claude-sonnet-5 に構造化出力で投げる', async () => {
    const cap: { params?: Record<string, unknown> } = {}
    const p = createAnthropicProvider({
      apiKey: 'K', model: 'claude-sonnet-5',
      client: fakeClient(okReply([{ index: 0, status: 'ok' }, { index: 1, status: 'ok' }]), cap),
    })
    await p.verify(claims, 400)

    expect(cap.params!.model).toBe('claude-sonnet-5')
    expect(cap.params!.max_tokens).toBe(400)
    const oc = cap.params!.output_config as { format: { type: string } }
    expect(oc.format.type).toBe('json_schema')
  })

  it('thinking は adaptive のみ。budget_tokens を送らない（Sonnet 5 では 400 になる）', async () => {
    const cap: { params?: Record<string, unknown> } = {}
    const p = createAnthropicProvider({
      apiKey: 'K', model: 'claude-sonnet-5',
      client: fakeClient(okReply([{ index: 0, status: 'ok' }, { index: 1, status: 'ok' }]), cap),
    })
    await p.verify(claims, 400)
    expect(cap.params!.thinking).toEqual({ type: 'adaptive' })
    expect(JSON.stringify(cap.params)).not.toContain('budget_tokens')
  })

  it('プレフィルを使わない（Sonnet 5 では 400 になる）', async () => {
    const cap: { params?: Record<string, unknown> } = {}
    const p = createAnthropicProvider({
      apiKey: 'K', model: 'claude-sonnet-5',
      client: fakeClient(okReply([{ index: 0, status: 'ok' }, { index: 1, status: 'ok' }]), cap),
    })
    await p.verify(claims, 400)
    const msgs = cap.params!.messages as Array<{ role: string }>
    expect(msgs.every(m => m.role === 'user')).toBe(true)
  })

  it('主張が0件なら呼び出さない（無駄な課金をしない）', async () => {
    const client = fakeClient(okReply([]))
    const p = createAnthropicProvider({ apiKey: 'K', model: 'claude-sonnet-5', client })
    const r = await p.verify([], 400)
    expect(r.verdicts).toEqual([])
    expect(client.messages.create).not.toHaveBeenCalled()
  })
})

describe('判定の解釈', () => {
  const mk = (reply: unknown) =>
    createAnthropicProvider({ apiKey: 'K', model: 'claude-sonnet-5', client: fakeClient(reply) })

  it('index で claim に対応づける', async () => {
    const r = await mk(okReply([
      { index: 1, status: 'wrong', reason: '年号が違います' },
      { index: 0, status: 'ok' },
    ])).verify(claims, 400)
    expect(r.verdicts[0]).toMatchObject({ status: 'ok' })
    expect(r.verdicts[1]).toMatchObject({ status: 'wrong', reason: '年号が違います' })
    expect(r.verdicts[1]!.claim.text).toContain('ハンムラビ')
  })

  it('判定が返らなかった主張を ok 扱いにしない（検証されていない ≠ 正しい）', async () => {
    const r = await mk(okReply([{ index: 0, status: 'ok' }])).verify(claims, 400)
    expect(r.verdicts).toHaveLength(2)
    expect(r.verdicts[1]!.status).toBe('unverifiable')
    expect(r.verdicts[1]!.reason).toContain('判定を返しませんでした')
  })

  it('usage を返す（元帳に載せる）', async () => {
    const r = await mk(okReply([{ index: 0, status: 'ok' }, { index: 1, status: 'ok' }])).verify(claims, 400)
    expect(r.usage).toEqual({ inputTokens: 1200, outputTokens: 400 })
  })

  it('JSON でなければ落とす', async () => {
    const bad = { stop_reason: 'end_turn', content: [{ type: 'text', text: 'JSONではない' }], usage: { input_tokens: 1, output_tokens: 1 } }
    await expect(mk(bad).verify(claims, 400)).rejects.toBeInstanceOf(VerifyFailedError)
  })

  it('スキーマ違反は落とす', async () => {
    await expect(mk(okReply([{ index: 0, status: 'たぶん正しい' }])).verify(claims, 400))
      .rejects.toBeInstanceOf(VerifyFailedError)
  })
})

describe('検証結果が無いまま通さない', () => {
  const mk = (reply: unknown) =>
    createAnthropicProvider({ apiKey: 'K', model: 'claude-sonnet-5', client: fakeClient(reply) })

  it('拒否されたら落とす（検証していないのに配信してしまわない）', async () => {
    const refused = {
      stop_reason: 'refusal', stop_details: { category: 'cyber' },
      content: [], usage: { input_tokens: 1, output_tokens: 0 },
    }
    await expect(mk(refused).verify(claims, 400)).rejects.toThrow(/拒否/)
  })

  it('出力が上限で切れたら落とす', async () => {
    const cut = {
      stop_reason: 'max_tokens',
      content: [{ type: 'text', text: '{"verdicts":[' }],
      usage: { input_tokens: 1, output_tokens: 400 },
    }
    await expect(mk(cut).verify(claims, 400)).rejects.toThrow(/上限で切れ/)
  })
})

/**
 * ★ **役割の分離は、このファイルの仕事ではない。**
 *
 *   2026-09-04 まで、ここには「Anthropic に生成はさせない」という試験があり、
 *   `generate()` が必ず例外を投げることを固定していた。向きが
 *   「生成 Claude / 検証 Gemini」へ入れ替わった瞬間、**製品が動かなくなった**
 *   （作者が実際に踏んだ: 「anthropic は生成に使わない設定です」）。
 *
 *   自己検証への退化を防ぐのは `client.ts` の `assertConfig` である。
 *   **不変条件を間違った層に置いていた**、というのがこの一件の教訓である。
 */
describe('生成（教材）', () => {
  const provider = (reply: unknown, cap?: { params?: Record<string, unknown> }) =>
    createAnthropicProvider({ apiKey: 'K', model: 'claude-opus-5', client: fakeClient(reply, cap) })

  const call = (p: ReturnType<typeof createAnthropicProvider>, maxOut = 16_000) =>
    p.generate({ prompt: genPrompt, schema: materialJsonSchema(), maxOutputTokens: maxOut })

  /**
   * ★ **実測で分かった制約を試験に固定する。**
   *
   *   2026-09-04、作者が実鍵で回して出た 400（request_id req_011CeiPWeKkAjSeaPDzHB2z9）:
   *
   *     output_config.format.schema: For 'array' type, 'minItems' values other than
   *     0 or 1 are not supported (got: [6, ∞])
   *
   *   教材スキーマは sections(7) / flashcards(10) / mcqs(6) / claims(6) / choices(4) と
   *   **全ての配列が引っかかる**ので、変換しないと1文字も生成されずに落ちる。
   *   件数の契約は応答側の zod で守るので、落としても正しさは失われない。
   */
  it('配列の minItems を 1 以下にして送る（Anthropic は 0/1 しか受けない）', async () => {
    const cap: { params?: Record<string, unknown> } = {}
    await call(provider(genReply(validMaterial()), cap))

    const sent = JSON.stringify((cap.params!.output_config as { format: { schema: unknown } }).format.schema)
    const mins = [...sent.matchAll(/"minItems":(\d+)/g)].map(m => Number(m[1]))
    expect(mins.length, 'minItems が1つも無いと、この試験は何も見ていない').toBeGreaterThan(0)
    expect(mins.every(n => n <= 1), `1 を超える minItems が残っている: ${mins.join(', ')}`).toBe(true)

    // ★ 0 にはしない。空配列を API 側で素通りさせないため
    expect(mins.every(n => n === 1)).toBe(true)
    // ★ maxItems は落とさない（上の 400 は minItems だけを名指ししている）
    expect(sent).toContain('"maxItems":7')
    expect(sent).toContain('"maxItems":14')
  })

  it('検証の側も同じ変換を通す（片方だけ落ちるのを防ぐ）', async () => {
    const cap: { params?: Record<string, unknown> } = {}
    const p = createAnthropicProvider({
      apiKey: 'K', model: 'claude-sonnet-5',
      client: fakeClient(okReply([{ index: 0, status: 'ok' }, { index: 1, status: 'ok' }]), cap),
    })
    await p.verify(claims, 400)
    const sent = JSON.stringify((cap.params!.output_config as { format: { schema: unknown } }).format.schema)
    const mins = [...sent.matchAll(/"minItems":(\d+)/g)].map(m => Number(m[1]))
    expect(mins.every(n => n <= 1)).toBe(true)
  })

  it('構造化出力・adaptive thinking・max_tokens を送る', async () => {
    const cap: { params?: Record<string, unknown> } = {}
    await call(provider(genReply(validMaterial()), cap))

    expect(cap.params!.model).toBe('claude-opus-5')
    expect(cap.params!.max_tokens).toBe(16_000)
    expect(cap.params!.system).toBe('SYS')
    const oc = cap.params!.output_config as { format: { type: string } }
    expect(oc.format.type).toBe('json_schema')
    // budget_tokens は Opus 5 では 400 になる
    expect(cap.params!.thinking).toEqual({ type: 'adaptive' })
    expect(JSON.stringify(cap.params)).not.toContain('budget_tokens')
    // ★ adaptive thinking と temperature の併用は 400 になる
    expect(cap.params).not.toHaveProperty('temperature')
  })

  it('ストリームで受ける（出力16,000で非ストリームだと時間上限に当たりうる）', async () => {
    const client = fakeClient(genReply(validMaterial()))
    const p = createAnthropicProvider({ apiKey: 'K', model: 'claude-opus-5', client })
    await call(p)
    const m = (client as unknown as { messages: { stream: { mock: unknown }; create: { mock: { calls: unknown[] } } } }).messages
    expect(m.create.mock.calls).toHaveLength(0)
  })

  it('正しい教材は通り、usage を返す', async () => {
    const r = await call(provider(genReply(validMaterial())))
    expect(r.model).toBe('claude-opus-5')
    expect(r.usage).toEqual({ inputTokens: 3000, outputTokens: 9500 })
    expect(bodyCharCount(r.value as never)).toBe(3500)
  })

  it('スキーマに合わない出力を通さない', async () => {
    const broken = { ...validMaterial(), sections: [] }
    await expect(call(provider(genReply(broken)))).rejects.toThrow(GenerateFailedError)
  })

  it('JSON として読めなければ落とす', async () => {
    const reply = { stop_reason: 'end_turn', content: [{ type: 'text', text: '{壊れ' }], usage: { input_tokens: 1, output_tokens: 1 } }
    await expect(call(provider(reply))).rejects.toThrow(/JSON として読めません/)
  })

  it('出力が上限で切れたらパースしようとせず落とす', async () => {
    // 途中で切れた JSON をパースしても壊れているだけである
    const reply = genReply(validMaterial(), { stop_reason: 'max_tokens' })
    await expect(call(provider(reply))).rejects.toThrow(/上限で切れました/)
  })

  it('拒否されたら落とす（空の教材を配信しない）', async () => {
    const reply = genReply(validMaterial(), { stop_reason: 'refusal', stop_details: { category: 'x' } })
    await expect(call(provider(reply))).rejects.toThrow(/拒否/)
  })
})

describe('埋め込み', () => {
  it('Anthropic に埋め込み API は無い', async () => {
    const p = createAnthropicProvider({ apiKey: 'K', model: 'claude-sonnet-5', client: fakeClient({}) })
    await expect(p.embed(['x'])).rejects.toThrow(/埋め込み API はありません/)
  })
})
