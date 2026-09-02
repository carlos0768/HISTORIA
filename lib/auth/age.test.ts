import { describe, it, expect } from 'vitest'
import { ageOn, checkBirthDate, MIN_AGE, ageError } from './age'

const NOW = new Date('2026-09-02T00:00:00Z')

describe('満年齢', () => {
  it('誕生日を迎えていれば加算する', () => {
    expect(ageOn(new Date('2010-09-01T00:00:00Z'), NOW)).toBe(16)
  })

  it('誕生日の当日に加算する', () => {
    expect(ageOn(new Date('2010-09-02T00:00:00Z'), NOW)).toBe(16)
  })

  /** 年の引き算だけで済ませると、ここで1つ多く数えてしまう */
  it('誕生日の前日はまだ加算しない', () => {
    expect(ageOn(new Date('2010-09-03T00:00:00Z'), NOW)).toBe(15)
  })

  it('月をまたぐ手前でも加算しない', () => {
    expect(ageOn(new Date('2010-10-01T00:00:00Z'), NOW)).toBe(15)
  })

  it('うるう日生まれでも落ちない', () => {
    expect(ageOn(new Date('2008-02-29T00:00:00Z'), NOW)).toBe(18)
  })
})

describe('生年月日の受け付け（docs/10 §5・作者判断で16歳未満は断る）', () => {
  it('16歳ちょうどは通る', () => {
    expect(checkBirthDate('2010-09-02', NOW)).toEqual({ ok: true, age: 16 })
  })

  it('16歳の誕生日の前日は断る', () => {
    const r = checkBirthDate('2010-09-03', NOW)
    expect(r).toMatchObject({ ok: false, reason: 'too_young', age: 15 })
  })

  it('作者本人（2008-12-08 生まれ）は通る', () => {
    expect(checkBirthDate('2008-12-08', NOW)).toMatchObject({ ok: true, age: 17 })
  })

  it('未来の日付は断る', () => {
    expect(checkBirthDate('2027-01-01', NOW)).toMatchObject({ ok: false, reason: 'future' })
  })

  it('書式が違えば断る', () => {
    for (const s of ['2010/09/02', '20100902', '2010-9-2', '', 'あ']) {
      expect(checkBirthDate(s, NOW), s).toMatchObject({ ok: false, reason: 'invalid' })
    }
  })

  /** Date は 2026-02-30 を 3月2日に繰り上げる。黙って通すと嘘の日付が DB に入る */
  it('存在しない日付は断る', () => {
    expect(checkBirthDate('2010-02-30', NOW)).toMatchObject({ ok: false, reason: 'invalid' })
    expect(checkBirthDate('2010-13-01', NOW)).toMatchObject({ ok: false, reason: 'invalid' })
  })

  it('うるう日生まれを弾かない', () => {
    expect(checkBirthDate('2008-02-29', NOW)).toMatchObject({ ok: true })
  })

  it('断る理由を日本語で出せる', () => {
    const r = checkBirthDate('2020-01-01', NOW)
    expect(r.ok).toBe(false)
    if (!r.ok) expect(ageError(r)).toContain(String(MIN_AGE))
  })
})
