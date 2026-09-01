# 04b. 間隔反復アルゴリズム仕様（SM-2 ／ KC 単位）

> 対象: HISTORIA MVP / 状態: 確定（v0.3 で適用単位を変更） / 最終更新: 2026-09-01
>
> **v0.2 からの変更**: SM-2 の適用単位を `card (user_id, item_id)` から
> **`kc_card (user_id, kc_id)`** に移した。理由は §1.2。

## 0. この文書の位置づけ

本アプリの復習スケジューリングは **SM-2（SuperMemo 2, Wozniak 1987）** で行う。
「いつその知識をもう一度問うか」を決めるのは本アルゴリズムだけであり、
「その知識をどれだけ理解しているか」の推定は `04-weakness-engine.md` の KC 層が担う。

## 1. なぜ SM-2 か、なぜ KC 単位か

### 1.1 SM-2 を選ぶ理由

FSRS（FSRS-5）は SM-2 より予測精度が高いが採用しない。

| 論点 | SM-2 | FSRS-5 |
|---|---|---|
| パラメータ数 | 実質1個（EF初期値2.5） | 21個 |
| パラメータ最適化 | 不要 | 本人の数百〜数千レビュー履歴が必要 |
| 想定ユーザー数 | 数人 | — |
| 実装量 | 約30行・ライブラリ不要 | `ts-fsrs` 依存 |
| ユーザーへの説明 | `(n, EF, I)` をそのまま提示できる | 内部状態の説明が困難 |

利用者が数人という前提では、FSRS のパラメータ最適化に必要なレビュー履歴が**そもそも存在しない**。
既定パラメータのまま使うなら精度優位はほとんど消え、依存とブラックボックス性だけが残る。

### 1.2 KC 単位にする理由（v0.3 の変更）

**設問を毎回生成する方針にしたため、item 単位のスケジューリングが成立しない。**

`card (user_id, item_id)` に `n / EF / interval` を積み上げる設計は、
**同じ item が繰り返し出題されること**を前提にしている。設問が毎回新しく生成されると、
昨日解いた item は今日存在せず、状態を引き継ぐ相手がいない。
`n` は永久に 0 のまま、間隔は 1 日から伸びず、**間隔反復が完全に無効化される**。

したがって状態を **KC に紐づける**。

```
v0.2:  card (user_id, item_id)  ← item が固定であることが前提
v0.3:  kc_card (user_id, kc_id) ← KC は固定語彙（02-domain-model.md §5）なので安定
```

KC は `kc_proposal` の作者承認制で管理される閉じた語彙であり、生成のたびに増減しない。
スケジューリングの土台として安定している。

### 1.3 この変更の利点と代償

| | 内容 |
|---|---|
| **利点** | 同じ知識が**毎回違う切り口**で問われる。問題文の丸暗記で正解できなくなり、入試の初見問題への転移が良くなる。`06-assessment.md` §2.2 で懸念していた「逐語再認」の問題が構造的に消える |
| **利点** | 状態が KC 単位なので、`04-weakness-engine.md` の `p_know` と**同じ粒度**になり、2つの層のインターフェースが単純になる |
| **代償** | **Elo による item 難易度の較正が効かない**。同じ item が二度と出ないため `elo_b` が初期値のまま溜まらない。難易度は生成プロンプトで指定するしかない（§5） |
| **代償** | 「同じカードを繰り返す」ことによる記憶の手がかりの一貫性が失われる。SM-2 の `EF`（項目の易しさ）が、item ではなく KC の易しさを表すようになり、意味が変わる |

**将来 FSRS へ移行できる。** `response` は不変の追記専用ログであり `kc_card` は完全な導出テーブルなので、
移行は再計算だけで済む。`kc_card` は最初から `sched_algo` / `sched_version` を持つ。

## 2. KC カードの状態

| 列 | 型 | 初期値 | 意味 |
|---|---|---|---|
| `n` | `int` | `0` | 連続正答回数（誤答で0にリセット） |
| `ef` | `real` | `2.5` | Easiness Factor。下限 `1.3` |
| `interval_days` | `int` | `0` | 直近に決定した復習間隔（日） |
| `due_at` | `timestamptz` | 作成時刻 | 次回出題日時 |
| `lapses` | `int` | `0` | 累計の誤答回数（leech 判定） |
| `suspended` | `boolean` | `false` | leech 等で出題停止中 |
| `last_review_at` | `timestamptz` | `NULL` | 直近の解答時刻 |
| `sched_algo` / `sched_version` | | `'sm2'` / `1` | 再計算の版管理 |

主キーは `(user_id, kc_id)`。

## 3. 更新アルゴリズム

`q` は 0〜5 の評価値（§4 で本アプリの入力から導出する）。

