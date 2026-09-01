# 09b. 関連YouTube動画の埋め込み仕様

> 対象: HISTORIA MVP / 状態: 確定 / 最終更新: 2026-09-01

## 0. 要件

教材や確認テストの文脈に応じた**関連YouTube動画をページ内に埋め込んで再生できる**ようにする。

## 1. 設計を規定する2つの制約

この機能の設計は、実装の好みではなく次の2つの外部制約によって決まる。

### 制約1: YouTube Data API v3 のクォータ

- 無料枠は **1プロジェクトあたり1日10,000ユニット**（太平洋時間の午前0時にリセット）
- `search.list` は **1回100ユニット** → **1日100検索が上限**
- `videos.list` / `playlistItems.list` は **1回1ユニット**（1回で最大50件を取得できる）

MVPのKCは 800〜900 件（`02-domain-model.md`）。1KCあたり1検索で候補を作ると
**80,000〜90,000ユニット＝8〜9日分のクォータ**を消費する。検索ベースの設計は成立しない。

### 制約2: 未成年ユーザーとプライバシー

想定ユーザーは高校生であり、16歳未満を含む（`10-legal-risk.md`）。
`youtube-nocookie.com` は「ページ読み込み時にHTTP Cookieを置かない」だけであり、
**localStorage にデバイス識別子（`yt-remote-device-id`）を保存し、再生ボタンを押した時点で Cookie を設定する**。
nocookie ドメインを使うだけでは同意なしのトラッキングを避けられない。

## 2. 決定事項

| # | 決定 |
|---|---|
| V1 | **実行時に YouTube API を呼ばない。** ユーザーのリクエストは `video` テーブルから返すだけ（API呼び出しゼロ） |
| V2 | 候補収集は検索ではなく **チャンネル許可リスト方式**にする |
| V3 | 埋め込みは **2クリック（click-to-load）** とする。初期表示はサムネイル画像のみ |
| V4 | `status = 'approved'` の動画だけを配信する。承認は作者が行う |
| V5 | `embeddable = false` と `yt_rating = 'ytAgeRestricted'` の動画は**絶対に採用しない** |
| V6 | 動画視聴は受動的消費なので、**視聴後に必ず retrieval（四択2問）を挟む** |
| V7 | 自動検索によるオープンな候補生成は **Phase2** |

## 3. データモデル

```sql
-- 信頼できるチャンネルの許可リスト。ここに無いチャンネルの動画は取り込まない。
CREATE TABLE channel_allowlist (
  channel_id    text PRIMARY KEY,              -- YouTube channelId (UC...)
  channel_title text NOT NULL,
  subject_scope text NOT NULL                  -- 'world_history' | 'japanese_history' | 'both'
                CHECK (subject_scope IN ('world_history','japanese_history','both')),
  note          text,
  added_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE video (
  id              text PRIMARY KEY,             -- YouTube videoId（11文字）
  title           text NOT NULL,
  description     text,
  channel_id      text NOT NULL REFERENCES channel_allowlist(channel_id),
  duration_sec    int  NOT NULL,
  published_at    timestamptz,
  embeddable      boolean NOT NULL,             -- videos.list status.embeddable
  yt_rating       text,                         -- contentDetails.contentRating.ytRating
  status          text NOT NULL DEFAULT 'candidate'
                  CHECK (status IN ('candidate','approved','rejected','unavailable')),
  reject_reason   text,
  approved_at     timestamptz,
  last_checked_at timestamptz,                  -- 生存確認バッチの最終実行時刻
  embedding       vector(768),                  -- title + description の埋め込み
  created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON video (status) WHERE status = 'approved';
CREATE INDEX ON video USING hnsw (embedding vector_cosine_ops);

-- 動画とKCの対応。start_sec で該当箇所を頭出しできる。
CREATE TABLE video_kc (
  video_id   text NOT NULL REFERENCES video(id) ON DELETE CASCADE,
  kc_id      text NOT NULL REFERENCES kc(id),
  start_sec  int  NOT NULL DEFAULT 0,
  end_sec    int,
  relevance  real NOT NULL DEFAULT 1.0 CHECK (relevance BETWEEN 0 AND 1),
  source     text NOT NULL DEFAULT 'embedding'  -- 'embedding' | 'manual'
             CHECK (source IN ('embedding','manual')),
  PRIMARY KEY (video_id, kc_id, start_sec),
  CHECK (end_sec IS NULL OR end_sec > start_sec)
);
CREATE INDEX ON video_kc (kc_id, relevance DESC);

-- 視聴イベント。弱い学習イベントとして扱う（§6）。
CREATE TABLE video_view (
  id          bigserial PRIMARY KEY,
  user_id     uuid NOT NULL,
  video_id    text NOT NULL REFERENCES video(id),
  watched_sec int  NOT NULL,
  duration_sec int NOT NULL,                    -- 視聴時点の動画長（後の再生成に備えて控える）
  viewed_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON video_view (user_id, viewed_at DESC);
```

