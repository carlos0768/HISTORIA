/**
 * 層2: 正典マスタとの機械照合
 *
 * 仕様: docs/08-ai-architecture.md §5 層2
 *
 * 決定的な照合であり、ベクトル検索の曖昧さが入らない分、年号の検証に適している。
 * docs/08 §5 は「毎回生成では人手レビューが物理的に不可能」なので
 * **機械照合が唯一の防衛線になる**としている。
 *
 * ★ ここが出す `matched` / `matchable` が Phase 0 の判定項目 0-4b（照合率 80%）
 *   そのものである（docs/13）。分母の定義がずれると判定が意味を失うので、
 *   **「照合できたはずなのにできなかった」ものだけを分母に入れる**。
 *   年を読み取れない claim は照合の失敗ではなく対象外なので分母から外す。
 */
import type { Sql } from 'postgres'
import type { Claim } from '@/lib/ai/types'

export type MachineVerdict = {
  claim: Claim
  status: 'ok' | 'wrong' | 'unmatched'
  reason?: string
  canonId?: string
}

export type MachineCheckResult = {
  verdicts: MachineVerdict[]
  /** 照合できた claim の数。docs/08 §5 層2 の目標は year/person の80%以上 */
  matched: number
  /** 照合できたはずの claim の数（＝照合率の分母） */
  matchable: number
  /** 種別は対象だが年を読み取れず、分母にも入れなかった数。分母が痩せていないかを見る */
  unreadable: number
}

/** 照合率。分母が0なら null（0除算を「0%」と偽らない） */
export const matchRate = (r: MachineCheckResult): number | null =>
  r.matchable === 0 ? null : r.matched / r.matchable

/**
 * 年号の一致とみなす幅。precision に応じて範囲の外側に余裕を付ける。
 *
 * ★ century / decade でも year_to を必ず見る。以前は `year_from` からの
 *   ±100 / ±10 だけを見て **year_to を捨てていた**。期間を持つ正典
 *   （「ローマの平和 前27〜後180」など）でこれをやると、範囲の後半が
 *   まるごと外れて**正しい年を誤りと判定する**。実データを書いていて気づいた。
 */
export function yearMatches(claimYear: number, canonFrom: number, canonTo: number | null, precision: string): boolean {
  const to = canonTo ?? canonFrom
  const slack = precision === 'century' ? 100 : precision === 'decade' ? 10 : 0
  return claimYear >= canonFrom - slack && claimYear <= to + slack
}

/** claim の本文から西暦を拾う。「前18世紀」のような表記は拾わない（照合対象外にする） */
export function extractYear(text: string): number | null {
  const bc = text.match(/前\s*(\d{1,4})\s*年/)
  if (bc) return -Number(bc[1])
  const ad = text.match(/(\d{3,4})\s*年/)
  if (ad) return Number(ad[1])
  return null
}

/**
 * 照合に使う文字列。
 *
 * ★ subject があればそれだけを見る。本文全体を見ると
 *   「ウェストファリア条約で三十年戦争が終わった」から「三十年戦争」の正典を引いてしまう。
 */
const needleOf = (claim: Claim): string => claim.subject?.trim() || claim.text

/**
 * claim の年。
 *
 * ★ モデルが構造化して返した year_from を優先する。本文からの正規表現抽出は
 *   3〜4桁の西暦と「前N年」しか拾えないので、あくまで後詰めである。
 */
const yearOf = (claim: Claim): number | null =>
  claim.yearFrom ?? extractYear(claim.text)

export async function machineCheck(db: Sql, claims: Claim[]): Promise<MachineCheckResult> {
  const verdicts: MachineVerdict[] = []
  let matched = 0
  let matchable = 0
  let unreadable = 0

  for (const claim of claims) {
    if (claim.type !== 'year' && claim.type !== 'person') {
      verdicts.push({ claim, status: 'unmatched', reason: '機械照合の対象外の種別です' })
      continue
    }
    const needle = needleOf(claim)

    if (claim.type === 'person') {
      matchable++
      // ★ 最長一致にする。「李」と「李世民」が両方あるとき、短い方に当たると
      //   別人を正しいと判定してしまう。同点は id で決めて毎回同じ結果にする
      const rows = await db<{ id: number; label: string }[]>`
        SELECT id, label FROM person
         WHERE ${needle} LIKE '%' || label || '%'
            OR EXISTS (SELECT 1 FROM unnest(aliases) a WHERE ${needle} LIKE '%' || a || '%')
         ORDER BY GREATEST(
           CASE WHEN ${needle} LIKE '%' || label || '%' THEN length(label) ELSE 0 END,
           COALESCE((SELECT max(length(a)) FROM unnest(aliases) a
                      WHERE ${needle} LIKE '%' || a || '%'), 0)
         ) DESC, id ASC
         LIMIT 1`
      const hit = rows[0]
      if (!hit) {
        verdicts.push({ claim, status: 'unmatched', reason: 'person に一致する人物がありません' })
      } else {
        matched++
        verdicts.push({ claim, status: 'ok', canonId: hit.label })
      }
      continue
    }

    // ---- type === 'year' ----
    const year = yearOf(claim)
    if (year === null) {
      // ★ 分母に入れない。「前18世紀の…」は正典を何件足しても照合できるようにならないので、
      //   ここを分母に含めると照合率が構造的に 80% に届かなくなる（分母の水増し）
      unreadable++
      verdicts.push({ claim, status: 'unmatched', reason: '年を読み取れないため機械照合の対象外です' })
      continue
    }
    matchable++

    const rows = await db<
      { id: string; label: string; year_from: number; year_to: number | null; precision: string }[]
    >`SELECT id, label, year_from, year_to, precision FROM canon_event
       WHERE ${needle} LIKE '%' || label || '%'
          OR EXISTS (SELECT 1 FROM unnest(aliases) a WHERE ${needle} LIKE '%' || a || '%')
       ORDER BY GREATEST(
         CASE WHEN ${needle} LIKE '%' || label || '%' THEN length(label) ELSE 0 END,
         COALESCE((SELECT max(length(a)) FROM unnest(aliases) a
                    WHERE ${needle} LIKE '%' || a || '%'), 0)
       ) DESC, id ASC
       LIMIT 1`

    const hit = rows[0]
    if (!hit) {
      verdicts.push({ claim, status: 'unmatched', reason: 'canon_event に一致する事象がありません' })
      continue
    }
    matched++
    if (yearMatches(year, hit.year_from, hit.year_to, hit.precision)) {
      verdicts.push({ claim, status: 'ok', canonId: hit.id })
    } else {
      // ★ どの正典行に当たったかを理由に書く。年号は一括承認で入れており
      //   検算していないので、**誤っているのが教材ではなく正典の側**でありうる。
      //   blocked_reason からこの id を辿って正典を直せるようにしておく
      verdicts.push({
        claim, status: 'wrong', canonId: hit.id,
        reason: `正典「${hit.label}」(${hit.id}) は ${hit.year_from} 年ですが、教材は ${year} 年としています`,
      })
    }
  }

  return { verdicts, matched, matchable, unreadable }
}
