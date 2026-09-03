import { describe, it, expect } from 'vitest'
import {
  auditItems, scanYears, sentences, findCanon, boundCanon, isDuration, bigrams, dice,
  loadForAudit, type ItemRow, type CanonRow,
} from './audit-items'
import { extractYear } from '@/lib/pipeline/factcheck'

/**
 * 共有設問の機械検査（scripts/db/audit-items.ts）
 *
 * ★ この道具の値打ちは「何を挙げるか」より **「何を挙げないか」** にある。
 *   408問に当てた最初の版は 103 件を挙げたが、読んでみると**ほぼ全部が
 *   こちらの取り違え**だった。規則を締めて 3 件になった。
 *   ここに残す試験は、そのとき踏んだ罠をそのまま形にしたものである。
 */

const item = (o: Partial<ItemRow>): ItemRow => ({
  id: 'it.x.y.1', kc_id: 'kc.x.y', stem: '問題文。',
  a: 'ああああ', b: 'いいいい', c: 'うううう', d: 'ええええ',
  answer: 'a', explanation: '解説。', ...o,
})
const canon = (o: Partial<CanonRow>): CanonRow => ({
  id: 'ce.x', label: 'X', aliases: [], year_from: 1000, year_to: null, precision: 'exact', ...o,
})
const run = (items: ItemRow[], cs: CanonRow[] = [], persons: string[] = []) =>
  auditItems({ items, canon: cs, personLabels: persons })

describe('年の拾い方', () => {
  it('最初の1つは factcheck.ts の extractYear と同じ', () => {
    // ★ 規則を2箇所に書いてしまうと、片方だけ直したときに黙って食い違う
    for (const t of ['1868年の明治維新', '前221年に統一', 'ここには年が無い', '前18世紀のこと']) {
      expect(scanYears(t)[0]?.year ?? null, t).toBe(extractYear(t))
    }
  })

  it('1文の中の年を全部拾う', () => {
    expect(scanYears('1526年にモハーチ、1529年にウィーン包囲').map(y => y.year)).toEqual([1526, 1529])
  })

  it('「前N年」が「N年」に食われない', () => {
    expect(scanYears('前221年').map(y => y.year)).toEqual([-221])
  })

  it('期間は年号として拾わない', () => {
    // ★ 逆対照。実データで踏んだ罠。「約800年の国土回復運動」の 800 を
    //   西暦と読むと、正典（1085）と突き合わせて設問を誤りにしてしまう
    expect(scanYears('約800年の国土回復運動').map(y => y.year)).toEqual([])
    expect(scanYears('30年間続いた').map(y => y.year)).toEqual([])
    expect(scanYears('100年後に').map(y => y.year)).toEqual([])
    expect(isDuration('約800年の', 1, 6)).toBe(true)
    expect(isDuration('1492年に', 0, 5)).toBe(false)
  })
})

describe('正典の当て方', () => {
  const cs = [canon({ id: 'a', label: '唐' }), canon({ id: 'b', label: '唐招提寺' })]

  it('最長一致にする（短い方に当てない）', () => {
    // ★ 逆対照。「唐」に当ててしまうと別の事象を正しいと判定する
    const hits = findCanon('唐招提寺が建てられた', cs)
    expect(hits).toHaveLength(1)
    expect(hits[0]!.hit).toBe('唐招提寺')
  })

  it('別名でも当たる', () => {
    const hits = findCanon('大唐帝国', [canon({ label: '唐', aliases: ['大唐帝国'] })])
    expect(hits[0]!.hit).toBe('大唐帝国')
  })
})

describe('年と正典の結びつけ（boundCanon）', () => {
  const c = canon({ label: '三国同盟', year_from: 1882 })

  it('「1882年の三国同盟」は結ぶ', () => {
    const text = '1882年の三国同盟'
    const y = scanYears(text)[0]!
    expect(boundCanon(text, y, findCanon(text, [c]))?.row.year_from).toBe(1882)
  })

  it('「三国同盟（1882年）」は結ぶ', () => {
    const text = '三国同盟（1882年）'
    const y = scanYears(text)[0]!
    expect(boundCanon(text, y, findCanon(text, [c]))?.row.year_from).toBe(1882)
  })

  it('並列の区切りを跨いで結ばない', () => {
    // ★ 逆対照。ここが最初の版の最大の誤りだった。
    //   「）、」「）と」を繋ぎとして許すと、1879 を三国同盟（1882）に結んで
    //   **正しい文を誤りだと言う**。実データで 103 件のうち大半がこれだった
    for (const text of ['独墺同盟（1879年）、三国同盟', '審査法廃止（1828年）と三国同盟']) {
      const y = scanYears(text)[0]!
      expect(boundCanon(text, y, findCanon(text, [c])), text).toBeNull()
    }
  })

  it('離れていれば黙る（「読み取れない」は「誤り」ではない）', () => {
    const text = '1526年にハンガリーを破り、のちに三国同盟'
    const y = scanYears(text)[0]!
    expect(boundCanon(text, y, findCanon(text, [c]))).toBeNull()
  })
})

