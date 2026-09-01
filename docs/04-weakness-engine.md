# 04. 弱点エンジン — 習熟度推定とアダプティブ設計

> 対象: HISTORIA MVP / 状態: 確定（v0.3 で Elo を縮小） / 最終更新: 2026-09-01
>
> **v0.2 からの変更**: 設問を毎回生成する方針になったため、
> **Elo による item 難易度の較正を廃止**した（同じ item が二度と出ず観測が溜まらないため）。
> 学習者の能力 θ の推定は診断テストの出題選択に必要なので残す。

## 0. この文書が解く問題

v0.1 は弱点保存について「**確認テストでユーザの弱点がわかるわけだが、その情報をどのようにして保存するかが問題**」
と書いて設計を保留していた。しかし「正誤の羅列から弱点を出す関数」は自明ではない。

- **単純正答率は使えない。** 1問しか出していないKCは0%か100%の二値になり、確認テストの直後に必ず
  「弱点が数十個ある／ゼロになった」という無意味な出力を出す
- **DKT（LSTM）は使えない。** 学習用の他人データが1件もない状態では訓練不能で、冷スタート時に完全に無力
- **BKT の EM 推定も使えない。** KCあたり数百〜数千観測が必要な上、
  パラメータが縮退解（「知っている方が正答率が低い」等の概念的仮定と矛盾する解）に落ちることが知られている

## 1. 決定: BKT風ベイズ更新 ＋ Elo（パラメータは推定せず固定）

**BKT の4パラメータをデータから推定するのをやめ、出題形式から決まる定数にハードコードする。**
これで縮退問題も推定コストも消える。

Elo は**学習者の能力 θ の更新のみ**に使う。v0.2 では item 難易度 `b` も同時更新して
AI生成問題を較正する設計だったが、**設問を毎回生成する方針になったため廃止した**。
同じ item が二度と出題されないので `elo_n` が溜まらず、較正が原理的に成立しない。
θ は診断テストの出題選択（§5.2）に必要なので残す。

```
guess (g):  四択 0.25 / 一問一答 0.05 / フラッシュカード 0.02 / 正誤判定 0.50
slip  (sl): 0.10  （ただし「誤答 かつ latency < 1500ms」は 0.25 = ケアレス寄り）
learn (T):  0.10
```

1応答あたりの計算量は `O(その item に紐づく KC 数) = 1〜3` であり、
**Vercel のリクエスト内で同期実行できる**（バッチ不要）。

### 1.1 更新式

```python
def on_response(user, item, correct, latency_ms):
    p_know_before = weighted_mean(state(user, kc).p_know for kc, w in item.kcs)   # SM-2 の q 算出に渡す

    for kc, w in item.kcs:                       # w = item_kc.weight
        s  = state(user, kc)
        g  = item.guess_rate                     # format から決まる定数
        sl = 0.25 if (not correct and latency_ms < 1500) else 0.10

        # --- P(習得) のベイズ更新 ---
        if correct:
            num = s.p_know * (1 - sl)
            den = num + (1 - s.p_know) * g
        else:
            num = s.p_know * sl
            den = num + (1 - s.p_know) * (1 - g)
        post = num / den

        # --- 遭遇による学習 ---
        s.p_know = post + (1 - post) * 0.10

        # --- Elo（学習者 θ のみ更新。K は観測数で減衰＝初期は速く動き後で安定） ---
        # item 難易度 b は較正できないため、KC の base_difficulty を代用する
        b     = kc.base_difficulty
        p_exp = g + (1 - g) * sigmoid(s.theta - b)
        Ku    = 0.6 / (1 + 0.05 * s.n_obs)
        s.theta += w * Ku * (correct - p_exp)

        # --- 実効証拠量（推測で当たった分を割り引く） ---
        s.n_eff += w * (1 - g) if correct else w
        s.n_obs += 1
        s.last_seen_at = now()

    # 実測難易度（Elo の代替。04b §5.1）
    item.observed_total   += 1
    item.observed_correct += 1 if correct else 0
    return p_know_before
```

### 1.2 推測正解の補正 — `n_eff`

`n_eff`（実効証拠量）が本設計の要である。

```
正解時: n_eff += w * (1 - g)     # 四択なら 0.75 しか増えない
誤答時: n_eff += w               # 誤答は形式によらず満額の証拠
```

