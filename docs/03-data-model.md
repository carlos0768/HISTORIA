# 03. データモデル

> 対象: HISTORIA MVP / 状態: 確定（DDL は PostgreSQL 16 で実行検証済み） / 最終更新: 2026-09-01
>
> **完全な DDL は [`schema.sql`](./schema.sql) にある。本文書はその設計判断を説明する。**

## 0. 検証結果

`schema.sql` は PostgreSQL 16.13 に対して実行し、40テーブルすべてが作成されることを確認した。
さらに14件の制約テストを実施し、すべて意図どおりの挙動であることを確認した（§8）。

pgvector が検証環境に無かったため、`vector(768)` を `real[]` に、HNSW インデックスを除外した
検証用コピーで実行した。この2点は Supabase 上での実機確認が必要（**要検証**）。

## 1. 設計の中心 — KC が全機能を串刺しにする

v0.1 の最大の構造的欠陥は、**機能間の連結を担う「知識単位の共通ID体系」が存在しないこと**だった。

教材・クイズ・確認テスト・弱点・タイムライン・Wiki用語・過去問・動画が**同じものを指せなければ**、
5本の柱は互いに参照できない「別アプリの寄せ集め」になる。
「この教材に対応する問題を出す」「この問題が解けなかったからこの範囲が弱点」「間違えたところの動画を見せる」
のいずれも実装できない。

**決定: `kc` を中心ハブとする。** すべての機能が `kc.id` を経由して結び付く。

```
                          ┌─────────────┐
              material ───┤             ├─── item ─── card (SM-2)
                          │             │              │
                 video ───┤     kc      ├─── response ─┘
                          │  （中心ハブ）│      │
             past_exam ───┤             │      └── user_kc_state
                          │             │              (マスタリー)
                 drill ───┤             ├─── misconception
                          └─────────────┘
                                 │
                   era / region / person / syllabus_unit
                          （facet・学習単位）
```

`kc.id` は人間可読の安定文字列（`kc.islam.umayyad_vs_abbasid`）であり、
**LLM の出力を DB の外部キー制約で検証できる**（`02-domain-model.md` §5）。

## 2. 層の分離 — 3つの独立した層

この設計で最も重要なのは、**役割の異なる3つの層を混ぜないこと**である。

| 層 | テーブル | 単位 | 責務 |
|---|---|---|---|
| **イベント層** | `response` | 1回の解答 | 起きたことの記録。**不変・追記専用** |
| **マスタリー層** | `user_kc_state` | user × KC | 「どれだけ理解しているか」 |
| **スケジュール層** | `card` | user × item | 「いつもう一度出すか」 |

### 2.1 なぜマスタリー層とスケジュール層を分けるのか

集中特訓は同時に複数走る。「イスラーム史」と「近代ヨーロッパ」の両方が十字軍のKCを含んだとき、
**特訓ごとにスケジュールを持たせると同じ問題が2回出題され、SM-2 の状態が2枚に分裂して
両方の間隔推定が壊れる**（各カードは相手の復習を知らないので、実際より短い間隔を出し続ける）。

したがって:
- `card` は **user × item** で一意（`UNIQUE (user_id, item_id)`）
- `user_kc_state` は **user × KC** で一意（特訓に依存しない）
- `drill` は「KC集合＋締切」を持つ**ビュー**であり、自前のキューを持たない

### 2.2 なぜイベント層を不変にするのか

個人開発の適応アルゴリズムは**必ず閾値を何度も変える**。現在値だけを持つ設計だと、
変更のたびに新旧の判定が混在し、**ユーザーが積み上げた学習履歴を捨てる**ことになる。

`user_kc_state` / `card` / `misconception` は `response` から**完全に再生成できる**。
`algo_version` / `sched_version` を持たせ、式を変えたら `response` を `answered_at` 昇順に再生する。
1ユーザー数千件なので数百ミリ秒で終わる。

```sql
-- 再計算の擬似コード
DELETE FROM user_kc_state WHERE user_id = $1;
DELETE FROM card          WHERE user_id = $1;
DELETE FROM misconception WHERE user_id = $1;
-- response を answered_at 昇順に再生して両テーブルを作り直す
```

`response` は RLS で SELECT / INSERT のポリシーのみを作り、**UPDATE / DELETE のポリシーを作らない**。

## 3. 共有カタログと個人データの境界

原価をユーザー数から切り離すため、教材は共有カタログ方式を採る（`07-content-pipeline.md` §3）。
これはスキーマに直接現れる。

