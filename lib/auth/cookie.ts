/**
 * 登録の途中経過を持ち越す cookie
 *
 * ★ なぜ actions.ts から切り出しているか。
 *   'use server' を付けたファイルは **async 関数しか export できない**。
 *   定数を1つ混ぜるだけで「export が1つも無いモジュール」と判定され、
 *   Server Action の import が全て壊れる（next build が落ちる）。
 *   名前と設定は画面側からも要るので、素のモジュールに置く。
 *
 * ★ 招待コードを cookie に置くのは、Google の同意画面へ行って戻ってくる間、
 *   入力した内容を持ち越す先が他にないためである。
 *   httpOnly にして JavaScript から触れないようにし、
 *   登録が済んだら必ず消す（残すと使い回しの手がかりになる）。
 */

/** 招待コードを持ち越す cookie。登録が済んだら消す */
export const INVITE_COOKIE = 'historia_invite'

/** 1時間。ログインを挟むだけなので短くてよい */
export const INVITE_MAX_AGE = 60 * 60

/** 画面から cookie を書くための共通の指定 */
export const inviteCookieOptions = {
  httpOnly: true as const,
  sameSite: 'lax' as const,
  secure: process.env.NODE_ENV === 'production',
  path: '/',
}
