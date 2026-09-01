# 05. 集中特訓スケジューラ仕様

> 対象: HISTORIA MVP / 状態: 確定（v0.3 で単位を KC に統一） / 最終更新: 2026-09-01
>
> **v0.2 からの変更**: スケジューリングの単位が `card (user, item)` から
> `kc_card (user, kc)` に変わった（`04b-spaced-repetition.md` §1.2）。
> これにより「KC単位で1回だけ数える」という重複計上の対処が不要になり、式が単純になった。

## 0. この文書が解く問題

v0.1 は「**習得したい分野と、いつまでに完成させたいかを時間で設定し、逆算して一日にこなすべき量が自動決定される**」
と書いているが、逆算の式が存在しない。素直に実装すると次の4点で破綻する。

1. **分母が決まらない。** 「範囲の量」を何で数えるのかが未定義
2. **間隔反復と矛盾する。** `残KC数 ÷ 残日数` にすると復習の負荷が計算に入らない。
   KCは1回触れれば終わりではなく、締切時点で保持しているために複数回の復習が要る
3. **サボった日の再計画がない。** 残りを日数で割り直すだけだと終盤に達成不能な数字が出る
4. **複数特訓の調停がない。** v0.1 は「集中特訓は同時に複数取れる」としているが、
   各特訓が独立に計算すると1日8時間になる

## 1. 集中特訓（drill）の定義

**集中特訓は「KC集合 ＋ 締切」を持つビューであり、自前の出題キューを持たない。**

```sql
CREATE TABLE drill (
  id           uuid PRIMARY KEY,
  user_id      uuid NOT NULL,
  title        text NOT NULL,
  deadline     date NOT NULL,
  mode         text NOT NULL CHECK (mode IN ('ai_material','self_study')),
  status       text NOT NULL DEFAULT 'active'
               CHECK (status IN ('active','completed','abandoned')),
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE drill_kc (
  drill_id uuid NOT NULL REFERENCES drill(id) ON DELETE CASCADE,
  kc_id    text NOT NULL REFERENCES kc(id),
  PRIMARY KEY (drill_id, kc_id)
);
```

自前のキューを持たせない理由は次のとおりである。
「イスラーム史」と「近代ヨーロッパ」の両方が十字軍のKCを含んだとき、特訓ごとのキューだと
**同じ知識が2回出題され、SM-2 の状態が2つに分裂して両方の間隔推定が壊れる**
（各々が相手の復習を知らないので、実際より短い間隔を出し続ける）。

**スケジューリングの単位を KC にしたことで、この問題は構造的に消えた**
（`04b-spaced-repetition.md` §1.2）。`kc_card` の主キーは `(user_id, kc_id)` であり、
どの特訓から到達しても同じ1行を更新するため、分裂しようがない。

**出題は常に `kc_card` を `due_at` 昇順で引き、drill はフィルタとしてのみ効く。**
どの設問でその KC を問うかは、引いた後に決める（`04b-spaced-repetition.md` §5）。

## 2. 範囲の量の定量化

「範囲」の入力は `syllabus_unit`（教科書の章・節）で受ける。AI に分割させない
（理由は `02-domain-model.md` §4.4）。

```
drill の範囲指定（ユーザー入力）
  → syllabus_unit の集合
  → kc_syllabus_unit 経由で KC 集合（drill_kc に確定保存）
  → kc_card 集合（user × kc）
```

**分母は KC の数ではなく「締切までに必要な復習回数の総和」である**（§3）。
KC数で数えると、既に習得済みの KC と初見の KC が同じ重みになり、
「8割終わっているのに残量が減らない」状態になる。

## 3. 締切逆算の式

`04b-spaced-repetition.md` の SM-2 に整合させる。締切 `D` において保持率 `R ≥ 0.90` を満たすには、
最後の復習時点の間隔 `I` が「締切までの残り日数」以上である必要がある
（`R = 0.9^(t/I)` より、`t = I` のとき `R = 0.90`）。