四択を回すだけで見かけの習得度が上がる**報酬ハック**を防ぐ。
`g = 0.25` の四択で正解しても、`g = 0.02` のフラッシュカードで正解した場合の 77% の証拠にしかならない。
正誤判定（`g = 0.50`）はさらに半分である。

## 2. 弱点の状態 — 「マスタリー」と「証拠量」の2軸

v0.1 は「弱点／そうでない」の二値を暗黙に前提していたが、次の3つは区別しなければならない。

- 四択は25%で偶然当たる
- フラッシュカードの自己申告は当たり判定が甘い
- **初見の問題を落とすのは弱点ではなく単なる未学習**

```
retrievability(kc, t)  # 04b-spaced-repetition.md §6 の SM-2 由来の定義 0.9^(t/I)
mastery(kc, t) = p_know * retrievability(kc, t)

status =
  'unknown'   if n_eff < 1.5                    -- 未測定。弱点として表示しない
  'weak'      if mastery < 0.60
  'shaky'     if 0.60 <= mastery < 0.85
  'mastered'  if mastery >= 0.85
                 and n_eff >= 3
                 and count(distinct date(answered_at)) >= 2   -- 別日に2回以上正解
                 and exists(response WHERE format <> 'flashcard' AND correct)  -- 客観形式での正解
```

最後の条件（客観形式での正解が1回以上）は、フラッシュカードの「わかった」を連打するだけで
進捗率が100%になるのを防ぐためである（`06-assessment.md` §4.1）。

`'unknown'` を設けることが決定的に重要である。これが無いと、
**初回の確認テストで「弱点120件」が並び、ホームのボタンが破綻的な件数になる**。
逆に四択を数回回すだけで全KCが `mastered` になり、締切逆算の1日ノルマが0になる。
どちらもリリース初日に発生する。

`mastered` に「別日に2回以上」を課しているのは、同じセッション内の連続正解を習得と見なさないためである
（分散学習の原則）。

## 3. 誤答の中身を保存する — misconception 検出

正誤だけでは、生成すべき教材が決まらない。

- 四択で毎回「アッバース朝」を選ぶユーザー → **混同**。区別を扱う教材が要る
- 誤答がランダムに散るユーザー → **未学習**。基礎から扱う教材が要る

したがって `response.chosen`（選んだ選択肢）を必ず保存する。
**同じ誤選択肢を2回以上選んだら `misconception` を立て、そのKCを最優先で教材化する。**

```sql
CREATE TABLE misconception (
  user_id        uuid NOT NULL,
  kc_id          text NOT NULL REFERENCES kc(id),
  distractor_key text NOT NULL,          -- 繰り返し選ばれた誤答の選択肢キー
  hits           smallint NOT NULL DEFAULT 1,
  last_at        timestamptz NOT NULL DEFAULT now(),
  resolved_at    timestamptz,            -- そのKCが mastered になったら埋める
  PRIMARY KEY (user_id, kc_id, distractor_key)
);
```

`misconception` は `04b-spaced-repetition.md` §4.1 の `q = 0`（最も強い EF 減衰）の条件にもなる。

## 4. `response` を不変の追記専用ログにする

### 4.1 なぜ現在値テーブルを作ってはいけないか

`user_weakness(user_id, genre, level)` のような現在値だけのテーブルは、最も自然な実装だが詰む。

個人開発の適応アルゴリズムは**必ず初期値と閾値を何度も変える**（`guess=0.25` を 0.2 に、
`mastered` 閾値を 0.85 から 0.80 に）。現在値しか持っていないと、変更しても既存ユーザーの弱点は
古い式で書かれた値のまま残り、新旧の判定が混在する。数十人が使い始めてからアルゴリズムを触るたびに、
**ユーザーが積み上げた学習履歴を捨てる**ことになる。

### 4.2 決定: イベントソーシング

`response` を**唯一の真実**とし、`user_kc_state` / `card` / `misconception` は
**完全に導出可能な派生テーブル**として扱う。

