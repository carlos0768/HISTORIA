/**
 * 本文の語に人物・出来事のリンクを埋める（docs/11-ux.md §4.2）
 *
 * 教材の本文（body_md）に出てくる **人物（person）と出来事（canon_event）の名前**を見つけ、
 * その語を「調べる」（`/research?q=`）へのリンクにする。読者は本文から離れずに
 * その人物・出来事の年代と地域を年表と地図で確かめられる。
 *
 * ★ 引く先は層2の正典そのものである。別の語彙表を作らない（docs/09 §7 の「DB を唯一の真実にしない」
 *   と同じで、CSV → DB の1本道）。正典に無い語はリンクにならない。それは正典の不足であって、
 *   ここで補わない。
 * ★ 日本語には語の切れ目が無いので、**同じ位置では最も長い語を採る**
 *   （「アッカドのメソポタミア統一」の中の「アッカド」だけを拾わない）。
 * ★ 短い語は前後を見る。「ベル」を「ベルリン」の中で、「武帝」を「光武帝」の中で拾うと誤りになる。
 *   カタカナ・ラテン文字の語は隣がその文字種なら拾わない。漢字2字以下の語は隣が漢字なら拾わない。
 *   漢字3字以上の語（「北宋の成立」等）は文の中に自然に埋まっているので隣を見ない。
 * ★ この部品は DB も React も触らない。サーバー（全語彙で探す）とクライアント（見つかった語だけで
 *   同じ規則で切る）の両方が使うので、規則をここ1か所に置く。
 */

export type TermKind = 'person' | 'event'

/** 正典の1行。label と aliases のどれが本文に出ても、その行へ結ぶ */
export type Term = {
  kind: TermKind
  label: string
  aliases: readonly string[]
}

/** 本文で見つかった語。text は本文に出た表記、label は「調べる」に渡す語 */
export type LinkedTerm = {
  text: string
  kind: TermKind
  label: string
}

/** 本文を「リンクにする語」と「そのままの文字」に切ったもの */
export type Segment = { text: string; term: LinkedTerm | null }

/** 検索語の上限（lib/loop/research.ts の QUERY_MAX_CHARS と同じ）。超える語はリンクにしない */
const LABEL_MAX_CHARS = 60

/** これより短い漢字の語は、隣が漢字だと拾わない */
const KANJI_GUARD_MAX = 2

const isKatakana = (c: string) => /[゠-ヿー]/.test(c)
const isKanji = (c: string) => /[㐀-鿿々〆]/.test(c)
const isLatin = (c: string) => /[A-Za-z0-9]/.test(c)
const isKanjiOnly = (s: string) => [...s].every(isKanji)

/**
 * text[from..to) を語として採ってよいか。前後の文字種で判定する。
 * ★ 「隣が同じ文字種なら語の途中」という近似である。形態素解析はしない
 *   （依存を増やさず、クライアントでも同じ規則で動かすため）。
 */
export function boundaryOk(text: string, from: number, to: number): boolean {
  const term = text.slice(from, to)
  const before = from > 0 ? text[from - 1]! : ''
  const after = to < text.length ? text[to]! : ''
  const head = term[0]!
  const tail = term[term.length - 1]!

  if (isKatakana(head) && before !== '' && isKatakana(before)) return false
  if (isKatakana(tail) && after !== '' && isKatakana(after)) return false
  if (isLatin(head) && before !== '' && isLatin(before)) return false
  if (isLatin(tail) && after !== '' && isLatin(after)) return false
  if (isKanjiOnly(term) && [...term].length <= KANJI_GUARD_MAX) {
    if (before !== '' && isKanji(before)) return false
    if (after !== '' && isKanji(after)) return false
  }
  return true
}

type Entry = { surface: string; term: LinkedTerm }

export type Linker = {
  /** 本文を切る。seen を渡すと、そこに入っている label は2度目からリンクにしない */
  segment: (text: string, seen?: Set<string>) => Segment[]
  /** 本文に出てくる語を、初出の順に1回ずつ */
  find: (text: string) => LinkedTerm[]
}

/**
 * 語彙表から「本文を切る道具」を作る。
 *
 * 同じ表記が複数の行に当たるとき（「高祖」「太祖」は王朝ごとに居る。「孔子」は人物にも出来事にもある）:
 * - 種別は人物を先にする（本文で名前として出るのは人物のほうが多い）
 * - 「調べる」に渡す語は、当たった行が1つならその label、複数なら本文の表記そのまま
 *   （どの行か決められないのに1つの label に寄せると、別の人物へ飛ばすことになる）
 */
export function createLinker(terms: readonly Term[]): Linker {
  // 表記 → その表記で当たる行。挿入順は terms の順（呼び出し側が人物を先に並べる）
  const bySurface = new Map<string, Term[]>()
  for (const t of terms) {
    for (const s of [t.label, ...t.aliases]) {
      const surface = s.trim()
      if (surface === '' || [...surface].length > LABEL_MAX_CHARS) continue
      const list = bySurface.get(surface)
      if (!list) bySurface.set(surface, [t])
      else if (!list.includes(t)) list.push(t)
    }
  }

  // 先頭の1文字 → 長い順に並べた候補
  const byHead = new Map<string, Entry[]>()
  for (const [surface, rows] of bySurface) {
    const person = rows.find(r => r.kind === 'person')
    const kind: TermKind = person ? 'person' : rows[0]!.kind
    const labels = new Set(rows.map(r => r.label))
    const label = labels.size === 1 ? rows[0]!.label : surface
    const entry: Entry = { surface, term: { text: surface, kind, label } }
    const head = surface[0]!
    const list = byHead.get(head)
    if (!list) byHead.set(head, [entry])
    else list.push(entry)
  }
  for (const list of byHead.values()) list.sort((a, b) => b.surface.length - a.surface.length)

  /** i から始まる最も長い語。境界に合わなければ次に長い語を試す */
  const matchAt = (text: string, i: number): Entry | null => {
    const list = byHead.get(text[i]!)
    if (!list) return null
    for (const e of list) {
      if (text.startsWith(e.surface, i) && boundaryOk(text, i, i + e.surface.length)) return e
    }
    return null
  }

  const segment = (text: string, seen?: Set<string>): Segment[] => {
    const out: Segment[] = []
    let plain = ''
    let i = 0
    while (i < text.length) {
      const e = matchAt(text, i)
      if (e && !(seen?.has(e.term.label))) {
        if (plain !== '') { out.push({ text: plain, term: null }); plain = '' }
        out.push({ text: e.surface, term: e.term })
        seen?.add(e.term.label)
        i += e.surface.length
      } else if (e) {
        // 既にリンクにした語。文字はそのまま通すが、語の途中で別の語を拾わないよう語ごと進める
        plain += e.surface
        i += e.surface.length
      } else {
        plain += text[i]!
        i += 1
      }
    }
    if (plain !== '') out.push({ text: plain, term: null })
    return out
  }

  const find = (text: string): LinkedTerm[] => {
    const seen = new Set<string>()
    const out: LinkedTerm[] = []
    for (const s of segment(text, seen)) if (s.term) out.push(s.term)
    return out
  }

  return { segment, find }
}

/** 「調べる」へのリンク先。ページ側（app/research）と同じ `?q=` を使う */
export const researchHref = (label: string) => `/research?q=${encodeURIComponent(label)}`
