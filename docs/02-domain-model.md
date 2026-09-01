# 02. ドメインモデル — 知識単位(KC)と分類体系

> 対象: HISTORIA MVP / 状態: 確定 / 最終更新: 2026-09-01

## 0. この文書が解く問題

v0.1 は弱点を「**人物・時代・地域の三つのジャンル**」で保存するとしていた。これは着工不能な設計である。

### 問題1: 3軸は「弱点」を表現できない

3軸は**事象を指す座標**であって、**受験生ができないことの型**ではない。実際の失点は次のように起きる。

| 実際の弱点 | 3軸での表現 | 判定 |
|---|---|---|
| 宗教改革の因果関係が説明できない | 時代=近世, 地域=西欧 | **能力の情報が消える** |
| 条約名と年号が結びつかない | 地域が横断（ウェストファリア/パリ/ベルリン…） | **表現不能** |
| タテ（通史）は分かるがヨコ（同時代性）が弱い | 対象が存在しない | **表現不能** |
| ウマイヤ朝とアッバース朝を混同する | 時代=中世, 地域=西アジア | **「何と何を」の情報が消える** |

「中世×西アジアが苦手」という情報だけが残ると、生成すべき教材も出すべき設問も一意に決まらない。
教材は『イスラーム史の解説文』という汎用記事に退化し、v0.1 が最も避けたがっていた
「単なる暗記アプリ」に自ら着地する。

### 問題2: 3軸は直交しない

カール大帝は「人物」であり同時に「西欧」であり「中世」である。AI自動判定が同じ弱点を
3レコードに分裂させるか、どれか1つに恣意的に丸めるかが未定義であり、
**弱点の強さを比較する演算が定義できない**。

## 1. 決定: KC（知識コンポーネント）モデル

**3ジャンルは KC の属性(facet)に降格する。** 弱点の単位は KC とする。

KC は「用語」ではなく **「識別すべき区別・因果・年代順・地理比定」** の単位で切る。

```
kc.kind ∈ { fact, distinction, causal, chronology, geo }
```

| `kind` | 意味 | 例 |
|---|---|---|
| `fact` | 単一の事実の再認 | 「ハンムラビ法典を制定したのはハンムラビ王」 |
| `distinction` | 2つ以上の項目の区別 | 「ウマイヤ朝とアッバース朝の違い」 |
| `causal` | 因果関係 | 「三十年戦争がウェストファリア条約に至った経緯」 |
| `chronology` | 時系列・順序 | 「19世紀ヨーロッパの主要条約の年代順」 |
| `geo` | 地理比定 | 「オスマン帝国の最大版図の範囲」 |

問題1の表は、この `kind` によって次のように表現できるようになる。

| 実際の弱点 | KC |
|---|---|
| 宗教改革の因果が説明できない | `kind=causal`, `kc.euro.reformation_causes` |
| 条約名と年号が結びつかない | `kind=chronology`, `kc.euro.c19_treaties_order` |
| ヨコ（同時代性）が弱い | `kind=chronology`, `kc.cross.c17_simultaneity` |
| ウマイヤ朝とアッバース朝の混同 | `kind=distinction`, `kc.islam.umayyad_vs_abbasid` |

## 2. KC の ID 体系

**自動採番せず、人間可読の安定文字列を主キーにする。**

```
kc.<領域スラッグ>.<内容スラッグ>
例: kc.islam.umayyad_vs_abbasid
    kc.euro.reformation_causes
    kc.japan.perry_arrival
    kc.cross.opium_war_and_japan_opening
```

理由:
1. LLM に KC を名指しさせる必要がある（`07-content-pipeline.md`）。数値IDだと出力の妥当性を人間が検証できない
2. 外部キー制約で LLM 出力を DB 層でも弾ける（存在しないIDは INSERT が失敗する）
3. seed データを git で差分管理できる

