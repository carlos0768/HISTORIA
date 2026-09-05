/**
 * 投影後の座標でパスを間引く。基図（build-basemap.mjs）と版図（build-territories.mjs）で共有する。
 *
 * ★ 挙動は build-basemap.mjs にあったものをそのまま移した。ここを変えると
 *   lib/map/basemap.ts の再生成で差分が出る（＝変えた証拠になる）。
 *
 * 前提: d 文字列は M / L / Z しか含まない（d3 の geoPath が投影に曲線を使わないため）。
 */
/**
 * 投影後の座標で間引く。660×340 で見えない差は落とす。
 * minStep: 直前の点からこれ未満しか動かない点を落とす（px）
 * minRing: これより小さい輪を落とす（px）。0 なら落とさない
 */
export function simplify(d, minStep, minRing) {
  const out = []
  for (const sub of d.split('M').filter(Boolean)) {
    const closed = sub.endsWith('Z')
    const pts = sub.replace(/Z$/, '').split('L').map(s => s.split(',').map(Number))
    if (pts.some(p => !isFinite(p[0]) || !isFinite(p[1]))) continue
    if (minRing > 0) {
      const xs = pts.map(p => p[0]), ys = pts.map(p => p[1])
      if (Math.max(...xs) - Math.min(...xs) < minRing && Math.max(...ys) - Math.min(...ys) < minRing) continue
    }
    const kept = [pts[0]]
    for (const p of pts.slice(1)) {
      const q = kept[kept.length - 1]
      if (Math.hypot(p[0] - q[0], p[1] - q[1]) >= minStep) kept.push(p)
    }
    if (kept.length < 3) continue
    const s = kept.map(([a, b]) => `${Math.round(a * 10) / 10},${Math.round(b * 10) / 10}`)
      .filter((v, i, a) => v !== a[i - 1]).join('L')
    out.push('M' + s + (closed ? 'Z' : ''))
  }
  return out.join('')
}