```python
def sm2_update(kc_card, q, deadline, today):
    clamped = False

    if q >= 3:                                    # 正答
        if   kc_card.n == 0: interval = 1
        elif kc_card.n == 1: interval = 6
        else:                interval = round(kc_card.interval_days * kc_card.ef)
        kc_card.n += 1
    else:                                         # 誤答
        kc_card.n = 0
        kc_card.lapses += 1
        interval = 1

    # EF は正誤にかかわらず毎回更新する（SM-2 原典どおり）
    kc_card.ef = max(1.3, kc_card.ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))

    interval = min(interval, 365)                 # 間隔爆発の上限

    # 締切クランプ: 締切の3日前までに最後の復習を終える
    natural_due = today + timedelta(days = round(interval * (1 + jitter())))
    hard_due    = deadline - timedelta(days = 3) if deadline else None

    if hard_due and natural_due > hard_due:
        kc_card.due_at = max(hard_due, today + timedelta(days = 1))
        clamped = True
        # クランプ時は interval も ef も更新しない（理由は §6）
    else:
        kc_card.due_at        = natural_due
        kc_card.interval_days = interval

    if kc_card.lapses >= 8:                       # leech ルール（§7）
        kc_card.suspended = True

    kc_card.last_review_at = now()
    return clamped        # response.clamped に記録する
```

`jitter()` は `[-0.05, +0.05]` の一様乱数。復習が同じ日に山積みになるのを防ぐ。
再計算で `due_at` がぶれないよう、**`response.id` を種とした決定的な擬似乱数**にする。

### EF の増減値（`q` 別）

| `q` | ΔEF | 意味 |
|---|---|---|
| 5 | `+0.10` | 完全に想起できた |
| 4 | `0.00` | 想起できた |
| 3 | `-0.14` | 苦労して想起できた |
| 2 | `-0.32` | 誤答（通常） |
| 1 | `-0.54` | 誤答（即答・当てずっぽう） |
| 0 | `-0.80` | 誤答（誤概念の反復） |

### 3.1 1つの item が複数 KC に紐づく場合

`item_kc` は多対多である。1回の解答で複数の `kc_card` を更新する。

```python
for kc, w in item.kcs:            # w = item_kc.weight
    q_kc = derive_q(kc, correct, latency_ms)   # p_know は KC ごとに違う（§4.1）
    sm2_update(kc_card(user, kc), q_kc, deadline_of(kc), today)
```

**重み `w` は SM-2 には効かせない。** SM-2 は「思い出せたか」の離散評価であり、
重み付き更新は定義されていない。`w` は `04-weakness-engine.md` の
`p_know` / `n_eff` の更新にのみ効かせる。

`item_kc.weight` が 0.5 未満の副次的な KC については、
**`sm2_update` を呼ばない**（その問題はその KC を主に問うていないため）。

## 4. HISTORIA の入力 → `q` の写像

SM-2 は「6段階の自己評価」を前提にしているが、本アプリの入力は四択・一問一答・フラッシュカードである。
さらに SM-2 には guess パラメータが無く、**四択の当てずっぽう正解がそのまま `q=4` として
間隔を ×EF 伸ばしてしまう**。

`04-weakness-engine.md` の `p_know`（その KC を習得している確率の事前信念）と結合して解決する。

### 4.1 客観形式（四択・一問一答・正誤判定・並べ替え）

```python
if correct:
    q = 3 + round(2 * p_know_before(kc))       # <0.25→3 / 0.25-0.75→4 / >0.75→5
    if latency_ms > 1.5 * median_latency_ms:
        q = max(3, q - 1)                      # 時間がかかった＝想起に苦労した
else:
    if misconception_hit(kc):  q = 0           # 同じ誤選択肢を2回以上選んでいる
    elif latency_ms < 1500:    q = 1           # 即答の誤り＝当てずっぽう/ケアレス
    else:                      q = 2
```

`q = 3 + round(2 · p_know_before)` の意味:

- モデルが「知っている」と信じていた KC の正解 → **強い証拠**（`q=5`）
- モデルが「知らない」と信じていた KC の正解 → **推測の疑い**（`q=3` に留める）

**新しいパラメータを1つも増やさずに推測正解を補正できる。**
`q=3` は間隔を伸ばすが EF を `-0.14` するため、まぐれ当たりが続いても伸びが自然に鈍化する。

**`p_know_before` は KC ごとの値を使う。** v0.2 では item に紐づく KC の加重平均を使っていたが、
KC 単位になったのでその平均が不要になった。設計が1段単純になっている。

### 4.2 フラッシュカード（自己申告4段階）

UIのボタンは4つに固定する。5段階以上は高校生が選び分けられない。

