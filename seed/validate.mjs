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

// ---- 結果 ----
console.log(`era ${era.length} / region ${region.length} / syllabus_unit ${syllabus.length}（節 ${leafUnits.size}） / kc ${kc.length}`);
console.log('kind の分布:');
for (const k of KINDS) console.log(`  ${k.padEnd(12)} ${String(count[k]).padStart(3)}  ${pct(count[k]).toFixed(1).padStart(5)}%`);
const covered = new Set(kc.map(k => k.unit_id));
const uncovered = [...leafUnits].filter(u => !covered.has(u));
console.log(`KC を持つ節: ${covered.size} / ${leafUnits.size}（未着手 ${uncovered.length}）`);

if (errors.length) {
  console.error(`\n✗ ${errors.length} 件\n` + errors.map(e => '  - ' + e).join('\n'));
  process.exit(1);
}
console.log(`\n✓ 検査を通過${STRICT ? '（投入可）' : '（起草中）'}`);
