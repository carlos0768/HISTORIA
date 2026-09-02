/**
 * 招待コード
 *
 * 仕様: docs/10-legal-risk.md §3.2
 *   G1 招待コードなしにアカウントを作れない
 *   G7 利用者数の上限を設ける（発行上限 10名）
 *
 * ★ 上限は2箇所で見る。
 *   発行側（invite_code の件数）だけを見ていると、1つのコードを使い回されたときに
 *   利用者が11人になりうる。使用側（app_user の件数）でも数える。
 *
 * ★ 判定と消し込みを1つのトランザクションで行う。
 *   「空いているか確かめる」と「使う」の間に他の登録が入ると上限を越える。
 */
import type { Sql, TransactionSql } from 'postgres'

/** docs/10 G7。この数を超えて利用者を作らない */
export const MAX_USERS = 10

export type InviteCheck =
  | { ok: true }
  | { ok: false; reason: 'not_found' | 'used' | 'expired' | 'full' }

export const inviteError = (reason: Exclude<InviteCheck, { ok: true }>['reason']): string => ({
  not_found: '招待コードが違います',
  used: 'この招待コードは使用済みです',
  expired: 'この招待コードは期限が切れています',
  full: '定員に達しています（上限10名）',
}[reason])

type Row = { used_by: string | null; expired: boolean }

/**
 * コードが今つかえるかを見る。まだ消し込まない。
 * 入力画面で「違います」を出すためだけに使う。
 */
export async function checkInvite(db: Sql, code: string, now: Date): Promise<InviteCheck> {
  if (!code.trim()) return { ok: false, reason: 'not_found' }

  const [row] = await db<Row[]>`
    SELECT used_by, expires_at <= ${now} AS expired
      FROM invite_code WHERE code = ${code.trim()}`
  if (!row) return { ok: false, reason: 'not_found' }
  if (row.used_by) return { ok: false, reason: 'used' }
  if (row.expired) return { ok: false, reason: 'expired' }

  if (await isFull(db)) return { ok: false, reason: 'full' }
  return { ok: true }
}

/** 利用者が上限に達しているか */
export async function isFull(db: Sql | TransactionSql): Promise<boolean> {
  const [n] = await db<{ count: string }[]>`SELECT count(*) FROM app_user`
  return Number(n!.count) >= MAX_USERS
}

/**
 * コードを1つ消し込む。
 *
 * ★ UPDATE の WHERE で未使用と期限を見る。SELECT してから UPDATE すると、
 *   その隙に同じコードが使われうる。1文で決める。
 *
 * ★ 定員（G7）はここでは見ない。signup() が利用者を作る前に見る。
 *   invite_code.used_by は app_user を参照する外部キーなので、
 *   **利用者を作ってからでないと消し込めない**。この順序だと
 *   ここで数えた時点の件数には作ったばかりの本人が入ってしまい、
 *   10人目が「定員です」と断られる。数えるのは作る前でなければならない。
 */
export async function consumeInvite(
  tx: TransactionSql, code: string, userId: string, now: Date,
): Promise<InviteCheck> {
  const updated = await tx`
    UPDATE invite_code SET used_by = ${userId}, used_at = ${now}
     WHERE code = ${code.trim()} AND used_by IS NULL AND expires_at > ${now}`
  if (updated.count === 1) return { ok: true }

  // 効かなかった理由を返す。無い／使用済み／期限切れの区別は利用者に出す
  const [row] = await tx<Row[]>`
    SELECT used_by, expires_at <= ${now} AS expired
      FROM invite_code WHERE code = ${code.trim()}`
  if (!row) return { ok: false, reason: 'not_found' }
  if (row.used_by) return { ok: false, reason: 'used' }
  return { ok: false, reason: 'expired' }
}

/**
 * 招待コードを発行する。
 *
 * ★ 発行側でも上限を見る。まだ使われていないコードも席を1つ押さえているとみなし、
 *   「利用者 ＋ 未使用のコード」が上限を超えないようにする。
 *   そうしないと10枚配ってから10人が登録し、作者自身が入れなくなる。
 */
export async function issueInvite(
  db: Sql, opts: { code: string; expiresAt: Date; issuedBy?: string | null },
): Promise<{ ok: true } | { ok: false; reason: 'full' | 'duplicate' }> {
  const [n] = await db<{ count: string }[]>`
    SELECT (SELECT count(*) FROM app_user)
         + (SELECT count(*) FROM invite_code WHERE used_by IS NULL) AS count`
  if (Number(n!.count) >= MAX_USERS) return { ok: false, reason: 'full' }

  const done = await db`
    INSERT INTO invite_code (code, issued_by, expires_at)
    VALUES (${opts.code}, ${opts.issuedBy ?? null}, ${opts.expiresAt})
    ON CONFLICT (code) DO NOTHING`
  return done.count === 1 ? { ok: true } : { ok: false, reason: 'duplicate' }
}

/** 読みやすく、紛らわしい文字を含まないコードを作る */
export function generateCode(random: () => number = Math.random): string {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'   // I,O,0,1 を除く
  const pick = () => alphabet[Math.floor(random() * alphabet.length)]!
  const group = () => Array.from({ length: 4 }, pick).join('')
  return `${group()}-${group()}`
}
