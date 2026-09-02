/**
 * 共有設問のレビュー用1枚ものを出す
 *
 *   npx tsx scripts/db/review-sheet.ts               # seed/out/item-review.html に書き出す
 *   npx tsx scripts/db/review-sheet.ts --stdout      # 標準出力に出す
 *
 * ★ 承認は作者の判断である（docs/02 §5）。approve-kc.ts が判断を代行しないのと同じで、
 *   この道具も「判断のための材料を並べる」だけである。408問を CSV で読むのは現実的でないので、
 *   節ごとに並べ、正解に印を付け、絞り込みと付箋を付けられる形にする。
 *
 * ★ 出力は Artifact に貼れるよう <!doctype> / <html> / <head> / <body> を含めない。
 *   先頭に <title> と <style> を置き、そのあとは本文だけを出す。
 *
 * ★ 絞り込みは JS で hidden を付け外しするだけにしてある。
 *   カードは全部 HTML に書き出すので、JS が動かなくても中身は読める。
 */
import { writeFileSync, mkdirSync } from 'node:fs'
import { join } from 'node:path'
import { readCsv } from './csv'
import { SEED_DIR as DEFAULT_SEED_DIR } from './seed'

const esc = (s: string): string =>
  s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
   .replaceAll('"', '&quot;').replaceAll("'", '&#39;')

/** kind の日本語。KC の分類（docs/02） */
const KIND_JA: Record<string, string> = {
  fact: '事実', distinction: '区別', causal: '因果', chronology: '順序', geo: '位置',
}

const KEYS = ['a', 'b', 'c', 'd'] as const