```sql
CREATE TABLE response (
  id                  bigserial PRIMARY KEY,
  user_id             uuid NOT NULL,
  item_id             uuid NOT NULL REFERENCES item(id),
  session_kind        text NOT NULL
                      CHECK (session_kind IN ('diagnostic','flashcard','quiz','checktest','video_retrieval','import')),
  drill_id            uuid REFERENCES drill(id),
  correct             boolean NOT NULL,
  chosen              jsonb,               -- 選んだ選択肢。misconception 検出に必須
  latency_ms          int,
  q                   smallint CHECK (q BETWEEN 0 AND 5),   -- SM-2 に渡した評価値
  clamped             boolean NOT NULL DEFAULT false,       -- 締切クランプが効いた回か
  weight              real NOT NULL DEFAULT 1.0,            -- import 由来は 0.5
  evidence_import_id  uuid REFERENCES evidence_import(id),
  answered_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON response (user_id, answered_at);
```

`response` は **UPDATE / DELETE を禁止する**（RLS とアプリ層の両方で）。

`user_kc_state` と `card` は `algo_version` を持ち、式を変えたら
**該当ユーザーの `response` を古い順に再生して作り直す**。1ユーザー数千件なので数百msで再計算できる。

### 4.3 説明可能性

イベントソーシングの副次効果として、**「なぜこれが弱点なのか」を説明できる**ようになる。
受験生は自分の弱点判定に納得できないと使うのをやめるため、これは必須の機能である。

```sql
CREATE VIEW v_weakness_evidence AS
SELECT r.user_id, ik.kc_id, r.answered_at, r.correct, r.chosen, i.stem, r.session_kind
FROM response r
JOIN item i     ON i.id = r.item_id
JOIN item_kc ik ON ik.item_id = i.id;
```

UI には必ず次の形で根拠を3件程度出す。

> **この弱点の根拠**
> ・四択12問中9問で「アッバース朝」を2回選択
> ・最後に正解してから11日経過（保持率の推定 58%）
> ・別日での正解が1回のみ

これは説明責任のためだけでなく、**作者自身がアルゴリズムのバグを見つける唯一の手段**でもある。

## 5. 初回オンボーディング — 適応的診断テスト

### 5.1 解く問題: 循環依存

弱点は確認テストから生まれ、確認テストは集中特訓の中にあり、集中特訓の教材は弱点に基づいて生成される。
**新規ユーザーはこの閉路のどこからも起動できず、初回のホームに表示するものが何もない。**

v0.1 は流入経路として「AIによる自動判定か、ユーザの手動設定」を挙げていたが、
AI自動判定の入力データが新規時点では存在しない。診断テストがこの閉路を断ち切る唯一の入口である。

### 5.2 診断テスト専用の共有設問プール（v0.3 で追加）

**毎回生成にしたことで穴が開く。** 診断テストはサインアップ直後に走るが、
その時点でそのユーザー用の設問は1問も生成されていない。
かといってオンボーディングで2〜3分の生成待ちを課すのは致命的である。

**決定: 診断テスト用の設問だけは、全ユーザー共通の固定プールにする。**

```
item.user_id IS NULL   →  共有プール（診断専用）
item.user_id = <uuid>  →  そのユーザー用に生成された設問
```

これは「毎回生成」の例外だが、次の理由で正当化できる。

| 理由 | 内容 |
|---|---|
| 診断は**測定器**であって学習教材ではない | 個人化する必要がない。むしろ全員に同じ物差しを当てる方が正しい |
| **待たせない** | 生成待ちゼロで即座に始められる |
| **人手レビューできる** | 診断の質が全ユーザーの初期値を決める。ここは品質を落とせない |
| **Elo 較正が効く** | 同じ item が全ユーザーに出るので `elo_b` / `elo_n` が溜まる。§1 で廃止した較正が、診断プールに対してだけは成立する |

規模: **12セル（3時代 × 4地域）× 各20問 = 240問**。作者が生成してレビューする（一度きり・約2人日）。
`exam_weight` 上位のKCを被覆するように配分する。

### 5.3 設計

**出題プール**: 上記の共有プール（`item.user_id IS NULL`）から、facet被覆を保証して選ぶ。

**選択規則**:
```
next = argmax_i  facet_uncertainty(i) * 4 * p_i * (1 - p_i)
       ただし p_i = g + (1-g) * sigmoid(theta_cell(i) - item.elo_b)
       （診断プールは共有・固定なので elo_b が較正される。§5.2）
```
四択の情報量が最大になるのは `p ≈ 0.5〜0.6` 付近である。常に易問／難問ばかり出るのを防ぐ。