**ID は一度発行したら変更しない。** 統合が必要になった場合は `kc.retired = true` にして
`kc_merge(from_id, to_id)` に記録し、`response` の再生時にマッピングする。

## 3. 規模

| 案 | KC数 | 判定 |
|---|---|---|
| 用語をそのままKCにする | 5,200超（山川『世界史用語集』の採録語数） | **不可**。1KCあたりの観測数が永久に足りず、全KCが `status='unknown'` から動かない |
| 受験で問われる粒度に丸める | 1,500〜2,500 | 最終的な目標 |
| **MVP初期シード** | **800〜900** | **採用** |

MVP の内訳:

| 範囲 | KC数 |
|---|---|
| 世界史探究（共通テスト頻出＋私大マーク頻出） | 600 |
| 歴史総合（日本史分野・対外関係史） | 200〜300 |
| **合計** | **800〜900** |

※ 山川『世界史用語集』の採録語数「約5,200語」は出版社の公表値。KC への丸め比率（用語約6語→KC1件）は
本仕様の見積りであり、実際の作成作業で **要検証**。

## 4. facet（3ジャンルの降格先）

3ジャンルは KC の**属性**として保持する。弱点の単位ではないが、
診断テストの被覆保証・教材の範囲指定・UI のフィルタに使う。

### 4.1 時代 — 測定用の粗グリッドとして持つ

v0.1 は「時代」が西暦レンジなのか区分名（古代・中世・近世・近代）なのかを定義していなかった。
**区分名は採用しない。** 「中世」「近世」はヨーロッパ史由来の概念で、中国史・イスラーム史に
そのまま適用するのは学界でも論争があり、教科書もこの用語では章立てしていない
（山川『詳説世界史』世探704 は「諸地域の歴史的特質の形成」「諸地域の交流・再編」という主題ベースの部立て）。

**決定**: 時代は次の2つに分離する。

- **`era`（測定用の粗グリッド）** — 診断テストと弱点の可視化に使う3区分。西暦レンジで定義する
- **`syllabus_unit`（学習単位）** — 教科書の部・章・節に対応する固定マスタ。集中特訓の範囲指定はこちら

```sql
CREATE TABLE era (
  id         smallint PRIMARY KEY,
  label      text NOT NULL,
  start_year int  NOT NULL,     -- 負値は紀元前
  end_year   int  NOT NULL,
  ord        smallint NOT NULL
);
INSERT INTO era VALUES
  (1, '前近代（〜1500年）',      -4000, 1500, 1),
  (2, '近世・近代（1500-1900）',  1500, 1900, 2),
  (3, '現代（1900年〜）',         1900, 2100, 3);
```

3区分にとどめる理由は §6 の診断テストのセル数（3時代 × 4地域 = 12セル）に直結する。
セルを増やすと診断の必要問数が増え、高校生が離脱する。

年代が不確実な事象（ハンムラビ法典、殷の成立）のために、`kc` は
`year_from` / `year_to` / `year_precision ∈ {exact, decade, century, unknown}` を持つ。
単一の `year` カラムにすると紀元前の事象を入れられない。

### 4.2 地域 — 階層マスタ ＋ 多対多

v0.1 は地域が単一階層か木構造かを定義していなかった。受験世界史では地域概念が単純な入れ子にならない。

- 「イスラーム世界」は地域ではなく文化圏で、西アジア・北アフリカ・イベリア・インド・東南アジアにまたがる
- オスマン帝国はバルカン＋西アジア＋北アフリカ、モンゴル帝国はユーラシア全域
- **対外関係史（歴史総合）は定義上2地域以上にまたがる**

**決定**: 地域は階層マスタで持ち、KC との関係は**多対多**にする。

```sql
CREATE TABLE region (
  id        smallint PRIMARY KEY,
  label     text NOT NULL,
  parent_id smallint REFERENCES region(id),
  grid_id   smallint NOT NULL,   -- 診断テストの粗グリッド用（4値）
  ord       smallint NOT NULL
);
```

