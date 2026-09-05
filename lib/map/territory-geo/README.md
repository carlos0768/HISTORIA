# 版図の境界データ（historical-basemaps 由来）

このディレクトリの `<国家id>.ts` / `index.ts` / `attribution.ts` は **自動生成**で、手で編集しない。

| | |
|---|---|
| 出典 | [aourednik/historical-basemaps](https://github.com/aourednik/historical-basemaps)（André Ourednik） |
| コミット | `scripts/map/fetch-historical.mjs` の `HISTORICAL_BASEMAPS_COMMIT` |
| ライセンス | **GPL-3.0**（同ディレクトリの `LICENSE` は上流の写し）。この派生データも GPL-3.0 で再配布する。詳細は `docs/10-legal-risk.md` §7b |
| 基図 | Natural Earth（パブリックドメイン）。`lib/map/basemap.ts` |

## 作り直す

```bash
node scripts/map/fetch-historical.mjs 1700 1880 1914      # 元データを取る（gitignore。1本 1.5MB）
npx tsx scripts/map/build-territories.mjs                   # ここに焼く
```

`lib/map/territories.ts` のスナップショットに `geo: { year, names }` が付いているものだけを焼く。
`year` はデータ側の年（`lib/map/historical-years.ts` の一覧にある年）で、段階の年と一致しなくてよい
（例: オスマン帝国 1683 年 → データの 1700 年）。画面にはどの年のデータかを出す。

## 精度

各パスの `precision` は上流の `BORDERPRECISION` の最小値。1=概略、2=中程度、3=国際法で確定。
1648 年より前の境界は上流の作者自身が「概念的」と断っている。学習用の模式図として扱う。