describe('A段: 年号の矛盾', () => {
  it('1年ずれていれば挙げる', () => {
    const { findings } = run(
      [item({ explanation: '三国同盟（1883年）が結ばれた。' })],
      [canon({ label: '三国同盟', year_from: 1882 })],
    )
    expect(findings.filter(f => f.kind === '年号の矛盾')).toHaveLength(1)
  })

  it('合っていれば挙げない', () => {
    const { findings } = run(
      [item({ explanation: '三国同盟（1882年）が結ばれた。' })],
      [canon({ label: '三国同盟', year_from: 1882 })],
    )
    expect(findings.filter(f => f.kind === '年号の矛盾')).toHaveLength(0)
  })

  it('century の正典には ±100 年の幅を認める', () => {
    // ★ 逆対照。factcheck.ts が実データで踏んだ罠と同じもの。
    //   幅を無視すると、正しい年を誤りだと言う
    const c = [canon({ label: '倭寇', year_from: 1350, precision: 'century' })]
    expect(run([item({ explanation: '倭寇（1440年）。' })], c)
      .findings.filter(f => f.kind === '年号の矛盾')).toHaveLength(0)
    expect(run([item({ explanation: '倭寇（1600年）。' })], c)
      .findings.filter(f => f.kind === '年号の矛盾')).toHaveLength(1)
  })

  it('期間を持つ正典は year_to まで見る', () => {
    // ★ 逆対照。year_to を捨てると範囲の後半が丸ごと誤りになる
    const c = [canon({ label: '南北戦争', year_from: 1861, year_to: 1865 })]
    expect(run([item({ explanation: '南北戦争（1864年）。' })], c)
      .findings.filter(f => f.kind === '年号の矛盾')).toHaveLength(0)
  })

  it('誤りの選択肢は突き合わせない（わざと間違えて書いてある）', () => {
    const { findings } = run(
      [item({ answer: 'a', a: '正しい', b: '三国同盟は1899年に結ばれた' })],
      [canon({ label: '三国同盟', year_from: 1882 })],
    )
    expect(findings.filter(f => f.kind === '年号の矛盾')).toHaveLength(0)
  })
})

describe('A段: 作りの欠陥', () => {
  it('答えが設問文にそのまま在れば挙げる', () => {
    const { findings } = run([item({
      stem: 'ウェストファリア条約で三十年戦争が終わった。正しいものはどれか。',
      a: 'ウェストファリア条約で三十年戦争が終わった', answer: 'a',
    })])
    expect(findings.filter(f => f.kind === '答えが設問文に在る')).toHaveLength(1)
  })

  it('普通の設問では挙げない', () => {
    expect(run([item({})]).findings.filter(f => f.kind === '答えが設問文に在る')).toHaveLength(0)
  })

  it('並べ替えで正解だけ要素が多いと挙げる', () => {
    // ★ 実データで2問見つかった型。中身を読まず矢印を数えるだけで解ける
    const { findings } = run([item({
      stem: '古いものから順に並べたものはどれか。',
      a: '甲 → 乙 → 丙 → 丁 → 戊', b: '乙 → 甲 → 丙 → 丁',
      c: '丙 → 甲 → 乙 → 丁', d: '丁 → 丙 → 乙 → 甲', answer: 'a',
    })])
    expect(findings.filter(f => f.kind === '並べ替えの要素数で解ける')).toHaveLength(1)
  })

  it('4択とも要素数が同じなら挙げない', () => {
    // ★ 逆対照。並べ替え型そのものを挙げてしまうと 50 問が雑音になる
    const { findings } = run([item({
      stem: '古いものから順に並べたものはどれか。',
      a: '甲 → 乙 → 丙 → 丁', b: '乙 → 甲 → 丙 → 丁',
      c: '丙 → 甲 → 乙 → 丁', d: '丁 → 丙 → 乙 → 甲', answer: 'a',
    })])
    expect(findings.filter(f => f.kind === '並べ替えの要素数で解ける')).toHaveLength(0)
  })

  it('「上記すべて」型を挙げる', () => {
    const { findings } = run([item({ d: 'すべて正しい' })])
    expect(findings.filter(f => f.kind === '4択の体を成さない選択肢')).toHaveLength(1)
  })
})