## 4. コンテンツ調達フロー（クォータ設計）

すべてオフラインの seed / バッチ処理であり、ユーザーのリクエスト経路には乗らない。

### 4.1 初期シード（作者が手動で1回実行）

| 手順 | API | ユニット消費 |
|---|---|---|
| 1. 下記 §4.1.1 の候補から作者が実際に視聴して選び、`channel_allowlist` に登録 | なし | 0 |
| 2. 各チャンネルの uploads プレイリストIDを取得（`channels.list`） | `channels.list` × 15 | **15** |
| 3. 各 uploads プレイリストを全件取得（`playlistItems.list`、1回50件） | 3,000本なら60回 | **60** |
| 4. 取得した videoId を50件ずつ `videos.list` で詳細取得（`status`, `contentDetails`, `snippet`） | 60回 | **60** |
| 5. `embeddable=false` / `ytRating='ytAgeRestricted'` を `rejected` に落とす | なし | 0 |
| 6. `title + description` を埋め込み、KCラベルの埋め込みと pgvector 近傍検索で対応付け | なし（自前） | 0 |
| 7. 作者が対応付けを確認して `approved` にする | なし | 0 |
| **合計** | | **約135ユニット**（1日枠10,000の1.4%） |

### 4.1.1 チャンネルの候補（調査結果・作者の最終確認が必要）

**最優先: Try IT（トライイット）** — 作者の指定。

| # | チャンネル | 運営 | 適合性 |
|---|---|---|---|
| **1** | **映像授業 Try IT（トライイット）** | 家庭教師のトライ | **最優先。** 完全無料・単元別・世界史と**日本史の両方**があるため歴史総合もカバーできる。単元別の構成が `syllabus_unit` と対応付けやすい |
| 2 | ムンディ先生（山崎圭一） | 個人（現役高校教員） | 網羅型の通史解説。『一度読んだら絶対に忘れない世界史の教科書』の著者 |
| 3 | グシャの世界史探究授業 | 個人（現役教員） | **「世界史探究」を明示的に扱う**（新課程対応）。歴史総合との接続を確認する価値がある |
| 4 | 佐藤幸夫（Yukio Sato） | 代ゼミ世界史講師 | 予備校講師。受験に直結した解説 |
| 5 | 研伸館 世界史テーマ解説シリーズ | 研伸館 | テーマ別の解説。ヨコ（同時代性）の補強に向く可能性 |
| 6 | ユーテラ授業チャンネル | 予備校講師もりてつ | 複数教科。世界史の単元解説あり |

Try IT の識別子（**実装時に再確認すること**）:

```
チャンネル:        UCcj-cHmS0uD91MLjtdiN89Q
高校世界史 再生リスト: PLdG31GUo-My-kgENYDal25CJtarSwk7CD
高校日本史 再生リスト: PLdG31GUo-My81rw-pchccjaR2x6pCEmg4
```

**日本史の再生リストも取り込む。** 歴史総合は日本史分野を含むため（`02-domain-model.md` §6）、
世界史だけでは範囲を覆えない。

### 4.1.2 採用しないと判断したもの

