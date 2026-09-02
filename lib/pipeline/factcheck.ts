/**
 * 層2: 正典マスタとの機械照合
 *
 * 仕様: docs/08-ai-architecture.md §5 層2
 *
 * 決定的な照合であり、ベクトル検索の曖昧さが入らない分、年号の検証に適している。
 *
 * ★ いま canon_event に seed データが無い。したがってこの層は照合対象0件で
 *   空回りし、実質的に層3（課金モデル）だけが事実確認をしている状態になる。
 *   **その事実を握りつぶさず、matched=0 として記録する**（docs/14 M26）。
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
  /** 照合対象（year / person）の claim の数 */
  matchable: number
}

/** 年号の一致とみなす幅。precision に応じて緩める */
function yearMatches(claimYear: number, canonFrom: number, canonTo: number | null, precision: string): boolean {
  const to = canonTo ?? canonFrom
  if (precision === 'century') return Math.abs(claimYear - canonFrom) <= 100
  if (precision === 'decade') return Math.abs(claimYear - canonFrom) <= 10
  return claimYear >= canonFrom && claimYear <= to
}

/** claim の本文から西暦を拾う。「前18世紀」のような表記は拾わない（照合対象外にする） */
export function extractYear(text: string): number | null {
  const bc = text.match(/前\s*(\d{1,4})\s*年/)
  if (bc) return -Number(bc[1])
  const ad = text.match(/(\d{3,4})\s*年/)
  if (ad) return Number(ad[1])
  return null
}

export async function machineCheck(db: Sql, claims: Claim[]): Promise<MachineCheckResult> {
  const verdicts: MachineVerdict[] = []
  let matched = 0
  let matchable = 0

  for (const claim of claims) {
    if (claim.type !== 'year' && claim.type !== 'person') {
      verdicts.push({ claim, status: 'unmatched', reason: '機械照合の対象外の種別です' })
      continue
    }
    matchable++

    if (claim.type === 'person') {
      const rows = await db<{ label: string }[]>`
        SELECT label FROM person
         WHERE ${claim.text} LIKE '%' || label || '%'
            OR EXISTS (SELECT 1 FROM unnest(aliases) a WHERE ${claim.text} LIKE '%' || a || '%')
         LIMIT 1`
      if (rows.length === 0) {
        verdicts.push({ claim, status: 'unmatched', reason: 'person に一致する人物がありません' })
      } else {
        matched++
        verdicts.push({ claim, status: 'ok', canonId: rows[0]!.label })
      }
      continue
    }

    const year = extractYear(claim.text)
    if (year === null) {
      verdicts.push({ claim, status: 'unmatched', reason: '本文から西暦を取り出せません' })
      continue
    }

    const rows = await db<
      { id: string; year_from: number; year_to: number | null; precision: string }[]
    >`SELECT id, year_from, year_to, precision FROM canon_event
       WHERE ${claim.text} LIKE '%' || label || '%'
          OR EXISTS (SELECT 1 FROM unnest(aliases) a WHERE ${claim.text} LIKE '%' || a || '%')
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
      verdicts.push({
        claim, status: 'wrong', canonId: hit.id,
        reason: `正典では ${hit.year_from} 年ですが、教材は ${year} 年としています`,
      })
    }
  }

  return { verdicts, matched, matchable }
}
