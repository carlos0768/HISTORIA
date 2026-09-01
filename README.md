# HISTORIA

受験世界史の**弱点を測って、そこだけを出し直す**アプリ。歴史総合・世界史探究が対象。

> 単なる暗記アプリにしないことを設計の中心に置いている。
> 覚えたかどうかではなく「区別・因果・年代順・地理比定」ができるかを測る。

## いまの状態

| | 状態 |
|---|---|
| 仕様書 | [`docs/`](./docs) 19文書。作者判断の未決は0件 |
| スキーマ | [`docs/schema.sql`](./docs/schema.sql) 42テーブル・RLS 21本。PostgreSQL 16.13 で投入検証済み |
| マスタ | [`seed/`](./seed) 章立て117件・KC 60件（**承認待ち**） |
| 学習ロジック | SM-2 / 弱点推定 / スケジューラ / 確認テスト / 支出遮断器 — テスト200件 |
| 閉ループ | 出題→採点→弱点更新→翌日出し直しが実 DB で動く |
| 画面 | ホームと出題画面。Litverse デザインシステム |
| AI 生成 | プロバイダ抽象層のみ。**鍵が無い間はフェイクで通る** |

## 動かす

```bash
npm install
docker run -d -p 5433:5432 -e POSTGRES_PASSWORD=postgres pgvector/pgvector:pg16   # 任意
export DATABASE_URL=postgres://postgres:postgres@127.0.0.1:5433/historia
npx tsx scripts/db/dev-seed.ts        # DB を作り、seed と開発用データを入れる
export DEMO_USER_ID=<上の出力の値>
npm run dev
```

`DATABASE_URL` が無くても画面は開く（「未接続」と表示される）。

## 検査

```bash
npm run seed:validate                 # seed CSV を DB に入れる前に落とす
npm run typecheck
npm test                              # TEST_DATABASE_URL があれば DB テストも走る
npm run build
```

## 設計の要点

- **KC（知識コンポーネント）が単位**。「人物・時代・地域」の3軸では弱点を表現できない（[`02`](./docs/02-domain-model.md)）
- **`response` が唯一の真実**。弱点もスケジュールもここから再計算できる（[`03`](./docs/03-data-model.md) §2.2）
- **SM-2 は KC 単位**。設問を毎回生成すると item 単位では状態が積み上がらない（[`04b`](./docs/04b-spaced-repetition.md) §1.2）
- **正答はクライアントに配らない**。採点はサーバー（[`12`](./docs/12-nonfunctional.md) §6.1）
- **月1万円で AI 呼び出しを機械的に停止する**。上限を1円も超えない（[`08`](./docs/08-ai-architecture.md) §7.1）
- **生成は無料枠、検証は課金**。同一モデルの自己検証に退化させない（[`08`](./docs/08-ai-architecture.md) §2）

読む順は [`docs/README.md`](./docs/README.md) にある。

## 残っていること

1. **KC 60件の承認** — [`seed/kc.csv`](./seed/kc.csv) の `approve` 列（[手順](./seed/README.md)）
2. Supabase プロジェクトと API キー
3. Phase 0（仮説検証）— [`13-roadmap.md`](./docs/13-roadmap.md)
