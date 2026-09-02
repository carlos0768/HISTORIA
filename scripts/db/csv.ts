/** seed/*.csv を読む最小のパーサ。seed/validate.mjs と同じ規則で読む */
import { readFileSync } from 'node:fs'

export function parseCsv(text: string): Record<string, string>[] {
  const rows: string[][] = []
  let row: string[] = []
  let field = ''
  let quoted = false
  let i = text.charCodeAt(0) === 0xfeff ? 1 : 0
  for (; i < text.length; i++) {
    const c = text[i]!
    if (quoted) {
      if (c === '"') {
        if (text[i + 1] === '"') { field += '"'; i++ } else quoted = false
      } else field += c
    } else if (c === '"') quoted = true
    else if (c === ',') { row.push(field); field = '' }
    else if (c === '\n') { row.push(field); rows.push(row); row = []; field = '' }
    else if (c !== '\r') field += c
  }
  if (field !== '' || row.length) { row.push(field); rows.push(row) }

  const head = rows.shift()
  if (!head) return []
  return rows
    .filter(r => r.some(v => v !== ''))
    .map(r => Object.fromEntries(head.map((h, j) => [h, (r[j] ?? '').trim()])))
}

export const readCsv = (path: string): Record<string, string>[] => parseCsv(readFileSync(path, 'utf8'))

/** 空欄は NULL として扱う（CSV に NULL の表現が無いため） */
export const orNull = (v: string | undefined): string | null => (v === undefined || v === '' ? null : v)
export const num = (v: string | undefined): number | null => (orNull(v) === null ? null : Number(v))
export const list = (v: string | undefined): string[] =>
  orNull(v) === null ? [] : v!.split(';').map(s => s.trim()).filter(Boolean)
