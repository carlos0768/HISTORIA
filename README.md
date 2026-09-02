# HISTORIA

受験世界史の**弱点を測って、そこだけを出し直す**アプリ。歴史総合・世界史探究が対象。

> 単なる暗記アプリにしないことを設計の中心に置いている。
> 覚えたかどうかではなく「区別・因果・年代順・地理比定」ができるかを測る。

## いまの状態

| | 状態 |
|---|---|
| 仕様書 | [`docs/`](./docs) 19文書。作者判断の未決は0件 |
| スキーマ | [`docs/schema.sql`](./docs/schema.sql) 42テーブル・RLS 42本＋ポリシー34本。本番 Supabase で 52項目の検査を通過 |
| マスタ | [`seed/`](./seed) 章立て117件・KC 408件・`canon_event` 1,180件・`person` 446件（すべて承認済み・本番 Supabase 投入済み） |
| 学習ロジック | SM-2 / 弱点推定 / スケジューラ / 確認テスト / 支出遮断器 |
| 閉ループ | 出題→採点→弱点更新→翌日出し直しが実 DB で動く |
| **認証** | 招待コード＋Google／メールリンク。未認証は全経路 404 |
| 画面 | ホーム・出題・教材・範囲選択・特訓一覧・確認テスト・その結果・記録・認証4画面。三分割シェルと3タブ。Litverse デザインシステム |
| AI 生成 | プロバイダ抽象層のみ。**鍵が無い間はフェイクで通る** |
| PWA | オフラインは**読むだけ**。出題は端末に降ろさない（[`12`](./docs/12-nonfunctional.md) §10） |
| テスト | 486件（`npm test`） |

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
`NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY` を**設定しなければ認証も無効**で、
`DEMO_USER_ID` の1人として全画面を見られる（意匠の確認用）。

## 認証を有効にする

環境変数を2つ入れると認証が有効になり、**未認証は `/invite` `/login` `/auth/callback`
以外の全経路が 404 になる**（[`10`](./docs/10-legal-risk.md) §3.2 G2）。

```bash
export NEXT_PUBLIC_SUPABASE_URL=https://<project>.supabase.co
export NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon key>
```

### 招待コードを発行する

`invite_code` は 0 件で始まるので、**発行しないと誰もサインアップできない**。

```bash
DATABASE_URL='postgresql://...' npx tsx scripts/db/issue-invite.ts                  # 一覧だけ
DATABASE_URL='postgresql://...' npx tsx scripts/db/issue-invite.ts --issue           # 1枚
DATABASE_URL='postgresql://...' npx tsx scripts/db/issue-invite.ts --issue --count 3 --days 30
```

上限は**利用者＋未使用のコードで10**（G7）。10枚配ってから作者自身が入れない、が起きない。
発行したコードと `/invite` の URL は、招待する相手に直接渡す（検索からは辿れない）。

### Google ログインを使えるようにする（作者の手作業）

メールリンクは Supabase の既定で動くので、**この設定を待たずに実機で確かめられる**。
Google を主にするには次を行う（[`03`](./docs/03-data-model.md) §7.1）。

1. **Supabase の戻り先 URL を控える** — Authentication → Providers → Google を開くと
   `https://<project>.supabase.co/auth/v1/callback` が表示される