| ボタン | `q` |
|---|---|
| わからない | 1 |
| あいまい | 3 |
| わかった | 4 |
| 余裕 | 5 |

**自己欺瞞への耐性**: 答えを表示してから 800ms 未満で「わかった／余裕」を押した場合は
`q = min(q, 3)` に丸める。読む時間が物理的に足りていないため。

### 4.3 `median_latency_ms` の決め方

初期は**形式別の固定値**を使う。応答が100件を超えたら、そのユーザーの形式別中央値に切り替える。

| 形式 | 初期値 |
|---|---|
| 四択 | 12,000 ms |
| 一問一答 | 10,000 ms |
| フラッシュカード | 6,000 ms |

※ 提案値であり、実データでの妥当性は **要検証**。

## 5. 出題する item の選び方（毎回生成に対応）

KC が due になったとき、**どの設問でその KC を問うか**を決める必要がある。

```python
MAX_POOL_PER_KC = 12          # 1 KC あたりの item 蓄積上限
REUSE_BLOCK_DAYS = 14         # この期間内に解いた item は再出題しない

def pick_item(user, kc):
    pool = [i for i in items_of(user, kc)
            if i.approved and not i.hidden
            and not answered_within(user, i, days=REUSE_BLOCK_DAYS)]

    if pool:
        # 目標正答率 0.6 付近を狙う。Elo が使えないので実測難易度を使う（§5.1）
        return min(pool, key=lambda i: abs(expected_p(user, kc, i) - 0.6))

    # 全部最近解いている → 新しい設問を作る
    if len(items_of(user, kc)) < MAX_POOL_PER_KC:
        enqueue(kind='items_refresh', scope_id=unit_of(kc), user=user)
        # 生成を待たせない。今回は最も古い item を出す
    return oldest(items_of(user, kc))
```

**設問は使い捨てではなく蓄積する。** 「毎回生成」は
「そのユーザーがその範囲を初めて開いたときに生成する」という意味であり
（`07-content-pipeline.md` §3）、復習のたびに作り直すのではない。
プールが尽きたときだけ追加生成する。これで RPD の消費が抑えられる（`08-ai-architecture.md` §3）。

### 5.1 Elo の代わり — 実測難易度

Elo による item 難易度の較正は使えない（§1.3）。代わりに**実測値**を持つ。

```sql
-- item テーブル（抜粋）
observed_correct  int  NOT NULL DEFAULT 0,   -- この item に正解した回数
observed_total    int  NOT NULL DEFAULT 0,   -- この item が出題された回数
```

```
expected_p(user, kc, item) =
    observed_total >= 3  →  観測正答率 (observed_correct / observed_total)
    それ未満             →  p_know(user, kc) を代用する
```

利用者が数人なので `observed_total` はなかなか溜まらない。
**実質的には `p_know` を難易度の代理として使うことになる。** これは Elo に劣る。
劣ることを承知の上で、無料枠と毎回生成を選んだ結果である。

### 5.2 生成プロンプトへの難易度の指定

較正できない分、**生成時に難易度帯を指示する**（`07-content-pipeline.md` §5.2）。

```
この学習者はこの項目の習得度が low です。
基礎的な事実の確認から入る問題を作ってください。
誤答選択肢は、同時代・同地域の紛らわしいものにしてください。
```

習得度は `low` / `mid` / `high` の3段階に丸めて渡す
（生の数値は送らない。`08-ai-architecture.md` §4.1）。

## 6. 忘却曲線の定義

SM-2 は明示的な保持率関数 `R(t)` を持たない。しかし
`04-weakness-engine.md` の `mastery = p_know × retrievability` を計算するために必要である。

SM-2 は各区間の終端で約90%の保持率を狙う設計であることから、次のように定義する。

```
retrievability(kc, t) = 0.9 ^ (t_days_since_last_review / interval_days)
```

`t = interval_days` のとき `R = 0.90` になる。`interval_days = 0`（未学習）の場合は `R = 1.0` とし、
`p_know` の初期値のみで `mastery` が決まるようにする。

**KC 単位になったことで、v0.2 にあった「1つの KC が複数カードを持つ場合の加重平均」が不要になった。**

### 締切クランプ時に `interval` と `ef` を更新しない理由

締切が近いと `due_at` は人為的に短い間隔へ切り詰められる。その短い間隔で正解しても、
「本来の間隔でも想起できた」ことの証拠にはならない。ここで `interval` を伸ばすと
`retrievability` の推定が楽観側に振れ、締切当日に「習得済み」と表示しながら実際は忘れている状態を作る。

よってクランプが効いた回は **スケジュールだけを前倒しし、モデルの状態は据え置く**。
`response.clamped = true` として記録し、再計算でも同じ扱いを再現する。

