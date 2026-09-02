'use client'

import { useState, useTransition } from 'react'
import { signInWithGoogleAction, signInWithEmailAction } from '../actions'

/**
 * ログインの2択
 *
 * ★ Google が主（docs/03 §7）。メールリンクは Google の OAuth 設定が済むまでの
 *   予備として併設した（作者判断・2026-09-02）。
 *   docs/03 §7 は「メール確認の導線は離脱が大きい」としているので、順序を入れ替えない。
 */
export function LoginForm() {
  const [email, setEmail] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [sent, setSent] = useState(false)
  const [pending, startTransition] = useTransition()

  const google = () => {
    setError(null)
    startTransition(async () => {
      const r = await signInWithGoogleAction()
      // 成功時は redirect で遷移するので、戻ってくるのは失敗のときだけ
      if (!r.ok) setError(r.message)
    })
  }

  const magic = (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    startTransition(async () => {
      const r = await signInWithEmailAction(email)
      if (r.ok) setSent(true)
      else setError(r.message)
    })
  }

  if (sent) {
    return (
      <div className="hs-stack">
        <p className="lv-body">{email} にログイン用のリンクを送りました。</p>
        <p className="lv-caption">メールのリンクを開くと登録の続きに進みます。</p>
      </div>
    )
  }

  return (
    <div className="hs-stack">
      <button type="button" className="lv-btn lv-btn--primary lv-btn--block"
              onClick={google} disabled={pending}>
        Google でログイン
      </button>

      <p className="lv-caption">または、メールにリンクを送る</p>
      <form onSubmit={magic} className="hs-stack">
        <input
          type="email"
          className={`lv-field${error ? ' lv-field--error' : ''}`}
          value={email}
          onChange={e => setEmail(e.target.value)}
          placeholder="you@example.com"
          autoComplete="email"
          required
        />
        <button type="submit" className="lv-btn" disabled={pending || !email.trim()}>
          {pending ? '送っています…' : 'リンクを送る'}
        </button>
      </form>

      {error && <p className="lv-field-note" role="alert">{error}</p>}
    </div>
  )
}
