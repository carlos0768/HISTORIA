import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { readFileSync } from 'node:fs'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createKcs } from './fixture'
import {
  remindTargets, sendReminders, remindMessage,
  REMIND_CRON_HOUR_JST, REMIND_HOUR_MIN, REMIND_HOUR_MAX,
  type PushTarget, type Notification,
} from './remind'
import { jstDate, jstHour, jstDayStart } from '@/lib/domain/jst'

/**
 * リマインド（docs/11-ux.md §7・docs/12-nonfunctional.md §10）
 *
 * ★ ここで守りたいのは「**送りすぎない**」ことである。
 *   もう解いた人に催促を送る、同じ日に2通送る、端末ごとに別の催促が届く。
 *   どれも1回起きれば通知そのものが読まれなくなり、機能が死ぬ。
 */

describe('日本時間の扱い（lib/domain/jst.ts）', () => {
  it('深夜0〜9時は「その日」に入る（UTC のままだと前日になる）', () => {
    // 日本時間 2026-09-15 00:30 = UTC 2026-09-14 15:30
    const d = new Date('2026-09-14T15:30:00Z')
    expect(jstDate(d)).toBe('2026-09-15')
    expect(jstHour(d)).toBe(0)
    // ★ 逆対照。UTC で数えると前日になる
    expect(d.toISOString().slice(0, 10)).toBe('2026-09-14')
  })

  it('日本時間の1日の始まりは UTC の前日15時', () => {
    expect(jstDayStart('2026-09-15').toISOString()).toBe('2026-09-14T15:00:00.000Z')
  })

  it('20 時は 20 と読む', () => {
    expect(jstHour(new Date('2026-09-15T11:00:00Z'))).toBe(20)
  })
})

describe('cron の時刻と設定の範囲がずれていないこと', () => {
  /**
   * ★ vercel.json の cron と REMIND_CRON_HOUR_JST は**同じ時刻を指していなければならない**。
   *   片方だけ直すと、設定画面では選べるのに永遠に届かない時刻が生まれる。
   *   人が気づける類のずれではないので、機械に見張らせる。
   */
  it('vercel.json の cron が REMIND_CRON_HOUR_JST と一致する', () => {
    const vercel = JSON.parse(readFileSync('vercel.json', 'utf8')) as {
      crons?: { path: string; schedule: string }[]
    }
    const cron = vercel.crons?.find(c => c.path === '/api/cron')
    expect(cron, 'vercel.json に /api/cron の cron が無い').toBeDefined()

    const [minute, hour] = cron!.schedule.split(' ')
    expect(minute).toBe('0')
    // schedule は UTC。日本時間に直して比べる
    const jst = (Number(hour) + 9) % 24
    expect(jst).toBe(REMIND_CRON_HOUR_JST)
  })

  it('選ばせる時刻の上限は cron の時刻を超えない（届かない時刻を選ばせない）', () => {
    expect(REMIND_HOUR_MAX).toBeLessThanOrEqual(REMIND_CRON_HOUR_JST)
    expect(REMIND_HOUR_MIN).toBeLessThan(REMIND_HOUR_MAX)
  })
})