| 除外するもの | 理由 |
|---|---|
| **中田敦彦のYouTube大学（エクストリーム世界史）** | 知名度は高いが、**大学教授を含む複数の指摘により事実誤りが報告されている**（日中戦争と日清戦争の混同、満洲事変の解釈など）。運営者自身も「諸説ありは大前提」として流れの理解と興味喚起を目的に掲げており、**受験用の正確性を意図していない**。誤情報を配らないという本アプリの原則（`08-ai-architecture.md` §5）と相容れない |
| 武田塾・スタディコーチ・STRUX 等の「参考書ルート」系 | **勉強法や参考書の紹介であって単元解説ではない**。KC に紐づけられないため `video_kc` の対応付けが成立しない |
| 世界史の雑学・エンタメ系 | 出典が示されないものが多い。教材の補強にならない |

**「有名だから」で選ばない。** 選定基準は次の3つである。

1. **単元別に構成されているか**（KC に対応付けられるか）
2. **事実の正確性について信頼できるか**（運営が教育機関・現職教員・予備校講師か）
3. **埋め込みが許可されているか**（`status.embeddable`・年齢制限なし。§4.1 の手順4で機械的に確認する）

### 4.1.3 選定の手順

```
1. 上記の候補を作者が実際に3〜5本ずつ視聴する（1チャンネル15分程度）
2. 「この動画を自分の弱点として提示されたら役に立つか」で判断する
3. 合格したチャンネルだけ channel_allowlist に入れる
4. 10〜15本に届かなくてもよい。少数の良質なチャンネルの方が、
   対応付けの精度が上がる（近傍検索の候補が絞られるため）
```

手順6の対応付けは次の規則で行う。

```
各KCについて、cosine類似度が 0.72 以上の動画を上位5件まで video_kc に candidate として書く。
1動画が複数KCに紐づくのは正常（1本の動画が複数の論点を扱うため）。
1KCに1件も紐づかない場合は「動画なし」として扱い、UI上は動画セクションを描画しない。
```

※ 閾値 0.72 は本仕様の提案値であり、実データでの調整が必要（**要検証**）。

### 4.2 週次の生存確認バッチ

動画は削除・非公開化・埋め込み禁止化されうる。放置すると「再生できない動画」がユーザーに出る。

```
週1回、status='approved' の全動画IDを50件ずつ videos.list に投げる。
  - レスポンスに含まれない  → status='unavailable'（削除または非公開）
  - embeddable が false になった → status='unavailable'
  - ytRating が 'ytAgeRestricted' になった → status='rejected'
  - last_checked_at を更新
```

承認済み動画が1,200本なら **24ユニット/週**。年間で約1,250ユニットしか使わない（1日枠10,000の0.24%）。

`unavailable` になった動画は即座に配信対象から外れ、同じKCの次点動画（`relevance` 降順）に差し替わる。

### 4.3 Phase2（MVP では実装しない）

- `search.list` によるオープンな候補探索（1日100検索の枠内でKCを巡回する）
- 動画の字幕（`captions`）を取得して章単位で `start_sec` を自動決定する

## 5. 埋め込みの実装仕様

### 5.1 2クリック（click-to-load）

**初期描画時に iframe を出してはならない。** 次の順序で描画する。

```
[初期状態]
  <div> 16:9 のアスペクト比ボックス
    <img src="https://i.ytimg.com/vi/{videoId}/hqdefault.jpg" loading="lazy" alt="{title}">
    <button> ▶ 再生（YouTubeで再生します）</button>
    <p class="notice">再生するとYouTube（Google）に情報が送信されます</p>
  </div>

[ユーザーがボタンをタップした後]
  同じボックス内に iframe を注入する:
  <iframe
    src="https://www.youtube-nocookie.com/embed/{videoId}?start={start_sec}&rel=0&modestbranding=1&playsinline=1"
    title="{title}"
    allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
    referrerpolicy="strict-origin-when-cross-origin"
    allowfullscreen>
  </iframe>
```

- `start={start_sec}` で `video_kc.start_sec` の位置から頭出しする
- `rel=0` で終了後の関連動画を同一チャンネル内に限定する（無関係な動画への離脱を減らす）
- `playsinline=1` でスマホでも全画面に飛ばさない（学習フローから離脱させない）
- **自動再生しない。** `autoplay` パラメータは使わない

### 5.2 遅延ロード

サムネイル画像は `loading="lazy"`、`IntersectionObserver` でビューポートに入るまで描画しない。
教材ページに動画が5本あってもサムネイル5枚しか読まない。

