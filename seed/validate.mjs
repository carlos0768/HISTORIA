#!/usr/bin/env node
// seed/*.csv を DB へ投入する前に落とすための検査。依存なし（Node 標準ライブラリのみ）。
//   node seed/validate.mjs           … 起草中の検査（approve 列は見ない）
//   node seed/validate.mjs --strict  … 投入前の検査（approve 列の空欄も落とす）
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const DIR = dirname(fileURLToPath(import.meta.url));
const STRICT = process.argv.includes('--strict');
const errors = [];
const fail = (m) => errors.push(m);

// ---- 最小の CSV パーサ（引用符・埋め込み改行に対応） ----
function parseCsv(text) {
  const rows = [];
  let row = [], field = '', quoted = false, i = 0;
  if (text.charCodeAt(0) === 0xfeff) i = 1;              // BOM
  for (; i < text.length; i++) {
    const c = text[i];
    if (quoted) {
      if (c === '"') { if (text[i + 1] === '"') { field += '"'; i++; } else quoted = false; }
      else field += c;
    } else if (c === '"') quoted = true;
    else if (c === ',') { row.push(field); field = ''; }
    else if (c === '\n') { row.push(field); rows.push(row); row = []; field = ''; }
    else if (c !== '\r') field += c;
  }
  if (field !== '' || row.length) { row.push(field); rows.push(row); }
  const head = rows.shift();
  return rows.filter(r => r.some(v => v !== ''))
             .map(r => Object.fromEntries(head.map((h, j) => [h, (r[j] ?? '').trim()])));
}
const load = (f) => parseCsv(readFileSync(join(DIR, f), 'utf8'));

const era      = load('era.csv');
const region   = load('region.csv');
const syllabus = load('syllabus_unit.csv');
const kc       = load('kc.csv');

// ---- マスタ側の整合 ----
const regionLabels = new Set(region.map(r => r.label));
if (regionLabels.size !== region.length) fail('region.csv: label が重複している');
for (const r of region) {
  if (r.parent_label && !regionLabels.has(r.parent_label)) fail(`region.csv: 親 "${r.parent_label}" が存在しない（${r.label}）`);
  if (!['1', '2', '3', '4'].includes(r.grid_id)) fail(`region.csv: grid_id は1〜4（${r.label} = ${r.grid_id}）`);
}
const unitIds = new Set(syllabus.map(u => u.id));
if (unitIds.size !== syllabus.length) fail('syllabus_unit.csv: id が重複している');
for (const u of syllabus) {
  if (u.level !== '1' && !unitIds.has(u.parent_id)) fail(`syllabus_unit.csv: 親 "${u.parent_id}" が存在しない（${u.id}）`);
  if (u.level === '1' && u.parent_id) fail(`syllabus_unit.csv: 部に親がある（${u.id}）`);
  const depth = u.id.split('.').length - 1;
  if (String(depth) !== u.level) fail(`syllabus_unit.csv: id の階層と level が食い違う（${u.id} level=${u.level}）`);
}
const leafUnits = new Set(syllabus.filter(u => u.level === '3').map(u => u.id));
const eraIds = new Set(era.map(e => e.id));

// ---- 1. id の一意性と命名 ----
const seen = new Set();
const ID_RE = /^kc\.[a-z0-9_]+\.[a-z0-9_]+$/;
for (const k of kc) {
  if (!ID_RE.test(k.id)) fail(`1: id の形式が不正: "${k.id}"`);
  if (seen.has(k.id)) fail(`1: id が重複: ${k.id}`);
  seen.add(k.id);
}

// ---- 2. kind の分布 ----
const KINDS = ['fact', 'distinction', 'causal', 'chronology', 'geo'];
// fact のみ上限、他は下限（docs 側の B0-3 と一致させること）
const LIMIT = { fact: { max: 35 }, distinction: { min: 20 }, causal: { min: 20 },
                chronology: { min: 12 }, geo: { min: 3 } };
const count = Object.fromEntries(KINDS.map(k => [k, 0]));
for (const k of kc) {
  if (!KINDS.includes(k.kind)) { fail(`2: kind が不正: ${k.id} = "${k.kind}"`); continue; }
  count[k.kind]++;
}
const pct = (n) => (n / kc.length) * 100;
for (const [k, lim] of Object.entries(LIMIT)) {
  const p = pct(count[k]);
  if (lim.max != null && p > lim.max) fail(`2: ${k} が ${p.toFixed(1)}% で上限 ${lim.max}% を超えた（用語集の写しになっていないか）`);
  if (lim.min != null && p < lim.min) fail(`2: ${k} が ${p.toFixed(1)}% で下限 ${lim.min}% を下回った`);
}