export function buildReviewSheet(SEED_DIR = DEFAULT_SEED_DIR): string {
  const items = readCsv(join(SEED_DIR, 'item.csv'))
  const kcs = new Map(readCsv(join(SEED_DIR, 'kc.csv')).map(k => [k.id!, k]))
  const units = new Map(readCsv(join(SEED_DIR, 'syllabus_unit.csv')).map(u => [u.id!, u]))

  /** 節 id から「部 > 章 > 節」の見出しを組み立てる */
  const unitPath = (id: string): string[] => {
    const parts = id.split('.')
    const out: string[] = []
    for (let i = 2; i <= parts.length; i++) {
      const u = units.get(parts.slice(0, i).join('.'))
      if (u?.label) out.push(u.label)
    }
    return out
  }
  /** 大単元（wh.1 / gh.2 …）。絞り込みの単位にする */
  const bigUnit = (id: string): string => id.split('.').slice(0, 2).join('.')

  type Row = { t: Record<string, string | undefined>; unitId: string; kind: string }
  const rows: Row[] = items.map(t => {
    const k = kcs.get(t.kc_id!)
    if (!k) throw new Error(`item.csv: kc_id "${t.kc_id}" が kc.csv にありません（${t.id}）`)
    return { t, unitId: k.unit_id!, kind: k.kind! }
  })
  // 節の並びは syllabus_unit.csv の順（教科書の順）に合わせる
  const unitOrder = [...units.keys()]
  rows.sort((a, b) => unitOrder.indexOf(a.unitId) - unitOrder.indexOf(b.unitId) ||
                      a.t.id!.localeCompare(b.t.id!))

  const bigUnits = [...new Set(rows.map(r => bigUnit(r.unitId)))]
  const kinds = [...new Set(rows.map(r => r.kind))]
  const approved = rows.filter(r => r.t.approve === '○').length
  const rejected = rows.filter(r => r.t.approve === '×').length
  const pending = rows.length - approved - rejected

  const out: string[] = []
  const w = (s = '') => out.push(s)

  w('<title>HISTORIA 設問レビュー</title>')
  w('<link rel="preconnect" href="https://fonts.googleapis.com">')
  w('<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>')
  w('<link rel="stylesheet" href="https://fonts.googleapis.com/css2?' +
    'family=M+PLUS+1+Code:wght@400;500;600;700&family=Space+Mono:wght@400;700&display=swap">')
  w('<style>')
  w(STYLE)
  w('</style>')

  // ---- 上の帯（要約と操作） ----
  w('<header class="bar">')
  w('  <div class="bar__row">')
  w('    <h1 class="bar__title">設問レビュー</h1>')
  w(`    <p class="bar__lede">世界史探究と歴史総合の全 <b>${rows.length}</b> 問。` +
    'KC 1件につき1問で、承認した分だけが出題される。</p>')
  w('  </div>')
  w('  <div class="tally">')
  w(`    <span class="tally__cell"><b>${pending}</b><span>未記入</span></span>`)
  w(`    <span class="tally__cell"><b>${approved}</b><span>承認済み ○</span></span>`)
  w(`    <span class="tally__cell"><b>${rejected}</b><span>差し戻し ×</span></span>`)
  w(`    <span class="tally__cell"><b id="shown">${rows.length}</b><span>表示中</span></span>`)
  w('  </div>')
  w('  <div class="filters">')
  w('    <input id="q" class="find" type="search" placeholder="語で絞る（設問文・選択肢・解説・id）">')
  w('    <div class="chips" id="chips-unit">')
  w('      <button class="chip chip--on" data-unit="">すべての範囲</button>')
  for (const b of bigUnits) {
    const u = units.get(b)
    w(`      <button class="chip" data-unit="${esc(b)}">${esc(u?.label ?? b)}</button>`)
  }
  w('    </div>')
  w('    <div class="chips" id="chips-kind">')
  w('      <button class="chip chip--on" data-kind="">すべての型</button>')
  for (const k of kinds) {
    w(`      <button class="chip" data-kind="${esc(k)}">${esc(KIND_JA[k] ?? k)}</button>`)
  }
  w('      <button class="chip" id="only-flag" data-flagonly="1">付箋だけ</button>')
  w('    </div>')
  w('  </div>')
  w('</header>')

  // ---- 手順 ----
  w('<section class="howto">')
  w('  <h2 class="howto__h">読み方と、そのあとの手順</h2>')
  w('  <ol class="howto__list">')
  w('    <li>上から流し読みする。<b>蛍光の行が正解</b>で、その下が解説である。</li>')
  w('    <li>怪しいものは <b>付箋</b> を押す。押した id は下の「付箋を付けた設問」に集まる。' +
    'ブラウザに残るので、閉じても消えない。</li>')
  w('    <li>全部よければ、次の3つを順に走らせる。' +
    '<code>--file item --all</code> が承認欄を ○ で埋める。</li>')
  w('  </ol>')
  w('  <pre class="cmd">npx tsx scripts/db/approve-kc.ts --file item --all\n' +
    'node seed/validate.mjs --strict\n' +
    'npx tsx scripts/db/dump-sql.ts</pre>')
  w('  <p class="howto__note">付箋を付けたものを外す場合は、先に ' +
    '<code>--file item --reject &lt;id&gt;,&lt;id&gt;</code> を走らせてから ' +
    '<code>--all</code> を走らせる（× は上書きされない）。</p>')
  w('  <details class="flagbox">')
  w('    <summary>付箋を付けた設問 <span id="flag-n">0</span> 件</summary>')
  w('    <p class="flagbox__hint">この行をそのまま <code>--reject</code> に渡せる。</p>')
  w('    <textarea id="flag-out" class="flagbox__out" readonly rows="3" ' +
    'placeholder="まだ付箋はありません"></textarea>')
  w('    <button id="flag-clear" class="btn">付箋を全部はがす</button>')
  w('  </details>')
  w('</section>')

  // ---- 設問（節ごと） ----
  w('<main class="sheet">')
  let lastUnit = ''
  for (const { t, unitId, kind } of rows) {
    if (unitId !== lastUnit) {
      if (lastUnit) w('  </section>')
      lastUnit = unitId
      const path = unitPath(unitId)
      w(`  <section class="unit" data-unit="${esc(bigUnit(unitId))}">`)
      w('    <h2 class="unit__h">')
      w(`      <span class="unit__id">${esc(unitId)}</span>`)
      w(`      <span class="unit__t">${esc(path[path.length - 1] ?? unitId)}</span>`)
      w(`      <span class="unit__p">${esc(path.slice(0, -1).join(' › '))}</span>`)
      w('    </h2>')
    }
    const kcLabel = kcs.get(t.kc_id!)?.label ?? ''
    const hay = [t.id, t.stem, ...KEYS.map(k => t[k]), t.explanation, kcLabel]
      .join(' ').toLowerCase()
    w(`    <article class="q" data-id="${esc(t.id!)}" data-unit="${esc(bigUnit(unitId))}" ` +
      `data-kind="${esc(kind)}" data-find="${esc(hay)}">`)
    w('      <div class="q__head">')
    w(`        <span class="q__kind">${esc(KIND_JA[kind] ?? kind)}</span>`)
    w(`        <span class="q__kc">${esc(kcLabel)}</span>`)
    w(`        <button class="flag" type="button" aria-pressed="false">付箋</button>`)
    w('      </div>')
    w(`      <p class="q__stem">${esc(t.stem!)}</p>`)
    w('      <ul class="q__choices">')
    for (const k of KEYS) {
      const on = t.answer === k
      w(`        <li class="c${on ? ' c--key' : ''}">` +
        `<span class="c__k">${k}</span><span class="c__t">${esc(t[k] ?? '')}</span></li>`)
    }
    w('      </ul>')
    w(`      <p class="q__exp">${esc(t.explanation ?? '')}</p>`)
    w(`      <p class="q__meta"><span>${esc(t.id!)}</span><span>${esc(t.kc_id!)}</span>` +
      `<span>${esc(t.note ?? '')}</span></p>`)
    w('    </article>')
  }
  if (lastUnit) w('  </section>')
  w('</main>')

  w('<script>')
  w(SCRIPT)
  w('</script>')
  return out.join('\n') + '\n'
}

