import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { readFileSync } from 'node:fs'
import { vapidKeys, pushEnabled, publicVapidKey } from './vapid'
import { cronAuthorized, cronSecretConfigured } from './cron-auth'

/**
 * Web Push の鍵と、定時実行の関門（docs/12-nonfunctional.md §10）
 *
 * ★ 守りたいのは2つ。
 *   1. 鍵が無いときに**黙って機能ごと消える**こと（押せないボタンを出さない）
 *   2. 定時実行の経路が**既定で閉じている**こと（proxy.ts が素通しするため）
 */

const KEYS = {
  VAPID_PUBLIC_KEY: 'BJxxPUBLICxx',
  VAPID_PRIVATE_KEY: 'xxPRIVATExx',
  VAPID_SUBJECT: 'mailto:a@example.com',
}

let saved: Record<string, string | undefined>
const ENV_KEYS = [...Object.keys(KEYS), 'CRON_SECRET']

beforeEach(() => {
  saved = Object.fromEntries(ENV_KEYS.map(k => [k, process.env[k]]))
  for (const k of ENV_KEYS) delete process.env[k]
})
afterEach(() => {
  for (const [k, v] of Object.entries(saved)) {
    if (v === undefined) delete process.env[k]
    else process.env[k] = v
  }
})

describe('VAPID の鍵', () => {
  it('3つ揃っていれば有効', () => {
    Object.assign(process.env, KEYS)
    expect(vapidKeys()).toEqual({
      publicKey: 'BJxxPUBLICxx', privateKey: 'xxPRIVATExx', subject: 'mailto:a@example.com',
    })
    expect(pushEnabled()).toBe(true)
    expect(publicVapidKey()).toBe('BJxxPUBLICxx')
  })

  it('1つも無ければ無効', () => {
    expect(vapidKeys()).toBeNull()
    expect(pushEnabled()).toBe(false)
    expect(publicVapidKey()).toBeNull()
  })

  /**
   * ★ 「公開鍵だけ在る」を有効と見なさない。購読はできるのに送信で必ず落ち、
   *   利用者には「登録したのに来ない」としか見えない
   */
  it('秘密鍵だけ欠けていても無効にする', () => {
    Object.assign(process.env, KEYS)
    delete process.env.VAPID_PRIVATE_KEY
    expect(pushEnabled()).toBe(false)
  })

  it('連絡先が欠けていても無効にする', () => {
    Object.assign(process.env, KEYS)
    delete process.env.VAPID_SUBJECT
    expect(pushEnabled()).toBe(false)
  })

  /** RFC 8292 §2.1。mailto: か https: でなければ配信元に拒まれる */
  it('連絡先が mailto: でも https: でもなければ無効にする', () => {
    Object.assign(process.env, KEYS, { VAPID_SUBJECT: 'a@example.com' })
    expect(pushEnabled()).toBe(false)
    process.env.VAPID_SUBJECT = 'https://historia.example/contact'
    expect(pushEnabled()).toBe(true)
  })

  it('空白だけの値は未設定と同じに扱う', () => {
    Object.assign(process.env, KEYS, { VAPID_PUBLIC_KEY: '   ' })
    expect(pushEnabled()).toBe(false)
  })
})

describe('定時実行の関門', () => {
  it('秘密が未設定なら誰も通さない（既定は閉）', async () => {
    expect(cronSecretConfigured()).toBe(false)
    expect(await cronAuthorized('Bearer anything', undefined)).toBe(false)
    expect(await cronAuthorized(null, undefined)).toBe(false)
  })

  it('正しい秘密なら通す', async () => {
    expect(await cronAuthorized('Bearer s3cret', 's3cret')).toBe(true)
  })

  it('違う秘密は通さない', async () => {
    expect(await cronAuthorized('Bearer wrong!', 's3cret')).toBe(false)
  })

  it('長さが違っても例外を投げずに false を返す', async () => {
    expect(await cronAuthorized('Bearer s3', 's3cret')).toBe(false)
    expect(await cronAuthorized('Bearer s3cretcretcret', 's3cret')).toBe(false)
  })

  it('Bearer が無い形は通さない', async () => {
    expect(await cronAuthorized('s3cret', 's3cret')).toBe(false)
    expect(await cronAuthorized('Basic s3cret', 's3cret')).toBe(false)
  })

  it('ヘッダが無ければ通さない', async () => {
    expect(await cronAuthorized(null, 's3cret')).toBe(false)
    expect(await cronAuthorized('', 's3cret')).toBe(false)
  })
})

describe('定時実行の経路の扱い', () => {
  const route = readFileSync('app/api/cron/route.ts', 'utf8')
  const proxy = readFileSync('proxy.ts', 'utf8')

  /**
   * ★ proxy.ts はこの経路を素通しする（cron は session を持たないため）。
   *   素通しと、route.ts 側の関門は**対で意味を持つ**。片方だけ消えると
   *   「誰でも叩ける通知送信 API」になる。両方を同時に見る。
   */
  it('proxy は /api/cron を素通しし、route が自分で閉じている', () => {
    expect(proxy).toContain("'/api/cron'")
    expect(route).toContain('cronAuthorized')
  })

  it('拒むときは 401 ではなく 404（docs/10 G2 と同じ作法）', () => {
    expect(route).toContain('status: 404')
    expect(route).not.toContain('status: 401')
  })

  /** web-push は node:crypto を使う。Edge では動かない */
  it('Node ランタイムを明示している', () => {
    expect(route).toContain("export const runtime = 'nodejs'")
  })

  /** docs/12:172「cron の実行結果を記録し、24時間無ければ警告」 */
  it('実行のたび ops_log に残す。失敗しても残す', () => {
    expect(route).toContain('INSERT INTO ops_log')
    expect(route).toContain("log('remind', false")
    expect(route).toContain("log('reap_reservations', false")
  })

  /** 呼び出し元が無かった掃除を、ここから呼ぶ */
  it('取り残された予約の解放を呼ぶ', () => {
    expect(route).toContain('reapStaleReservations')
  })
})