// ---- 3〜7 ----
const ids = new Set(kc.map(k => k.id));
for (const k of kc) {
  // 3. unit_id は節（level=3）に限る
  if (!leafUnits.has(k.unit_id)) fail(`3: unit_id が節として存在しない: ${k.id} → "${k.unit_id}"`);
  if (!eraIds.has(k.era_id)) fail(`3: era_id が存在しない: ${k.id} → "${k.era_id}"`);

  // 4. primary region はちょうど1件。others に重複させない
  if (!k.region_primary) fail(`4: region_primary が空: ${k.id}`);
  else if (!regionLabels.has(k.region_primary)) fail(`4: region_primary が region.csv に無い: ${k.id} → "${k.region_primary}"`);
  const others = k.region_others ? k.region_others.split(';').map(s => s.trim()).filter(Boolean) : [];
  for (const r of others) {
    if (!regionLabels.has(r)) fail(`4: region_others が region.csv に無い: ${k.id} → "${r}"`);
    if (r === k.region_primary) fail(`4: region_others に primary と同じ地域がある: ${k.id} → "${r}"`);
  }
  if (new Set(others).size !== others.length) fail(`4: region_others に重複がある: ${k.id}`);

  // 5. prereq_ids の解決（自己参照・未定義。循環は後段でまとめて検出）
  for (const p of (k.prereq_ids ? k.prereq_ids.split(';').map(s => s.trim()).filter(Boolean) : [])) {
    if (p === k.id) fail(`5: prereq が自分自身: ${k.id}`);
    else if (!ids.has(p)) fail(`5: prereq が未定義: ${k.id} → "${p}"`);
  }

  // 6. 年代の整合
  const yf = k.year_from === '' ? null : Number(k.year_from);
  const yt = k.year_to === '' ? null : Number(k.year_to);
  if (yf !== null && yt !== null && yf > yt) fail(`6: year_from > year_to: ${k.id}（${yf} > ${yt}）`);
  if (!['exact', 'decade', 'century', 'unknown', ''].includes(k.year_precision)) fail(`6: year_precision が不正: ${k.id} = "${k.year_precision}"`);
  if (k.year_precision === 'exact' && yf === null) fail(`6: year_precision=exact なのに year_from が空: ${k.id}`);
  if (k.exam_weight !== '' && !(Number(k.exam_weight) >= 0)) fail(`6: exam_weight が不正: ${k.id} = "${k.exam_weight}"`);

  // 7. why_confusable — 承認できない KC を作者に投げない
  if (!k.why_confusable) fail(`7: why_confusable が空（なぜ間違えやすいかを書けない KC は出さない）: ${k.id}`);

  // 8. 投入前は approve 列が全て埋まっていること
  if (STRICT && !['○', '×'].includes(k.approve)) fail(`8: approve が未記入または不正: ${k.id} = "${k.approve}"`);
}

// ---- 5b. prereq の循環 ----
const graph = new Map(kc.map(k => [k.id, (k.prereq_ids ? k.prereq_ids.split(';').map(s => s.trim()).filter(s => ids.has(s)) : [])]));
const state = new Map();
const walk = (n, path) => {
  if (state.get(n) === 'done') return;
  if (state.get(n) === 'open') { fail(`5: prereq が循環している: ${[...path, n].join(' → ')}`); return; }
  state.set(n, 'open');
  for (const p of graph.get(n) ?? []) walk(p, [...path, n]);
  state.set(n, 'done');
};
for (const id of ids) walk(id, []);

// ---- 9. 層2の正典（canon_event / person）----
//
// ★ 年号は作者が全件検算しない決定である（2026-09-02）。検算の代わりに
//   機械でできる検査をここで厚くする。特に「他のラベルを部分文字列として含む」
//   組は、照合が最長一致でも取り違えの温床になるので必ず目に入れる。
const canon  = load('canon_event.csv');
const person = load('person.csv');
const PRECISIONS = ['exact', 'decade', 'century'];

const canonIds = new Set();
const canonNames = new Map();       // ラベル・別名 → それを名乗る id の一覧
const addName = (name, id) => {
  if (!name) return;
  if (!canonNames.has(name)) canonNames.set(name, []);
  canonNames.get(name).push(id);
};

