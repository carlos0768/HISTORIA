import { describe, it, expect, vi, afterEach } from 'vitest'
import { readFileSync } from 'node:fs'
import { classifyDbError, dbErrorMessage, dbFailure, DbNotConfiguredError } from './error'

/**
 * DB の失敗の分類（lib/db/error.ts）
 *
 * ★ この試験が守っている一線は2つある。
 *   1. **生の message を画面に返さない。** postgres.js は接続エラーの message に
 *      ホスト名とポートを入れる。返してしまうと本番プロジェクトの ref が
 *      未認証の訪問者のブラウザに出る。
 *   2. **原因ごとに違う手を出す。** 全部を1文にまとめると、
 *      「少し待ってもう一度」が資格情報の誤りでは永久に嘘になる。
 */

/** 本番でホストを漏らしたら困る文字列。実在の ref は使わない */
const HOST = 'db.abc123.supabase.co'

/**
 * postgres.js が実際に作る接続エラーの形。
 *
 * src/errors.js の connection():
 *   new Error('write ' + x + ' ' + (host + ':' + port))
 *   { code: x, errno: x, address: host, port }
 */
const connErr = (code: string) => Object.assign(
  new Error(`write ${code} ${HOST}:5432`),
  { code, errno: code, address: HOST, port: 5432 },
)

/** PostgresError の形。SQLSTATE が code に入る */
const pgErr = (code: string, message: string) => Object.assign(
  new Error(message), { code, name: 'PostgresError' },
)

afterEach(() => vi.restoreAllMocks())

describe('classifyDbError', () => {
  it('DATABASE_URL が無ければ unset', () => {
    expect(classifyDbError(new DbNotConfiguredError())).toBe('unset')
  })

  it('instanceof が効かない経路でも name で unset と分かる', () => {
    // モジュールが二重に読まれると instanceof は落ちる。保険が効いていること
    expect(classifyDbError(Object.assign(new Error('x'), { name: 'DbNotConfiguredError' })))
      .toBe('unset')
  })

  it('postgres.js 自身の接続 code は unreachable', () => {
    for (const c of ['CONNECTION_CLOSED', 'CONNECTION_ENDED', 'CONNECTION_DESTROYED', 'CONNECT_TIMEOUT']) {
      expect(classifyDbError(connErr(c)), c).toBe('unreachable')
    }
  })

  it('socket の errno も unreachable', () => {
    for (const c of ['ENOTFOUND', 'ECONNREFUSED', 'ECONNRESET', 'ETIMEDOUT', 'ENETUNREACH', 'EAI_AGAIN']) {
      expect(classifyDbError(connErr(c)), c).toBe('unreachable')
    }
  })

  it('資格情報の拒否は auth。unreachable にしない', () => {
    // ★ 逆対照。ここを unreachable に混ぜると「少し待って」と言ってしまう。
    //   パスワードを回し忘れた作者は、何時間待っても直らないものを待つことになる
    expect(classifyDbError(pgErr('28P01', 'password authentication failed for user "postgres"')))
      .toBe('auth')
    expect(classifyDbError(pgErr('28000', 'no pg_hba.conf entry'))).toBe('auth')
  })

  it('表が無いのは schema', () => {
    expect(classifyDbError(pgErr('42P01', 'relation "app_user" does not exist'))).toBe('schema')
    expect(classifyDbError(pgErr('3D000', 'database "nope" does not exist'))).toBe('schema')
  })

  it('こちらの書き間違いは unknown。設定の問題に化けさせない', () => {
    // ★ 逆対照。「code が無ければ未設定」とすると、TypeError が
    //   「DATABASE_URL を設定してください」と表示され、最も直しにくい嘘になる
    expect(classifyDbError(new TypeError('x is not a function'))).toBe('unknown')
    expect(dbErrorMessage(new TypeError('x is not a function'))).not.toContain('DATABASE_URL')
  })

  it('error でないものを渡しても落ちない', () => {
    for (const x of [null, undefined, 'ENOTFOUND', 42, {}, { code: 7 }]) {
      expect(classifyDbError(x)).toBe('unknown')
    }
  })
})

