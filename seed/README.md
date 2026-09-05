# seed — マスタデータ

DB を唯一の真実にしない（`docs/09-content-sourcing.md` §7）。
KC・章立て・地域・時代は **CSV で git 管理し、作者が承認したものだけが DB に入る**
（`docs/02-domain-model.md` §5）。

| ファイル | 中身 | 承認 |
|---|---|---|
| `era.csv` | 時代の粗グリッド3区分 | 不要（仕様で確定済み） |
| `region.csv` | 地域の階層マスタ24件 | 不要（同上） |
| `syllabus_unit.csv` | 教科書の部・章・節 117件（うち節75） | **軽く目を通す** |
| `kc.csv` | 知識コンポーネント 408件 | **承認済み** |
| `canon_event.csv` | 層2の正典（年号照合）1,180件 | **承認済み** |
| `person.csv` | 層2の正典（人名照合）446件 | **承認済み** |
| `item.csv` | 共有の設問 408件（KC 1件につき1問） | **一括承認** ← いまここ |
| `validate.mjs` | 投入前の検査。依存なし | — |

---

## 1. いまの状態

**KC は 408 件・全件承認済み**（2026-09-02）。75/75 節を覆っている。

```
KC 408 件
  fact          44   10.8%
  distinction  104   25.5%
  causal       148   36.3%
  chronology    54   13.2%
  geo           58   14.2%
KC を持つ節: 75 / 75
```

**層2の正典マスタも入った**（2026-09-02）。

| ファイル | 中身 | 状態 |
|---|---|---|
| `canon_event.csv` | 年号照合の正典 **1,180件** | 全件承認済み（作者の一括承認） |
| `person.csv` | 人名照合の正典 **446件** | 同上 |

規模の根拠は `docs/08` §5。1単元の生成が出す claims は 12〜24件なので、
75節 × 約16件 ≒ 1,200件で照合対象が claims と同じ桁に乗る。
v0.3 の 3,000件は「人手レビューが無くなった分を埋める」という見積りであって
実測値ではないため、**まず1,200件で照合率を測り、足りない分を実測で足す**。

**本番 Supabase へは投入済み**（章立て117 / KC 408 / canon_event 1,180 / person 446）。
経路は §7 に書いた。

## 2. やること

`kc.csv` の **`approve` 列だけ**を埋める。他の列は触らなくてよい。

| 記号 | 意味 |
|---|---|
| `○` | 採用する |
| `×` | 採用しない（受験に出ない／粒度が違う／他のKCと重複している） |
| `△` | **私に直してほしい。** `note` 列に理由を書く |

`△` は起草中の印なので、DB に投入する前には1件も残っていてはいけない。
`△` を見つけたら私が直して `○` か `×` にし、また見てもらう。

### 一括で承認する

```bash
npx tsx scripts/db/approve-kc.ts --all                     # kc.csv
npx tsx scripts/db/approve-kc.ts --file canon_event --all  # canon_event.csv
npx tsx scripts/db/approve-kc.ts --file person --all       # person.csv
```

既に `○` か `×` が入っている行には触らない（一度下した判断を上書きしない）。

### 正典（canon_event / person）の見方は KC と違う

KC は「粒度が適切か」を見るが、**正典は年号そのものが中身**である。
誤った正典は「**正しい教材を誤りと判定して配信を止める**」向きに効く
（層2で誤りが1件出ると層3を呼ばずに `blocked` にするため、二次照合の救済も働かない）。

作者の判断は**一括承認**（全件検算はしない・2026-09-02）。
その代わりに機械でできる検査を厚くしてある。

- `precision` と年の整合、`year_from <= year_to`、世界史の範囲（前1万〜2100年）
- **同じ語を2つ以上の正典が名乗っていないか**（どちらに当たるかが運になる）
- **他のラベルを部分文字列として含む組**は警告に出す（最長一致で拾うが目で見る）
- `note` 列に典拠を書いてある。DB には入らないので、後から抽出検査に使える

## 3. 判断の基準

### KC は「用語」ではない

これが最も大事な線引きである（`docs/02-domain-model.md` §1）。

| これは KC ではない | これが KC |
|---|---|
| ハンムラビ法典 | ハンムラビ法典の**同害復讐と身分差** |
| ウマイヤ朝 | ウマイヤ朝と**アッバース朝の支配原理の違い** |
| ペロポネソス戦争 | ペルシア戦争の勝利が**ペロポネソス戦争を招いた因果** |

用語をそのまま KC にすると 5,200件を超え、1件あたりの観測数が永久に足りず、
**全 KC が「わからない」のまま動かなくなる**。それ以前に、教材が
「イスラーム史の解説文」のような汎用記事に退化して、**単なる暗記アプリになる。**

### `why_confusable` 列を読んでほしい

**「なぜ受験生が間違えるか」が書けない KC は、KC ではない。**
この列は DB には入らず、承認のためだけに付けてある。
ここを読んで「いや、そこは間違えない」と思ったら `×` でよい。

### `kind` の意味