for (const e of canon) {
  if (!/^ce\.[a-z0-9_]+\.[a-z0-9_]+$/.test(e.id ?? '')) fail(`9: canon_event の id の書式が違う: "${e.id}"`);
  if (canonIds.has(e.id)) fail(`9: canon_event の id が重複: ${e.id}`);
  canonIds.add(e.id);

  if (!e.label) fail(`9: canon_event に label が無い: ${e.id}`);
  if (!PRECISIONS.includes(e.precision)) fail(`9: precision は ${PRECISIONS.join('/')}: ${e.id} = "${e.precision}"`);
  if (e.year_from === '') fail(`9: year_from は必須: ${e.id}`);
  else if (!/^-?\d+$/.test(e.year_from)) fail(`9: year_from が数値でない: ${e.id} = "${e.year_from}"`);
  if (e.year_to !== '') {
    if (!/^-?\d+$/.test(e.year_to)) fail(`9: year_to が数値でない: ${e.id} = "${e.year_to}"`);
    else if (Number(e.year_from) > Number(e.year_to)) fail(`9: year_from > year_to: ${e.id}`);
  }
  // ★ 桁の打ち間違いと符号の落としを拾う。世界史の範囲を外れる年は入力誤りである
  //   （前1万年より前は農耕以前、2100年より後は未来）
  for (const [col, v] of [['year_from', e.year_from], ['year_to', e.year_to]]) {
    if (v === '' || !/^-?\d+$/.test(v)) continue;
    if (Number(v) < -10000 || Number(v) > 2100) fail(`9: ${col} が世界史の範囲外（桁か符号の誤りでは）: ${e.id} = ${v}`);
  }
  for (const label of (e.region_ids ? e.region_ids.split(';').map(s => s.trim()).filter(Boolean) : [])) {
    if (!regionLabels.has(label)) fail(`9: canon_event の region "${label}" が region.csv にない（${e.id}）`);
  }
  addName(e.label, e.id);
  for (const a of (e.aliases ? e.aliases.split(';').map(s => s.trim()).filter(Boolean) : [])) {
    if (a === e.label) fail(`9: aliases に label と同じ語がある: ${e.id}`);
    addName(a, e.id);
  }
  if (STRICT && !['○', '×'].includes(e.approve)) fail(`9: canon_event の approve が未記入または不正: ${e.id} = "${e.approve}"`);
}

// 同じ語を2つ以上の正典が名乗っていたら、どちらに当たるかが運になる
for (const [name, owners] of canonNames) {
  if (owners.length > 1) fail(`9: 同じ語 "${name}" を複数の canon_event が名乗っている: ${owners.join(', ')}`);
}

// 他のラベルを完全に含む組を調べる。
//
// ★ 包含そのものは正常である（「アヘン戦争」⊂「第2次アヘン戦争」）。照合は最長一致なので
//   長い方が勝ち、正しく解決される。
//
// ★ 危ないのは「**短く、かつ他の語に埋もれる**」名前である。たとえば「商」は
//   「日米修好通商条約」「英仏協商」に含まれるので、それらを主語とする主張が
//   殷（前1600年）に当たり、**正しい年が誤りと判定されて配信が止まる**。
//   長い名前なら最長一致で救えるが、短い名前は救えない
//   （「日米通商条約」のように、こちらの長いラベルの方が主語に含まれないことがあるため）。
//   したがって **2文字以下で、かつ他の名前に埋もれるもの**だけは落とす。
const SHORT_NAME = 2;
const canonWarnings = [];
const dupWarnings = [];
const itemWarnings = [];
const names = [...canonNames.keys()].sort((a, b) => b.length - a.length);
for (const long of names) {
  for (const short of names) {
    if (short.length >= long.length) continue;
    if (!long.includes(short)) continue;
    // ★ 同じ行の label と alias どうしの包含は無害。どちらに当たっても同じ行が返る
    //   （「史記」と「司馬遷の史記」は両方とも ce.cul.sima_qian）
    if (canonNames.get(short)[0] === canonNames.get(long)[0]) continue;
    const where = `"${short}"（${canonNames.get(short)[0]}）が "${long}"（${canonNames.get(long)[0]}）に含まれる`;
    if (short.length <= SHORT_NAME) fail(`9: ${SHORT_NAME}文字以下の名前が他の語に埋もれている（照合が取り違える）: ${where}`);
    else canonWarnings.push(where);
  }
}

