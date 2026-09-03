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
      try {
        const r = await submitInviteAction(code)
        if (r.ok) router.push('/login')
        else setError(r.message)
      } catch (err) {
        // ★ ここで受け止める。startTransition の中の未処理の例外は
        //   最も近い error boundary へ上がる（Next の作法書 error-handling.md）ため、
        //   受けないと画面ごと差し替わり、**打った招待コードが消える。**
        //   コードは手で写している人が多いので、打ち直させない。
        // ★ err の message は出さない。本番では Server 側の例外は総称に
        //   置き換わるので、英語の内部文が出るだけである（同 error.md）。
        console.error(err)
        setError('確認できませんでした。もう一度お試しください。')
      }
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
