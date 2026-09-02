'use client'

import { useState, useTransition } from 'react'
import { setMaxDaily, deleteAccount } from './actions'
import { signOutAction } from '@/app/(auth)/actions'
import { MAX_DAILY_MIN, MAX_DAILY_MAX } from '@/lib/domain/scheduler'

/**
 * 端末に保存したものを消すよう Service Worker に頼む。
 *
 * ★ ログアウトの前に呼ぶ。Server Action は redirect を投げるので、
 *   後ろに書いた行は走らない。
 * ★ 失敗しても止めない。SW が未登録・未対応でもログアウトはできるべきである。
 *   なお sw.js は 404 を合図にも消すので、ここが動かなくても最終的には消える。
 */
async function purgeCaches() {
  try {
    const reg = await navigator.serviceWorker?.getRegistration()
    reg?.active?.postMessage({ type: 'purge' })
  } catch { /* SW が無い環境。何もしない */ }
}

export function SettingsForm({ maxDaily, authEnabled }: { maxDaily: number; authEnabled: boolean }) {
  const [n, setN] = useState(String(maxDaily))
  const [msg, setMsg] = useState<string | null>(null)
  const [confirm, setConfirm] = useState('')
  const [danger, setDanger] = useState(false)
  const [pending, start] = useTransition()

  const save = () => start(async () => {
    const r = await setMaxDaily(Number(n))
    setMsg(r.message)
  })

  const logout = () => start(async () => {
    await purgeCaches()
    await signOutAction()
  })

  const remove = () => start(async () => {
    await purgeCaches()
    const r = await deleteAccount(confirm)
    // 成功したら redirect が投げられるので、ここに来るのは失敗のときだけ
    setMsg(r.message)
  })

  return (
    <>
      <div className="lv-card">
        <div className="lv-card__pad hs-stack">
          <span className="lv-label">1日の上限</span>
          <p className="lv-caption">
            締切から逆算した分量がこれを超えるときは、ここで打ち切ります。
            {MAX_DAILY_MIN}〜{MAX_DAILY_MAX} 問。
          </p>
          <div className="lv-field">
            <input
              className="lv-input" type="number" inputMode="numeric"
              min={MAX_DAILY_MIN} max={MAX_DAILY_MAX} value={n}
              onChange={e => setN(e.target.value)} aria-label="1日の上限"
            />
          </div>
          <button type="button" className="lv-btn lv-btn--block" disabled={pending} onClick={save}>
            保存する
          </button>
          {msg && <p className="lv-field-note" role="status">{msg}</p>}
        </div>
      </div>

      {authEnabled && (
        <div className="lv-card">
          <div className="lv-card__pad hs-stack">
            <span className="lv-label">ログアウト</span>
            <p className="lv-caption">
              この端末に保存した教材と記録も一緒に消します（共用の端末で他の人に見えないように）。
            </p>
            <button type="button" className="lv-btn lv-btn--block" disabled={pending} onClick={logout}>
              ログアウトする
            </button>
          </div>
        </div>
      )}

      {/* ★ 退会は docs/10 §5.4 の要件。物理削除で、消した件数を返す。
           開いた瞬間に押せる位置には置かない */}
      <div className="lv-card">
        <div className="lv-card__pad hs-stack">
          <span className="lv-label">アカウントと学習データの削除</span>
          <p className="lv-caption">
            解答・特訓・確認テスト・教材・弱点の推定をすべて消します。元に戻せません。
          </p>
          {!danger ? (
            <button type="button" className="lv-btn lv-btn--block" onClick={() => setDanger(true)}>
              削除の手続きに進む
            </button>
          ) : (
            <>
              <p className="lv-body">確認のため「削除します」と入力してください。</p>
              <div className="lv-field">
                <input
                  className="lv-input" type="text" value={confirm}
                  onChange={e => setConfirm(e.target.value)} aria-label="確認の入力"
                  autoComplete="off"
                />
              </div>
              <button
                type="button" className="lv-btn lv-btn--block"
                disabled={pending || confirm !== '削除します'} onClick={remove}
              >
                すべて削除する
              </button>
              <button type="button" className="lv-btn lv-btn--block" onClick={() => setDanger(false)}>
                やめる
              </button>
            </>
          )}
        </div>
      </div>
    </>
  )
}
