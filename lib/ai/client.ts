/**
 * AI クライアント — 外に出る唯一の経路
 *
 * 仕様: docs/08-ai-architecture.md §6, §7.1
 *
 * ★ アプリのどこからも fetch で直接 LLM を呼ばない。ここだけが外に出る。
 * ★ 生成と検証は必ず別プロバイダにする。同一モデルの自己検証に退化するため、
 *   両方が同じ値になる設定は起動時に拒否する。
 * ★ すべての呼び出しは支出遮断器の関門を通る。迂回路を作らない。
 */
import type { Sql } from 'postgres'
import type { Claim, GenerateResult, Provider, RenderedPrompt, VerifyResult } from './types'
import { createFakeProvider, type FakeOptions } from './fake'
import { createGeminiProvider } from './gemini'
import { createAnthropicProvider } from './anthropic'
import { assertNoIdentifiers } from './redact'
import { reserve, settle, release, estimateJpy, type Purpose, type Price } from './budget'

export type AiConfig = {
  genProvider: string
  genModel: string
  verifyProvider: string
  verifyModel: string
  embedModel: string
  geminiApiKey?: string
  anthropicApiKey?: string
}

/**
 * ★ 既定は「生成 Claude / 検証 Gemini」。2026-09-04 に作者が費用試算を見て決めた
 *   （全75節で約 ¥4,300、月上限 1万円の 43%。docs/08 §3.4）。v0.3 までの
 *   「生成は Gemini の無料枠、検証は Anthropic」から**向きが逆になっている**。
 *
 * ★ 既定をそのままにしなかった理由。鍵だけ入れて GEN_PROVIDER を設定し忘れると、
 *   教材が黙って Gemini Flash で作られる。フェイクではないので警告も出ず、
 *   安いので遮断器も鳴らない——**一番気づきにくい間違い方**をする。
 *
 * ★ VERIFY_MODEL の既定を Gemini 3 Pro にしていない。この環境から
 *   ai.google.dev に到達できず、正しいモデル id を確認できなかったため。
 *   gemini.ts は id を URL のパスにそのまま入れるので、推測を書くと 404 になる
 *   （docs/14 M28 で実際に観測した症状）。作者が AI Studio で確認したものを
 *   Vercel の VERIFY_MODEL に入れる。既定はリポジトリで既に使っている id を置く。
 */
export function readConfig(env: NodeJS.ProcessEnv = process.env): AiConfig {
  return {
    genProvider: env.GEN_PROVIDER ?? 'anthropic',
    genModel: env.GEN_MODEL ?? 'claude-opus-5',
    verifyProvider: env.VERIFY_PROVIDER ?? 'gemini',
    verifyModel: env.VERIFY_MODEL ?? 'gemini-3.6-flash',
    embedModel: env.EMBED_MODEL ?? 'gemini-embedding-001',
    geminiApiKey: env.GEMINI_API_KEY || undefined,
    anthropicApiKey: env.ANTHROPIC_API_KEY || undefined,
  }
}

/**
 * 起動時の設定検査。
 * 生成と検証が同じプロバイダだと、同じモデルが同じ誤りを見逃すため
 * ファクトチェックが自己検証に退化する（§2.1）。
 */
