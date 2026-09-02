'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { submitInviteAction } from '../actions'

/**
 * 招待コードの入力
 *
 * ★ ここでは席を取らない。確かめて cookie に置くだけである。
 *   途中でやめた人のぶんだけ席が死ぬのを避けるため、消し込みは登録の最後に行う。
 */
export function InviteForm() {
  const router = useRouter()
  const [code, setCode] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  const submit = (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    startTransition(async () => {
      const r = await submitInviteAction(code)
      if (r.ok) router.push('/login')
      else setError(r.message)
    })
  }

  return (
    <form onSubmit={submit} className="hs-stack">
      <label className="lv-caption" htmlFor="invite-code">招待コード</label>
      <input
        id="invite-code"
        className={`lv-field${error ? ' lv-field--error' : ''}`}
        value={code}
        onChange={e => setCode(e.target.value.toUpperCase())}
        placeholder="XXXX-XXXX"
        autoComplete="off"
        autoCapitalize="characters"
        spellCheck={false}
        required
      />
      {error && <p className="lv-field-note" role="alert">{error}</p>}
      <button type="submit" className="lv-btn lv-btn--primary" disabled={pending || !code.trim()}>
        {pending ? '確認しています…' : '次へ'}
      </button>
    </form>
  )
}