| `kind` | 単位 |
|---|---|
| `fact` | 単一の事実の再認 |
| `distinction` | 2つ以上の項目の区別 |
| `causal` | 因果関係 |
| `chronology` | 時系列・順序 |
| `geo` | 地理比定 |

`fact` が全体の35%を超えたら**それは用語集の写しである**と判断し、`validate.mjs` が落とす。
第1バッチは16.7%と低いが、部2が概念的な範囲だからで、
近現代の条約・人名が増える後半のバッチで上がる見込み。

### 迷ったときは

- **共通テストで問われるか**を基準にする。私大特有の細目は第2トランシェに回すので `×` でよい
- 重複が気になったら `△` にして `note` に「◯◯と重なる」と書く。統合は私がやる
- 1件に30秒以上かけない。迷ったものは `△` にして先に進む

## 4. 他の列（参考。触らなくてよい）

| 列 | 意味 |
|---|---|
| `id` | 人間可読の安定文字列。**一度発行したら変更しない**（`02` §2） |
| `unit_id` | `syllabus_unit.csv` の節。KC はここに紐づく |
| `era_id` | 1=前近代 / 2=近世・近代 / 3=現代。診断テストの粗グリッド用 |
| `region_primary` / `region_others` | 地域。対外関係史は2つ以上になる（`02` §6）。`others` は `;` 区切り |
| `year_precision` | `exact` / `decade` / `century` / `unknown`。年代が不確実な事象のため |
| `exam_weight` | 出題頻度の重み。1.0 が標準、1.5 以上が共通テスト頻出 |
| `prereq_ids` | 先に理解しておくべき KC。出題順の制御に使う |
| `retired` | **空なら範囲内。何か書けば範囲外**（書いた文字列が理由になる）。出題・教材・診断から外れる |

### `retired` — 範囲から外す（行は消さない）

2026-09-04 に歴史総合の**日本史分野 52 件**をここで外した（`02` §6.1）。

**行を消さないのが要点である。** 消すと `item_kc` / `response` / `kc_region` の外部キーが
道連れになり、**一度でも解いた記録まで消える**。`retired` なら出題・教材・診断から
外れるだけで、列を空にすれば戻る。

外してよいのは**歴史総合（`general_history`）の KC だけ**である。世界史探究の KC を
外したらそれは事故なので、`validate.mjs` の 8b が落とす。
範囲内の KC が範囲外の KC を前提にしていないことも、同じ 8b で見る。

## 5. `syllabus_unit.csv` について

学習指導要領の大項目を部、教科書の章立てを章・節に対応させてある。

**節のタイトルは教科書によって割り方が異なる。** 実際に使う教科書
（山川『詳説世界史』世探704 を想定）と突き合わせて、ずれていたら教えてほしい。
KC は節に紐づくので、ここがずれると範囲指定がずれる。

## 5b. Supabase に入れる

**3つの方法がある。どれでも結果は同じになる。**

### 方法A: SQL を貼る（Node も接続文字列も要らない）

Supabase のダッシュボード → SQL Editor に、この順で貼る。

| # | 貼るもの | 中身 |
|---|---|---|
| 1 | `docs/schema.sql` | 44テーブル・RLS 44本＋ポリシー35本。**そのまま貼れる** |
| 2 | `seed/sql/02_seed.sql` | 時代3・地域24・章立て117・KC 408・正典・共有設問（**承認済みのみ**） |

**すでに `docs/schema.sql` を流し終えている本番へは、代わりに差分を当てる。**
`docs/schema.sql` は `IF NOT EXISTS` を使っていないので上書きも追記もできない。

| # | 貼るもの | 中身 |
|---|---|---|
| 1 | `seed/sql/04_phase3.sql` | 後から足した表（`push_subscription`・`ops_log`）と列（`app_user.remind_hour`）。何度流しても同じ |
| 2 | `seed/sql/05_atlas.sql` | 歴史地球儀の7表・RLS・読み取り権限。既存DBにだけ流す |
| 3 | `seed/sql/03_rls.sql` | RLS とポリシーを貼り直す。**新しい表もここで覆われる**ので、必ず 04・05 のあとに流す |

`docs/schema.sql` に手を加えなくてよいのは、Supabase には pgvector があり
`auth.uid()` も実在するためである（ローカル用の置換も shim も要らない）。

`02_seed.sql` は CSV から生成している。**手で編集しない。**
CSV を直したら作り直すこと。

```bash
npx tsx scripts/db/dump-sql.ts       # seed/sql/02_seed.sql を作り直す
npx tsx scripts/db/dump-rls.ts       # seed/sql/03_rls.sql を作り直す
npx tsx scripts/db/dump-migration.ts # seed/sql/04_phase3.sql を作り直す
```

どちらも `ON CONFLICT` で上書きするので、**何度流しても結果は同じ**である。
最後にコメントで書いてある確認用の SELECT を流すと、件数が期待どおりか分かる。

### 方法B: 手元から流す（`DATABASE_URL` が要る）