診断テスト用の粗グリッド（`grid_id`）は4値に固定する。

| `grid_id` | ラベル |
|---|---|
| 1 | 欧米 |
| 2 | 西アジア・アフリカ |
| 3 | 南アジア・東南アジア |
| 4 | 東アジア・日本 |

`region` の実マスタはこれより細かい階層（例: `欧米 > 西欧 > フランス`）を持つが、
**AI には自由文字列を書かせず、必ず `region.id` を選ばせる**（§5）。

### 4.3 人物

```sql
CREATE TABLE person (
  id       int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  label    text NOT NULL,                 -- 正規表記
  aliases  text[] NOT NULL DEFAULT '{}',  -- 「フビライ/クビライ」等の表記ゆれ
  era_id   smallint REFERENCES era(id),
  UNIQUE (label)
);
```

`aliases` は Phase2 の用語リンクでも使う（`09-content-sourcing.md`）。

### 4.4 学習単位（教科書章立て）

**集中特訓の範囲指定・教材の生成単位・進捗の分母は、すべてこのマスタで数える。**

```sql
CREATE TABLE syllabus_unit (
  id        text PRIMARY KEY,             -- 'wh.2.3' = 世界史探究 第2部 第3章
  subject   text NOT NULL CHECK (subject IN ('world_history','general_history')),
  parent_id text REFERENCES syllabus_unit(id),
  level     smallint NOT NULL,            -- 1=部 2=章 3=節
  label     text NOT NULL,
  ord       smallint NOT NULL
);
CREATE TABLE kc_syllabus_unit (
  kc_id   text NOT NULL REFERENCES kc(id),
  unit_id text NOT NULL REFERENCES syllabus_unit(id),
  PRIMARY KEY (kc_id, unit_id)
);
```

固定マスタにする理由は `05-scheduler.md` に直結する。v0.1 は
「範囲からどれくらいの単位に分けて文章を作るかも完全にAIに決めさせる」としていたが、
分割を毎回 AI に委ねると同じ「フランス革命〜ナポレオン」が今日は4単位、明日は7単位になり、
**「一日にこなすべき量」の逆算の分母が非決定的になる**。ホームの残量表示が再生成のたびに増減し、
「昨日3日分終えたのに残りが増えた」という状態になってアプリの信頼が一発で失われる。

さらに受験生の学習単位は外部と照合される。学校の定期テスト範囲も模試の出題範囲も予備校のカリキュラムも
「教科書の第○章〜第○章」で告知されるため、**アプリ内だけで通用する独自分割はその照合を不可能にする**。

## 5. LLM に KC を生成させない

v0.1 の「AIによる自動判定」「完全にAIに決めさせる」を素直に実装すると、LLM が弱点ラベルや KC を
毎回自然言語で生成して DB に入る。その瞬間に

```
「アッバース朝の成立」「アッバース朝成立の経緯」「アッバース革命」
```

が別レコードになり、同じ知識の観測が3つに分裂して、どれも観測数が閾値に届かず
**永久に `status='unknown'` のまま留まる**。弱点推定の統計が原理的に成立しなくなる。

**決定**: LLM の役割は「生成」ではなく「**既存KCへの分類**」に限定する。

1. LLM 呼び出しは必ず「候補KCのidリストを与え、その中から選ばせる」制約付き構造化出力にする
2. 候補の絞り込みは LLM ではなく **pgvector の近傍検索**で行う（KCラベルの埋め込みを事前計算し、
   教材本文や設問文から上位30件を引いて LLM に渡す）
3. `kc.id` が外部キー制約になっているので、存在しないIDを返せば **DB層でも弾かれる**（二重の担保）
4. 新KCが本当に必要な場合は `kc_proposal` に積み、**作者が承認して初めて `kc` に入る**。
   承認前のKCで弱点判定はしない