| | テーブル | `user_id` を持つか |
|---|---|---|
| **共有** | `material` / `material_section` / `item` / `video` / `kc` / `past_exam` | **持たない** |
| **個人** | `response` / `card` / `user_kc_state` / `drill` / `material_read` / `material_personalization` / `video_view` | 持つ |

```sql
CREATE UNIQUE INDEX material_one_approved_per_unit
  ON material (unit_id) WHERE status = 'approved';
```

**1つの `syllabus_unit` に対して `approved` な教材はちょうど1件**である。
これが共有カタログ方式をスキーマ層で強制する。`draft` は複数持てるので、
新版を並行して作ってから切り替えられる（`07` §7）。

## 4. 多対多にした3箇所とその理由

| 関係 | テーブル | 多対多にした理由 |
|---|---|---|
| KC × 地域 | `kc_region` | **対外関係史は単一地域に属さない**。「アヘン戦争と日本の開国」は東アジアと欧米にまたがる |
| item × KC | `item_kc` | 1問が複数の知識を問うのは普通。Q行列として重み `weight` を持つ |
| 動画 × KC | `video_kc` | 1本の動画が複数の論点を扱う。`start_sec` で該当箇所を頭出しする |

`kc_region` には診断テストの粗グリッド用に代表地域を1つ決める制約を入れた。

```sql
CREATE UNIQUE INDEX kc_region_one_primary ON kc_region (kc_id) WHERE is_primary;
```

部分ユニークインデックスなので、「primary はちょうど1件、非primary は何件でも」が表現できる。

## 5. 権利状態をスキーマで扱う

**過去問は MVP では扱わないが、要素分解だけは最初から入れる**（`10-legal-risk.md` §3.3）。
1カラムに丸ごと入れる設計を後から分解するのは不可能だからである。

```sql
CHECK (rights_status IN ('self_made','public_domain','licensed') OR body IS NULL)
```

**権利が未処理の要素は本文を保持できない。** アプリのバグで `needs_permission` のまま本文を
INSERT しようとしても DB が拒否する。「気をつける」ではなく制約で守る。

同じ考え方を動画にも適用した。

```sql
CHECK (status <> 'approved' OR (embeddable AND yt_rating IS DISTINCT FROM 'ytAgeRestricted'))
```

**埋め込み禁止・年齢制限の動画は `approved` にできない**（`09b-video.md` §2 V5）。

## 6. DB プロバイダの選定

| 候補 | 無料枠 | pgvector | 日本語全文検索 | Vercel との接続 | 判定 |
|---|---|---|---|---|---|
| **Supabase** | あり | ○ | **PGroonga がネイティブ対応** | Supavisor（プーラ）あり | **採用** |
| Neon | あり | ○ | PGroonga 非対応 | プーラあり | 次点 |
| Turso | あり | SQLite。○（限定的） | 弱い | ○ | 不採用（SQLite で RLS と pgvector の要件を満たしにくい） |
| PlanetScale | 有料化済み | MySQL。× | × | ○ | 不採用 |

**Supabase を採用する。** 決め手は3点。

1. **日本語全文検索**: Supabase は PGroonga をネイティブ対応の拡張として提供している。
   `pg_bigm` は Supabase では利用できない。Phase2 の用語検索・過去問検索で必要になる
2. **認証と RLS が統合されている**: `auth.uid()` を使った RLS を書けば、
   API 層のバグでも他人のデータが漏れない。個人開発では多層防御が効く
3. **pgvector** が使える（KC の近傍検索、動画の KC 対応付け）

**接続プーリング**: Vercel の Serverless から直接 PostgreSQL に接続すると、
関数インスタンスごとにコネクションを張って上限を食い潰す。
Supabase の Supavisor（transaction モード）経由で接続する。

**注意（要検証）**: Supabase Free は一定期間の非アクティブでプロジェクトが一時停止される。
数人しか使わない本アプリでは実際に起きうる。問題が出れば Pro（約3,750円/月）に上げる。

## 7. 認証

対象は高校生であり、**メール認証の確認リンクを踏ませる導線は離脱が大きい**。

**決定: Supabase Auth ＋ Google ログインを主にする。** 加えて招待制を強制する。

```
1. 招待コードを入力（invite_code。作者が発行、上限10名）
2. Google ログイン
3. 生年月日を入力
4. 16歳未満なら保護者メールでの同意（10-legal-risk.md §5.3）
```

