/**
 * 共有設問プールを機械で洗う（承認の前に）
 *
 *   npx tsx scripts/db/audit-items.ts              … 全件を検査して報告
 *   npx tsx scripts/db/audit-items.ts --ids-only   … A段の id だけを改行区切りで出す
 *   npx tsx scripts/db/audit-items.ts --tier B     … その段だけ出す
 *
 * ★ **鍵も DB も要らない。** seed/*.csv を読むだけである。
 *   マスタの真実は CSV であって DB ではない（docs/12 §5「DB を唯一の真実にしない」）し、
 *   作者が承認する前の CSV を見たいので、DB を見ても意味が無い。
 *
 * ★ **構造の検査はここでやらない。** seed/validate.mjs §10 が既に全部見ている
 *   （id の書式と重複・kc_id の実在・空欄・選択肢4つ・選択肢の重複・answer の範囲・
 *   正解だけ極端に長い・問題文の完全重複・正解位置の偏り）。ここで見るのは**中身**、
 *   とくに年号である。設問文と解説は年号だらけで、そこが最も間違いやすく、
 *   かつ正典と突き合わせれば機械で決まる。
 *
 * ★ **段を分ける。混ぜない。**
 *   A = 誤りの疑い（承認から外す候補）。ただし機械が挙げただけであって、
 *       **人が読んで確かめるまで「誤り」と呼ばない。**
 *   B = 要確認（作りの癖。誤りとは限らない）
 *   C = 参考（分布。良い悪いを言わない数字）
 *
 * ★ 偽陽性を減らすことを優先する。報告が雑音で埋まると読まれず、
 *   「機械で洗った」という事実だけが残って却って危ない。
 */
import { join } from 'node:path'
import { readCsv } from './csv'
import { SEED_DIR } from './seed'
import { yearMatches } from '@/lib/pipeline/factcheck'

export type Tier = 'A' | 'B' | 'C'

export type Finding = {
  tier: Tier
  /** 検査の名前。同じ種類をまとめて読めるようにする */
  kind: string
  itemId: string
  /** 何を見てそう言っているか。**根拠を書く**（作者が自分で確かめられるように） */
  detail: string
}

export type ItemRow = {
  id: string; kc_id: string; stem: string
  a: string; b: string; c: string; d: string
  answer: string; explanation: string
}
export type CanonRow = {
  id: string; label: string; aliases: string[]
  year_from: number; year_to: number | null; precision: string
}

const CHOICE_KEYS = ['a', 'b', 'c', 'd'] as const

/* ------------------------------------------------------------------ 年 */

/**
 * 本文の中の西暦を**位置つきで全部**拾う。
 *
 * ★ 規則は lib/pipeline/factcheck.ts の extractYear と同じにする。
 *   あちらは最初の1つしか返さないので、こちらで走査するが、
 *   **拾う形は必ず一致させる**（試験が両者の一致を見ている）。
 */
export function scanYears(text: string): { year: number; at: number; end: number; raw: string }[] {
  const out: { year: number; at: number; end: number; raw: string }[] = []
  // 「前N年」を先に取る。後の「N年」に食われないようにするため
  const bc = /前\s*(\d{1,4})\s*年/g
  const taken: [number, number][] = []
  for (let m = bc.exec(text); m; m = bc.exec(text)) {
    if (isDuration(text, m.index, m.index + m[0].length)) continue
    out.push({ year: -Number(m[1]), at: m.index, end: m.index + m[0].length, raw: m[0] })
    taken.push([m.index, m.index + m[0].length])
  }
  const ad = /(\d{3,4})\s*年/g
  for (let m = ad.exec(text); m; m = ad.exec(text)) {
    if (taken.some(([s, e]) => m!.index >= s && m!.index < e)) continue
    if (isDuration(text, m.index, m.index + m[0].length)) continue
    out.push({ year: Number(m[1]), at: m.index, end: m.index + m[0].length, raw: m[0] })
  }
  return out.sort((x, y) => x.at - y.at)
}