// 同じ年で名前が包含関係にある組は、同じ事象を二度書いた疑いがある。
// ★ 落とさない。同じ年に起きた別の事象（ポツダム会談とポツダム宣言の受諾）は正常である。
//   ただし二重登録は正典を無駄に増やし、照合の取り違えも招くので目に入れる。
for (let i = 0; i < canon.length; i++) {
  const a = canon[i];
  const an = [a.label, ...(a.aliases ? a.aliases.split(';').map(s => s.trim()).filter(Boolean) : [])];
  for (let j = i + 1; j < canon.length; j++) {
    const b = canon[j];
    if (a.year_from !== b.year_from) continue;
    const bn = [b.label, ...(b.aliases ? b.aliases.split(';').map(s => s.trim()).filter(Boolean) : [])];
    if (an.some(x => bn.some(y => x.includes(y) || y.includes(x)))) {
      // ★ 包含の警告とは別の配列に入れる。同じ配列に混ぜると、包含が数十件あるときに
      //   表示の上限（20件）に押し出されて**二重登録が画面に出ない**。実際に一度そうなった
      dupWarnings.push(`同じ ${a.year_from} 年で名前が重なる: ${a.id}「${a.label}」と ${b.id}「${b.label}」（二重登録では）`);
    }
  }
}

const personIds = new Set();
const personLabels = new Set();
for (const p of person) {
  if (!/^pe\.[a-z0-9_]+$/.test(p.id ?? '')) fail(`9: person の id の書式が違う: "${p.id}"`);
  if (personIds.has(p.id)) fail(`9: person の id が重複: ${p.id}`);
  personIds.add(p.id);
  if (!p.label) fail(`9: person に label が無い: ${p.id}`);
  // label は DB 側で UNIQUE。重複したまま流すと後勝ちで黙って1件になる
  if (personLabels.has(p.label)) fail(`9: person の label が重複: ${p.label}`);
  personLabels.add(p.label);
  if (p.era_id && !eraIds.has(p.era_id)) fail(`9: person の era_id が存在しない: ${p.id} = "${p.era_id}"`);
  for (const a of (p.aliases ? p.aliases.split(';').map(s => s.trim()).filter(Boolean) : [])) {
    if (a === p.label) fail(`9: person の aliases に label と同じ語がある: ${p.id}`);
  }
  if (STRICT && !['○', '×'].includes(p.approve)) fail(`9: person の approve が未記入または不正: ${p.id} = "${p.approve}"`);
}

// ---- 10. item（共有の設問プール） ----
// ★ 中身の正しさは機械では見られない。だからこそ**構造の誤り**は全部ここで落とす。
//   選択肢が3つしか無い・正解の記号が範囲外・同じ文の選択肢が2つある、といったものは
//   出題した瞬間に「壊れている」と分かるので、DB に入れる前に止める。
const item = load('item.csv');
const kcIds = new Set(kc.map(k => k.id));
const itemIds = new Set();
const stems = new Map();
for (const t of item) {
  if (!/^it\.[a-z0-9_.]+$/.test(t.id ?? '')) fail(`10: item の id の書式が違う: "${t.id}"`);
  if (itemIds.has(t.id)) fail(`10: item の id が重複: ${t.id}`);
  itemIds.add(t.id);

  if (!kcIds.has(t.kc_id)) fail(`10: item の kc_id が kc.csv にない: ${t.id} = "${t.kc_id}"`);
  if (!t.stem) fail(`10: item に問題文が無い: ${t.id}`);
  if (!t.explanation) fail(`10: item に解説が無い（間違えたときに何も返せない）: ${t.id}`);

  const choices = ['a', 'b', 'c', 'd'].map(k => t[k]);
  if (choices.some(c => !c)) fail(`10: item の選択肢が4つ揃っていない: ${t.id}`);
  if (new Set(choices).size !== 4) fail(`10: item に同じ選択肢が2つある: ${t.id}`);
  if (!['a', 'b', 'c', 'd'].includes(t.answer)) fail(`10: item の answer が a〜d でない: ${t.id} = "${t.answer}"`);

  // ★ 正解だけが目立って長いと、中身を知らなくても選べてしまう。
  //   四択の 0.25 という前提（guess_rate）が崩れ、測定が歪む。
  const correct = t[t.answer];
  if (correct) {
    const others = choices.filter(c => c !== correct).map(c => c.length);
    const longest = Math.max(...others);
    if (correct.length > longest * 2) {
      itemWarnings.push(`${t.id}: 正解だけが極端に長い（${correct.length} 対 最長 ${longest}）`);
    }
  }

  // ★ 日本語の文章に別の言語の文字が紛れ込むのを落とす。
  //   起草中に "única"（スペイン語）と "교회"（ハングル）を実際に混入させた。
  //   人が読めば一目で分かるが、400件を目視で洗うのは現実的でない。
  //   許すのは日本語・英数字・記号・ギリシア文字（史料名などに出る）まで。
  for (const [field, text] of Object.entries({ 問題文: t.stem, 解説: t.explanation, a: t.a, b: t.b, c: t.c, d: t.d })) {
    const stray = [...(text ?? '')].filter(ch => {
      const cp = ch.codePointAt(0);
      if (cp < 0x0250) return false;                       // ASCII とラテン拡張
      if (cp >= 0x0370 && cp <= 0x03ff) return false;      // ギリシア文字
      if (cp >= 0x2000 && cp <= 0x303f) return false;      // 記号・約物
      if (cp >= 0x3040 && cp <= 0x30ff) return false;      // かな
      if (cp >= 0x4e00 && cp <= 0x9fff) return false;      // 漢字
      if (cp >= 0xff00 && cp <= 0xffef) return false;      // 全角の英数と記号
      return true;
    });
    if (stray.length) fail(`10: ${t.id} の${field}に日本語以外の文字が混ざっている: ${[...new Set(stray)].join('')}`);

    // ★ ラテン文字の単語も落とす。上の検査は ASCII を許すので "individual" を
    //   すり抜けた（実際に混入させた）。年号や「4区分」の数字は通し、
    //   2文字以上続く英字だけを見る。史料名などで必要になったら note に書く。
    const words = (text ?? '').match(/[A-Za-z]{2,}/g);
    if (words) fail(`10: ${t.id} の${field}に英単語が混ざっている: ${[...new Set(words)].join(', ')}`);
  }

  // 同じ問題文が2つあると、同じ設問を2回出すことになる
  const seen = stems.get(t.stem);
  if (seen) fail(`10: item の問題文が重複: ${t.id} と ${seen}`);
  stems.set(t.stem, t.id);

  if (STRICT && !['○', '×'].includes(t.approve)) fail(`10: item の approve が未記入または不正: ${t.id} = "${t.approve}"`);
}

