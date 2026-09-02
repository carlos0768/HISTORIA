/**
 * サインアップ（招待コードの消し込み＋利用者の作成）
 *
 * 仕様: docs/03 §7 / docs/10 §3.2 G1・G7 / §5
 *
 * ★ 招待コードの消し込みと app_user の作成を1つのトランザクションで行う。
 *   分けると、コードを消し込んだのに利用者が作られない（席が1つ死ぬ）か、
 *   利用者が作られたのにコードが残る（使い回せる）かのどちらかが起きる。
 *
 * ★ app_user.id は auth.users.id と同じ uuid にする。
 *   schema.sql §3 のコメントどおり、単体で検証できるよう外部キーは張っていない。
 *   だからここで揃えることが唯一の担保になる。
 */
import type { Sql } from 'postgres'
import { consumeInvite, isFull, type InviteCheck } from './invite'
import { checkBirthDate, type AgeCheck } from './age'

/** 同意した規約・プライバシーポリシーの版。変えたら再同意を取る */
export const CONSENT_VERSION = 'v1'

export type SignupInput = {
  /** auth.users.id */
  userId: string
  code: string
  birthDate: string
  displayName?: string | null
}

export type SignupResult =
  | { ok: true }
  | { ok: false; kind: 'age'; check: Extract<AgeCheck, { ok: false }> }
  | { ok: false; kind: 'invite'; check: Extract<InviteCheck, { ok: false }> }
  | { ok: false; kind: 'already' }

/**
 * 登録する。
 *
 * ★ 年齢は DB に触る前に見る。16歳未満（docs/10 §5・作者判断）を
 *   受け付けないので、弾くものを先に弾いてから席を押さえる。
 */
export async function signup(db: Sql, input: SignupInput, now: Date): Promise<SignupResult> {
  const age = checkBirthDate(input.birthDate, now)
  if (!age.ok) return { ok: false, kind: 'age', check: age }

  const [existing] = await db`SELECT id FROM app_user WHERE id = ${input.userId}`
  if (existing) return { ok: false, kind: 'already' }

  return db.begin(async tx => {
    // ★ 定員は「作る前」に数える。作ってから数えると本人が1つ数に入り、
    //   10人目が断られる（G7 は10名まで受け入れる、という意味である）
    if (await isFull(tx)) {
      return { ok: false, kind: 'invite', check: { ok: false, reason: 'full' } } as SignupResult
    }

    // ★ 利用者が先。invite_code.used_by は app_user を参照する外部キーなので、
    //   コードを先に消し込もうとすると必ず失敗する（実DBで踏んだ）。
    await tx`
      INSERT INTO app_user (id, display_name, birth_date,
                            guardian_consent_required, consent_version, consent_at)
      VALUES (${input.userId}, ${input.displayName ?? null}, ${input.birthDate},
              false, ${CONSENT_VERSION}, ${now})`

    const used = await consumeInvite(tx, input.code, input.userId, now)
    if (!used.ok) {
      // 同じトランザクションなので、投げれば上の INSERT ごと巻き戻る。
      // 「コードが使えないのに利用者だけできる」を防ぐ唯一の方法である
      throw new SignupRollback({ ok: false, kind: 'invite', check: used })
    }
    return { ok: true } as SignupResult
  }).catch((e: unknown) => {
    if (e instanceof SignupRollback) return e.result
    throw e
  })
}

/** 巻き戻しのためだけの例外。外へは漏らさない */
class SignupRollback extends Error {
  constructor(readonly result: SignupResult) { super('signup rollback') }
}

/** 登録済みかどうか。ログイン直後にプロフィール入力へ回すかの判断に使う */
export async function isRegistered(db: Sql, userId: string): Promise<boolean> {
  const [row] = await db`SELECT 1 FROM app_user WHERE id = ${userId}`
  return row !== undefined
}
