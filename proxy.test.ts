/**
 * 未認証の遮断（docs/10-legal-risk.md §3.2 G2）
 *
 * ★ ここを試験にする理由。G2 は「未認証は404」と定めており、
 *   リダイレクトにすると**ログイン画面の存在が外から見える**。
 *   実装は1行の違い（`NextResponse.redirect` か `status: 404` か）で、
 *   後から書き換えても誰も気づかない種類の退行である。
 *
 * ★ 認証サーバーへの往復は差し替える。ここで確かめたいのは
 *   「認証の可否をどう扱うか」であって、Supabase が動くことではない。
 */
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { NextRequest } from 'next/server'

const getUser = vi.fn()
vi.mock('@supabase/ssr', () => ({
  createServerClient: () => ({ auth: { getUser } }),
}))

// vi.mock は巻き上げられるので、この import で差し替え済みのものが入る
const { default: proxy } = await import('./proxy')

const req = (path: string) => new NextRequest(`https://historia.example${path}`)

const loggedIn = () => getUser.mockResolvedValue({ data: { user: { id: 'u1' } }, error: null })
const loggedOut = () => getUser.mockResolvedValue({ data: { user: null }, error: null })

describe('proxy（未認証の遮断）', () => {
  beforeEach(() => {
    getUser.mockReset()
    vi.stubEnv('NEXT_PUBLIC_SUPABASE_URL', 'https://project.supabase.co')
    vi.stubEnv('NEXT_PUBLIC_SUPABASE_ANON_KEY', 'anon-key')
  })
  afterEach(() => { vi.unstubAllEnvs() })

  describe('認証が有効なとき', () => {
    it('未認証は 404 を返す（リダイレクトではない）', async () => {
      loggedOut()
      const res = await proxy(req('/study'))
      expect(res.status).toBe(404)
      // 3xx だと Location で行き先が漏れる。G2 の趣旨に反する
      expect(res.headers.get('location')).toBeNull()
    })

    it('404 にも CSP を付ける', async () => {
      loggedOut()
      const res = await proxy(req('/study'))
      expect(res.headers.get('Content-Security-Policy')).toContain("default-src 'self'")
    })

    it('ログインしていれば通す', async () => {
      loggedIn()
      const res = await proxy(req('/study'))
      expect(res.status).toBe(200)
    })

    it.each(['/invite', '/login', '/auth/callback'])(
      '%s は未認証でも開ける', async (path) => {
        loggedOut()
        const res = await proxy(req(path))
        expect(res.status).toBe(200)
        // 素通りさせる経路では認証サーバーに問い合わせない（無駄な往復をしない）
        expect(getUser).not.toHaveBeenCalled()
      })

    it('/auth/callback?code=… のような下位経路も開ける', async () => {
      loggedOut()
      const res = await proxy(new NextRequest('https://historia.example/auth/callback?code=abc'))
      expect(res.status).toBe(200)
    })

    it('/invitation は /invite ではない（接頭辞での取り違えをしない）', async () => {
      loggedOut()
      const res = await proxy(req('/invitation'))
      expect(res.status).toBe(404)
    })
  })

  describe('認証が設定されていないとき（プレビュー）', () => {
    beforeEach(() => {
      vi.stubEnv('NEXT_PUBLIC_SUPABASE_URL', '')
      vi.stubEnv('NEXT_PUBLIC_SUPABASE_ANON_KEY', '')
    })

    it('関門ごと素通りさせる', async () => {
      // ★ lib/db/optional.ts の tryDb() と同じ作法。そうしないと
      //   DB も鍵も無い Vercel のプレビューが全ページ 404 になり、意匠を確認できない
      const res = await proxy(req('/study'))
      expect(res.status).toBe(200)
      expect(getUser).not.toHaveBeenCalled()
    })
  })

  /**
   * ★ worker-src が無くても Service Worker は登録できる（default-src に落ちるため）。
   *   だからこそ試験で留めておく。CSP を締めたときに黙って PWA が死ぬのを防ぐ。
   */
  it('CSP が Service Worker と manifest を許している（docs/12 §10）', async () => {
    loggedIn()
    const csp = (await proxy(req('/'))).headers.get('Content-Security-Policy')!
    expect(csp).toContain("worker-src 'self'")
    expect(csp).toContain("manifest-src 'self'")
  })

  it('CSP は毎回ちがう nonce を出す', async () => {
    loggedIn()
    const a = (await proxy(req('/'))).headers.get('Content-Security-Policy')!
    const b = (await proxy(req('/'))).headers.get('Content-Security-Policy')!
    const nonce = (csp: string) => /'nonce-([^']+)'/.exec(csp)?.[1]
    expect(nonce(a)).toBeTruthy()
    expect(nonce(a)).not.toBe(nonce(b))
  })
})
