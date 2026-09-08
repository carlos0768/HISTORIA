import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { describe, it, expect } from 'vitest'
import { readCsv, list } from '@/scripts/db/csv'
import { SEED_DIR } from '@/scripts/db/seed'
import { boundaryOk, createLinker, researchHref, type Term } from './term-link'

const T = (kind: Term['kind'], label: string, ...aliases: string[]): Term => ({ kind, label, aliases })

describe('本文の語のリンク（docs/11 §4.2）', () => {
  it('人物と出来事の名前を見つけ、初出の順に1回ずつ返す', () => {
    const l = createLinker([
      T('person', 'ハンムラビ', 'ハンムラピ'),
      T('event', 'ハンムラビ法典', 'ハンムラビ法典の制定'),
    ])
    const text = 'ハンムラビ王はハンムラビ法典を制定した。ハンムラビの死後、王朝は衰えた。'
    expect(l.find(text)).toEqual([
      { text: 'ハンムラビ', kind: 'person', label: 'ハンムラビ' },
      { text: 'ハンムラビ法典', kind: 'event', label: 'ハンムラビ法典' },
    ])
  })

  it('同じ位置では最も長い語を採る（「アッカド」より「アッカドのメソポタミア統一」）', () => {
    const l = createLinker([
      T('event', 'アッカド'),
      T('event', 'アッカドのメソポタミア統一'),
    ])
    const segs = l.segment('サルゴン1世がアッカドのメソポタミア統一を果たした')
    expect(segs.map(s => s.term?.label ?? null)).toEqual([null, 'アッカドのメソポタミア統一', null])
  })

  it('別名で出ても label へ結ぶ（「キュロス大王」→「キュロス2世」）', () => {
    const l = createLinker([T('person', 'キュロス2世', 'キュロス大王')])
    expect(l.find('キュロス大王は新バビロニアを滅ぼした')).toEqual([
      { text: 'キュロス大王', kind: 'person', label: 'キュロス2世' },
    ])
  })

  it('同じ表記が複数の行に当たるときは、本文の表記のまま「調べる」に渡す', () => {
    const l = createLinker([
      T('person', '劉邦', '高祖'),
      T('person', '李淵', '高祖'),
    ])
    expect(l.find('劉邦（高祖）が前漢を建てた')).toEqual([
      { text: '劉邦', kind: 'person', label: '劉邦' },
      // 「高祖」は2人に当たるので label は表記そのもの。劉邦（既出）に寄せない
      { text: '高祖', kind: 'person', label: '高祖' },
    ])
  })

  it('人物にも出来事にもある表記は人物として扱う', () => {
    const l = createLinker([T('event', '孔子'), T('person', '孔子')])
    expect(l.find('孔子は仁を説いた')[0]!.kind).toBe('person')
  })

  it('初出だけをリンクにする。seen を渡せば呼び出しをまたいで続きになる', () => {
    const l = createLinker([T('person', 'ビスマルク')])
    const seen = new Set<string>()
    expect(l.segment('ビスマルクは', seen).filter(s => s.term)).toHaveLength(1)
    expect(l.segment('ビスマルクが', seen).filter(s => s.term)).toHaveLength(0)
    // 2度目の語は文字としては残る
    expect(l.segment('ビスマルクが', seen).map(s => s.text).join('')).toBe('ビスマルクが')
  })

  describe('語の途中で拾わない', () => {
    it('カタカナの語は隣がカタカナなら拾わない（「ベル」を「ベルリン」「ノーベル」の中で）', () => {
      const l = createLinker([T('person', 'ベル'), T('person', 'マニ')])
      expect(l.find('ベルリン会議のあと、ノーベルが、ゲルマニアで')).toEqual([])
      expect(l.find('1876年にベルが電話を発明した')).toHaveLength(1)
      expect(l.find('マニ教はササン朝で生まれた')).toHaveLength(1)
    })

    it('漢字2字以下の語は隣が漢字なら拾わない（「武帝」を「光武帝」の中で）', () => {
      const l = createLinker([T('person', '武帝'), T('person', '文帝'), T('event', '殷')])
      expect(l.find('光武帝が後漢を再興し、孝文帝が均田制を')).toEqual([])
      expect(l.find('漢の武帝は張騫を派遣した').map(t => t.text)).toEqual(['武帝'])
      expect(l.find('殷墟から甲骨文字が出た')).toEqual([])
      expect(l.find('殷（商）の王は')).toHaveLength(1)
    })

    it('漢字3字以上の語は文の中に埋まっていても拾う', () => {
      const l = createLinker([T('event', '北宋の成立'), T('person', '趙匡胤')])
      expect(l.find('趙匡胤による北宋の成立後').map(t => t.text)).toEqual(['趙匡胤', '北宋の成立'])
    })

    it('ラテン文字の語は隣がラテン文字なら拾わない', () => {
      expect(boundaryOk('NATOX', 0, 4)).toBe(false)
      expect(boundaryOk('NATOの成立', 0, 4)).toBe(true)
    })
  })

  it('空の語彙なら何もしない', () => {
    const l = createLinker([])
    expect(l.segment('本文')).toEqual([{ text: '本文', term: null }])
    expect(l.find('本文')).toEqual([])
    expect(l.segment('')).toEqual([])
  })

  it('60字を超える表記は語彙に入れない（「調べる」の上限と同じ）', () => {
    const long = 'あ'.repeat(61)
    const l = createLinker([T('event', long)])
    expect(l.find(long)).toEqual([])
  })

  it('リンク先は /research?q= で、語を URL に符号化する', () => {
    expect(researchHref('アッバース朝')).toBe('/research?q=%E3%82%A2%E3%83%83%E3%83%90%E3%83%BC%E3%82%B9%E6%9C%9D')
  })
})

