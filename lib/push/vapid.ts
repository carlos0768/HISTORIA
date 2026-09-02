/**
 * Web Push の鍵（VAPID）
 *
 * 仕様: docs/11-ux.md §7（リマインド）・docs/12-nonfunctional.md §10
 *
 * ★ 鍵が無ければ **黙って機能ごと消える**。例外を投げない。
 *   lib/ai/client.ts の resolveProvider と lib/db/optional.ts の tryDb() が
 *   同じ作法を採っている。鍵の無い Vercel のプレビューや、手元での意匠確認が
 *   通知のせいで壊れるのは筋が悪い。
 *
 * ★ 秘密鍵はリポジトリに書かない。環境変数だけから読む。
 *   鍵の作り方は `npx tsx scripts/push/gen-vapid.ts`（標準出力に出すだけで、
 *   ファイルには書かない）。
 *
 * ★ 公開鍵を NEXT_PUBLIC_ にしない。サーバ側の component から props で渡す。
 *   NEXT_PUBLIC_ にすると同じ値を2つの名前で持つことになり、
 *   片方だけ更新したときに購読が黙って壊れる。
 */

export type VapidKeys = {
  publicKey: string
  privateKey: string
  /** RFC 8292 の `sub`。連絡先。プッシュ配信元が障害時に使う */
  subject: string
}

/**
 * 鍵一式。1つでも欠けたら null。
 *
 * ★ 「公開鍵だけ在る」を有効と見なさない。購読はできるのに送信で必ず落ちる状態になり、
 *   利用者には「登録したのに来ない」としか見えない。
 */
export function vapidKeys(): VapidKeys | null {
  const publicKey = process.env.VAPID_PUBLIC_KEY?.trim()
  const privateKey = process.env.VAPID_PRIVATE_KEY?.trim()
  const subject = process.env.VAPID_SUBJECT?.trim()
  if (!publicKey || !privateKey || !subject) return null
  // mailto: か https: でなければ配信元に拒まれる（RFC 8292 §2.1）
  if (!/^(mailto:|https:\/\/)/.test(subject)) return null
  return { publicKey, privateKey, subject }
}

/** 通知の導線を出してよいか */
export function pushEnabled(): boolean {
  return vapidKeys() !== null
}

/** 画面へ渡す公開鍵。無効なら null（＝購読ボタンを出さない） */
export function publicVapidKey(): string | null {
  return vapidKeys()?.publicKey ?? null
}
