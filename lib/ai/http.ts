/**
 * HTTP の共通処理 — リトライとエラー分類
 *
 * 仕様: docs/08-ai-architecture.md §7
 *
 * ★ SDK の自動リトライは無効化して、ここで一元管理する。
 *   二重にリトライすると、無料枠の RPM を意図せず倍消費する。
 */

/** 指数バックオフ 2s / 4s / 8s・最大3回（docs/08 §7） */
export const BACKOFF_MS = [2_000, 4_000, 8_000] as const
export const MAX_ATTEMPTS = BACKOFF_MS.length

export class RateLimitedError extends Error {
  constructor(readonly provider: string, readonly attempts: number) {
    super(`${provider}: レート制限で ${attempts} 回試して諦めました`)
    this.name = 'RateLimitedError'
  }
}

export class ProviderHttpError extends Error {
  constructor(readonly provider: string, readonly status: number, readonly body: string) {
    super(`${provider}: HTTP ${status} ${body.slice(0, 300)}`)
    this.name = 'ProviderHttpError'
  }
}

export type Sleep = (ms: number) => Promise<void>
const realSleep: Sleep = ms => new Promise(r => setTimeout(r, ms))

/**
 * 429 と 5xx だけを再試行する。4xx（スキーマ違反・鍵の誤り）は再試行しない。
 * 同じ入力で同じ 400 が返るだけで、無料枠を無駄に消費するため。
 */
export async function fetchWithRetry(
  url: string,
  init: RequestInit,
  opts: { provider: string; fetchImpl?: typeof fetch; sleep?: Sleep } = { provider: 'unknown' },
): Promise<Response> {
  const doFetch = opts.fetchImpl ?? fetch
  const sleep = opts.sleep ?? realSleep
  let last: Response | null = null

  for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
    const res = await doFetch(url, init)
    if (res.ok) return res
    last = res

    const retryable = res.status === 429 || res.status >= 500
    if (!retryable) {
      throw new ProviderHttpError(opts.provider, res.status, await res.text().catch(() => ''))
    }
    if (attempt < MAX_ATTEMPTS - 1) await sleep(BACKOFF_MS[attempt]!)
  }

  if (last && last.status === 429) throw new RateLimitedError(opts.provider, MAX_ATTEMPTS)
  throw new ProviderHttpError(opts.provider, last?.status ?? 0, await last?.text().catch(() => '') ?? '')
}