describe('dbErrorMessage', () => {
  it('接続エラーの文にホスト名が入らない', () => {
    // ★ ここが本命の逆対照。実装が e.message を返すようにすると必ず落ちる
    const msg = dbErrorMessage(connErr('CONNECTION_CLOSED'))
    expect(msg).not.toContain('abc123')
    expect(msg).not.toContain('supabase.co')
    expect(msg).not.toContain('5432')
    expect(msg).not.toContain(HOST)
  })

  it('どの種別でも、生の message を混ぜない', () => {
    const cases = [
      connErr('ENOTFOUND'),
      pgErr('28P01', `password authentication failed at ${HOST}`),
      pgErr('42P01', 'relation "app_user" does not exist'),
      new TypeError('internal: /home/user/HISTORIA/lib/secret.ts blew up'),
    ]
    for (const e of cases) {
      const msg = dbErrorMessage(e)
      expect(msg, msg).not.toContain(HOST)
      expect(msg, msg).not.toContain('app_user')
      expect(msg, msg).not.toContain('/home/user')
    }
  })

  it('原因ごとに違う文を出す', () => {
    const msgs = new Set([
      dbErrorMessage(new DbNotConfiguredError()),
      dbErrorMessage(connErr('ENOTFOUND')),
      dbErrorMessage(pgErr('28P01', 'nope')),
      dbErrorMessage(pgErr('42P01', 'nope')),
      dbErrorMessage(new TypeError('nope')),
    ])
    // ★ 逆対照。1文にまとめる実装にすると 5 が 1 になって落ちる
    expect(msgs.size).toBe(5)
  })

  it('待てば直るものにだけ「待って」と書く', () => {
    expect(dbErrorMessage(connErr('ENOTFOUND'))).toContain('待って')
    expect(dbErrorMessage(pgErr('28P01', 'nope'))).not.toContain('待って')
    expect(dbErrorMessage(new DbNotConfiguredError())).not.toContain('待って')
  })

  it('未設定のときだけ DATABASE_URL を名指しする', () => {
    expect(dbErrorMessage(new DbNotConfiguredError())).toContain('DATABASE_URL')
    expect(dbErrorMessage(connErr('ENOTFOUND'))).not.toContain('DATABASE_URL')
  })
})

describe('dbFailure', () => {
  it('画面に出す文は dbErrorMessage と同じ', () => {
    vi.spyOn(console, 'error').mockImplementation(() => {})
    const e = connErr('CONNECT_TIMEOUT')
    expect(dbFailure('invite', e)).toBe(dbErrorMessage(e))
  })

  it('生の error はログにだけ残す（作者が原因を辿れるように）', () => {
    const spy = vi.spyOn(console, 'error').mockImplementation(() => {})
    const e = connErr('ENOTFOUND')
    dbFailure('invite', e)

    expect(spy).toHaveBeenCalledTimes(1)
    const [label, logged] = spy.mock.calls[0]!
    expect(label).toContain('invite')
    expect(label).toContain('unreachable')
    // ★ ホスト名は「画面には出ないが、ログには在る」。
    //   両方を確かめないと、隠したつもりで作者からも隠すことになる
    expect(logged).toBe(e)
    expect((logged as Error).message).toContain(HOST)
  })
})

/**
 * ★ 上の fixture は postgres.js の中身を写したものである。
 *   ライブラリが code を変えたら分類が黙って効かなくなるので、
 *   **本物のソースを読んで**在ることを確かめる。
 *   （手本: lib/loop/video.test.ts が video-embed.tsx の字面を読んでいる）
 *   src/errors.js は package.json の exports に無く import できないため、
 *   ファイルとして読む。
 */
describe('postgres.js 側の前提', () => {
  it('connection() が message にホストとポートを入れている', () => {
    const src = readFileSync('node_modules/postgres/src/errors.js', 'utf8')
    expect(src).toContain("host + ':' + port")
    expect(src).toContain('address: options.path || host')
  })

  it('分類している接続 code が本物のソースに在る', () => {
    const src = readFileSync('node_modules/postgres/src/connection.js', 'utf8')
      + readFileSync('node_modules/postgres/src/index.js', 'utf8')
    for (const c of ['CONNECTION_CLOSED', 'CONNECTION_ENDED', 'CONNECTION_DESTROYED', 'CONNECT_TIMEOUT']) {
      expect(src, c).toContain(`Errors.connection('${c}'`)
    }
  })

  it('socket のエラーがそのまま上がってくる（errno を分類する根拠）', () => {
    const src = readFileSync('node_modules/postgres/src/connection.js', 'utf8')
    expect(src).toContain("socket.on('error', error)")
  })
})