/**
 * 「約800年の国土回復運動」の 800 は**年号ではなく長さ**である。
 *
 * ★ 実データで踏んだ。これを西暦として読むと、レコンキスタ（正典 1085）と
 *   突き合わせて「誤り」と言ってしまう。設問は正しく、こちらが間違っていた。
 */
export function isDuration(text: string, at: number, end: number): boolean {
  const before = text.slice(Math.max(0, at - 3), at)
  const after = text.slice(end, end + 4)
  return /約|およそ|ほぼ|わずか/.test(before) || /^(間|後|以上|以内|ぶり|にわた|あまり)/.test(after)
}

/** 「。」で切る。年と固有名が別の文に在るなら、それは無関係とみなす */
export function sentences(text: string): { text: string; at: number }[] {
  const out: { text: string; at: number }[] = []
  let at = 0
  for (const part of text.split('。')) {
    if (part.trim()) out.push({ text: part, at })
    at += part.length + 1
  }
  return out
}

/**
 * 文の中に現れる正典を、位置つきで拾う。
 *
 * ★ **最長一致にする。** 「李」と「李世民」が両方あるとき短い方に当たると、
 *   別人・別事象を正しいと判定してしまう（factcheck.ts の SQL と同じ理由・同じ規則）。
 *   重なった一致は長い方だけを残す。
 */
export function findCanon(text: string, canon: CanonRow[]): { row: CanonRow; at: number; hit: string }[] {
  const raw: { row: CanonRow; at: number; hit: string }[] = []
  for (const row of canon) {
    for (const name of [row.label, ...row.aliases]) {
      if (!name) continue
      const at = text.indexOf(name)
      if (at >= 0) raw.push({ row, at, hit: name })
    }
  }
  // 長い順に見て、既に取った範囲と重なるものを捨てる
  raw.sort((x, y) => y.hit.length - x.hit.length || x.at - y.at)
  const kept: typeof raw = []
  for (const r of raw) {
    const s = r.at, e = r.at + r.hit.length
    if (kept.some(k => s < k.at + k.hit.length && k.at < e)) continue
    kept.push(r)
  }
  return kept.sort((x, y) => x.at - y.at)
}

/**
 * 年と正典を**隣り合っているときだけ**組にする。
 *
 * ★ 最初は「同じ文でいちばん近いもの」と組にしていた。それだと
 *   「1526年にモハーチでハンガリーを破り、1529年に第1次ウィーン包囲を行った」
 *   のような**1文に複数の事象がある正しい文**で、1526 と 第1次ウィーン包囲 を
 *   結んで「誤り」と言ってしまう。408問に当てて103件出たが、読んだものは
 *   すべて設問のほうが正しかった。**規則が雑だっただけである。**
 *
 * ★ 日本語の歴史記述で年が事象に結びつく形は2つしかない:
 *     「1623年のアンボイナ事件」（年 → 助詞 → 事象）
 *     「アンボイナ事件（1623年）」（事象 → 括弧 → 年）
 *   どちらも**あいだに入るのは助詞と括弧だけ**である。そこを条件にする。
 *   離れているものは「関係が読み取れない」であって「誤り」ではない。黙る。
 */