```python
BUFFER_DAYS = 3        # 締切の3日前に最後の復習を終える
MAX_DAILY   = user.max_daily_items   # 1日の出題上限。既定80。変更可（§9.1）

def reps_left(c, deadline, today):          # c = kc_card
    I_need = (deadline - today).days - BUFFER_DAYS
    if I_need <= 0:                 return 1 if c.interval_days == 0 else 0
    if c.interval_days >= I_need:   return 0
    if c.n == 0:  return 1 + ceil(log(I_need / 1) / log(c.ef))
    if c.n == 1:  return 1 + ceil(log(I_need / 6) / log(c.ef))
    return ceil(log(I_need / c.interval_days) / log(c.ef))

def remaining_reps(user, today):
    kcs = union(drill_kc[d] for d in active_drills(user))   # union なので自然に重複が消える
    total = 0
    for kc in kcs:
        if status(user, kc) == 'mastered':
            continue
        earliest = min(d.deadline for d in active_drills(user) if kc in drill_kc[d])
        total += reps_left(kc_card(user, kc), earliest, today)
    return total
```

**v0.2 にあった「KC単位で1回だけ数える」という但し書きが不要になった。**
スケジューリングの単位が KC そのものになったため、集合の union を取るだけで重複計上が消える。

`ef` の下限が 1.3 なので `log(ef) > 0` が保証され、ゼロ除算は起きない。

### 3.1 1日のノルマ

```python
def daily_plan(user, today):
    need      = remaining_reps(user, today)
    days_left = max(1, (earliest_deadline(user) - today).days)
    required  = ceil(need / days_left)

    if required > MAX_DAILY:
        return {
            'target'   : MAX_DAILY,
            'feasible' : False,
            'shortfall': need - MAX_DAILY * days_left,   # 何問分足りないか
        }
    return {'target': required, 'feasible': True, 'shortfall': 0}
```

### 3.2 達成不能を黙って表示しない

`required` が `MAX_DAILY` を超えた場合、**出題キューは `MAX_DAILY` で打ち切るが、
その事実をユーザーに明示する**。

> ⚠️ このペースでは締切に間に合いません
> 残り12日 / 必要 1,840回 / 1日あたり154回（上限80回）
> **約890回分が不足します。**
> ▸ 締切を 2026-11-20 まで延ばす（1日80回で間に合います）
> ▸ 範囲を減らす（第5章〜第7章を外すと1日76回になります）
> ▸ このまま続ける（間に合わない範囲が残ります）

黙って `MAX_DAILY` に丸めると「毎日ノルマを達成しているのに締切に間に合わない」という
最悪の体験になる。逆に丸めずに表示すると「1日340問」がホームに出る。**どちらも避ける。**

## 4. サボった日の再計画

**専用の再計画ロジックは持たない。** `daily_plan()` はログイン時に毎回計算されるため、
サボった翌日は自動的に `days_left` が減って `required` が上がる。これが正しい再計画である。

ただし2つのガードを入れる。

### 4.1 上限による早期警告

`required > MAX_DAILY` になった最初の日に §3.2 の警告を出す。
「終盤になって初めて達成不能が判明する」のを防ぐ。

### 4.2 overdue の山崩し

長期間サボると `due_at` を過ぎたカードが大量に溜まる。全部出すと初日に300問が並んで離脱する。

```
出題キューは常に MAX_DAILY 件で打ち切る。
overdue カードの優先順位: overdue 日数の降順ではなく、以下のスコア降順とする。

  priority(kc) = 2.0 * is_misconception(kc)
                 + 1.5 * urgency(earliest_deadline_of(kc))    # 締切が近いほど大
                 + 1.0 * (1 - mastery(kc))
                 + 0.5 * min(overdue_days / 14, 1.0)
```

