# 歴史地球儀データ

`events.ndjson` と `stories/*.json` が AtlasBundle v1 の Git 上の原本です。
すべてのイベントは、描画可能な地理要素と、日付・位置・叙述それぞれの外部出典を持ちます。

```bash
npm run atlas:validate
npm run atlas:coverage
npm run atlas:validate:release                           # 3000件・75物語の公開ゲート
npm run atlas:bootstrap:wikidata                         # dry-run
npm run atlas:bootstrap:wikidata -- --apply              # 探索用の要検証データを更新
npm run atlas:ingest                 # dry-run
npm run atlas:ingest -- --apply      # DATABASE_URL のDBへ反映
```

最初の手動校閲済みゴールデン物語は「コロンブスの第1回航海」と「産業革命の波及」です。
低信頼度を隠さず、画面では「要検証」と根拠の理由を表示します。面は歴史的国境ではなく
ISO 3166-1 numeric の現在の国境による近似です。

`wikidata-events.ndjson` は探索レイヤーです。座標・年代・出典URLを機械的に検証したうえで
取り込みますが、単元への割当と叙述は未校閲のままです。75節ぶんの物語は人手で校閲し、
`atlas:validate:release` が通るまで完成扱いにしません。
