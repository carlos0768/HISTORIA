import { describe, it, expect } from 'vitest'
// @ts-expect-error .mjs には型定義を付けていない（基図の生成にしか使わない）
import { simplify } from './simplify.mjs'

/**
 * ★ build-basemap.mjs から切り出した関数の挙動を固定する。
 *   ここが変わると lib/map/basemap.ts の再生成で差分が出る（それが検出手段でもある）。
 */
describe('パスの間引き（scripts/map/simplify.mjs）', () => {
  it('近すぎる点を落とし、小数1桁に丸め、閉じた輪は Z を保つ', () => {
    expect(simplify('M0,0L0.1,0.1L5,0L5,5Z', 0.35, 0)).toBe('M0,0L5,0L5,5Z')
  })
  it('小さすぎる輪を落とす（両方の軸で minRing 未満のときだけ）', () => {
    expect(simplify('M0,0L0.2,0L0.2,0.2Z', 0.1, 0.5)).toBe('')
    // 片方の軸だけ小さい輪は残る
    expect(simplify('M0,0L10,0L10,0.2L0,0.2Z', 0.1, 0.5)).toBe('M0,0L10,0L10,0.2L0,0.2Z')
    // minRing = 0 なら落とさない
    expect(simplify('M0,0L0.2,0L0.2,0.2Z', 0.1, 0)).toBe('M0,0L0.2,0L0.2,0.2Z')
  })
  it('3点未満になった部分パスと、数値でない座標を含む部分パスは落とす', () => {
    expect(simplify('M0,0L10,0', 0.1, 0)).toBe('')
    expect(simplify('M0,0LNaN,1L5,5Z', 0.1, 0)).toBe('')
  })
  it('丸めで同じになった連続する点をまとめる', () => {
    expect(simplify('M0,0L5,0L5.04,0.02L5,5Z', 0.01, 0)).toBe('M0,0L5,0L5,5Z')
  })
  it('空には空', () => {
    expect(simplify('', 0.35, 0.5)).toBe('')
  })
})