overdue 日数だけで並べると、**最も昔にサボった簡単なカードが延々と先頭に来る**。
締切と弱さを優先する。

## 5. 複数特訓の調停

v0.1 の「集中特訓は同時に複数取れる」を素直に実装すると、各特訓が独立に
`daily_target` を出して合計が1日8時間になる。

### 5.1 決定: 1日の出題キューは全特訓の union で1本

```
daily_queue(user, today) =
    全 active drill の KC の union に属する kc_card のうち
      (a) due_at <= today                … 復習
      (b) kc_card が存在しない KC        … 新規学習（初回は due_at = now で作る）
    を priority 降順で並べ、MAX_DAILY 件で打ち切る。
    各 KC について、実際に出す設問は 04b-spaced-repetition.md §5 の pick_item() で決める。
```

ホームには「**今日やること: 42問**」と**1つの数字だけ**を出す。
特訓ごとのノルマは表示しない（合計が一致せず混乱を招くため）。
特訓ごとには**進捗率のみ**を表示する（§6）。

### 5.2 範囲が重複した場合

- `reps_left` は KC 単位で計算される（§3）。単位が KC なので重複計上は起きない
- 締切は**最も早いものを採用**する（`earliest` in `remaining_reps`）
- 特訓Aと特訓Bが同じKCを含む場合、そのKCが `mastered` になれば**両方の進捗が同時に進む**

これは正しい挙動である。同じ知識を2回学習させる必要はない。
ただしUI上は「特訓Aの進捗が、特訓Bをやったら進んだ」ように見えるため、
特訓詳細に「他の特訓と重複: 12KC」を表示する。

### 5.3 新規特訓作成時の重複警告

```
新しい特訓の KC 集合と、既存の active な特訓の KC 集合の共通部分が
新特訓の 40% を超える場合、作成前に警告する:

「この範囲は『近代ヨーロッパ』と 62%（78KC）重複しています。
 ▸ このまま作る  ▸ 重複部分を除いて作る  ▸ やめる」
```

## 6. 進捗の定義

v0.1 のホーム「あと⚪︎日で〜を仕上げよう！！」には、残日数と進捗率の定義が無かった。

```
残日数   = deadline - today
進捗率   = |{kc ∈ drill_kc : status(kc) = 'mastered'}| / |drill_kc|
```

**「教材を読んだ」は進捗ではない。** 読了は `mastery` を弱く押し上げるだけであり
（`04-weakness-engine.md`）、進捗の分子には入れない。読んだだけで100%になるなら、
このアプリは「単なる暗記アプリ」ですらない。

ただしユーザーには読了率も別途見せる（「教材 8/12 読了・習得 5/48 KC」）。
進捗率だけを見せると「たくさん読んだのに1%も進まない」と感じて離脱するため、
**2本のバーを並べて「読む」と「身につく」が別物であることを可視化する**。

### 6.1 特訓の完了条件

```
status = 'completed'  ⇔  進捗率 >= 0.90 かつ 締切を過ぎていない
```

100% を要求しない。SM-2 の `mastered` 条件（別日に2回以上正解）は最後の数KCで
必ず取りこぼしが出るため、100%完了は事実上到達できない。

締切を過ぎて進捗率が 0.90 未満の特訓は `abandoned` にはせず `active` のまま残し、
ホームに「**締切を過ぎています。新しい締切を設定しますか？**」を出す。
勝手に消すと、ユーザーが積み上げた学習履歴が見えなくなる。

## 7. 実行方式 — 夜間バッチを使わない

**全ユーザーのノルマを夜間バッチで再計算する設計を採用しない。**

- Vercel Functions の実行時間上限は Hobby 標準60秒 / Fluid Compute 300秒（`08-ai-architecture.md`）。
  `ユーザー数 × KC数` の再計算は容易に超える
- Vercel Cron は Hobby プランで **1日1回・実行時刻は指定時間内の任意**という制限がある
- **cron の失敗は UI に出ない。** 静かに全員のノルマ計算が止まり、気づけない

