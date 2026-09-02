'use client'

import { useState, useTransition } from 'react'
import { REMIND_HOUR_MIN, REMIND_HOUR_MAX, REMIND_CRON_HOUR_JST } from '@/lib/loop/remind'

/**
 * リマインドの入切（docs/11-ux.md §7・§10 の画面12）
 *
 * ★ 鍵が無ければ**この部品ごと描かれない**（app/settings/page.tsx が出し分ける）。
 *   「押しても何も起きないボタン」を置かない。
 *
 * ★ 許可の要求は**押されてから**にする。開いた瞬間に権限ダイアログを出すのは
 *   最も嫌われる作法で、しかも一度「ブロック」を押されると設定画面の奥からしか
 *   戻せない。何のための通知かを読んでから押せる順にする。
 *
 * ★ 断られたことを画面に書く。ブラウザの権限は JS から戻せないので、
 *   「許可しない」を選んだ人には、どこを操作すれば戻せるかを伝えるしかない。
 */

/**
 * base64url の VAPID 公開鍵を、pushManager が要る Uint8Array に直す
 *
 * ★ 返り値に `Uint8Array<ArrayBuffer>` と書く。TypeScript 5.7 以降、
 *   `new Uint8Array(n)` は `Uint8Array<ArrayBufferLike>` になり、
 *   `SharedArrayBuffer` を含みうるため `BufferSource` に代入できない。
 *   ArrayBuffer を先に作って被せると、そちらだと確定する。
 */
function urlBase64ToUint8Array(base64: string): Uint8Array<ArrayBuffer> {
  const padded = (base64 + '='.repeat((4 - base64.length % 4) % 4))
    .replace(/-/g, '+').replace(/_/g, '/')
  const raw = atob(padded)
  const out = new Uint8Array(new ArrayBuffer(raw.length))
  for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i)
  return out
}

/** ArrayBuffer を base64url にする（p256dh と auth の保存形式） */
function toBase64Url(buf: ArrayBuffer | null): string {
  if (!buf) return ''
  const bytes = new Uint8Array(buf)
  let s = ''
  for (const b of bytes) s += String.fromCharCode(b)
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
}

const HOURS = Array.from(
  { length: REMIND_HOUR_MAX - REMIND_HOUR_MIN + 1 },
  (_, i) => REMIND_HOUR_MIN + i,
)

export function PushToggle({
  vapidPublicKey, remindHour, subscribe, unsubscribe,
}: {
  vapidPublicKey: string
  /** すでに設定されている時刻。null なら通知は切れている */
  remindHour: number | null
  subscribe: (input: { endpoint: string; p256dh: string; auth: string; remindHour: number })
    => Promise<{ ok: boolean; message: string }>
  unsubscribe: (endpoint: string | null) => Promise<{ ok: boolean; message: string }>
}) {
  const [hour, setHour] = useState(remindHour ?? 20)
  const [on, setOn] = useState(remindHour !== null)
  const [msg, setMsg] = useState<string | null>(null)
  const [pending, start] = useTransition()

  const enable = () => start(async () => {
    setMsg(null)
    try {
      if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
        setMsg('このブラウザは通知に対応していません')
        return
      }
      const permission = await Notification.requestPermission()
      if (permission !== 'granted') {
        setMsg('通知が許可されませんでした。ブラウザの設定（サイトの権限）から変えられます。')
        return
      }
      const reg = await navigator.serviceWorker.ready
      const sub = await reg.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array(vapidPublicKey),
      })
      const r = await subscribe({
        endpoint: sub.endpoint,
        p256dh: toBase64Url(sub.getKey('p256dh')),
        auth: toBase64Url(sub.getKey('auth')),
        remindHour: hour,
      })
      setMsg(r.message)
      if (r.ok) setOn(true)
    } catch (e) {
      setMsg(e instanceof Error ? e.message : '通知を設定できませんでした')
    }
  })

  const disable = () => start(async () => {
    setMsg(null)
    let endpoint: string | null = null
    try {
      const reg = await navigator.serviceWorker?.ready
      const sub = await reg?.pushManager.getSubscription()
      if (sub) { endpoint = sub.endpoint; await sub.unsubscribe() }
    } catch { /* 端末側が既に無い。DB の行だけ消す */ }
    const r = await unsubscribe(endpoint)
    setMsg(r.message)
    if (r.ok) setOn(false)
  })

  return (
    <div className="lv-card">
      <div className="lv-card__pad hs-stack">
        <span className="lv-label">学習のリマインド</span>
        <p className="lv-caption">
          その日まだ1問も解いていないときだけ通知します。解いた日には送りません。
          いまは1日1回、{REMIND_CRON_HOUR_JST} 時ごろの配信なので、
          選んだ時刻はここでは「これ以降なら送ってよい時刻」として使います。
        </p>

        <div className="lv-field">
          <label className="lv-caption" htmlFor="remind-hour">通知してよい時刻</label>
          <select
            id="remind-hour" className="lv-input" value={hour} disabled={pending}
            onChange={e => setHour(Number(e.target.value))}
          >
            {HOURS.map(h => <option key={h} value={h}>{h}:00 以降</option>)}
          </select>
        </div>

        {!on ? (
          <button type="button" className="lv-btn lv-btn--block" disabled={pending} onClick={enable}>
            {pending ? '設定しています…' : '通知を受け取る'}
          </button>
        ) : (
          <>
            <button type="button" className="lv-btn lv-btn--block" disabled={pending} onClick={enable}>
              時刻を変える
            </button>
            <button type="button" className="lv-btn lv-btn--block" disabled={pending} onClick={disable}>
              通知を止める
            </button>
          </>
        )}
        {msg && <p className="lv-field-note" role="status">{msg}</p>}
      </div>
    </div>
  )
}
