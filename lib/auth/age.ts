/**
 * 年齢の判定
 *
 * 仕様: docs/10-legal-risk.md §5（作者判断・2026-09-02 に改訂）
 *
 * ★ 当初の仕様は「16歳未満は保護者の同意を取る」だったが、
 *   作者の判断で **16歳未満は受け付けない** に変えた。理由は docs/10 §5.3 に書いた。
 *   保護者へメールを送る依存と秘密を1つ増やさずに済み、
 *   16歳未満の個人情報の規律（§5.1）にそもそも入らない側に倒れる。
 *   代償は高1（15〜16歳）の友人を招待できないこと。
 *
 * ★ 生年月日は自己申告であり、検証する手段はない。
 *   ここでできるのは「申告どおりなら弾く」までである（docs/14 の残存リスク）。
 */

/** これ未満は受け付けない */
export const MIN_AGE = 16

/**
 * 誕生日を迎えたかどうかまで見た満年齢。
 *
 * ★ 年の引き算だけで済ませない。3月生まれの人を1月に判定すると1つ多くなる。
 */
export function ageOn(birthDate: Date, on: Date): number {
  let age = on.getUTCFullYear() - birthDate.getUTCFullYear()
  const m = on.getUTCMonth() - birthDate.getUTCMonth()
  if (m < 0 || (m === 0 && on.getUTCDate() < birthDate.getUTCDate())) age--
  return age
}

export type AgeCheck =
  | { ok: true; age: number }
  | { ok: false; reason: 'invalid' | 'future' | 'too_young'; age?: number }

/**
 * 入力された生年月日（YYYY-MM-DD）を判定する。
 *
 * ★ 未来の日付を弾く。弾かないと「0歳」や負の年齢が通り、
 *   too_young の判定をすり抜けはしないものの、意味のない値が DB に入る。
 */
export function checkBirthDate(input: string, now: Date): AgeCheck {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(input)) return { ok: false, reason: 'invalid' }
  const d = new Date(`${input}T00:00:00Z`)
  if (Number.isNaN(d.getTime())) return { ok: false, reason: 'invalid' }
  // 「2026-02-30」のような存在しない日は Date が繰り上げる。書式が保たれるかで見る
  if (d.toISOString().slice(0, 10) !== input) return { ok: false, reason: 'invalid' }
  if (d.getTime() > now.getTime()) return { ok: false, reason: 'future' }

  const age = ageOn(d, now)
  if (age < MIN_AGE) return { ok: false, reason: 'too_young', age }
  return { ok: true, age }
}

export const ageError = (c: Extract<AgeCheck, { ok: false }>): string => ({
  invalid: '生年月日を YYYY-MM-DD の形式で入力してください',
  future: '生年月日が未来になっています',
  too_young: `${MIN_AGE}歳未満の方は登録できません`,
}[c.reason])