## 7. SM-2 の既知の弱点と対策

| 弱点 | 内容 | 本仕様の対策 |
|---|---|---|
| ease hell | 誤答を繰り返すと EF が下限1.3に貼り付き、1.3倍成長のまま延々と出続ける | **leech ルール**: `lapses >= 8` で KC カードを `suspended` にし、「教材に戻る」導線として提示する |
| 間隔爆発 | EF=2.5 で7回正解すると間隔が595日になる | `interval = min(interval, 365)` |
| 復習の山 | 同じ日に登録した KC が同じ日に一斉に due になる | `jitter ∈ [-0.05, +0.05]` |
| 推測正解 | SM-2 に guess パラメータが無い | §4.1 の `p_know` 結合写像 |
| 自己申告の甘さ | 答えを見てから「わかった」を押せる | §4.2 の 800ms ガード |
| **難易度が制御できない** | **KC 単位にしたため Elo 較正が効かない** | §5.1 の実測難易度＋§5.2 の生成時指定。**Elo に劣ることを受け入れる** |

### leech 時のユーザー体験

`suspended = true` になった KC は出題キューから外れ、ホームに
「**この項目は8回間違えています。問題を解く前に教材を読み直しましょう**」と、
該当 KC を扱う教材セクション（`material_section_kc` 経由）へのリンクを出す。

教材セクションを読了した時点で `suspended` を解除し、`lapses` を 0 に、
`ef` を `max(ef, 1.8)` に戻す。

**毎回生成では、読み直す教材がそのユーザー用に既に生成済みである**ため、この導線は確実に機能する。

## 8. 机上検証（この表の通りに実装されていること）

`EF` 初期値 2.5、`interval_days` 初期値 0、締切クランプなしとする。

### ケース1: 全問 `q = 4`

| 回 | `q` | `n`(更新後) | `EF`(更新後) | `interval_days` |
|---|---|---|---|---|
| 1 | 4 | 1 | 2.50 | 1 |
| 2 | 4 | 2 | 2.50 | 6 |
| 3 | 4 | 3 | 2.50 | 15 |
| 4 | 4 | 4 | 2.50 | 38 |
| 5 | 4 | 5 | 2.50 | 95 |
| 6 | 4 | 6 | 2.50 | 238 |
| 7 | 4 | 7 | 2.50 | **365**（上限クリップ） |
| 8 | 4 | 8 | 2.50 | **365** |

### ケース2: `q = 4` と `q = 2` の交互

| 回 | `q` | `n` | `EF` | `interval_days` | `lapses` |
|---|---|---|---|---|---|
| 1 | 4 | 1 | 2.50 | 1 | 0 |
| 2 | 2 | 0 | 2.18 | 1 | 1 |
| 3 | 4 | 1 | 2.18 | 1 | 1 |
| 4 | 2 | 0 | 1.86 | 1 | 2 |
| 5 | 4 | 1 | 1.86 | 1 | 2 |
| 6 | 2 | 0 | 1.54 | 1 | 3 |
| 7 | 4 | 1 | 1.54 | 1 | 3 |
| 8 | 2 | 0 | **1.30**（下限クリップ、素の値1.22） | 1 | 4 |

**`n` が2に到達しないため間隔が永久に1日から伸びない。** これが ease hell の実態であり、
leech ルールが必要な理由である。

### ケース3: 連続失敗（全問 `q = 1`）

| 回 | `q` | `n` | `EF` | `lapses` | `suspended` |
|---|---|---|---|---|---|
| 1 | 1 | 0 | 1.96 | 1 | false |
| 2 | 1 | 0 | 1.42 | 2 | false |
| 3 | 1 | 0 | **1.30**（素の値 0.88） | 3 | false |
| 4〜7 | 1 | 0 | 1.30 | 4〜7 | false |
| 8 | 1 | 0 | 1.30 | 8 | **true** |

8回目で leech として `suspended` になり、教材への再学習導線が出る。

## 9. 実装上の注意

- **`response` への記録が先、`kc_card` の更新は後。** `response` が唯一の真実であり、
  `kc_card` はそこから再生成できなければならない。1トランザクションで両方を書く
- `q` の算出には `p_know_before`（更新**前**の値）を使う。KC 層の更新と順序が入れ替わると
  同じ応答から違う `q` が出て再現性が失われる
- 1つの item が複数 KC に紐づく場合、`item_kc.weight >= 0.5` の KC のみ `sm2_update` を呼ぶ（§3.1）
- 再計算（`sched_version` 変更時）は `response` を `answered_at` の昇順に再生する
- **item を削除しない。** `response.item_id` の参照先が消えると再計算できなくなる。
  不要になった item は `hidden = true` にする