```sql
CREATE TABLE kc_proposal (
  id             bigserial PRIMARY KEY,
  label          text NOT NULL,
  rationale      text,
  nearest_kc_id  text REFERENCES kc(id),
  similarity     real,
  proposed_by    text NOT NULL,          -- 'material_gen' | 'item_gen' | 'user_report'
  status         text NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','approved','merged','rejected')),
  created_at     timestamptz NOT NULL DEFAULT now()
);
```

## 6. 歴史総合の扱い

2025年度から共通テストの科目名は「**歴史総合、世界史探究**」であり、
歴史総合は日本と世界の近現代を一体で扱う（日本史分野を含む）。
v0.1 には日本史側の記述が一切なく、地域マスタにも「日本」を置く想定が読み取れなかった。

**決定: 歴史総合を対象に含める**（作者判断）。

- `region` に「日本」を置き、`grid_id = 4`（東アジア・日本）に属させる
- `syllabus_unit.subject = 'general_history'` として歴史総合の章立てを別に持つ
- **対外関係史のKCは単一地域に属さない。** `kc_region` を多対多にし、`primary` フラグで
  診断グリッド用の代表地域を1つ決める

```sql
CREATE TABLE kc_region (
  kc_id     text NOT NULL REFERENCES kc(id) ON DELETE CASCADE,
  region_id smallint NOT NULL REFERENCES region(id),
  is_primary boolean NOT NULL DEFAULT false,
  PRIMARY KEY (kc_id, region_id)
);
-- 各KCはちょうど1つの primary region を持つ
CREATE UNIQUE INDEX ON kc_region (kc_id) WHERE is_primary;
```

例: `kc.cross.opium_war_and_japan_opening`（アヘン戦争と日本の開国）は
`region = {東アジア・日本(primary), 欧米}` の2件を持つ。

※ 歴史総合における日本史分野：世界史分野の分量比は「およそ1:2」とされるが、
正確な配点内訳は **要検証**。KC の初期シード配分（200〜300件）はこの比率を仮定している。

## 7. KC マスタの DDL

```sql
CREATE TABLE kc (
  id              text PRIMARY KEY,
  label           text NOT NULL,
  kind            text NOT NULL CHECK (kind IN ('fact','distinction','causal','chronology','geo')),
  era_id          smallint REFERENCES era(id),
  person_id       int      REFERENCES person(id),      -- 人物facet（NULL可）
  year_from       int,
  year_to         int,
  year_precision  text CHECK (year_precision IN ('exact','decade','century','unknown')),
  prereq_ids      text[] NOT NULL DEFAULT '{}',        -- 前提KC
  exam_weight     real   NOT NULL DEFAULT 1.0,         -- 出題頻度。冷スタート事前分布に使う
  base_difficulty real   NOT NULL DEFAULT 0.0,         -- Eloスケール初期値
  embedding       vector(768),
  retired         boolean NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON kc (era_id) WHERE NOT retired;
CREATE INDEX ON kc (person_id) WHERE person_id IS NOT NULL;
CREATE INDEX ON kc USING hnsw (embedding vector_cosine_ops);
```

`exam_weight` は「教科書7点中の掲載数」に相当する頻度指標を 0.0〜1.0 に正規化して入れる。
冷スタート時の事前分布（`04-weakness-engine.md` §E）と診断テストの出題プール選択に使う。

## 8. 初期シードの作成手順

1. 山川『詳説世界史』（世探704）および歴史総合の教科書の**章立て**を `syllabus_unit` に手で入力する（約80行）
2. 各章について、AI に「この章で受験生が間違えやすい区別・因果・年代順」を列挙させ、
   `kc_proposal` に積む。**作者が1件ずつ承認する**
3. 承認済みKCに `kind` / `era_id` / `kc_region` / `exam_weight` を付与する
4. KCラベルを埋め込み、`kc.embedding` に格納する

手順2〜3は800〜900件あるため、**1章あたり10〜12件 × 80章**として作業を分割する。
これは MVP のクリティカルパスであり、`13-roadmap.md` で独立したフェーズとして扱う。