export function boundCanon(
  text: string,
  y: { at: number; end: number },
  hits: { row: CanonRow; at: number; hit: string }[],
): { row: CanonRow; at: number; hit: string } | null {
  // ★ **極端に狭くする。** 最初は助詞と括弧をまとめて許したが、それでも
  //   「独墺同盟（1879年）、三国同盟（1882年）」の 1879 を三国同盟に結んでしまった。
  //   「）、」「）と」は**並列の区切り**であって、繋ぎではない。
  //   結びつく形は2つしかないので、その2つだけを書く。
  const FORWARD = /^の?$/          // 「1623年のアンボイナ事件」
  const BACKWARD = /^[（(]?$/       // 「アンボイナ事件（1623年）」

  for (const h of hits) {
    const hEnd = h.at + h.hit.length
    if (y.end <= h.at && FORWARD.test(text.slice(y.end, h.at))) return h
    if (hEnd <= y.at && BACKWARD.test(text.slice(hEnd, y.at))) return h
  }
  return null
}

/* ------------------------------------------------- 文字の重なり（近さ） */

/** 2文字の並びの集合。日本語は語で切れないので文字 bigram で見る */
export function bigrams(text: string): Set<string> {
  const t = text.replace(/[\s、。「」『』（）()・,.]/g, '')
  const out = new Set<string>()
  for (let i = 0; i + 1 < t.length; i++) out.add(t.slice(i, i + 2))
  return out
}

/** Dice 係数。0〜1。両方空なら 0（「空どうしは似ている」と言わない） */
export function dice(a: Set<string>, b: Set<string>): number {
  if (a.size === 0 || b.size === 0) return 0
  let inter = 0
  for (const g of a) if (b.has(g)) inter++
  return (2 * inter) / (a.size + b.size)
}

/* ------------------------------------------------------------ 検査本体 */

export type AuditInput = { items: ItemRow[]; canon: CanonRow[]; personLabels: string[] }
export type AuditStats = {
  total: number
  answerDist: Record<string, number>
  correctIsLongest: number
  /** 「中身を読まず、常に最長の選択肢を選ぶ」だけで取れる正答率。当てずっぽうは 0.25 */
  naiveLongestScore: number
  /** 同じく「常に最短を選ぶ」。直しすぎて鏡像の癖を作っていないかを見る */
  naiveShortestScore: number
  /** 正解が長さで何位か（[最長, 2位, 3位, 最短]）。理想は各 25% */
  lengthRank: [number, number, number, number]
  itemsPerKc: { kcId: string; n: number }[]
  canonTouched: number
  /** 正典に1件も当たらなかった設問。正典側の網羅の穴でもあるので数だけ持つ */
  canonUntouched: string[]
}

/** 「上記すべて」型。4択の体を成していない */
const CATCH_ALL = /^(上記(の)?)?(すべて|全て)(が|は)?(正しい|あてはまる|当てはまる)|いずれ(でも|も)ない|該当(する(もの)?は)?ない|^すべて$/

export function auditItems(input: AuditInput): { findings: Finding[]; stats: AuditStats } {
  const { items, canon, personLabels } = input
  const findings: Finding[] = []
  const push = (tier: Tier, kind: string, itemId: string, detail: string) =>
    findings.push({ tier, kind, itemId, detail })

  const answerDist: Record<string, number> = { a: 0, b: 0, c: 0, d: 0 }
  let correctIsLongest = 0
  let canonTouched = 0
  let naiveHits = 0
  let naiveShortHits = 0
  const lengthRank = [0, 0, 0, 0]
  const canonUntouched: string[] = []
  const perKc = new Map<string, number>()

  for (const t of items) {
    const choices = CHOICE_KEYS.map(k => ({ key: k, text: t[k] ?? '' }))
    const correct = choices.find(c => c.key === t.answer)?.text ?? ''
    if (t.answer in answerDist) answerDist[t.answer]!++
    perKc.set(t.kc_id, (perKc.get(t.kc_id) ?? 0) + 1)

    // ★ 「常に最長を選ぶ」戦略の得点。同点は等分する（当てずっぽうの扱いに合わせる）
    const longest = Math.max(...choices.map(c => c.text.length))
    const tops = choices.filter(c => c.text.length === longest)
    if (correct.length === longest) { correctIsLongest++; naiveHits += 1 / tops.length }

    // ★ **逆向きも測る。** 「最長を選ぶと当たる」だけを見ていると、
    //   正解を一律に短くする直し方で数字は下がるが、
    //   今度は「最短を選ぶと当たる」という鏡像の癖ができる。
    //   直ったと言えるのは**両方が 25% 前後**になったときだけである。
    const shortest = Math.min(...choices.map(c => c.text.length))
    const bottoms = choices.filter(c => c.text.length === shortest)
    if (correct.length === shortest) naiveShortHits += 1 / bottoms.length

    // 正解が長さで何位か（1位=最長）。理想は各位 25%
    const rank = [...choices].sort((x, y) => y.text.length - x.text.length || x.key.localeCompare(y.key))
      .findIndex(c => c.key === t.answer)
    if (rank >= 0) lengthRank[rank]!++

    /* --- A-1 年号の矛盾 ------------------------------------------------ */
    // 設問文・正解選択肢・解説だけを見る。**誤りの選択肢は見ない**
    // （わざと間違えて書いてあるので、そこを正典と突き合わせるのは無意味である）
    const factText = `${t.stem}。${correct}。${t.explanation}`
    let touched = false
    for (const sent of sentences(factText)) {
      const years = scanYears(sent.text)
      const hits = findCanon(sent.text, canon)
      if (hits.length > 0) touched = true
      if (years.length === 0 || hits.length === 0) continue

      for (const y of years) {
        const near = boundCanon(sent.text, y, hits)
        if (!near) continue
        if (yearMatches(y.year, near.row.year_from, near.row.year_to, near.row.precision)) continue
        const span = near.row.year_to === null || near.row.year_to === near.row.year_from
          ? `${near.row.year_from}`
          : `${near.row.year_from}〜${near.row.year_to}`
        push('A', '年号の矛盾', t.id,
          `「${y.raw}」の近くに「${near.hit}」が在るが、正典は ${span}（${near.row.precision}）`)
      }
    }
    // ★ 正典に当たらないことは**設問の欠陥ではない。** 史料の扱いや先史のように
    //   年を持たない題材があり、日本史は正典の網羅がそもそも薄い。
    //   1件ずつ並べると84行の雑音になって、読むべきものが埋まる。数だけ持つ
    if (touched || personLabels.some(p => factText.includes(p))) canonTouched++
    else canonUntouched.push(t.id)

    /* --- A-2 答えが設問文に書いてある ---------------------------------- */
    // 正解の文言がそのまま設問文に在り、他の選択肢は在らない＝読めば解ける
    if (correct.length >= 6 && t.stem.includes(correct)
        && !choices.some(c => c.key !== t.answer && c.text.length >= 6 && t.stem.includes(c.text))) {
      push('A', '答えが設問文に在る', t.id, `設問文が正解「${correct.slice(0, 24)}」をそのまま含む`)
    }

    /* --- A-3b 並べ替え型で正解だけ要素が多い ----------------------------- */
    /**
     * ★ 「古いものから順に並べたもの」型で、正解だけ矢印が1本多いと
     *   **中身を読まず数を数えるだけで解ける。** 実データで2問見つかった
     *   （50問中2問。残り48問は4択とも同数だったので、癖ではなく取りこぼしだった）。
     *   長さの偏りと違って、これは1問ずつ確実に決まるので A 段に置く。
     */
    if (choices.some(c => c.text.includes('→'))) {
      const n = choices.map(c => ({ key: c.key, n: c.text.split('→').length }))
      const mine = n.find(x => x.key === t.answer)?.n ?? 0
      const others = n.filter(x => x.key !== t.answer).map(x => x.n)
      if (others.length > 0 && mine > Math.max(...others)) {
        push('A', '並べ替えの要素数で解ける', t.id,
          `正解は ${mine} 要素、誤答は最大 ${Math.max(...others)} 要素。矢印を数えるだけで当たる`)
      }
    }

    /* --- A-3 「上記すべて」型 ------------------------------------------ */
    for (const c of choices) {
      if (CATCH_ALL.test(c.text.trim())) {
        push('A', '4択の体を成さない選択肢', t.id, `選択肢${c.key}「${c.text.slice(0, 20)}」`)
      }
    }

    /* --- B-7 解説が設問文の丸写し -------------------------------------- */
    const d = dice(bigrams(t.stem), bigrams(t.explanation))
    if (d >= 0.7) {
      push('B', '解説が設問文の写し', t.id,
        `重なり ${(d * 100).toFixed(0)}%。間違えたときに新しいことを何も言っていない`)
    }
  }

  /* --- A-4 長さで解ける（プール全体） ---------------------------------- */
  /**
   * ★ **1問ずつ見ても分からない。** validate.mjs は「正解が最長の2倍を超える」
   *   極端なものだけを見ており、それは1件も出ない。にもかかわらず、
   *   差が中央値 +3 字ほど**一貫して**付いているため、束にすると効いてしまう。
   *
   * ★ これは測定の道具としての欠陥である。診断テストは「どこから確かめるか」を
   *   決めるためのもので（docs/04 §5）、`guess_rate` を 0.25 と置いて
   *   Elo と BKT を回している（dump-sql.ts の item 挿入）。読まずに解ける割合が
   *   0.25 から大きく離れると、その前提ごと崩れる。
   *
   * ★ 個々の設問は正しくても、束としては歪む。だから A 段に置く。
   */
  const naive = items.length === 0 ? 0 : naiveHits / items.length
  const naiveShort = items.length === 0 ? 0 : naiveShortHits / items.length
  // ★ **両方向を見る。** 片方だけを見ていると、直した先で鏡像の癖ができても気づけない
  if (naive >= 0.40 || naiveShort >= 0.40) {
    const which = naive >= naiveShort ? ['最長', naive] as const : ['最短', naiveShort] as const
    push('A', '長さで解ける（プール全体）', '(プール全体)',
      `中身を読まず常に${which[0]}を選ぶだけで ${(which[1] * 100).toFixed(1)}% 取れる` +
      `（当てずっぽうは 25%、guess_rate の前提も 0.25）`)
  }

  /* --- B-6 ほぼ重複 ---------------------------------------------------- */
  /**
   * 完全一致は seed/validate.mjs が fail にしている。ここは「ほぼ」を見る。
   *
   * ★ **設問文だけを比べてはいけない。** 最初はそうしていて8件出たが、
   *   「南北戦争が起きた要因として最も適切なものはどれか。」と
   *   「アヘン戦争が起きた要因として最も適切なものはどれか。」のような
   *   **枠が同じだけの別物**を拾っていた。四択の設問文は定型が大半を占めるので、
   *   そこだけ見ると定型の一致を測ることになる。選択肢まで入れて比べる。
   */
  const grams = items.map(t => ({
    t, g: bigrams([t.stem, ...CHOICE_KEYS.map(k => t[k] ?? '')].join('')),
  }))
  for (let i = 0; i < grams.length; i++) {
    for (let j = i + 1; j < grams.length; j++) {
      const s = dice(grams[i]!.g, grams[j]!.g)
      if (s >= 0.85) {
        push('B', 'ほぼ重複', grams[i]!.t.id, `${grams[j]!.t.id} と ${(s * 100).toFixed(0)}% 一致`)
      }
    }
  }

  return {
    findings,
    stats: {
      total: items.length,
      answerDist,
      correctIsLongest,
      naiveLongestScore: items.length === 0 ? 0 : naiveHits / items.length,
      naiveShortestScore: items.length === 0 ? 0 : naiveShortHits / items.length,
      lengthRank: lengthRank as [number, number, number, number],
      canonTouched,
      canonUntouched,
      itemsPerKc: [...perKc].map(([kcId, n]) => ({ kcId, n })).sort((x, y) => y.n - x.n),
    },
  }
}

/* -------------------------------------------------------------- 読み込み */

export function loadForAudit(dir = SEED_DIR): AuditInput {
  const items = readCsv(join(dir, 'item.csv')) as unknown as ItemRow[]
  const canon = readCsv(join(dir, 'canon_event.csv')).map(r => ({
    id: r.id!, label: r.label!,
    aliases: (r.aliases ?? '').split(';').map(s => s.trim()).filter(Boolean),
    year_from: Number(r.year_from),
    year_to: r.year_to ? Number(r.year_to) : null,
    precision: r.precision || 'year',
  }))
  const personLabels = readCsv(join(dir, 'person.csv')).flatMap(r =>
    [r.label!, ...(r.aliases ?? '').split(';').map(s => s.trim())].filter(Boolean))
  return { items, canon, personLabels }
}

/* ------------------------------------------------------------------ CLI */

if (process.argv[1]?.endsWith('audit-items.ts')) {
  const argv = process.argv.slice(2)
  const idsOnly = argv.includes('--ids-only')
  const only = argv.indexOf('--tier') >= 0 ? argv[argv.indexOf('--tier') + 1]?.toUpperCase() : null

  const { findings, stats } = auditItems(loadForAudit())
  const of = (tier: Tier) => findings.filter(f => f.tier === tier)

  if (idsOnly) {
    console.log([...new Set(of('A').map(f => f.itemId))].join('\n'))
    process.exit(0)
  }

  const show = (tier: Tier, title: string) => {
    if (only && only !== tier) return
    const list = of(tier)
    console.log(`\n【${tier}段】${title} — ${list.length} 件（設問 ${new Set(list.map(f => f.itemId)).size} 問）`)
    if (list.length === 0) { console.log('  何も出ませんでした。'); return }
    const byKind = new Map<string, Finding[]>()
    for (const f of list) byKind.set(f.kind, [...(byKind.get(f.kind) ?? []), f])
    for (const [kind, fs] of byKind) {
      console.log(`\n  ● ${kind}（${fs.length} 件）`)
      for (const f of fs) console.log(`    ${f.itemId}\n      ${f.detail}`)
    }
  }

  console.log(`設問 ${stats.total} 問を検査しました。`)
  show('A', '誤りの疑い（人が読んで確かめるもの）')
  show('B', '要確認（作りの癖）')

  if (!only || only === 'C') {
    console.log('\n【C段】参考の数字')
    const d = stats.answerDist
    const pct = (n: number) => `${((n / stats.total) * 100).toFixed(1)}%`
    console.log(`  正解の位置  a ${d.a} (${pct(d.a!)}) / b ${d.b} (${pct(d.b!)}) / ` +
                `c ${d.c} (${pct(d.c!)}) / d ${d.d} (${pct(d.d!)})`)
    console.log(`  正解が最長  ${stats.correctIsLongest} 問 (${pct(stats.correctIsLongest)})  ` +
                `※ 偶然なら 25% 前後`)
    console.log(`  最長を選ぶだけの正答率  ${(stats.naiveLongestScore * 100).toFixed(1)}%  ` +
                `/ 最短 ${(stats.naiveShortestScore * 100).toFixed(1)}%  ※ どちらも 25% 前後が理想`)
    console.log(`  正解の長さ順位  ` + stats.lengthRank
      .map((c, i) => `${i + 1}位 ${((c / stats.total) * 100).toFixed(1)}%`).join(' / ')
      + '  ※ 各 25% が理想')
    console.log(`  正典に触れている  ${stats.canonTouched} 問 (${pct(stats.canonTouched)})`)
    console.log(`  正典に当たらない  ${stats.canonUntouched.length} 問  ` +
                `※ 史料・先史・日本史など。設問の欠陥ではなく正典側の網羅の穴`)
    const many = stats.itemsPerKc.filter(k => k.n >= 3)
    console.log(`  KC 数 ${stats.itemsPerKc.length}（3問以上ある KC は ${many.length} 件）`)
  }
  console.log()
}