**打ち切り条件**:
```
「12問以上 かつ 粗グリッド（3時代 × 4地域 = 12セル）すべてで事後SD ≤ 0.35」
または「上限 24問」
```
1問25秒想定で **最大10分**。高校生に20分の診断を課すと離脱する。
参考として、2025年度共通テスト「歴史総合、世界史探究」は大問5題・マーク32個で60分（1問約1.9分）であり、
診断で24問超は明らかに重い。

**伝播**: 診断で測れるのは**12セルのθ**であって個々のKCではない。
診断終了時に、各KCの初期値を所属セル（`era_id` × `region.grid_id`）のθから与える。

### 5.4 冷スタートの事前分布

```
theta_0(user, cell) = -0.5                     # 診断前。やや低めに置いて過大評価を避ける
p_know_0(kc)        = clip(0.15 + 0.25 * norm(kc.exam_weight), 0.10, 0.45)
                      # 頻出＝教科書で先に習う＝既知の確率が高い、という弱い事前情報

# 診断後:
theta(kc) = theta_0(cell of kc)
n_eff(kc) = 0                                  # ← 変えない
```

### 5.5 診断で測っていないKCを弱点扱いしない

`n_eff` を 0 のままにするため、診断直後の全KCは `status = 'unknown'` である。
**診断結果は出題順の並べ替えにのみ使い、「弱点」として断定表示はしない。**

24問で 800〜900 KC を判定したと表示すると、実際には測っていないものを断定することになり、
ユーザーの信頼を初日に破壊する。UI文言は

> ✅ 「まずここから測っていきます」
> ❌ 「あなたの弱点はこれです」

## 6. 模試・確認テストの画像取り込み

v0.1 は「**将来的には確認テストとか、模試の画像を添付するだけでアプリの弱点データベースに保存される**」
としていたが、「模試の画像」は1種類ではなく4種類あり、**実現可能性が天と地ほど違う**。
一括で1機能として着手すると、最も難しいケースで詰まって全部止まる。

| 種別 | 実現可能性 | 得られる情報 | MVP |
|---|---|---|---|
| (a) 成績表（分野別得点率の印字） | **高**。活字・定型レイアウトで Vision LLM の抽出は安定 | 「西アジア史 42%」程度の facet 単位。KC単位ではない | Phase2 |
| (b) 自己採点済みの解答用紙／マークシート | **中**。「自分が何番を選んだか」が写っている唯一の種別 | 誤選択肢まで分かり misconception 検出に直結。ただし設問内容は別紙 | Phase2 |
| (c) 問題冊子だけ | **低**。設問文はOCRできるが**ユーザーの解答が写っていない** | 正誤の情報がゼロ。**何も更新できない** | 受け付けない |
| (d) 手書きの答案・ノート | 低〜中（日本語手書きの読み取り精度は **要検証**） | ― | Phase2以降 |

**MVP では画像取り込みを実装しない。** ただしスキーマと方針は先に決めておく（後から変更できない部分があるため）。

### 6.1 (a) の使い道の限定

成績表から得られるのは facet 単位の得点率であって KC 単位ではない。
`user_kc_state` を直接更新してはならない。**該当セルの θ を弱く補正するだけ**にとどめる。

```
該当 era × region_grid セルの全KCについて theta -= 0.3    （n_eff は増やさない）
```

### 6.2 誤認識時の確認UIを必須にする

**Vision 出力を直接 DB に書く設計を禁止する。** 必ず人間確認を挟む中間テーブルを置く。

UI は「1画面に最大12件のチェックボックス付きカード（KCラベル＋抽出根拠となる画像の切り抜き領域＋信頼度バッジ）、
既定は信頼度0.8以上のみチェック済み」とする。ユーザーが確定した分だけ `response` に
import 由来の擬似レコードとして流し込む（**`weight = 0.5` に減衰**。本人申告なので通常の出題より信頼度を下げる）。

### 6.3 原本画像を保存しない

模試（河合塾・駿台・ベネッセ・東進等）の問題は**民間企業の著作物**であり、大学入試ではないため
著作権法36条の議論の余地すらない。サーバに恒久保存すると、
**模試問題の無許諾アーカイブを自ら構築する**ことになる（詳細は `10-legal-risk.md`）。

