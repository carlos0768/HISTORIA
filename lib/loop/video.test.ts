import { describe, it, expect, beforeAll, afterAll, beforeEach, afterEach } from 'vitest'
import { readFileSync, writeFileSync, mkdirSync, mkdtempSync, rmSync } from 'node:fs'
import { join } from 'node:path'
import { tmpdir } from 'node:os'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, seedVideo, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createKcs, createItem } from './fixture'
import { videosForKcs, recordView, retrievalAfterVideo, WATCHED_RATIO } from './video'
import { submitAnswer } from './answer'

/**
 * ★ 埋め込みの安全性は「動くこと」ではなく「**やらないこと**」で決まる。
 *   ソースを読んで確かめる。描画の試験だけでは、うっかり
 *   初期表示に iframe を置いたことに気づけない。
 */
describe('2クリック埋め込み（docs/09b V3・§5.1）', () => {
  const src = readFileSync('components/video-embed.tsx', 'utf8')

  it('iframe は playing のときにしか描かない', () => {
    // {playing ? ( <iframe … ) : ( サムネイル )} の形であること
    const iframeAt = src.indexOf('<iframe')
    const ternaryAt = src.indexOf('{playing ? (')
    expect(ternaryAt).toBeGreaterThan(-1)
    expect(iframeAt).toBeGreaterThan(ternaryAt)
    // 初期値が false（開いただけでは再生しない）
    expect(src).toContain('useState(false)')
  })

  it('自動再生しない', () => {
    // ★ ファイル全体で見ない。コメントに「autoplay は付けない」と書くと
    //   その語で引っかかり、検査が空回りする（実際に一度そうなった）。
    //   iframe に渡す URL を組み立てている行だけを見る。
    const srcLine = src.split('\n').filter(l => l.includes('youtube-nocookie.com/embed') ||
                                                l.includes('modestbranding')).join(' ')
    expect(srcLine).not.toContain('autoplay')
    expect(srcLine.length).toBeGreaterThan(0)
  })

  it('cookie を置かない配信元と、関連動画の抑制、全画面への飛び出し防止', () => {
    expect(src).toContain('youtube-nocookie.com')
    expect(src).toContain('rel=0')
    expect(src).toContain('playsinline=1')
  })

  it('サムネイルは遅延読み込みにする（5本あってもサムネ5枚しか読まない）', () => {
    expect(src).toContain('loading="lazy"')
  })

  it('再生前に「YouTube に情報が送信される」と書く', () => {
    expect(src).toContain('YouTube（Google）に情報が送信されます')
  })
})