export function assertConfig(cfg: AiConfig): void {
  if (cfg.genProvider === cfg.verifyProvider) {
    throw new Error(
      `GEN_PROVIDER と VERIFY_PROVIDER が同じです（${cfg.genProvider}）。` +
        '同一系統のモデルによる自己検証に退化するため許可しません（docs/08 §6）。',
    )
  }

  /**
   * ★ プロバイダとモデル id の食い違いを起動時に落とす。
   *   gemini.ts は id を `/models/${model}:generateContent` と **URL のパスに
   *   そのまま入れる**ので、'claude-sonnet-5' を渡すと 404 になる。
   *   これは docs/14 M28 で実際に観測した症状で、鍵の問題と見分けがつかない。
   *   向きを入れ替えるときに片方だけ直し忘れるのが典型なので、ここで止める。
   */
  for (const [provider, model, gen] of [
    [cfg.genProvider, cfg.genModel, 'GEN'],
    [cfg.verifyProvider, cfg.verifyModel, 'VERIFY'],
  ] as const) {
    const looksAnthropic = model.startsWith('claude-')
    const looksGemini = model.startsWith('gemini-')
    const mismatch =
      (provider === 'gemini' && looksAnthropic) || (provider === 'anthropic' && looksGemini)
    if (mismatch) {
      throw new Error(
        `${gen}_PROVIDER=${provider} に ${gen}_MODEL=${model} が組み合わされています。` +
          'モデル id はそのままリクエストに乗るため、この組み合わせは 404 になります。',
      )
    }
  }
}

/** USD / MTok。docs/08 §3.4 */
export const PRICES: Record<string, Price> = {
  // ★ 生成に使うモデルは必ずここに書く。下の未知モデルの既定は**天井ではない**。
  //   Opus 5 は $5/$25 で、既定の $3/$15 を出力側で上回る。書き忘れると
  //   estimateJpy が実額の約6割しか返さず、settle も同じ式を使うので
  //   **元帳が実支出より4割少なく積まれる**。cap_jpy 10,000 は実額 16,700 円
  //   あたりまで素通りし、遮断器の不変条件（settled + reserved <= cap）が崩れる。
  'claude-opus-5': { inputPerMTok: 5, outputPerMTok: 25 },
  'claude-sonnet-5': { inputPerMTok: 2, outputPerMTok: 10 },
  // ★ Gemini の単価をここに書かない。
  //   docs/08 は「無料枠だから0円」を前提にしていたが、2026-09-02 の実測では
  //   gemini-2.5-flash が新規利用者に 404、他のモデルは
  //   「前払いクレジットが尽きた」の 429 を返した。
  //   **この鍵からは無料枠の存在を確認できていない**（docs/14 M28）。
  //   0 と書くと estimateJpy が 0 を返し、遮断器が生成を1円も数えなくなる。
  //   実際に課金されていた場合、元帳が空のまま支出だけが進む。
  //   単価を実測できるまでは、下の未知モデルの見積りに落ちるままにする。
  //   Gemini 3 Pro は $2/$12 と伝えられており、既定の $3/$15 はそれを上回るので
  //   Gemini については安全側に落ちる（Opus 5 と違って過小にならない）。
}

/**
 * ★ 既定値は「安全側」ではなく「Sonnet 5 より高め」でしかない。
 *   2026-09-04 まで「未知のモデルは高めに見積もる」と書いてあったが、
 *   それは Sonnet 5（$2/$10）だけが表に載っていた頃の話である。
 *   Opus 5（$5/$25）は既定を上回るので、**上に書かなければ過小評価になる**。
 *   実際に使うモデルは PRICES に載せること。ここは「載せ忘れても
 *   0 円にはしない」という最後の網であって、天井ではない。
 */
const priceOf = (model: string): Price =>
  PRICES[model] ?? { inputPerMTok: 3, outputPerMTok: 15 }

/**
 * 鍵があれば実物、無ければフェイクにする。
 * フェイクは実物と同じ型・同じ制約で動くので、鍵が無くても閉ループは最後まで通る。
 *
 * ★ **モデルは呼び出し側から渡す。ベンダーから決めない。**
 *   2026-09-04 まで、ここは `gemini → cfg.genModel` / `anthropic → cfg.verifyModel` と
 *   固定していた。旧構成（生成=Gemini / 検証=Anthropic）では正しかったが、
 *   向きを入れ替えると**ちょうど裏返しになる**:
 *
 *     生成（anthropic）に verifyModel = 'gemini-3.x'   → Anthropic が 400
 *     検証（gemini）に   genModel     = 'claude-opus-5' → /models/claude-opus-5 で 404
 *
 *   質が悪いのは、その 404 が「モデル id が間違っている」（M35）と**区別できない**こと。
 *   鍵でもモデル名でもなく配線の誤りなので、そちらを疑うと永久に直らない。
 *
 *   `assertConfig` の食い違い検査もここは守れない。あちらが見るのは
 *   「設定どうしが揃っているか」であって、**設定を実物へ配る途中で入れ替わること**
 *   ではないためである。
 */
