import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { randomUUID } from 'node:crypto'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { createUser } from '@/lib/loop/fixture'
import { signup, isRegistered, CONSENT_VERSION } from './signup'
import { MAX_USERS } from './invite'

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('サインアップ（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const LATER = new Date('2026-10-15T03:00:00Z')
  const OK_BIRTH = '2008-12-08'      // 17歳
  const YOUNG = '2012-01-01'         // 14歳

  beforeAll(async () => { ({ db, drop } = await createTestDb('historia_signup_test')) }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await db`TRUNCATE invite_code, app_user RESTART IDENTITY CASCADE`
    await db`INSERT INTO invite_code (code, expires_at) VALUES ('AAAA-BBBB', ${LATER})`
  })

  const uid = () => randomUUID()

  it('招待コードと生年月日が揃えば登録できる', async () => {
    const id = uid()
    expect(await signup(db, { userId: id, code: 'AAAA-BBBB', birthDate: OK_BIRTH }, NOW))
      .toEqual({ ok: true })

    const [row] = await db<{ birth_date: Date; consent_version: string;
                            guardian_consent_required: boolean }[]>`
      SELECT birth_date, consent_version, guardian_consent_required FROM app_user WHERE id = ${id}`
    expect(row!.consent_version).toBe(CONSENT_VERSION)
    // 16歳未満を受け付けないので、保護者同意は常に不要になる（docs/10 §5・作者判断）
    expect(row!.guardian_consent_required).toBe(false)
    expect(await isRegistered(db, id)).toBe(true)
  })

  it('登録すると招待コードが消し込まれる', async () => {
    const id = uid()
    await signup(db, { userId: id, code: 'AAAA-BBBB', birthDate: OK_BIRTH }, NOW)
    const [c] = await db`SELECT used_by FROM invite_code WHERE code = 'AAAA-BBBB'`
    expect(c!.used_by).toBe(id)
  })

  it('招待コードが無ければ登録できない（G1）', async () => {
    const r = await signup(db, { userId: uid(), code: 'ZZZZ-ZZZZ', birthDate: OK_BIRTH }, NOW)
    expect(r).toMatchObject({ ok: false, kind: 'invite' })
    expect(await db`SELECT count(*) FROM app_user`).toMatchObject([{ count: '0' }])
  })

  it('16歳未満は登録できない（docs/10 §5・作者判断）', async () => {
    const r = await signup(db, { userId: uid(), code: 'AAAA-BBBB', birthDate: YOUNG }, NOW)
    expect(r).toMatchObject({ ok: false, kind: 'age' })
    expect(await db`SELECT count(*) FROM app_user`).toMatchObject([{ count: '0' }])
  })

  /** 年齢で弾かれた人が席を1つ潰してしまうと、招待した意味がなくなる */
  it('年齢で断ったとき招待コードを消費しない', async () => {
    await signup(db, { userId: uid(), code: 'AAAA-BBBB', birthDate: YOUNG }, NOW)
    const [c] = await db`SELECT used_by FROM invite_code WHERE code = 'AAAA-BBBB'`
    expect(c!.used_by).toBeNull()
  })

  it('同じ人が二度登録しない', async () => {
    const id = uid()
    await signup(db, { userId: id, code: 'AAAA-BBBB', birthDate: OK_BIRTH }, NOW)
    await db`INSERT INTO invite_code (code, expires_at) VALUES ('CCCC-DDDD', ${LATER})`
    expect(await signup(db, { userId: id, code: 'CCCC-DDDD', birthDate: OK_BIRTH }, NOW))
      .toMatchObject({ ok: false, kind: 'already' })
  })

  it(`${MAX_USERS}人を超えて登録できない（G7）`, async () => {
    for (let i = 0; i < MAX_USERS; i++) await createUser(db, NOW)
    const r = await signup(db, { userId: uid(), code: 'AAAA-BBBB', birthDate: OK_BIRTH }, NOW)
    expect(r).toMatchObject({ ok: false, kind: 'invite' })
    if (!r.ok && r.kind === 'invite') expect(r.check.reason).toBe('full')
  })

  /**
   * ★ 順序が効く。invite_code.used_by は app_user を参照する外部キーなので、
   *   利用者を先に作らないと消し込めない。すると「コードが使えないのに
   *   利用者だけできる」が起こりうる。同じトランザクションで巻き戻すことでしか防げない。
   */
  it('コードが使えなければ利用者も作られない（巻き戻る）', async () => {
    const first = uid()
    await signup(db, { userId: first, code: 'AAAA-BBBB', birthDate: OK_BIRTH }, NOW)
    expect(await db`SELECT count(*) FROM app_user`).toMatchObject([{ count: '1' }])

    // 同じコードを2人目が使おうとする
    const second = uid()
    const r = await signup(db, { userId: second, code: 'AAAA-BBBB', birthDate: OK_BIRTH }, NOW)
    expect(r).toMatchObject({ ok: false, kind: 'invite' })
    if (!r.ok && r.kind === 'invite') expect(r.check.reason).toBe('used')

    // 2人目の app_user が残っていないこと（INSERT が巻き戻っている）
    expect(await db`SELECT count(*) FROM app_user`).toMatchObject([{ count: '1' }])
    expect(await isRegistered(db, second)).toBe(false)
  })

  /** 定員は「作る前」に数える。作ってから数えると本人が1つ数に入り、10人目が断られる */
  it(`${MAX_USERS}人目は登録できる（境界）`, async () => {
    for (let i = 0; i < MAX_USERS - 1; i++) await createUser(db, NOW)
    expect(await signup(db, { userId: uid(), code: 'AAAA-BBBB', birthDate: OK_BIRTH }, NOW))
      .toEqual({ ok: true })
    expect(await db`SELECT count(*) FROM app_user`).toMatchObject([{ count: String(MAX_USERS) }])
  })
})