const STYLE = `
/* Litverse（docs/design/litverse-tokens.json）。紙の見立てに寄せた1色系なので、
   暗い配色は用意せず、背景と文字色を明示して土台の色を借りないようにする。 */
:root {
  --paper:#FCF6E8; --canvas:#EFE4CC; --ink:#171512; --ink-soft:#3A342C;
  --sub:#5F584C; --muted:#8A7F6C; --accent:#F4703C; --accent-press:#DC5A28;
  --marker:#FCE04A;
  --ja:"M PLUS 1 Code", ui-monospace, "Hiragino Sans", "Noto Sans JP", monospace;
  --en:"Space Mono", ui-monospace, SFMono-Regular, Menlo, monospace;
  --hair:1px solid var(--ink); --rule:1.5px solid var(--ink);
  color-scheme: light;
}
* { box-sizing: border-box; }
body { margin:0; background:var(--canvas); color:var(--ink); font:400 14px/1.9 var(--ja); }
h1,h2 { margin:0; font-weight:600; }
p { margin:0; }
code { font-family:var(--en); font-size:12px; background:var(--canvas); padding:1px 4px; }
b { font-weight:700; }

/* ---- 上の帯 ---- */
.bar { position:sticky; top:0; z-index:5; background:var(--paper);
       border-bottom:var(--rule); padding:16px 24px 12px; }
.bar__row { display:flex; flex-wrap:wrap; align-items:baseline; gap:8px 16px; }
.bar__title { font-size:22px; line-height:1.4; }
.bar__lede { color:var(--sub); font-size:12px; line-height:1.7; }
.tally { display:flex; flex-wrap:wrap; gap:24px; margin-top:8px;
         padding-top:8px; border-top:1px dashed var(--muted); }
.tally__cell { display:flex; align-items:baseline; gap:4px; }
.tally__cell b { font:700 20px/1.3 var(--en); font-variant-numeric:tabular-nums; }
.tally__cell span { font-size:11px; color:var(--sub); }
.filters { display:flex; flex-direction:column; gap:8px; margin-top:12px; }
.find { width:100%; max-width:520px; padding:8px 12px; background:var(--paper);
        border:var(--hair); border-radius:4px; font:400 13px/1.6 var(--ja); color:var(--ink); }
.find::placeholder { color:var(--muted); }
.chips { display:flex; flex-wrap:wrap; gap:4px; }
.chip { padding:4px 10px; border:var(--hair); border-radius:999px; background:var(--paper);
        color:var(--ink); font:500 11px/1.6 var(--ja); cursor:pointer; }
.chip:hover { background:var(--canvas); }
.chip--on { background:var(--ink); color:var(--paper); }
.chip--on:hover { background:var(--ink); }
:focus-visible { outline:2px solid var(--accent); outline-offset:2px; }

/* ---- 手順 ---- */
.howto { margin:24px auto; padding:16px 24px; max-width:960px;
         background:var(--paper); border:var(--rule); }
.howto__h { font-size:16px; line-height:1.6; }
.howto__list { margin:8px 0 0; padding-left:20px; color:var(--ink-soft); font-size:13px; }
.howto__list li { margin-bottom:4px; }
.howto__note { margin-top:8px; color:var(--sub); font-size:12px; }
.cmd { margin:12px 0 0; padding:12px; background:var(--canvas); border-left:4px solid var(--accent);
       font:400 12px/1.9 var(--en); overflow-x:auto; white-space:pre; }
.flagbox { margin-top:12px; padding-top:12px; border-top:1px dashed var(--muted); }
.flagbox summary { cursor:pointer; font-size:13px; font-weight:600; }
.flagbox__hint { margin-top:8px; color:var(--sub); font-size:12px; }
.flagbox__out { display:block; width:100%; margin-top:8px; padding:8px; background:var(--canvas);
                border:var(--hair); border-radius:4px; font:400 12px/1.7 var(--en);
                color:var(--ink); resize:vertical; }
.btn { margin-top:8px; padding:6px 12px; border:var(--hair); border-radius:4px;
       background:var(--paper); color:var(--ink); font:500 12px/1.6 var(--ja); cursor:pointer; }
.btn:hover { background:var(--canvas); }

/* ---- 設問 ---- */
.sheet { max-width:960px; margin:0 auto 64px; padding:0 24px; }
.unit { margin-top:32px; }
.unit__h { display:flex; flex-wrap:wrap; align-items:baseline; gap:4px 12px;
           padding-bottom:8px; border-bottom:var(--rule); }
.unit__id { font:700 11px/1 var(--en); letter-spacing:.24em; text-transform:uppercase;
            color:var(--accent); }
.unit__t { font-size:16px; }
.unit__p { font-size:11px; color:var(--muted); }
.q { margin-top:12px; padding:16px; background:var(--paper); border:var(--hair); border-radius:4px; }
.q[data-flagged="1"] { border:var(--rule); border-left:4px solid var(--accent); }
.q__head { display:flex; flex-wrap:wrap; align-items:center; gap:8px; }
.q__kind { padding:2px 8px; background:var(--ink); color:var(--paper);
           font:500 11px/1.6 var(--ja); border-radius:999px; }
.q__kc { flex:1 1 200px; font-size:12px; color:var(--sub); }
.flag { padding:2px 10px; border:var(--hair); border-radius:999px; background:var(--paper);
        color:var(--ink); font:500 11px/1.6 var(--ja); cursor:pointer; }
.flag[aria-pressed="true"] { background:var(--accent); color:var(--paper); border-color:var(--accent); }
.flag:hover { background:var(--canvas); }
.flag[aria-pressed="true"]:hover { background:var(--accent-press); color:var(--paper); }
.q__stem { margin-top:12px; font-size:14px; }
.q__choices { margin:8px 0 0; padding:0; list-style:none;
              display:flex; flex-direction:column; gap:4px; }
.c { display:flex; gap:8px; padding:4px 8px; border-radius:4px; font-size:13px; line-height:1.8; }
.c--key { background:var(--marker); }
.c__k { flex:0 0 auto; width:16px; font:700 12px/1.9 var(--en); color:var(--sub); }
.c--key .c__k { color:var(--ink); }
.c__t { flex:1 1 auto; }
.q__exp { margin-top:12px; padding-top:8px; border-top:1px dashed var(--muted);
          color:var(--ink-soft); font-size:12px; line-height:1.9; }
.q__meta { display:flex; flex-wrap:wrap; gap:4px 16px; margin-top:8px;
           font:400 10px/1.6 var(--en); color:var(--muted); }
.empty { margin-top:32px; padding:24px; background:var(--paper); border:var(--hair);
         text-align:center; color:var(--sub); font-size:13px; }

@media (max-width:640px) {
  .bar { padding:12px 16px; }
  .howto, .sheet { padding-left:16px; padding-right:16px; }
  .howto { margin-left:16px; margin-right:16px; }
}
`.trim()