function resolveProvider(
  name: string,
  /** その役割で使うモデル。genProvider には genModel、verifyProvider には verifyModel */
  model: string,
  cfg: AiConfig,
  fake: FakeOptions = {},
): Provider {
  if (name === 'gemini' && cfg.geminiApiKey) {
    return createGeminiProvider({
      apiKey: cfg.geminiApiKey, model, embedModel: cfg.embedModel,
    })
  }
  if (name === 'anthropic' && cfg.anthropicApiKey) {
    return createAnthropicProvider({ apiKey: cfg.anthropicApiKey, model })
  }
  // ★ フェイクにも model を渡す。渡さないと結果が `gemini-fake` としか名乗らず、
  //   配線の誤りが鍵の無い試験から見えなくなる（fake.ts の注記）
  return createFakeProvider(name, fake, model)
}

export type GenerateCall = {
  db: Sql; prompt: RenderedPrompt; schema: object; maxOutputTokens: number
  purpose?: Purpose; jobId?: string | null; now: Date
}
export type VerifyCall = {
  db: Sql; claims: Claim[]; maxOutputTokens: number; jobId?: string | null; now: Date
}
export type EmbedCall = { db: Sql; texts: string[]; now: Date }

export type Client = {
  config: AiConfig
  usingFake: boolean
  /**
   * 実際に使われたプロバイダの名前。フェイクなら `fake:gemini` になる。
   *
   * ★ `config.genProvider` を記録に使わない。あれは「使いたいもの」であって
   *   「使われたもの」ではない。鍵が無ければフェイクに落ちるので、
   *   設定値を書くと嘘の記録が残る。
   */
  genProviderName: string
  verifyProviderName: string
  /**
   * 埋め込みに実際に使われるプロバイダの名前。フェイクなら `fake:gemini`。
   * ★ 生成の向きとは独立である（下の embed の注記）。「意味で引けるか」は
   *   これで判定する。genProviderName で判定すると、生成が Claude のとき
   *   本物の Gemini の鍵があっても「引けない」と誤る。
   */
  embedProviderName: string
  generate<T>(a: GenerateCall): Promise<GenerateResult<T>>
  verify(a: VerifyCall): Promise<VerifyResult>
  embed(a: EmbedCall): Promise<{ vectors: number[][]; model: string }>
}