/**
 * seed の正典と seed の教材で、実際に何が引けるかを確かめる。
 * ★ 正典の語彙は変わるので件数を固定しない。「本文の主役が引けている」ことだけを見る。
 */
describe('seed の正典と教材（オフライン）', () => {
  const terms: Term[] = [
    ...readCsv(join(SEED_DIR, 'person.csv')).map(r => T('person', r.label!, ...list(r.aliases))),
    ...readCsv(join(SEED_DIR, 'canon_event.csv')).map(r => T('event', r.label!, ...list(r.aliases))),
  ]
  const linker = createLinker(terms)
  const material = JSON.parse(readFileSync(join(SEED_DIR, 'material', 'wh.2.1.1.json'), 'utf8')) as {
    sections: { ord: number; body_md: string }[]
  }

  it('古代オリエントの本文で、ハンムラビ（人物）とハンムラビ法典（出来事）が別々に引ける', () => {
    const body = material.sections.find(s => s.ord === 3)!.body_md
    const found = linker.find(body)
    expect(found).toContainEqual({ text: 'ハンムラビ', kind: 'person', label: 'ハンムラビ' })
    expect(found).toContainEqual({ text: 'ハンムラビ法典', kind: 'event', label: 'ハンムラビ法典' })
    // 語は本文で初出の順。人物は法典より先に出る
    expect(found.findIndex(t => t.label === 'ハンムラビ')).toBeLessThan(found.findIndex(t => t.label === 'ハンムラビ法典'))
  })

  it('切っても文字は失われない（リンクは本文の意味を変えない）', () => {
    for (const s of material.sections) {
      expect(linker.segment(s.body_md, new Set()).map(x => x.text).join('')).toBe(s.body_md)
    }
  })

  it('本文のある節では1つ以上の語が引ける', () => {
    const body = material.sections.filter(s => s.ord >= 2)
    expect(body.every(s => linker.find(s.body_md).length > 0)).toBe(true)
  })
})