// ★ 1つの KC に設問が無いと、その KC は永久に出題されない（出題は KC 単位）。
const kcWithItem = new Set(item.map(t => t.kc_id));
const kcWithoutItem = kc.filter(k => !kcWithItem.has(k.id));

// ---- 結果 ----
console.log(`era ${era.length} / region ${region.length} / syllabus_unit ${syllabus.length}（節 ${leafUnits.size}） / kc ${kc.length}`);
console.log(`canon_event ${canon.length} / person ${person.length} / item ${item.length}`);
console.log(`設問を持つ KC: ${kcWithItem.size} / ${kc.length}（未着手 ${kcWithoutItem.length}）`);
console.log('kind の分布:');
for (const k of KINDS) console.log(`  ${k.padEnd(12)} ${String(count[k]).padStart(3)}  ${pct(count[k]).toFixed(1).padStart(5)}%`);
const covered = new Set(kc.map(k => k.unit_id));
const uncovered = [...leafUnits].filter(u => !covered.has(u));
console.log(`KC を持つ節: ${covered.size} / ${leafUnits.size}（未着手 ${uncovered.length}）`);

// ★ 警告は落とさない。包含はしばしば正しい（「ポエニ戦争」と「第1回ポエニ戦争」）。
//   落とすと正しい正典を消す方向に働くので、目に入れるだけにする。
if (dupWarnings.length) {
  // ★ 二重登録は必ず全件出す。件数が少なく、かつ見逃すと正典が無駄に増える
  console.log(`\n△ 同じ年で名前が重なる組が ${dupWarnings.length} 件`);
  for (const w of dupWarnings) console.log('  - ' + w);
}
if (canonWarnings.length) {
  console.log(`\n△ 正典のラベルに包含関係が ${canonWarnings.length} 件（最長一致で拾うが、意図した包含か確認する）`);
  for (const w of canonWarnings.slice(0, 20)) console.log('  - ' + w);
  if (canonWarnings.length > 20) console.log(`  … 他 ${canonWarnings.length - 20} 件`);
}

if (itemWarnings.length) {
  console.log(`\n△ 設問の作りに注意が要るもの ${itemWarnings.length} 件`);
  for (const w of itemWarnings.slice(0, 20)) console.log('  - ' + w);
  if (itemWarnings.length > 20) console.log(`  … 他 ${itemWarnings.length - 20} 件`);
}

if (errors.length) {
  console.error(`\n✗ ${errors.length} 件\n` + errors.map(e => '  - ' + e).join('\n'));
  process.exit(1);
}
console.log(`\n✓ 検査を通過${STRICT ? '（投入可）' : '（起草中）'}`);