**決定: 遅延評価にする。**

```
ホーム表示時に、そのユーザーの分だけ daily_plan() を計算する。
結果は user_daily_plan(user_id, plan_date, target, feasible, shortfall, computed_at) にキャッシュし、
同日中の再表示ではキャッシュを返す。
応答が記録されたら該当日のキャッシュを破棄する。
```

1ユーザーあたりの計算量は `O(active な drill の KC 数)` = 数百件であり、数十msで終わる。

cron は「**1日1通のリマインド通知**」にのみ使う。これなら失敗しても学習機能は止まらない。

## 8. エッジケース

| ケース | 挙動 |
|---|---|
| 締切が今日または過去 | `I_need <= 0`。未学習カードのみ1回ずつ出し、警告を出す |
| KC が0件の特訓（範囲指定ミス） | 作成時にバリデーションで弾く（「この範囲に学習項目がありません」） |
| active な特訓が0件 | ホームは診断テストの結果に基づく「弱点KCの復習」キューを出す。空画面にしない |
| 全KCが `mastered` | 「この範囲は仕上がっています」＋ 保持のための復習のみ（due のカードだけ） |
| 締切を延ばした | 次回のホーム表示で `daily_plan()` が再計算され、自動的に緩む |
| 特訓を削除した | `drill_kc` は消えるが `kc_card` と `user_kc_state` は残る（KC層は特訓に依存しない）。学習履歴は失われない |

## 9. パラメータ一覧

| パラメータ | 値 | 変更 |
|---|---|---|
| `BUFFER_DAYS`（締切前の余裕） | 3日 | 管理画面 |
| `MAX_DAILY`（1日の出題上限） | **80問**（既定） | **ユーザー本人＋管理画面**（§9.1） |
| 特訓の完了閾値 | 進捗率 0.90 | 管理画面 |
| 重複警告の閾値 | 40% | 固定 |
| overdue の priority 飽和日数 | 14日 | 固定 |

### 9.1 1日の上限を変更できるようにする（作者の決定）

`MAX_DAILY = 80` は妥当と判断されたが、**実運用で調整できる必要がある**。
人によって使える時間が違い、時期（直前期か夏休みか）でも変わる。

```sql
-- app_user（03-data-model.md）
max_daily_items smallint NOT NULL DEFAULT 80 CHECK (max_daily_items BETWEEN 10 AND 300)
```

| 変更する人 | 場所 | 選べる値 |
|---|---|---|
| **ユーザー本人** | 設定画面「1日の上限」 | 20 / 40 / 80 / 120 / 200 |
| **作者** | 管理画面 | 10〜300 の任意。全ユーザーの値を一覧で見て変更できる |

上限を下げても**締切逆算の計算式は変えない**。`required > MAX_DAILY` になれば
§3.2 の「このペースでは締切に間に合いません」が出るだけである。
つまり上限を下げることは「間に合わないことを受け入れる」という意思表示になる。

### 9.2 変更してよいパラメータとそうでないもの

**この区別を守らないと学習履歴が壊れる。**

| | パラメータ | 理由 |
|---|---|---|
| **変更してよい** | `max_daily_items` / `BUFFER_DAYS` / 特訓の完了閾値 / リマインド時刻 / 生成クォータ | **スケジューリングの設定**であり、変えても過去の `response` と矛盾しない |
| **変更してはいけない** | `guess` / `slip` / `T_learn` / `mastery` 閾値 / `ef` 初期値 / `n_eff` 閾値 | **推定パラメータ**であり、`response` から再計算しないと新旧の判定が混在する（`04-weakness-engine.md` §9） |

後者を変えるときは `algo_version` / `sched_version` を上げ、
**該当ユーザーの `response` を再生して導出テーブルを作り直す**。
管理画面から直接いじれるようにしてはいけない。