describe('A段: 長さで解ける（プール全体）', () => {
  const longCorrect = (i: number) => item({
    id: `it.x.y.${i}`, a: 'あ'.repeat(60), b: 'い'.repeat(10), c: 'う'.repeat(10), d: 'え'.repeat(10),
    answer: 'a',
  })

  it('正解が常に最長のプールを挙げる', () => {
    const { findings, stats } = run(Array.from({ length: 20 }, (_, i) => longCorrect(i)))
    expect(stats.naiveLongestScore).toBe(1)
    expect(findings.filter(f => f.kind === '長さで解ける（プール全体）')).toHaveLength(1)
  })

  it('正解が常に最短のプールも挙げる（鏡像の癖）', () => {
    // ★ 逆対照。最長だけを見ていると、この直し方で数字は下がるのに
    //   「最短を選ぶと当たる」という新しい癖ができたことに気づけない。
    //   直ったと言えるのは両方が 25% 前後になったときだけである。
    const shortCorrect = (i: number) => item({
      id: `it.x.y.${i}`, a: 'あ'.repeat(5), b: 'い'.repeat(40), c: 'う'.repeat(40), d: 'え'.repeat(40),
      answer: 'a',
    })
    const { findings, stats } = run(Array.from({ length: 20 }, (_, i) => shortCorrect(i)))
    expect(stats.naiveShortestScore).toBe(1)
    expect(stats.naiveLongestScore).toBe(0)
    expect(findings.filter(f => f.kind === '長さで解ける（プール全体）')).toHaveLength(1)
  })

  it('長さ順位を数える（理想は各25%）', () => {
    const { stats } = run(Array.from({ length: 20 }, (_, i) => longCorrect(i)))
    expect(stats.lengthRank[0]).toBe(20)   // 全部1位（最長）
    expect(stats.lengthRank.slice(1)).toEqual([0, 0, 0])
  })

  it('長さに癖が無いプールは挙げない', () => {
    // ★ 逆対照。閾値を下げすぎると健全なプールまで挙げてしまう
    const mixed = Array.from({ length: 20 }, (_, i) =>
      item({ id: `it.x.y.${i}`, answer: (['a', 'b', 'c', 'd'] as const)[i % 4]! }))
    const { findings, stats } = run(mixed)
    expect(stats.naiveLongestScore).toBeCloseTo(0.25, 5)  // 全部同じ長さ＝4等分
    expect(findings.filter(f => f.kind === '長さで解ける（プール全体）')).toHaveLength(0)
  })
})

describe('近さの測り方', () => {
  it('空どうしを「似ている」と言わない', () => {
    expect(dice(bigrams(''), bigrams(''))).toBe(0)
  })

  it('定型が同じで中身が違うものを重複と言わない', () => {
    // ★ 逆対照。設問文だけで比べると 89% 一致して重複扱いになっていた
    const a = item({ id: 'it.a.1', stem: '南北戦争が起きた要因として最も適切なものはどれか。',
                     a: '奴隷制と関税をめぐる南北の対立', b: '独立戦争の継続', c: '西部開拓の停止', d: '金本位制の放棄' })
    const b = item({ id: 'it.b.1', stem: 'アヘン戦争が起きた要因として最も適切なものはどれか。',
                     a: '三角貿易とアヘン厳禁策の衝突', b: '義和団の蜂起', c: '太平天国の建国', d: '辛亥革命の波及' })
    expect(run([a, b]).findings.filter(f => f.kind === 'ほぼ重複')).toHaveLength(0)
  })

  it('中身まで同じものは重複と言う', () => {
    const a = item({ id: 'it.a.1', stem: '南北戦争が起きた要因はどれか。', a: '奴隷制と関税をめぐる南北の対立' })
    const b = item({ id: 'it.b.1', stem: '南北戦争が起きた要因はどれか。', a: '奴隷制と関税をめぐる南北の対立' })
    expect(run([a, b]).findings.filter(f => f.kind === 'ほぼ重複').length).toBeGreaterThan(0)
  })
})

describe('文の切り方', () => {
  it('「。」で切る（年と固有名が別の文なら無関係とみなす）', () => {
    expect(sentences('あ。い。').map(s => s.text)).toEqual(['あ', 'い'])
  })
})

describe('いまの seed に当てる', () => {
  const { findings, stats } = auditItems(loadForAudit())
  const kinds = (k: string) => findings.filter(f => f.kind === k)

  it('408問を読める', () => {
    expect(stats.total).toBe(408)
  })

  it('答えが設問文に在るもの・4択の体を成さないものは無い', () => {
    expect(kinds('答えが設問文に在る')).toHaveLength(0)
    expect(kinds('4択の体を成さない選択肢')).toHaveLength(0)
  })

  it('ほぼ重複は無い', () => {
    expect(kinds('ほぼ重複')).toHaveLength(0)
  })

  it('並べ替えの要素数で解ける設問は無い', () => {
    expect(kinds('並べ替えの要素数で解ける')).toHaveLength(0)
  })

  it('★ 長さで解ける癖が残っている（直したらこの試験を消す）', () => {
    // ★ これは「いま壊れている」ことを固定する試験である。
    //   選択肢を書き直して癖が消えたら、この試験ごと消すのが正しい。
    expect(stats.naiveLongestScore).toBeGreaterThan(0.75)
    // ★ 直す方向を間違えないための錨。「最短を選ぶ」側へ倒しても直したことにならない
    expect(stats.naiveShortestScore).toBeLessThan(0.25)
  })
})
