'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { completeSignupAction } from '../actions'
import { MIN_AGE } from '@/lib/auth/age'

/**
 * 生年月日と同意
 *
 * ★ 「16歳未満は登録できない」と先に書いておく。
 *   入力してから断られるより、入れる前に分かる方がよい。
 */
export function ProfileForm({ email }: { email: string | null }) {
  const router = useRouter()
  const [birthDate, setBirthDate] = useState('')
  const [displayName, setDisplayName] = useState('')
  const [consent, setConsent] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  const submit = (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    startTransition(async () => {
      try {
        const r = await completeSignupAction({ birthDate, displayName, consent })
        if (r.ok) router.push('/')
        else setError(r.message)
      } catch (err) {
        // ★ 受け止める理由は invite/form.tsx と同じ。飛ばされると
        //   入れた生年月日と表示名が消え、同意からやり直しになる
        console.error(err)
        setError('登録できませんでした。もう一度お試しください。')
      }
    })
  }

  return (
    <form onSubmit={submit} className="hs-stack">
      {email && <p className="lv-caption">{email} でログインしています。</p>}

      <label className="lv-caption" htmlFor="birth">生年月日</label>
      <input
        id="birth"
        type="date"
        className={`lv-field${error ? ' lv-field--error' : ''}`}
        value={birthDate}
        onChange={e => setBirthDate(e.target.value)}
        required
      />
      <p className="lv-caption">{MIN_AGE}歳未満の方は登録できません。</p>

      <label className="lv-caption" htmlFor="name">表示名（任意）</label>
      <input
        id="name"
        className="lv-field"
        value={displayName}
        onChange={e => setDisplayName(e.target.value)}
        placeholder="ニックネームなど"
        autoComplete="nickname"
      />

      <label className="lv-check">
        <input
          type="checkbox"
          checked={consent}
          onChange={e => setConsent(e.target.checked)}
        />
        利用規約とプライバシーポリシーに同意します
      </label>

      {error && <p className="lv-field-note" role="alert">{error}</p>}

      <button type="submit" className="lv-btn lv-btn--primary"
              disabled={pending || !birthDate || !consent}>
        {pending ? '登録しています…' : '登録する'}
      </button>
    </form>
  )
}