export function createClient(cfg: AiConfig = readConfig(), fake: FakeOptions = {}): Client {
  assertConfig(cfg)
  // 役割とモデルを対にして渡す。ここがずれると 404 / 400 になる（resolveProvider の注記）
  const gen = resolveProvider(cfg.genProvider, cfg.genModel, cfg, fake)
  const ver = resolveProvider(cfg.verifyProvider, cfg.verifyModel, cfg, fake)
  const usingFake = !cfg.geminiApiKey || !cfg.anthropicApiKey

  /**
   * ★ 埋め込みは Gemini にしか無い（anthropic.ts の embed は投げる）。
   *   2026-09-04 に既定が「生成 Claude / 検証 Gemini」に変わったため、
   *   「生成側で埋め込む」のままだと既定の構成で埋め込みが**必ず失敗**する
   *   （教材の中の「調べる」が最初の利用者で、そこで見つかった）。
   *   生成と検証のどちらであれ Gemini の側を使い、支出もその名前で記録する。
   *   どちらも Gemini でなければ生成側に落とす（フェイクなら通り、本物なら投げる）。
   */
  const [emb, embedProvider] =
    cfg.genProvider === 'gemini' ? [gen, cfg.genProvider]
    : cfg.verifyProvider === 'gemini' ? [ver, cfg.verifyProvider]
    : [gen, cfg.genProvider]

  /** 予約 → 呼び出し → 確定。失敗したら解放する */
  async function guarded<R extends { usage: { inputTokens: number; outputTokens: number } }>(
    db: Sql, now: Date, model: string, provider: string, purpose: Purpose,
    maxInputTokens: number, maxOutputTokens: number, jobId: string | null | undefined,
    run: () => Promise<R>,
  ): Promise<R> {
    const price = priceOf(model)
    const est = estimateJpy(maxInputTokens, maxOutputTokens, price)
    const r = await reserve(db, { estJpy: est, provider, model, purpose, jobId, now })
    try {
      const out = await run()
      const actual = Math.min(
        est,
        estimateJpy(out.usage.inputTokens, out.usage.outputTokens, price),
      )
      await settle(db, r, { ...out.usage, actualJpy: actual })
      return out
    } catch (e) {
      await release(db, r)
      throw e
    }
  }

  return {
    config: cfg,
    usingFake,
    genProviderName: gen.name,
    verifyProviderName: ver.name,
    embedProviderName: emb.name,

    async generate<T>(a: GenerateCall) {
      // 型だけでなく実行時にも個人識別情報の混入を止める（§4.2）。
      // renderMaterialPrompt でも検査しているが、経路を1つに絞れない以上ここでも見る
      assertNoIdentifiers(a.prompt.system)
      assertNoIdentifiers(a.prompt.user)
      // 入力の上限はプロンプトの実測値から。教材生成は出力が支配的
      const maxIn = Math.ceil((a.prompt.system.length + a.prompt.user.length) / 1.5) + 1000
      return guarded(
        a.db, a.now, cfg.genModel, cfg.genProvider, a.purpose ?? 'generate',
        maxIn, a.maxOutputTokens, a.jobId,
        () => gen.generate<T>({ prompt: a.prompt, schema: a.schema, maxOutputTokens: a.maxOutputTokens }),
      )
    },

    async verify(a: VerifyCall) {
      const maxIn = Math.ceil(JSON.stringify(a.claims).length / 1.5) + 500
      return guarded(
        a.db, a.now, cfg.verifyModel, cfg.verifyProvider, 'factcheck',
        maxIn, a.maxOutputTokens, a.jobId,
        () => ver.verify(a.claims, a.maxOutputTokens),
      )
    },

    /** 送り先は createClient の `emb` で決めてある（役割ではなく「できるほう」） */
    async embed(a: EmbedCall) {
      /**
       * ★ どちらも Gemini でないなら、予算を予約する前に落とす。
       *   `emb` は生成側に落ちる作りなので、このまま進むと
       *   予約 → anthropic.ts の例外 → 解放、と DB を2往復してから同じ結果になる。
       *   設定の誤りは設定の言葉で言うほうが直せる。
       *
       *   ★ ただしフェイクは通す。鍵が無い状態で閉ループを最後まで回せることは
       *     この抽象層の目的そのものである（lib/ai/fake.ts）。
       */
      if (embedProvider !== 'gemini' && !emb.name.startsWith('fake:')) {
        throw new Error(
          '埋め込みは Gemini でしか作れません（docs/09 §6）。'
          + `いまの設定は 生成=${cfg.genProvider} / 検証=${cfg.verifyProvider} で、どちらも gemini ではありません。`,
        )
      }
      const maxIn = Math.ceil(a.texts.join('').length / 1.5)
      const out = await guarded(
        a.db, a.now, cfg.embedModel, embedProvider, 'embed', maxIn, 0, null,
        () => emb.embed(a.texts),
      )
      return { vectors: out.vectors, model: out.model }
    },
  }
}
