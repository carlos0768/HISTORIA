import { describe, it, expect } from 'vitest'
import { computeStreak, jstDate, PROTECT_PER_MONTH, MAX_BRIDGE_DAYS } from './streak'

const T = '2026-09-20'

describe('日付を Asia/Tokyo で数える', () => {
  it('日本時間の深夜0時30分は「その日」に入る', () => {
    // UTC では前日 15:30。UTC で数えると連続が1日ずれる
    expect(jstDate(new Date('2026-09-20T15:30:00Z'))).toBe('2026-09-21')
    expect(jstDate(new Date('2026-09-20T14:59:00Z'))).toBe('2026-09-20')
  })

  it('日本時間の23時59分はまだ当日', () => {
    expect(jstDate(new Date('2026-09-20T14:58:00Z'))).toBe('2026-09-20')
  })
})

describe('連続日数', () => {
  it('1日もやっていなければ 0', () => {
    expect(computeStreak([], T)).toEqual({
      current: 0, longest: 0, days: 0, protectionsLeft: PROTECT_PER_MONTH,
    })
  })

  it('今日まで毎日やっていれば、その日数', () => {
    const r = computeStreak(['2026-09-18', '2026-09-19', '2026-09-20'], T)
    expect(r.current).toBe(3)
    expect(r.longest).toBe(3)
    expect(r.days).toBe(3)
  })

  it('今日まだやっていなくても、昨日までの連続は途切れない', () => {
    // その日が終わるまで確定しない。ここを切ると朝いちで 0 に見えて心が折れる
    const r = computeStreak(['2026-09-18', '2026-09-19'], T)
    expect(r.current).toBe(2)
  })

  it('同じ日が2回入っていても1日として数える', () => {
    const r = computeStreak(['2026-09-19', '2026-09-19', '2026-09-20'], T)
    expect(r.current).toBe(2)
    expect(r.days).toBe(2)
  })
})

describe('ストリーク保護（docs/11-ux.md §7.1）', () => {
  it('1日空いても続く', () => {
    // 17, 18 をやり 19 を休み 20 にやった
    const r = computeStreak(['2026-09-17', '2026-09-18', '2026-09-20'], T)
    expect(r.current).toBe(3)
    expect(r.protectionsLeft).toBe(PROTECT_PER_MONTH - 1)
  })

  it('2日空いても続く（3日以上でリセットという明文と両立する唯一の読み方）', () => {
    const r = computeStreak(['2026-09-16', '2026-09-17', '2026-09-20'], T)
    expect(r.current).toBe(3)
    expect(r.protectionsLeft).toBe(PROTECT_PER_MONTH - 1)
  })

  it('3日空いたらリセットする', () => {
    const r = computeStreak(['2026-09-15', '2026-09-16', '2026-09-20'], T)
    expect(r.current).toBe(1)          // 20日ぶんだけ
    expect(r.protectionsLeft).toBe(PROTECT_PER_MONTH)
  })

  it('保護は月2回で打ち止め', () => {
    // 空白を3つ作る。2つは埋まり、3つ目で切れる
    const days = ['2026-09-10', '2026-09-12', '2026-09-14', '2026-09-16',
                  '2026-09-18', '2026-09-20']
    const r = computeStreak(days, T)
    // 20 →(保護1)→ 18 →(保護2)→ 16 で3つ目の空白に当たり止まる。数えるのは
    // 学習した日なので 20/18/16 の3日（休んだ日は数に入れない。下の試験を見よ）
    expect(r.current).toBe(3)
    expect(r.protectionsLeft).toBe(0)
  })

  /**
   * ★ 「連続日数」は**学習した日**を数える。保護で埋めた休みの日は数えない。
   *   保護の役目は「連続を切らさない」ことであって、休んだ日を学習した日に
   *   数え上げることではない。ここを逆にすると、休むほど数字が増えかねない。
   */
  it('保護で埋めた休みの日は日数に数えない', () => {
    const r = computeStreak(['2026-09-18', '2026-09-20'], T)
    expect(r.current).toBe(2)          // 19日は休み。暦では3日ぶんだが数えるのは2
    expect(r.days).toBe(2)
  })

  it('月をまたぐと保護が戻る', () => {
    // 8月に2回、9月に2回まで使える
    const days = ['2026-08-26', '2026-08-28', '2026-08-30',
                  '2026-09-01', '2026-09-03', '2026-09-05']
    const r = computeStreak(days, '2026-09-05')
    // 9/5 →(9月の保護1)→ 9/3 →(9月の保護2)→ 9/1 →(8月の保護1)→ 8/30
    //      →(8月の保護2)→ 8/28 で8月の保護が尽き、8/26 には届かない
    expect(r.current).toBe(5)
    // 月ごとに独立しているので、9月ぶんは使い切っている
    expect(r.protectionsLeft).toBe(0)
  })

  it('保護は最長記録を水増ししない', () => {
    // 実際に毎日やった最長は2日。保護で current は伸びるが longest は伸びない
    const r = computeStreak(['2026-09-17', '2026-09-18', '2026-09-20'], T)
    expect(r.current).toBe(3)
    expect(r.longest).toBe(3)          // current が上回るのでそちらを残す
    const r2 = computeStreak(['2026-09-01', '2026-09-02', '2026-09-03', '2026-09-04',
                              '2026-09-17', '2026-09-18', '2026-09-20'], T)
    expect(r2.longest).toBe(4)         // 9/1〜9/4 の4連続が最長
    expect(r2.current).toBe(3)
  })
})

describe('端', () => {
  it('学習した最初の日より前は空白として数えない', () => {
    // 1日しかやっていないのに、その前の空白で保護を使ってはいけない
    const r = computeStreak(['2026-09-20'], T)
    expect(r.current).toBe(1)
    expect(r.protectionsLeft).toBe(PROTECT_PER_MONTH)
  })

  it('ずっと前に1日だけやった記録は、いまの連続に数えない', () => {
    const r = computeStreak(['2026-01-01'], T)
    expect(r.current).toBe(0)
    expect(r.longest).toBe(1)
    expect(r.days).toBe(1)
  })

  it('埋められる空白の上限が定数と一致している', () => {
    // MAX_BRIDGE_DAYS を変えたらこの試験も落ちる（値の意味を固定する）
    const ok = ['2026-09-20']
    for (let i = 0; i < MAX_BRIDGE_DAYS; i++) ok.push(`2026-09-${18 - i}`)
    expect(computeStreak(ok, T).current).toBe(MAX_BRIDGE_DAYS + 1)
  })
})