2. **Google Cloud で OAuth クライアントを作る** — [console.cloud.google.com](https://console.cloud.google.com)
   → APIs & Services → OAuth consent screen（外部・テストで可、自分と友人をテストユーザーに追加）
   → Credentials → Create Credentials → OAuth client ID → **Web application**
   - Authorized redirect URIs に **1 で控えた URL** を入れる（アプリ側の `/auth/callback` ではない）
3. **Supabase に client ID と secret を入れる** — Providers → Google を有効にして貼る
4. **Supabase の Redirect URLs にアプリを登録する** — Authentication → URL Configuration →
   Redirect URLs に `https://<本番ドメイン>/auth/callback` と
   `http://localhost:3000/auth/callback` を追加する（ここに無い戻り先は拒否される）
5. **Vercel に環境変数を入れる** — `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY` /
   `DATABASE_URL`

> `anon key` は公開されてよい鍵である（RLS が守る）。**`service_role` key は絶対に入れない。**

## Vercel に載せる

環境変数を入れないと、全画面が「データベースに接続していません」「利用者を特定できていません」
だけになる（画面が壊れているのではなく、**そう出るように作ってある**）。

| 変数 | 値 | 無いとどうなる |
|---|---|---|
| `DATABASE_URL` | Supabase の **Transaction pooler**（下記） | 全画面が「データベースに接続していません」 |
| `NEXT_PUBLIC_SUPABASE_URL` | `https://<project>.supabase.co` | 認証が無効になり、未認証でも404にならない |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | anon key | 同上 |

### `DATABASE_URL` は Transaction pooler にする

**直結（`db.<project>.supabase.co:5432`）は Vercel からは使えない。** 理由は2つある。

1. **無料枠の直結は IPv6 のみ**である（IPv4 は有料アドオン）。Vercel の関数は IPv4 なので、
   そもそも名前が引けない
2. 仮に繋がっても、関数は要求ごとに立ち上がるので接続を食い潰して
   `too many connections` で落ちる（[`12`](./docs/12-nonfunctional.md) §4）

**取り方。** ダッシュボード上部の **Connect** ボタンを押す（Settings → Database ではない）。
直接開くなら `https://supabase.com/dashboard/project/<project>?showConnect=true&method=transaction`。
そこに出る **Transaction pooler**（公式文書では「Shared Pooler (Supavisor) - transaction mode」）
の文字列をそのまま貼る。ポートは **6543**。

```
postgres://postgres.<project>:<パスワード>@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres
```

★ **手で組み立てない。** 2箇所が直結と違う。

- ユーザ名が `postgres` ではなく **`postgres.<project>`**
- ホスト名に案件ごとの番号（`aws-0-` / `aws-1-`）が入る。
  DNS で確かめたところ、番号を落とした `aws-ap-northeast-1.pooler.supabase.com` は**存在しない**
  （公式文書の `aws-[REGION]` は表記の省略である）

`lib/db/client.ts` は既に `prepare: false` を設定してある。
transaction モードは prepared statement を持てないので、これが要る
（公式文書も「To avoid errors, turn off prepared statements」と明記している）。

| | ホスト | ポート | 用途 |
|---|---|---|---|
| 直結 | `db.<project>.supabase.co` | 5432 | 移行・`pg_dump`・常駐サーバ（IPv6） |
| Session pooler | `aws-N-<region>.pooler.supabase.com` | 5432 | IPv4 の常駐サーバ |
| **Transaction pooler** | `aws-N-<region>.pooler.supabase.com` | **6543** | **サーバーレス（Vercel）** |

ポートだけが違うので、**5432 のまま貼ると Session pooler になる**。ここが一番間違えやすい。

### 招待コードを1枚も発行していないと、誰もログインできない

`invite_code` は 0 件で始まる（G7）。**環境変数を入れただけでは自分も入れない。**

```bash
DATABASE_URL='postgresql://...' npx tsx scripts/db/issue-invite.ts --issue
```

出たコードと `/invite` の URL を自分に渡してサインアップする。

### 入れたあとの順番

1. 環境変数を3つ入れて再デプロイ
2. 招待コードを発行 → `/invite` から登録（生年月日と同意まで）
3. `/drills/new` で範囲を選んで特訓を作る
4. 教材と設問は AI 生成なので、**鍵が無い間は空のまま**（[`08`](./docs/08-ai-architecture.md)）

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
- **未認証はリダイレクトではなく404**。ログイン画面の存在すら見せない（[`10`](./docs/10-legal-risk.md) §3.2 G2）
- **ブラウザに Supabase を触らせない**。OAuth をサーバー側に閉じて CSP を広げない（[`03`](./docs/03-data-model.md) §7.3）
- **月1万円で AI 呼び出しを機械的に停止する**。上限を1円も超えない（[`08`](./docs/08-ai-architecture.md) §7.1）
- **生成は無料枠、検証は課金**。同一モデルの自己検証に退化させない（[`08`](./docs/08-ai-architecture.md) §2）

読む順は [`docs/README.md`](./docs/README.md) にある。

## 残っていること

1. **Vercel の環境変数と招待コード**（上記「Vercel に載せる」）— これが済むまで本番は空のまま
2. **Google OAuth の設定**（上記「認証を有効にする」）— メールリンクは設定不要で先に試せる
3. **Gemini の課金開通** — 済むまで教材も設問も生成されない（[`14`](./docs/14-open-questions.md) M28）
4. Phase 0（仮説検証）— [`13-roadmap.md`](./docs/13-roadmap.md)。3 が前提
5. 診断用の共有設問プール 240問 — 4 の通過が前提