### 5.3 CSP

```
frame-src   https://www.youtube-nocookie.com;
img-src     'self' data: https://i.ytimg.com;
```

`connect-src` に YouTube を足す必要はない（実行時にAPIを呼ばないため）。

### 5.4 YouTube 利用規約の遵守

- **公式の埋め込みプレーヤーを使う。** 動画のダウンロード、プレーヤーコントロールの除去、
  YouTubeブランディングの隠蔽は行わない
- API から取得したメタデータのキャッシュ保持期間の上限に注意する（**要検証**：
  YouTube API Services 規約の保存期間規定を実装前に確認すること）

### 5.5 プライバシーポリシーへの記載

「関連動画を再生した場合、YouTube（Google LLC）に対してお客様の IP アドレス、
ブラウザ情報および視聴状況が送信されます。再生前は当該送信は発生しません。」を明記する。

## 6. 学習設計上の位置づけ

**動画視聴は再読と同じ低効用象限の受動的消費である**（Dunlosky et al. 2013 では
re-reading は low utility、practice testing と distributed practice が high utility）。
「動画を見て終わり」にすると、教材を長文化したときと同じ失敗を繰り返すことになる。

したがって次の2点を仕様として固定する。

### 6.1 視聴イベントは弱い学習項にとどめる

視聴だけでは `p_know` のベイズ更新（`04-weakness-engine.md` §B）を**行わない**。
教材読了と同じ弱い学習項として扱う。

```
if watched_sec >= 0.6 * duration_sec:
    for kc in kcs_of(video):
        p_know(kc) += (1 - p_know(kc)) * 0.05
```

`n_eff` は増やさない。視聴は「測定」ではなく「学習機会」だからである。
視聴回数を積んでも `status` が `unknown` から動かないのは意図した挙動である。

### 6.2 視聴後に必ず retrieval を挟む

動画プレーヤーを閉じる、または再生が終了した時点で、
**その動画に紐づくKCから四択を2問出す**。この2問は通常の応答として `response` に記録され、
`04-weakness-engine.md` と `04b-spaced-repetition.md` のパイプラインを通る。

出題対象がない（該当KCに `approved` な item が2問未満）場合は、retrieval を出さずに閉じる。

## 7. 配置（導線）

MVP では次の2箇所にのみ置く。**フッタの独立タブにはしない**（動画を目的化させない）。

| 配置 | 出す動画 | 件数 |
|---|---|---|
| 教材セクションの末尾 | そのセクションの `material_section_kc` に紐づくKCの動画 | 最大2件（`relevance` 降順） |
| 確認テストの結果画面 | 落としたKCのうち `mastery` が最も低い3KCの動画 | 最大3件 |

いずれも「このセクションの理解を助ける動画」「間違えたところを解説している動画」という
**目的が明示されたラベル**を付ける。ラベルなしのサムネイル羅列にしない。

## 8. エッジケース

| ケース | 挙動 |
|---|---|
| KCに紐づく `approved` 動画が0件 | 動画セクション自体を描画しない（「動画がありません」も出さない） |
| 動画が視聴中に削除された | iframe がエラーを表示する。次回の週次バッチで `unavailable` になり消える |
| ネットワークが遅い | サムネイルは軽量（hqdefault は約20KB）なので描画は成立する。iframe は押されるまで読み込まれない |
| `start_sec` が動画長を超えている | `videos.list` の `duration_sec` と突き合わせて `video_kc` 登録時に弾く |
| 同じ動画が複数KCから推薦される | 1画面内では動画IDで重複排除し、最も `relevance` の高いKCの `start_sec` を使う |

## 9. 実装前に検証すること

1. `videos.list` の `part=status,contentDetails` で `embeddable` と `contentRating.ytRating` が
   期待どおり取得できること（**要検証**）
2. 年齢制限動画が埋め込みプレーヤーで実際に再生できないこと（仕様上できないはずだが実挙動を確認）
3. YouTube API Services 規約が定めるメタデータのキャッシュ保持期間の上限（**要検証**）
4. 埋め込み対応付けの cosine 類似度閾値 0.72 の妥当性（代表20KCで人手評価する）