```sql
CREATE TABLE evidence_import (
  id           uuid PRIMARY KEY,
  user_id      uuid NOT NULL,
  kind         text NOT NULL CHECK (kind IN ('score_report','marked_answer_sheet','handwritten')),
  storage_path text,                                  -- 抽出後に NULL にする
  purge_after  date NOT NULL,                         -- 既定 = 作成日 + 30日
  vision_model text NOT NULL,
  raw_json     jsonb NOT NULL,
  status       text NOT NULL DEFAULT 'pending_review'
               CHECK (status IN ('pending_review','confirmed','rejected','expired')),
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE evidence_claim (
  id          bigserial PRIMARY KEY,
  import_id   uuid NOT NULL REFERENCES evidence_import(id) ON DELETE CASCADE,
  kc_id       text REFERENCES kc(id),
  facet_hint  jsonb,                                  -- (a) は facet 止まり、(b) は kc_id まで
  claim       text NOT NULL CHECK (claim IN ('wrong','right','low_rate')),
  chosen_key  text,
  conf        real NOT NULL,
  bbox        jsonb,                                  -- 確認UIで切り抜き表示する領域
  user_verdict text CHECK (user_verdict IN ('accept','reject','edit')),
  applied_at  timestamptz
);
```

原本は `purge_after`（既定30日以内）で必ず破棄し、残すのは抽出済みの構造化 claim のみとする。
**この方針は後から変更できない**（貯めた画像を後で消しても、貯めていた事実は消えない）ため、
MVPで実装しなくてもスキーマと運用ルールは先に確定させる。

## 7. 「AIによる自動判定」の実態

v0.1 の「ジャンルの流入経路はAIによる自動判定」は、**そのほとんどが LLM を必要としない**。

| やりたいこと | 実装 |
|---|---|
| 誤答履歴から弱点KCを出す | **SQL**（`user_kc_state` を `mastery` 昇順で引くだけ）。LLM不要 |
| 教材本文から扱っているKCを判定する | LLM（ただし §5 の「候補から選ぶ」制約付き出力） |
| 模試画像から範囲を読み取る | Vision LLM（Phase2） |

**誤答率の集計で足りる部分を LLM 呼び出しにすると、判定のたびに課金と非決定性が乗る。**
LLM が必要なのは非構造入力（自然文・画像）を扱う場合だけである。

## 8. `user_kc_state` の DDL

```sql
CREATE TABLE user_kc_state (
  user_id          uuid NOT NULL,
  kc_id            text NOT NULL REFERENCES kc(id),
  theta            real NOT NULL DEFAULT -0.5,
  p_know           real NOT NULL,                     -- 冷スタート事前分布で初期化（§5.4）
  n_obs            int  NOT NULL DEFAULT 0,
  n_eff            real NOT NULL DEFAULT 0,
  last_seen_at     timestamptz,
  first_correct_at timestamptz,
  algo_version     smallint NOT NULL DEFAULT 1,
  updated_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, kc_id)
);
CREATE INDEX ON user_kc_state (user_id, p_know);
```

## 9. パラメータ一覧（すべて本仕様の提案値。実データ検証は要検証）

| パラメータ | 値 | 出典/根拠 |
|---|---|---|
| `guess` 四択 | 0.25 | 選択肢数の逆数 |
| `guess` 正誤判定 | 0.50 | 同上 |
| `guess` 一問一答 | 0.05 | 提案値 |
| `guess` フラッシュカード | 0.02 | 提案値 |
| `slip` 通常 | 0.10 | 提案値 |
| `slip` 即答誤答 | 0.25 | 提案値 |
| `T_learn` | 0.10 | 提案値 |
| Elo K 係数（θ のみ） | `0.6 / (1 + 0.05·n)` | 提案値 |
| `n_eff` unknown 閾値 | 1.5 | 提案値 |
| `mastery` weak 閾値 | 0.60 | 提案値 |
| `mastery` mastered 閾値 | 0.85 | 提案値 |
| `theta_0` | -0.5 | 提案値（過大評価を避ける） |
| 診断打ち切り 事後SD | 0.35 | 提案値 |
| 診断 最小/最大問数 | 12 / 24 | 提案値（1問25秒で最大10分） |

**これらは `algo_version` で管理し、変更時は `response` から再計算する。**
値を直接いじって既存の `user_kc_state` を残す運用は禁止する。