const SCRIPT = `
(function () {
  var qs = function (s, r) { return (r || document).querySelector(s) }
  var all = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)) }
  var cards = all('.q')
  var units = all('.unit')
  var state = { unit: '', kind: '', text: '', flagOnly: false }

  // 付箋はこの端末にだけ残る。読めない環境でも表示が壊れないようにする
  var KEY = 'historia.item-review.flags'
  var flags = {}
  try { flags = JSON.parse(localStorage.getItem(KEY) || '{}') || {} } catch (e) { flags = {} }
  var save = function () { try { localStorage.setItem(KEY, JSON.stringify(flags)) } catch (e) {} }

  function ids() { return Object.keys(flags).filter(function (k) { return flags[k] }).sort() }

  function paintFlags() {
    var list = ids()
    qs('#flag-n').textContent = String(list.length)
    qs('#flag-out').value = list.join(',')
    cards.forEach(function (c) {
      var on = !!flags[c.dataset.id]
      c.dataset.flagged = on ? '1' : '0'
      qs('.flag', c).setAttribute('aria-pressed', on ? 'true' : 'false')
    })
  }

  function apply() {
    var n = 0
    cards.forEach(function (c) {
      var ok = (!state.unit || c.dataset.unit === state.unit) &&
               (!state.kind || c.dataset.kind === state.kind) &&
               (!state.text || c.dataset.find.indexOf(state.text) >= 0) &&
               (!state.flagOnly || !!flags[c.dataset.id])
      c.hidden = !ok
      if (ok) n++
    })
    // 中身が全部隠れた節は見出しごと隠す
    units.forEach(function (u) {
      u.hidden = all('.q', u).every(function (c) { return c.hidden })
    })
    qs('#shown').textContent = String(n)
    var e = qs('.empty')
    if (n === 0 && !e) {
      e = document.createElement('p')
      e.className = 'empty'
      e.textContent = '条件に合う設問がありません。'
      qs('.sheet').appendChild(e)
    } else if (e) {
      e.hidden = n !== 0
    }
  }

  all('#chips-unit .chip').forEach(function (b) {
    b.addEventListener('click', function () {
      all('#chips-unit .chip').forEach(function (x) { x.classList.remove('chip--on') })
      b.classList.add('chip--on')
      state.unit = b.dataset.unit
      apply()
    })
  })
  all('#chips-kind .chip[data-kind]').forEach(function (b) {
    b.addEventListener('click', function () {
      all('#chips-kind .chip[data-kind]').forEach(function (x) { x.classList.remove('chip--on') })
      b.classList.add('chip--on')
      state.kind = b.dataset.kind
      apply()
    })
  })
  qs('#only-flag').addEventListener('click', function () {
    state.flagOnly = !state.flagOnly
    qs('#only-flag').classList.toggle('chip--on', state.flagOnly)
    apply()
  })
  qs('#q').addEventListener('input', function (e) {
    state.text = e.target.value.trim().toLowerCase()
    apply()
  })
  cards.forEach(function (c) {
    qs('.flag', c).addEventListener('click', function () {
      flags[c.dataset.id] = !flags[c.dataset.id]
      if (!flags[c.dataset.id]) delete flags[c.dataset.id]
      save(); paintFlags(); if (state.flagOnly) apply()
    })
  })
  qs('#flag-clear').addEventListener('click', function () {
    flags = {}; save(); paintFlags(); if (state.flagOnly) apply()
  })

  paintFlags()
  apply()
})();
`.trim()

export const REVIEW_PATH = join(DEFAULT_SEED_DIR, 'out', 'item-review.html')

if (process.argv[1]?.endsWith('review-sheet.ts')) {
  const html = buildReviewSheet()
  if (process.argv.includes('--stdout')) {
    process.stdout.write(html)
  } else {
    mkdirSync(join(DEFAULT_SEED_DIR, 'out'), { recursive: true })
    writeFileSync(REVIEW_PATH, html)
    console.log(`${REVIEW_PATH} に書き出した（${(html.length / 1024).toFixed(0)}KB）`)
  }
}
