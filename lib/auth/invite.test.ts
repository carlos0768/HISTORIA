import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { createUser } from '@/lib/loop/fixture'
import {
  checkInvite, consumeInvite, issueInvite, isFull, generateCode, inviteError, MAX_USERS,
} from './invite'

describe('招待コードの文字列', () => {
  it('紛らわしい文字を含まない（I O 0 1）', () => {
    for (let i = 0; i < 200; i++) {
      expect(generateCode()).not.toMatch(/[IO01]/)
    }
  })
  it('4文字ずつ2組', () => {
    expect(generateCode()).toMatch(/^[A-Z2-9]{4}-[A-Z2-9]{4}$/)
  })
  it('乱数を差し替えれば決まった値になる', () => {
    expect(generateCode(() => 0)).toBe('AAAA-AAAA')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('招待コード（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const LATER = new Date('2026-10-15T03:00:00Z')

  beforeAll(async () => { ({ db, drop } = await createTestDb('historia_invite_test')) }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await db`TRUNCATE invite_code, app_user RESTART IDENTITY CASCADE`
  })

  const put = (code: string, expires = LATER) =>
    db`INSERT INTO invite_code (code, expires_at) VALUES (${code}, ${expires})`

  describe('checkInvite', () => {
    it('未使用で期限内なら通る', async () => {
      await put('AAAA-BBBB')
      expect(await checkInvite(db, 'AAAA-BBBB', NOW)).toEqual({ ok: true })
    })

    it('前後の空白を落として照合する', async () => {
      await put('AAAA-BBBB')
      expect(await checkInvite(db, '  AAAA-BBBB  ', NOW)).toEqual({ ok: true })
    })

    it('無いコードは not_found', async () => {
      expect(await checkInvite(db, 'ZZZZ-ZZZZ', NOW)).toMatchObject({ reason: 'not_found' })
    })

    it('空文字は not_found（SQL を投げる前に落とす）', async () => {
      expect(await checkInvite(db, '   ', NOW)).toMatchObject({ reason: 'not_found' })
    })

    it('期限切れは expired', async () => {
      await put('AAAA-BBBB', new Date('2026-09-01T00:00:00Z'))
      expect(await checkInvite(db, 'AAAA-BBBB', NOW)).toMatchObject({ reason: 'expired' })
    })

    it('使用済みは used', async () => {
      const uid = await createUser(db, NOW)
      await put('AAAA-BBBB')
      await db.begin(tx => consumeInvite(tx, 'AAAA-BBBB', uid, NOW))
      expect(await checkInvite(db, 'AAAA-BBBB', NOW)).toMatchObject({ reason: 'used' })
    })
  })

  describe('consumeInvite', () => {
    it('消し込むと used_by と used_at が入る', async () => {
      const uid = await createUser(db, NOW)
      await put('AAAA-BBBB')
      expect(await db.begin(tx => consumeInvite(tx, 'AAAA-BBBB', uid, NOW))).toEqual({ ok: true })
      const [row] = await db`SELECT used_by, used_at FROM invite_code WHERE code = 'AAAA-BBBB'`
      expect(row!.used_by).toBe(uid)
      expect(row!.used_at).not.toBeNull()
    })

    /** 同じコードで2人目が入れてしまうと G1（招待制）が崩れる */
    it('同じコードを二度は使えない', async () => {
      const a = await createUser(db, NOW)
      const b = await createUser(db, NOW)
      await put('AAAA-BBBB')
      expect(await db.begin(tx => consumeInvite(tx, 'AAAA-BBBB', a, NOW))).toEqual({ ok: true })
      expect(await db.begin(tx => consumeInvite(tx, 'AAAA-BBBB', b, NOW))).toMatchObject({ reason: 'used' })
    })

    it('期限切れは消し込めない', async () => {
      const uid = await createUser(db, NOW)
      await put('AAAA-BBBB', new Date('2026-09-01T00:00:00Z'))
      expect(await db.begin(tx => consumeInvite(tx, 'AAAA-BBBB', uid, NOW))).toMatchObject({ reason: 'expired' })
    })
  })

  describe('上限10名（docs/10 G7）', () => {
    const fill = async (n: number) => {
      for (let i = 0; i < n; i++) await createUser(db, NOW)
    }

    it(`${MAX_USERS}人までは埋まっていない`, async () => {
      await fill(MAX_USERS - 1)
      expect(await isFull(db)).toBe(false)
    })

    it(`${MAX_USERS}人ちょうどで埋まる`, async () => {
      await fill(MAX_USERS)
      expect(await isFull(db)).toBe(true)
    })

    /**
     * 発行側だけを見ていると、コードを使い回されて11人目が入る。
     * 入力画面で断れるよう checkInvite が見る。
     * 消し込み側（consumeInvite）は定員を見ない——利用者を作った後に呼ばれるため、
     * そこで数えると本人が1つ数に入って10人目を誤って断ってしまう。
     * 定員は signup() が「作る前」に見る（signup.test.ts）。
     */
    it('定員に達していれば入力の時点で断る', async () => {
      await put('AAAA-BBBB')
      await fill(MAX_USERS)
      expect(await checkInvite(db, 'AAAA-BBBB', NOW)).toMatchObject({ reason: 'full' })
    })
  })

  describe('issueInvite', () => {
    it('発行できる', async () => {
      expect(await issueInvite(db, { code: 'AAAA-BBBB', expiresAt: LATER })).toEqual({ ok: true })
    })

    it('同じコードは二度発行しない', async () => {
      await issueInvite(db, { code: 'AAAA-BBBB', expiresAt: LATER })
      expect(await issueInvite(db, { code: 'AAAA-BBBB', expiresAt: LATER })).toMatchObject({ reason: 'duplicate' })
    })

    /**
     * 未使用のコードも席を1つ押さえているとみなす。
     * そうしないと10枚配ってから10人が登録し、作者自身が入れなくなる。
     */
    it('利用者＋未使用のコードで上限を数える', async () => {
      await createUser(db, NOW)                       // 1人
      for (let i = 0; i < MAX_USERS - 1; i++) {       // 残り9枠をコードで埋める
        expect(await issueInvite(db, { code: `CODE-${i}`, expiresAt: LATER })).toEqual({ ok: true })
      }
      expect(await issueInvite(db, { code: 'OVER-FLOW', expiresAt: LATER })).toMatchObject({ reason: 'full' })
    })
  })

  it('断る理由を日本語で出せる', () => {
    expect(inviteError('full')).toContain('10')
    expect(inviteError('used')).toContain('使用済み')
  })
})
