import { describe, it, expect, vi } from 'vitest'
import Anthropic from '@anthropic-ai/sdk'
import { createAnthropicProvider, VerifyFailedError } from './anthropic'
import type { Claim } from './types'

const claims: Claim[] = [
  { type: 'year', text: 'ウェストファリア条約は1648年' },
  { type: 'person', text: 'ハンムラビ法典を制定したのはハンムラビ王' },
]

/** SDK のクライアントを差し替えて、送っているリクエストを捕まえる */
function fakeClient(reply: unknown, capture?: { params?: Record<string, unknown> }) {
  return {
    messages: {
      create: vi.fn(async (params: Record<string, unknown>) => {
        if (capture) capture.params = params
        return reply
      }),
    },
  } as unknown as Anthropic
}

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

describe('§2.1 役割の分離', () => {
  it('Anthropic に生成はさせない', async () => {
    const p = createAnthropicProvider({ apiKey: 'K', model: 'claude-sonnet-5', client: fakeClient({}) })
    await expect(p.generate({ prompt: { system: '', user: '', promptVersion: 'v' }, schema: {}, maxOutputTokens: 1 }))
      .rejects.toThrow(/生成に使わない/)
  })

  it('Anthropic に埋め込み API は無い', async () => {
    const p = createAnthropicProvider({ apiKey: 'K', model: 'claude-sonnet-5', client: fakeClient({}) })
    await expect(p.embed(['x'])).rejects.toThrow(/埋め込み API はありません/)
  })
})