```bash
export DATABASE_URL='postgresql://postgres:【パスワード】@db.【ref】.supabase.co:5432/postgres'
npx tsx scripts/db/migrate.ts                  # 確認だけ。何も書き換えない
npx tsx scripts/db/migrate.ts --apply --seed   # 実行
```

接続文字列は **Direct connection**（Transaction pooler ではない）を使う。
繋がらないときは Session pooler。アプリ実行時の `DATABASE_URL` はこれとは別で、
そちらは Transaction pooler を使う（`docs/12` §4）。

### 方法C: Supabase MCP から流す（2026-09-02 に実際に使った経路）

**Claude Code の遠隔セッションからはこれしか通らない。** ネットワーク方針が
`*.supabase.co:443` への CONNECT を拒否するため、`DATABASE_URL` を渡されても
`seed-remote.ts` は繋がらない（`curl: (56) CONNECT tunnel failed, response 403`）。
MCP は `mcp-proxy.anthropic.com` 経由なので通る。

ただし MCP の `execute_sql` / `apply_migration` は SQL を引数で受けるため、
`02_seed.sql`（975KB）を渡すと**会話を1MB近い日本語が通過する**。
打ち直しになるので、誤りが混入しても気づけない。

そこで **DB 側に CSV を取りに行かせる**。

1. 承認済みの CSV を push し、**commit を固定**する
2. その commit の `raw.githubusercontent.com` を読む Edge Function を
   `deploy_edge_function` で置く（リポジトリが public なので認証が要らない）
3. `pg_net` を一時的に入れ、`net.http_post` で DB から関数を呼ぶ
   （こちらから関数の URL を叩くことはできないため）
4. `net._http_response` で結果を受け取る
5. **md5 で中身を照合する。** 件数だけでは打ち間違いを検出できない

```sql
-- 照合の例。ORDER BY には COLLATE "C" を付ける。
-- Postgres の既定（en_US）は記号を無視するので、手元のコードポイント順と一致しない
SELECT md5(string_agg(id || '|' || label || '|' || coalesce(year_from::text,''),
                      E'\n' ORDER BY id COLLATE "C")) FROM canon_event;
```

6. **後片付けを必ずする。** Edge Function は service_role でマスタ表に書けるうえ
   anon 鍵で呼べるので、置きっぱなしにすると攻撃面になる。中身を空にしてから
   ダッシュボードで削除する。`pg_net` も `DROP EXTENSION` する
   （DB から外向きに HTTP を出せる状態を残さない）

## 6. 検査

```bash
node seed/validate.mjs            # 起草中の検査（approve 列は見ない）
node seed/validate.mjs --strict   # 投入前の検査（approve 列の空欄も落とす）
```

検査するもの: id の一意性と命名 / `kind` の分布 / `unit_id` の実在（節に限る） /
地域の実在と primary の重複 / `prereq_ids` の解決と循環 / 年代の整合 /
`why_confusable` の空欄 / `approve` の記入（`--strict`）。

正典（`canon_event.csv` / `person.csv`）はこれに加えて:
`precision ∈ {exact,decade,century}` / `year_from` 必須 / `year_from <= year_to` /
年が世界史の範囲（前1万〜2100年）に収まる / `region_ids` の実在 /
**同じ語を複数の正典が名乗っていないこと** / `person.label` の重複 /
`aliases` に `label` と同じ語が無いこと。
ラベルの包含関係（「アヘン戦争」⊂「第2次アヘン戦争」）は**警告**として出す
（照合は最長一致なので正しく拾えるが、意図した包含かを目で見るため）。

## 7. このあと

1. ~~KC 60件を承認する~~ **完了**（2026-09-02）
2. ~~残り約340件を作る~~ **完了**（408件・75/75節）
3. ~~408件を承認する~~ **完了**（2026-09-02・作者が一括承認）
4. ~~正典（`canon_event` / `person`）を起草する~~ **完了**（1,180件 / 446件）
5. ~~正典を一括承認する~~ **完了**
6. ~~共有設問 408問を起草する~~ **完了**（KC 1件につき1問・全 KC を覆った）
7. **共有設問を一括承認する** ← いまここ

   ```bash
   npx tsx scripts/db/approve-kc.ts --file item --all   # 承認欄を ○ で埋める
   node seed/validate.mjs --strict                      # 空欄が残っていないか見る
   npx tsx scripts/db/dump-sql.ts                       # 02_seed.sql を作り直す
   ```

   **これをやるまで1問も出題されない。** `seedItem` も `dump-sql.ts` も
   `approve` が `○` の行しか読まないためである（`dump-sql.ts` は
   item が0件のとき、この手順を画面に出す）。

8. `seedAll()` が kc / kc_region / kc_syllabus_unit / canon_event / person / item / item_kc に展開する
9. Phase 0 はこの承認済みデータを使う（`docs/13-roadmap.md`）

Phase 0 で「AI が出した KC を AI が使って生成し AI が検証する」構図を避けるため、
**KC と正典だけは人間が固定した状態**で実験に入る。ここが承認制である理由である。