招待コードは「限られた範囲」の客観的な担保でもある（`10-legal-risk.md` §3.2 G1/G7）。

## 8. 制約テストの結果

`schema.sql` に対して以下を実行し、すべて意図どおりであることを確認した。

| # | テスト | 期待 | 結果 |
|---|---|---|---|
| T1 | 16歳未満・保護者同意なしのユーザー登録 | 失敗 | ✅ CHECK 違反 |
| T2 | 16歳未満・保護者同意ありのユーザー登録 | 成功 | ✅ |
| T3 | 同一KCに primary 地域を2件 | 失敗 | ✅ 一意制約違反 |
| T4 | primary 1件＋非primary 1件 | 成功 | ✅ |
| T5 | `needs_permission` のまま本文を保存 | 失敗 | ✅ CHECK 違反 |
| T6 | `self_made` で本文を保存 | 成功 | ✅ |
| T7 | `embeddable=false` の動画を `approved` に | 失敗 | ✅ CHECK 違反 |
| T8 | 年齢制限動画を `approved` に | 失敗 | ✅ CHECK 違反 |
| T9 | 通常の動画を `approved` に | 成功 | ✅ |
| T10 | `card.ef` に 1.2（下限未満） | 失敗 | ✅ CHECK 違反 |
| T11 | `card.interval_days` に 400（上限超過） | 失敗 | ✅ CHECK 違反 |
| T12 | 同一 unit に `approved` な教材を2件 | 失敗 | ✅ 一意制約違反 |
| T13 | 同一 unit に `draft` を追加 | 成功 | ✅ |
| T14 | `response.weight` に 1.5 | 失敗 | ✅ CHECK 違反 |

再現手順:

```bash
initdb -D $PGDATA -A trust -U postgres
pg_ctl -D $PGDATA start
createdb historia
# pgvector が無い環境では vector(768) → real[] に置換し、hnsw インデックス行を除外する
psql -d historia -v ON_ERROR_STOP=1 -f docs/schema.sql
```

## 9. インデックス方針

| インデックス | 用途 |
|---|---|
| `card (user_id, due_at) WHERE NOT suspended` | 出題キューの主クエリ。最も頻繁に叩かれる |
| `user_kc_state (user_id, p_know)` | 弱点の一覧、確認テストの層化抽出 |
| `response (user_id, answered_at)` | 再計算時の再生、学習履歴の表示 |
| `response (user_id, item_id, answered_at DESC)` | 「14日以内に解いたか」の判定（`06-assessment.md` §2.2） |
| `item_kc (kc_id)` / `material_section_kc (kc_id)` / `video_kc (kc_id, relevance DESC)` | KC からの逆引き。すべての「関連◯◯を出す」導線 |
| `kc USING hnsw (embedding)` / `video USING hnsw (embedding)` | 近傍検索（KC 分類・動画の対応付け） |
| `content_report (status) WHERE status = 'open'` | 未処理の誤り報告 |

## 10. 命名規則

| 規則 | 例 |
|---|---|
| テーブル名は**単数形**のスネークケース | `user_kc_state`（`users` ではなく `app_user`） |
| 主キーは `id` | 複合キーの中間テーブルを除く |
| 時刻は `_at` サフィックスの `timestamptz` | `answered_at` / `due_at` |
| 日付は `_date` サフィックスの `date` | `plan_date` / `birth_date` |
| 列挙は `text` ＋ `CHECK` | PostgreSQL の `ENUM` 型は値の追加が DDL 変更になるため使わない |
| 真偽値は肯定形 | `suspended`（`not_suspended` ではない） |

`ENUM` 型を避けたのは、`kind` や `status` の値が仕様の進化とともに増えるためである。
`CHECK` なら `ALTER TABLE ... DROP CONSTRAINT` / `ADD CONSTRAINT` で済む。

## 11. Phase2 で追加するテーブル

| テーブル | 用途 | 章 |
|---|---|---|
| `term` / `term_alias` | 用語マスタ（正規語・別表記・頻度）。Wiki リンクの土台 | `09-content-sourcing.md` §4 |
| `timeline_event` / `timeline_article` | タイムライン（事前生成・地域レーン） | `09-content-sourcing.md` §3 |

`past_exam` 系と `evidence_import` 系は **Phase2 の機能だがスキーマは MVP で確定済み**である
（後から構造を変えられない性質のものだけを前倒しした）。