describe('CSP が埋め込みを通す（docs/09b §5.3）', () => {
  const proxy = readFileSync('proxy.ts', 'utf8')
  it('frame-src と img-src が要る先だけを許している', () => {
    expect(proxy).toContain('frame-src https://www.youtube-nocookie.com')
    expect(proxy).toContain('https://i.ytimg.com')
    // ★ 実行時に API を呼ばないので connect-src は広げない（V1）
    expect(proxy).toContain("connect-src 'self'")
    expect(proxy).not.toContain('connect-src \'self\' https://www.googleapis.com')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('動画（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  let userId: string
  const NOW = new Date('2026-09-15T03:00:00Z')
  const UNIT = 'wh.2.1.1'
  const CH = 'UCtest0000000000000000'

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_video_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    for (const t of ['video_view', 'video_kc', 'video', 'channel_allowlist',
                     'response', 'user_activity', 'user_kc_state', 'kc_card',
                     'item_kc', 'item', 'kc_syllabus_unit', 'kc_region', 'kc', 'app_user']) {
      await db.unsafe(`DELETE FROM ${t}`)
    }
    userId = await createUser(db, NOW)
    await db`
      INSERT INTO channel_allowlist (channel_id, channel_title, subject_scope)
      VALUES (${CH}, 'テスト講座', 'world_history')`
  })

  const addVideo = async (id: string, o: {
    status?: string; duration?: number; embeddable?: boolean; rating?: string | null
  } = {}) => {
    await db`
      INSERT INTO video (id, title, channel_id, duration_sec, embeddable, yt_rating, status)
      VALUES (${id}, ${`動画 ${id}`}, ${CH}, ${o.duration ?? 600},
              ${o.embeddable ?? true}, ${o.rating ?? null}, ${o.status ?? 'approved'})`
    return id
  }
  const link = async (videoId: string, kcId: string, relevance = 1.0, startSec = 0) =>
    db`INSERT INTO video_kc (video_id, kc_id, start_sec, relevance, source)
       VALUES (${videoId}, ${kcId}, ${startSec}, ${relevance}, 'manual')`

  it('KC に紐づく動画を関連の強い順に返す', async () => {
    await createKcs(db, ['kc.v.a'], UNIT)
    await addVideo('vidAAAAAAA1'); await addVideo('vidAAAAAAA2')
    await link('vidAAAAAAA1', 'kc.v.a', 0.5)
    await link('vidAAAAAAA2', 'kc.v.a', 0.9)
    const got = await videosForKcs(db, ['kc.v.a'], 2)
    expect(got.map(v => v.id)).toEqual(['vidAAAAAAA2', 'vidAAAAAAA1'])
    expect(got[0]!.channelTitle).toBe('テスト講座')
  })

  /** ★ 承認していない動画を配ると、作者が見ていないものが学習者に届く（V4） */
  it('承認していない動画は出さない', async () => {
    await createKcs(db, ['kc.v.b'], UNIT)
    await addVideo('vidBBBBBBB1', { status: 'candidate' })
    await addVideo('vidBBBBBBB2', { status: 'unavailable' })
    await link('vidBBBBBBB1', 'kc.v.b'); await link('vidBBBBBBB2', 'kc.v.b')
    expect(await videosForKcs(db, ['kc.v.b'], 5)).toHaveLength(0)
  })

  it('同じ動画が複数の KC から出ても1回しか並べず、関連の強い方の頭出しを使う', async () => {
    await createKcs(db, ['kc.v.c', 'kc.v.d'], UNIT)
    await addVideo('vidCCCCCCC1')
    await link('vidCCCCCCC1', 'kc.v.c', 0.4, 30)
    await link('vidCCCCCCC1', 'kc.v.d', 0.9, 120)
    const got = await videosForKcs(db, ['kc.v.c', 'kc.v.d'], 5)
    expect(got).toHaveLength(1)
    expect(got[0]!.startSec).toBe(120)
  })

  it('件数の上限を守る', async () => {
    await createKcs(db, ['kc.v.e'], UNIT)
    for (const n of [1, 2, 3, 4]) {
      await addVideo(`vidEEEEEEE${n}`)
      await link(`vidEEEEEEE${n}`, 'kc.v.e', 0.5)
    }
    expect(await videosForKcs(db, ['kc.v.e'], 2)).toHaveLength(2)
  })

  it('紐づく動画が無ければ空を返す（「動画がありません」も出さない・§8）', async () => {
    await createKcs(db, ['kc.v.none'], UNIT)
    expect(await videosForKcs(db, ['kc.v.none'], 3)).toEqual([])
  })

  describe('視聴の記録（docs/09b §6.1）', () => {
    /**
     * ★ 視聴は弱い学習項にとどめる。n_eff を増やすと
     *   「動画を見ただけで習得済み」になり、弱点推定が壊れる。
     */
    it('6割以上見たら p_know を少し上げるが、n_eff と kc_card は触らない', async () => {
      await createKcs(db, ['kc.v.f'], UNIT)
      const item = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.v.f' }], answerKey: 'a', now: NOW })
      // 先に1問解いて状態を作る（視聴だけでは状態を作らない）
      await submitAnswer(db, {
        userId, itemId: item, sessionKind: 'quiz', drillId: null,
        chosen: 'a', latencyMs: 4000, msSinceReveal: null, now: NOW,
      })
      const before = await db<{ p_know: number; n_eff: number }[]>`
        SELECT p_know, n_eff FROM user_kc_state WHERE user_id = ${userId} AND kc_id = 'kc.v.f'`
      const cardsBefore = await db<{ n: string }[]>`
        SELECT count(*) AS n FROM kc_card WHERE user_id = ${userId}`

      await addVideo('vidFFFFFFF1', { duration: 600 })
      await link('vidFFFFFFF1', 'kc.v.f')
      const r = await recordView(db, { userId, videoId: 'vidFFFFFFF1', watchedSec: 400, now: NOW })
      expect(r.counted).toBe(true)
      expect(r.kcIds).toEqual(['kc.v.f'])

      const after = await db<{ p_know: number; n_eff: number }[]>`
        SELECT p_know, n_eff FROM user_kc_state WHERE user_id = ${userId} AND kc_id = 'kc.v.f'`
      expect(after[0]!.p_know).toBeGreaterThan(before[0]!.p_know)
      expect(after[0]!.n_eff).toBeCloseTo(before[0]!.n_eff, 6)
      const cardsAfter = await db<{ n: string }[]>`
        SELECT count(*) AS n FROM kc_card WHERE user_id = ${userId}`
      expect(cardsAfter[0]!.n).toBe(cardsBefore[0]!.n)
    })

    it('6割に届かなければ p_know を上げない（記録だけ残す）', async () => {
      await createKcs(db, ['kc.v.g'], UNIT)
      await addVideo('vidGGGGGGG1', { duration: 600 })
      await link('vidGGGGGGG1', 'kc.v.g')
      const r = await recordView(db, {
        userId, videoId: 'vidGGGGGGG1', watchedSec: 600 * WATCHED_RATIO - 1, now: NOW,
      })
      expect(r.counted).toBe(false)
      const [v] = await db<{ n: string }[]>`SELECT count(*) AS n FROM video_view WHERE user_id = ${userId}`
      expect(Number(v!.n)).toBe(1)
    })

    /** ★ 視聴だけで状態を作ると、一度も解いていない KC が記録に並ぶ */
    it('一度も解いていない KC の状態を、視聴だけで作らない', async () => {
      await createKcs(db, ['kc.v.h'], UNIT)
      await addVideo('vidHHHHHHH1', { duration: 100 })
      await link('vidHHHHHHH1', 'kc.v.h')
      const r = await recordView(db, { userId, videoId: 'vidHHHHHHH1', watchedSec: 100, now: NOW })
      expect(r.counted).toBe(true)
      expect(r.kcIds).toEqual([])
      const rows = await db`SELECT 1 FROM user_kc_state WHERE user_id = ${userId}`
      expect(rows).toHaveLength(0)
    })

    it('視聴時間は動画の長さで頭打ちにする', async () => {
      await createKcs(db, ['kc.v.i'], UNIT)
      await addVideo('vidIIIIIII1', { duration: 100 })
      await recordView(db, { userId, videoId: 'vidIIIIIII1', watchedSec: 99999, now: NOW })
      const [v] = await db<{ watched_sec: number }[]>`
        SELECT watched_sec FROM video_view WHERE user_id = ${userId}`
      expect(v!.watched_sec).toBe(100)
    })

    it('承認していない動画は視聴も記録しない', async () => {
      await addVideo('vidJJJJJJJ1', { status: 'candidate' })
      await expect(recordView(db, {
        userId, videoId: 'vidJJJJJJJ1', watchedSec: 10, now: NOW,
      })).rejects.toThrow('見つかりません')
    })
  })

  describe('視聴後の retrieval（docs/09b V6・§6.2）', () => {
    it('2問そろえば出す', async () => {
      await createKcs(db, ['kc.v.k', 'kc.v.l'], UNIT)
      await createItem(db, { userId: null, kcs: [{ kcId: 'kc.v.k' }], answerKey: 'a', now: NOW })
      await createItem(db, { userId: null, kcs: [{ kcId: 'kc.v.l' }], answerKey: 'a', now: NOW })
      await addVideo('vidKKKKKKK1')
      await link('vidKKKKKKK1', 'kc.v.k'); await link('vidKKKKKKK1', 'kc.v.l')
      const q = await retrievalAfterVideo(db, userId, 'vidKKKKKKK1')
      expect(q).toHaveLength(2)
      expect(q[0]!.choices).toHaveLength(4)
    })

    /** ★ 数合わせに関係ない設問を混ぜると retrieval の意味が消える */
    it('2問に足りなければ出さない（1問だけ出したりしない）', async () => {
      await createKcs(db, ['kc.v.m'], UNIT)
      await createItem(db, { userId: null, kcs: [{ kcId: 'kc.v.m' }], answerKey: 'a', now: NOW })
      await addVideo('vidMMMMMMM1')
      await link('vidMMMMMMM1', 'kc.v.m')
      expect(await retrievalAfterVideo(db, userId, 'vidMMMMMMM1')).toEqual([])
    })

    it('正答も解説もクライアントへ出さない（docs/12 §6.1）', async () => {
      await createKcs(db, ['kc.v.n', 'kc.v.o'], UNIT)
      await createItem(db, { userId: null, kcs: [{ kcId: 'kc.v.n' }], answerKey: 'a', now: NOW })
      await createItem(db, { userId: null, kcs: [{ kcId: 'kc.v.o' }], answerKey: 'a', now: NOW })
      await addVideo('vidNNNNNNN1')
      await link('vidNNNNNNN1', 'kc.v.n'); await link('vidNNNNNNN1', 'kc.v.o')
      const q = await retrievalAfterVideo(db, userId, 'vidNNNNNNN1')
      for (const item of q) {
        expect(Object.keys(item).sort()).toEqual(['choices', 'id', 'stem'])
      }
    })
  })

  describe('seed（docs/09b V2・V4・V5）', () => {
    const dir = 'seed'

    it('承認欄が空なら1件も入らない', async () => {
      const r = await seedVideo(db, dir)
      expect(r.channel).toBe(0)
      expect(r.video).toBe(0)
      expect(r.skipped).toBeGreaterThan(0)
    })

    it('承認済みとして流すとチャンネルが入る', async () => {
      const r = await seedVideo(db, dir, { requireApproval: false })
      expect(r.channel).toBeGreaterThan(0)
      // ★ 総数では数えない。beforeEach が試験用のチャンネルを1件入れているので、
      //   総数と r.channel は一致しない。seed が入れたものが在ることを見る
      const [c] = await db<{ n: string }[]>`
        SELECT count(*) AS n FROM channel_allowlist WHERE channel_id LIKE 'UCcj-%'`
      expect(Number(c!.n)).toBe(1)
    })

    it('2回流しても増えない', async () => {
      const before = await seedVideo(db, dir, { requireApproval: false })
      const [a] = await db<{ n: string }[]>`SELECT count(*) AS n FROM channel_allowlist`
      await seedVideo(db, dir, { requireApproval: false })
      const [b] = await db<{ n: string }[]>`SELECT count(*) AS n FROM channel_allowlist`
      expect(b!.n).toBe(a!.n)
      expect(before.channel).toBeGreaterThan(0)
    })

    /**
     * 埋め込めない動画・年齢制限つきの動画を **CSV の段で** 落とす（docs/09b V5）
     *
     * ★ なぜ本番の seed/video.csv では確かめられないのか。
     *   あの CSV は**空**である。実在する動画の識別子を作者がまだ承認していないため、
     *   こちらで捏造して置くわけにはいかない（存在しない11文字は 404 になるか、
     *   まったく無関係な動画を「歴史の授業」として出してしまう）。
     *   したがってここでは**試験専用の作り物の CSV** を別の場所に書いて流す。
     *   ここに書く識別子は DB に入るだけで、画面にも本番の seed にも出ない。
     *
     * ★ DB 側にも CHECK (status <> 'approved' OR (embeddable AND …)) が在る
     *   （docs/schema.sql:459）。ここで見たいのは、その最後の砦に**届く前に**
     *   落ちること。届いてしまうと seed 全体が例外で止まり、他の行も入らない。
     */
    describe('埋め込めない動画を弾く（V5）', () => {
      const CH_ID = 'UCfixture00000000000000'
      let fixtureDir: string

      const write = (rows: string[]) => {
        mkdirSync(fixtureDir, { recursive: true })
        writeFileSync(join(fixtureDir, 'channel_allowlist.csv'),
          'approve,id,channel_title,subject_scope,note\n' +
          `○,${CH_ID},試験用の作り物,world_history,\n`)
        writeFileSync(join(fixtureDir, 'video.csv'),
          'approve,id,channel_id,title,description,duration_sec,published_at,embeddable,yt_rating,note\n' +
          rows.join('\n') + '\n')
        writeFileSync(join(fixtureDir, 'video_kc.csv'),
          'id,video_id,kc_id,start_sec,end_sec,relevance,note\n')
      }
      // embeddable / yt_rating の列だけを変えた3行。他は同じにして、差の原因を1つに絞る
      const row = (id: string, embeddable: string, rating = '') =>
        `○,${id},${CH_ID},試験用,,600,,${embeddable},${rating},`

      beforeEach(() => {
        fixtureDir = mkdtempSync(join(tmpdir(), 'historia-video-'))
      })
      afterEach(() => { rmSync(fixtureDir, { recursive: true, force: true }) })

      it('embeddable=false の行は入らない', async () => {
        write([row('fixtureVID0', 'false')])
        const r = await seedVideo(db, fixtureDir)
        expect(r.video).toBe(0)
        expect(r.unsafe).toBe(1)
        const [n] = await db<{ n: string }[]>`SELECT count(*) AS n FROM video`
        expect(Number(n!.n)).toBe(0)
      })

      it('年齢制限つきの行は入らない', async () => {
        write([row('fixtureVID1', 'true', 'ytAgeRestricted')])
        const r = await seedVideo(db, fixtureDir)
        expect(r.video).toBe(0)
        expect(r.unsafe).toBe(1)
      })

      /**
       * ★ 逆対照。上の2件は「入らない」ことしか言っていない。
       *   seed が壊れていて何も入らなくても、同じように通ってしまう。
       *   1文字だけ違う行が**入る**ことを見て、検査が差を見分けていることを確かめる。
       */
      it('逆対照: embeddable=true・制限なしなら入る（違いは列の値だけ）', async () => {
        write([row('fixtureVID2', 'true')])
        const r = await seedVideo(db, fixtureDir)
        expect(r.video).toBe(1)
        expect(r.unsafe).toBe(0)
        const [v] = await db<{ status: string; embeddable: boolean }[]>`
          SELECT status, embeddable FROM video WHERE id = 'fixtureVID2'`
        expect(v!.status).toBe('approved')
        expect(v!.embeddable).toBe(true)
      })

      /**
       * ★ 最後の砦が生きていること。
       *   CSV の段の filter は「壊れうる自分のコード」である。壊れたときに
       *   DB が止めてくれるかどうかは、DB に直接投げて確かめるしかない。
       *   seed.ts が embeddable を true と決め打ちしていた頃、この砦は
       *   **一度も発火しない死んだ CHECK** だった（逆対照で気づいた）。
       */
      it('DB 自身も「承認済みなのに埋め込めない」を拒む（docs/schema.sql:484）', async () => {
        // ★ toThrow() だけで済ませない。列名を打ち間違えても throw するので、
        //   「拒まれた」ではなく「**この CHECK に**拒まれた」ことを見る。
        //   status の値の CHECK（video_status_check）とも取り違えないようにする
        const byThisCheck = async (q: Promise<unknown>) => {
          const e = await q.then(() => null, (err: Error) => err)
          expect(e?.message ?? '').toContain('violates check constraint')
          expect(e?.message ?? '').not.toContain('video_status_check')
        }

        await byThisCheck(db`
          INSERT INTO video (id, title, channel_id, duration_sec, embeddable, status)
          VALUES ('fixtureVID6', '埋め込めない動画', ${CH}, 600, false, 'approved')`)
        await byThisCheck(db`
          INSERT INTO video (id, title, channel_id, duration_sec, embeddable, yt_rating, status)
          VALUES ('fixtureVID7', '年齢制限', ${CH}, 600, true, 'ytAgeRestricted', 'approved')`)

        // 逆対照: 承認さえしなければ同じ行が入る。
        //   拒んでいるのは embeddable そのものではなく、status との**組み合わせ**である
        await db`
          INSERT INTO video (id, title, channel_id, duration_sec, embeddable, status)
          VALUES ('fixtureVID8', '埋め込めない動画', ${CH}, 600, false, 'candidate')`
        const [n] = await db<{ n: string }[]>`SELECT count(*) AS n FROM video WHERE id = 'fixtureVID8'`
        expect(Number(n!.n)).toBe(1)
      })

      it('3行まとめて流すと、危ないほうだけが落ちる', async () => {
        write([
          row('fixtureVID3', 'false'),
          row('fixtureVID4', 'true', 'ytAgeRestricted'),
          row('fixtureVID5', 'true'),
        ])
        const r = await seedVideo(db, fixtureDir)
        expect(r.video).toBe(1)
        expect(r.unsafe).toBe(2)
        const ids = await db<{ id: string }[]>`SELECT id FROM video ORDER BY id`
        expect(ids.map(x => x.id)).toEqual(['fixtureVID5'])
      })
    })
  })
})