describe('本文', () => {
  const base = { userId: 'u', displayName: null, subscriptions: [] }

  it('件数を出す（「勉強しましょう」だけにしない）', () => {
    expect(remindMessage({ ...base, dueCount: 12 }).body).toContain('12 件')
  })

  it('0件でも急かさない文にする', () => {
    const m = remindMessage({ ...base, dueCount: 0 })
    expect(m.body).toContain('1問だけでも')
    expect(m.body).not.toContain('0 件')
  })

  /**
   * ★ 本文は配信元（FCM など）を通る。中身は暗号化されているが、
   *   配信元は「誰がいつ受け取ったか」を見られる。学習内容は書かない
   */
  it('単元名や設問を入れない', () => {
    const m = remindMessage({ ...base, dueCount: 3 })
    expect(m.title).toBe('HISTORIA')
    expect(m.url).toBe('/study')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('送る相手の選別（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  let userId: string
  /** 日本時間 2026-09-15（火）20:00 */
  const NOW = new Date('2026-09-15T11:00:00Z')
  const TODAY = '2026-09-15'
  const UNIT = 'wh.2.1.1'

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_remind_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    for (const t of ['push_subscription', 'user_activity', 'kc_card', 'response',
                     'user_kc_state', 'kc_syllabus_unit', 'kc_region', 'kc', 'app_user']) {
      await db.unsafe(`DELETE FROM ${t}`)
    }
    userId = await createUser(db, NOW)
    await db`UPDATE app_user SET remind_hour = 20 WHERE id = ${userId}`
  })

  const subscribe = async (endpoint = 'https://push.example/aaa', uid?: string) => {
    await db`INSERT INTO push_subscription (endpoint, user_id, p256dh, auth)
             VALUES (${endpoint}, ${uid ?? userId}, 'p256', 'auth')`
    return endpoint
  }
  const studiedToday = (day = TODAY) =>
    db`INSERT INTO user_activity (user_id, activity_date, responses)
       VALUES (${userId}, ${day}, 1)`

  it('通知を設定して今日まだ解いていない人に送る', async () => {
    await subscribe()
    const t = await remindTargets(db, NOW)
    expect(t).toHaveLength(1)
    expect(t[0]!.userId).toBe(userId)
    expect(t[0]!.subscriptions).toHaveLength(1)
  })

  it('今日もう解いた人には送らない', async () => {
    await subscribe()
    await studiedToday()
    expect(await remindTargets(db, NOW)).toHaveLength(0)
  })

  it('昨日解いただけの人には送る（逆対照: 日付で絞れている）', async () => {
    await subscribe()
    await studiedToday('2026-09-14')
    expect(await remindTargets(db, NOW)).toHaveLength(1)
  })

  /**
   * ★ 日本時間の深夜0〜9時。UTC で数えると前日扱いになり、
   *   「0:30 に解いた」が翌日の催促を止められない
   */
  it('日本時間 0:30 に解いた分は、その日の学習として数える', async () => {
    await subscribe()
    await db`INSERT INTO user_activity (user_id, activity_date, responses)
             VALUES (${userId}, ${jstDate(new Date('2026-09-14T15:30:00Z'))}, 1)`
    expect(await remindTargets(db, NOW)).toHaveLength(0)
  })

  it('通知を設定していない人には送らない', async () => {
    await subscribe()
    await db`UPDATE app_user SET remind_hour = NULL WHERE id = ${userId}`
    expect(await remindTargets(db, NOW)).toHaveLength(0)
  })

  it('購読先が無い人には送らない', async () => {
    expect(await remindTargets(db, NOW)).toHaveLength(0)
  })

  it('設定した時刻より前には送らない', async () => {
    await subscribe()
    // 日本時間 10:00
    expect(await remindTargets(db, new Date('2026-09-15T01:00:00Z'))).toHaveLength(0)
  })

  it('設定した時刻を過ぎていれば送る', async () => {
    await subscribe()
    await db`UPDATE app_user SET remind_hour = 18 WHERE id = ${userId}`
    expect(await remindTargets(db, NOW)).toHaveLength(1)
  })

  it('今日もう送った人には送らない（1日1通）', async () => {
    await subscribe()
    await db`UPDATE push_subscription SET last_sent_at = ${NOW} WHERE user_id = ${userId}`
    expect(await remindTargets(db, NOW)).toHaveLength(0)
  })

  it('昨日送っただけなら今日は送る（逆対照）', async () => {
    await subscribe()
    await db`UPDATE push_subscription SET last_sent_at = ${new Date('2026-09-14T11:00:00Z')}
              WHERE user_id = ${userId}`
    expect(await remindTargets(db, NOW)).toHaveLength(1)
  })

  it('端末が2台あっても1人ぶんにまとめる', async () => {
    await subscribe('https://push.example/aaa')
    await subscribe('https://push.example/bbb')
    const t = await remindTargets(db, NOW)
    expect(t).toHaveLength(1)
    expect(t[0]!.subscriptions.map(s => s.endpoint).sort())
      .toEqual(['https://push.example/aaa', 'https://push.example/bbb'])
  })

  it('片方の端末で今日すでに送っていたら、もう片方にも送らない', async () => {
    await subscribe('https://push.example/aaa')
    await subscribe('https://push.example/bbb')
    await db`UPDATE push_subscription SET last_sent_at = ${NOW}
              WHERE endpoint = 'https://push.example/aaa'`
    expect(await remindTargets(db, NOW)).toHaveLength(0)
  })

  it('他人の購読先を自分のぶんとして数えない', async () => {
    const other = await createUser(db, NOW)
    await db`UPDATE app_user SET remind_hour = NULL WHERE id = ${other}`
    await subscribe('https://push.example/other', other)
    expect(await remindTargets(db, NOW)).toHaveLength(0)
  })

  it('期限の来た枚数を数える（停止したカードは除く）', async () => {
    await subscribe()
    await createKcs(db, ['kc.a', 'kc.b', 'kc.c'], UNIT)
    const past = new Date('2026-09-14T00:00:00Z')
    const future = new Date('2026-09-20T00:00:00Z')
    await db`INSERT INTO kc_card (user_id, kc_id, due_at) VALUES (${userId}, 'kc.a', ${past})`
    await db`INSERT INTO kc_card (user_id, kc_id, due_at) VALUES (${userId}, 'kc.b', ${future})`
    await db`INSERT INTO kc_card (user_id, kc_id, due_at, suspended)
             VALUES (${userId}, 'kc.c', ${past}, true)`
    const t = await remindTargets(db, NOW)
    expect(t[0]!.dueCount).toBe(1)
  })

  describe('送信', () => {
    /** 送信の偽物。ネットワークへ出ない */
    const collector = () => {
      const sent: { endpoint: string; body: string }[] = []
      const fn = async (target: PushTarget, payload: Notification) => {
        sent.push({ endpoint: target.endpoint, body: payload.body })
        return { ok: true }
      }
      return { sent, fn }
    }

    it('送ったら last_sent_at が入り、2回目は送らない', async () => {
      await subscribe()
      const c = collector()
      const r1 = await sendReminders(db, NOW, c.fn)
      expect(r1).toEqual({ users: 1, sent: 1, failed: 0, pruned: 0 })

      const r2 = await sendReminders(db, NOW, c.fn)
      expect(r2.users).toBe(0)
      expect(c.sent).toHaveLength(1)
    })

    it('端末が2台なら2通送るが、記録は1日ぶん', async () => {
      await subscribe('https://push.example/aaa')
      await subscribe('https://push.example/bbb')
      const c = collector()
      const r = await sendReminders(db, NOW, c.fn)
      expect(r.sent).toBe(2)
      expect(c.sent.map(s => s.body)).toEqual([c.sent[0]!.body, c.sent[0]!.body])
      expect(await remindTargets(db, NOW)).toHaveLength(0)
    })

    /**
     * ★ 404 / 410 は「その購読先はもう無い」。消さないと、機種変更のたびに
     *   死んだ行が溜まり、毎晩そこへ送ろうとして失敗し続ける
     */
    it('失効した購読先は消す', async () => {
      await subscribe()
      const r = await sendReminders(db, NOW, async () => ({ ok: false, gone: true }))
      expect(r).toEqual({ users: 1, sent: 0, failed: 1, pruned: 1 })
      const rows = await db`SELECT endpoint FROM push_subscription`
      expect(rows).toHaveLength(0)
    })

    it('一時的な失敗では消さない（逆対照: gone のときだけ消える）', async () => {
      await subscribe()
      const r = await sendReminders(db, NOW, async () => ({ ok: false }))
      expect(r.pruned).toBe(0)
      const rows = await db`SELECT endpoint FROM push_subscription`
      expect(rows).toHaveLength(1)
    })

    it('全部失敗した日は「送った」ことにしない（翌日また対象になる）', async () => {
      await subscribe()
      await sendReminders(db, NOW, async () => ({ ok: false }))
      const [s] = await db<{ last_sent_at: Date | null }[]>`
        SELECT last_sent_at FROM push_subscription`
      expect(s!.last_sent_at).toBeNull()
      expect(await remindTargets(db, NOW)).toHaveLength(1)
    })
  })
})
