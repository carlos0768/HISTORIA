/**
 * 版図マスタ — 国家の領域の移り変わりを、現在の国の集合で近似する
 *
 * ★★ countries による塗りは暫定である。★★
 *   lib/map/regions.ts と同じく、現在の国境で歴史上の版図を近似しているにすぎない。
 *   `geo` を付けた段階だけ、historical-basemaps の境界ポリゴン（lib/map/territory-geo/）で塗る。
 *   「オスマン帝国 1683 年」を「ハンガリー・セルビア・…の現在の国土」で塗るので、
 *   国の一部しか含まなかった場合も国ごと塗られる。学習用の模式図であり、
 *   境界線の正確さを示すものではない（画面にもそう書く）。
 *   史料が固まったら、この表ごと差し替える前提で書いてある。
 *
 * 1国家 = 年代順のスナップショットの列。版図が縮んでいく過程を再生できるよう、
 * 最大版図の後の縮小と滅亡（空の集合）も1段階として持つ。
 *
 * 国のコードは ISO 3166-1 の数値（lib/map/basemap.ts の COUNTRY_NAMES で名前を確認できる）。
 * 試験（territories.test.ts）が、基図に無いコードを指していないことを確かめる。
 */

export type TerritorySnapshot = {
  /** 負値は紀元前 */
  year: number
  /** その段階の名前（「最大版図」「滅亡」等） */
  label: string
  /** その時点で概ね含んでいた現在の国。空なら「版図なし」（滅亡・分裂） */
  countries: readonly string[]
  /** 近似の注意（「北部のみ」等） */
  note?: string
  /**
   * 本物の境界データ（historical-basemaps）。付いている段階だけ境界ポリゴンで塗り、
   * 無い段階は countries で現在の国に近似する。
   * year はデータ側の年（lib/map/historical-years.ts にある年）で、段階の年と一致しなくてよい。
   * names は一致させる NAME（by='SUBJECTO' なら宗主国名でも合わせる）。
   */
  geo?: { year: number; names: readonly string[]; by?: 'NAME' | 'SUBJECTO' }
}

export type Polity = {
  id: string
  label: string
  /** 表記ゆれ・略称。検索はこれにも当てる */
  aliases: readonly string[]
  /** 年代順 */
  snapshots: readonly TerritorySnapshot[]
}

// 読みやすさのための短い名前。値は ISO 3166-1 数値
const C = {
  italy: '380', spain: '724', portugal: '620', france: '250', uk: '826', ireland: '372',
  belgium: '056', netherlands: '528', luxembourg: '442', switzerland: '756', austria: '040',
  germany: '276', hungary: '348', czechia: '203', slovakia: '703', poland: '616', romania: '642',
  bulgaria: '100', greece: '300', serbia: '688', croatia: '191', bosnia: '070', slovenia: '705',
  albania: '008', macedonia: '807', montenegro: '499', turkey: '792', cyprus: '196', malta: '470',
  denmark: '208', norway: '578', sweden: '752', finland: '246',
  syria: '760', lebanon: '422', israel: '376', palestine: '275', jordan: '400', iraq: '368', iran: '364',
  egypt: '818', libya: '434', tunisia: '788', algeria: '012', morocco: '504',
  saudi: '682', yemen: '887', oman: '512', uae: '784', kuwait: '414', qatar: '634', bahrain: '048',
  afghanistan: '004', pakistan: '586', india: '356', bangladesh: '050', srilanka: '144', myanmar: '104',
  uzbekistan: '860', turkmenistan: '795', tajikistan: '762', kyrgyzstan: '417', kazakhstan: '398',
  mongolia: '496', china: '156', taiwan: '158', nkorea: '408', skorea: '410', japan: '392',
  russia: '643', ukraine: '804', belarus: '112', georgia: '268', armenia: '051', azerbaijan: '031',
  moldova: '498', lithuania: '440', latvia: '428', estonia: '233',
  sudan: '729', ethiopia: '231', somalia: '706', djibouti: '262',
  malaysia: '458', singapore: '702', indonesia: '360', philippines: '608', vietnam: '704', laos: '418',
  cambodia: '116', thailand: '764', brunei: '096', png: '598', australia: '036', nz: '554',
  canada: '124', usa: '840', mexico: '484', cuba: '192', dominican: '214', haiti: '332', jamaica: '388',
  trinidad: '780', bahamas: '044', belize: '084', guyana: '328',
  guatemala: '320', honduras: '340', elsalvador: '222', nicaragua: '558', costarica: '188', panama: '591',
  colombia: '170', venezuela: '862', ecuador: '218', peru: '604', bolivia: '068', chile: '152',
  argentina: '032', paraguay: '600', uruguay: '858', brazil: '076',
  angola: '024', mozambique: '508', guineabissau: '624',
  kenya: '404', uganda: '800', tanzania: '834', nigeria: '566', ghana: '288', sierraleone: '694', gambia: '270',
  southafrica: '710', zimbabwe: '716', zambia: '894', malawi: '454', botswana: '072', lesotho: '426', eswatini: '748',
  senegal: '686', mali: '466', niger: '562', chad: '148', burkina: '854', ivorycoast: '384', benin: '204', togo: '768',
  cameroon: '120', gabon: '266', congo: '178', car: '140', madagascar: '450', mauritania: '478', guinea: '324',
} as const

const P = (
  id: string, label: string, aliases: readonly string[], snapshots: readonly TerritorySnapshot[],
): Polity => ({ id, label, aliases, snapshots })

const LEVANT = [C.syria, C.lebanon, C.israel, C.palestine, C.jordan] as const
const MAGHREB = [C.libya, C.tunisia, C.algeria, C.morocco] as const
const ARABIA = [C.saudi, C.yemen, C.oman, C.uae, C.kuwait, C.qatar, C.bahrain] as const
const CENTRAL_ASIA = [C.uzbekistan, C.turkmenistan, C.tajikistan, C.kyrgyzstan] as const
const BALKANS = [C.greece, C.macedonia, C.albania, C.bulgaria, C.serbia, C.bosnia, C.montenegro] as const

export const POLITIES: readonly Polity[] = [
  P('rome', 'ローマ帝国', ['ローマ', '古代ローマ', 'ローマ共和国', '西ローマ帝国'], [
    { year: -264, label: 'イタリア半島の統一', countries: [C.italy] },
    { year: -146, label: 'カルタゴとマケドニアを征服', countries: [C.italy, C.tunisia, C.greece, C.macedonia, C.albania] },
    { year: -30, label: 'エジプト併合（共和政の終わり）',
      countries: [C.italy, C.spain, C.portugal, C.france, C.tunisia, C.algeria, C.libya, C.egypt, C.greece, C.macedonia,
                  C.albania, C.turkey, ...LEVANT, C.cyprus, C.bosnia, C.croatia, C.slovenia],
      note: 'アルジェリア・リビアは沿岸のみ' },
    { year: 117, label: '最大版図（トラヤヌス帝）',
      countries: [C.italy, C.spain, C.portugal, C.france, C.uk, C.belgium, C.netherlands, C.luxembourg, C.switzerland,
                  C.austria, C.hungary, C.bosnia, C.croatia, C.slovenia, C.serbia, C.montenegro, C.bulgaria, C.romania,
                  C.greece, C.macedonia, C.albania, C.turkey, C.cyprus, ...LEVANT, C.iraq, C.armenia, C.egypt,
                  C.libya, C.tunisia, C.algeria, C.morocco],
      note: 'イラク・アルメニアは一時的' },
    { year: 395, label: '東西に分裂（西ローマ帝国）',
      countries: [C.italy, C.spain, C.portugal, C.france, C.uk, C.belgium, C.luxembourg, C.switzerland, C.austria,
                  C.hungary, C.croatia, C.slovenia, C.tunisia, C.algeria, C.morocco, C.libya],
      note: '東側はビザンツ帝国へ' },
    { year: 476, label: '西ローマ帝国の滅亡', countries: [] },
  ]),

  P('byzantium', 'ビザンツ帝国', ['東ローマ帝国', 'ビザンティン帝国', 'ビザンツ'], [
    { year: 395, label: 'ローマ帝国の東半として成立',
      countries: [...BALKANS, C.romania, C.turkey, C.cyprus, ...LEVANT, C.egypt, C.libya] },
    { year: 555, label: 'ユスティニアヌス1世の再征服（最大版図）',
      countries: [...BALKANS, C.turkey, C.cyprus, ...LEVANT, C.egypt, C.libya, C.tunisia, C.algeria, C.italy, C.spain],
      note: 'スペインは南岸のみ' },
    { year: 800, label: 'イスラームの征服で縮小',
      countries: [C.greece, C.macedonia, C.albania, C.turkey, C.cyprus, C.italy], note: 'イタリアは南部のみ' },
    { year: 1025, label: 'バシレイオス2世の死（マケドニア朝の最大）',
      countries: [...BALKANS, C.turkey, C.cyprus, C.syria, C.lebanon, C.armenia, C.georgia, C.italy],
      note: 'シリアは北部のみ' },
    { year: 1204, label: '第4回十字軍でコンスタンティノープル陥落', countries: [C.turkey, C.greece], note: '亡命政権が分立' },
    { year: 1453, label: 'コンスタンティノープル陥落（滅亡）', countries: [] },
  ]),

  P('alexander', 'アレクサンドロス帝国', ['アレクサンドロス大王', 'マケドニア王国', 'アレクサンドロス'], [
    { year: -336, label: 'アレクサンドロスの即位', countries: [C.greece, C.macedonia, C.bulgaria] },
    { year: -331, label: 'ガウガメラの戦いでペルシアを破る',
      countries: [C.greece, C.macedonia, C.bulgaria, C.turkey, ...LEVANT, C.egypt, C.iraq] },
    { year: -323, label: '大王の死（最大版図）',
      countries: [C.greece, C.macedonia, C.bulgaria, C.turkey, ...LEVANT, C.egypt, C.iraq, C.iran, C.afghanistan,
                  ...CENTRAL_ASIA, C.pakistan] },
    { year: -301, label: 'イプソスの戦い（後継者に分裂）', countries: [], note: 'セレウコス朝・プトレマイオス朝などへ' },
  ]),

  P('achaemenid', 'アケメネス朝ペルシア', ['アケメネス朝', 'ペルシア帝国', 'ペルシャ', 'ペルシア'], [
    { year: -550, label: 'キュロス2世の建国', countries: [C.iran] },
    { year: -539, label: 'バビロン征服',
      countries: [C.iran, C.iraq, C.turkey, ...LEVANT, C.armenia, C.azerbaijan, C.turkmenistan] },
    { year: -500, label: 'ダレイオス1世（最大版図）',
      countries: [C.iran, C.iraq, C.turkey, ...LEVANT, C.armenia, C.azerbaijan, C.egypt, C.libya, C.pakistan,
                  C.afghanistan, ...CENTRAL_ASIA, C.bulgaria, C.macedonia, C.cyprus],
      note: 'リビアは東部のみ' },
    { year: -330, label: 'アレクサンドロスに滅ぼされる', countries: [] },
  ]),

  P('umayyad', 'ウマイヤ朝', ['ウマイヤ', '後ウマイヤ朝'], [
    { year: 661, label: 'ムアーウィヤの建国',
      countries: [...ARABIA, C.iraq, ...LEVANT, C.egypt, C.iran, C.afghanistan, ...CENTRAL_ASIA] },
    { year: 711, label: 'イベリア半島征服（最大版図）',
      countries: [...ARABIA, C.iraq, ...LEVANT, C.egypt, C.iran, C.afghanistan, ...CENTRAL_ASIA, ...MAGHREB,
                  C.spain, C.portugal, C.pakistan] },
    { year: 750, label: 'アッバース革命で倒れる（後ウマイヤ朝がイベリアに残る）', countries: [C.spain, C.portugal] },
    { year: 1031, label: '後ウマイヤ朝の滅亡', countries: [] },
  ]),

  P('abbasid', 'アッバース朝', ['アッバース', 'アッバース朝カリフ'], [
    { year: 750, label: '成立',
      countries: [...ARABIA, C.iraq, ...LEVANT, C.egypt, C.iran, C.afghanistan, ...CENTRAL_ASIA, ...MAGHREB, C.pakistan] },
    { year: 800, label: 'ハールーン=アッラシード（北アフリカ西部が離脱）',
      countries: [...ARABIA, C.iraq, ...LEVANT, C.egypt, C.iran, C.afghanistan, ...CENTRAL_ASIA, C.libya, C.tunisia, C.pakistan] },
    { year: 945, label: 'ブワイフ朝がバグダードに入城（実権を失う）', countries: [C.iraq], note: '名目上のカリフ' },
    { year: 1258, label: 'モンゴルに滅ぼされる', countries: [] },
  ]),

  P('mongol', 'モンゴル帝国', ['モンゴル', '元', '大元', 'チンギス=ハン', 'フビライ', 'クビライ'], [
    { year: 1206, label: 'チンギス=ハンの即位', countries: [C.mongolia] },
    { year: 1227, label: 'チンギス=ハンの死',
      countries: [C.mongolia, C.china, C.kazakhstan, ...CENTRAL_ASIA, C.afghanistan, C.iran],
      note: '中国は北部のみ' },
    { year: 1260, label: 'モンケの死（4ハン国へ）',
      countries: [C.mongolia, C.china, C.kazakhstan, ...CENTRAL_ASIA, C.afghanistan, C.iran, C.iraq, C.syria,
                  C.armenia, C.georgia, C.azerbaijan, C.turkey, C.russia, C.ukraine, C.belarus, C.pakistan, C.nkorea],
      note: 'ロシアは南部・西部のみ' },
    { year: 1279, label: '南宋を滅ぼし中国を統一（最大版図）',
      countries: [C.mongolia, C.china, C.kazakhstan, ...CENTRAL_ASIA, C.afghanistan, C.iran, C.iraq, C.syria,
                  C.armenia, C.georgia, C.azerbaijan, C.turkey, C.russia, C.ukraine, C.belarus, C.pakistan,
                  C.nkorea, C.skorea, C.myanmar],
      note: '高麗は服属。ハン国はそれぞれ独立の傾向' },
    { year: 1368, label: '元がモンゴル高原へ退く（北元）', countries: [C.mongolia] },
  ]),

  P('ottoman', 'オスマン帝国', ['オスマン', 'オスマン=トルコ', 'オスマントルコ', 'トルコ'], [
    { year: 1300, label: 'オスマン1世の建国', countries: [C.turkey], note: 'アナトリア北西部のみ' },
    { year: 1453, label: 'コンスタンティノープル征服',
      countries: [C.turkey, C.bulgaria, C.macedonia, C.greece, C.serbia, C.albania, C.bosnia] },
    { year: 1566, label: 'スレイマン1世の死',
      countries: [C.turkey, ...BALKANS, C.hungary, C.romania, C.moldova, C.ukraine, C.croatia, C.slovenia,
                  ...LEVANT, C.iraq, C.egypt, C.libya, C.tunisia, C.algeria, ...ARABIA],
      note: 'ウクライナは南岸。アラビア半島は沿岸' },
    { year: 1683, label: '第2次ウィーン包囲（最大版図）',
      countries: [C.turkey, ...BALKANS, C.hungary, C.romania, C.moldova, C.ukraine, C.croatia, C.slovenia, C.cyprus,
                  ...LEVANT, C.iraq, C.egypt, C.libya, C.tunisia, C.algeria, ...ARABIA],
      geo: { year: 1700, names: ['Ottoman Empire'] } },
    { year: 1718, label: 'パッサロヴィッツ条約（ハンガリーを失う）',
      countries: [C.turkey, ...BALKANS, C.romania, C.moldova, C.ukraine, C.cyprus,
                  ...LEVANT, C.iraq, C.egypt, C.libya, C.tunisia, C.algeria, ...ARABIA] },
    { year: 1812, label: 'ブカレスト条約（黒海北岸を失う）',
      countries: [C.turkey, ...BALKANS, C.romania, C.cyprus, ...LEVANT, C.iraq, C.egypt, C.libya, C.tunisia, C.algeria, ...ARABIA],
      note: 'アルジェリアは 1830 年にフランスへ' },
    { year: 1878, label: 'ベルリン条約（バルカン諸国が独立）',
      countries: [C.turkey, C.macedonia, C.albania, C.greece, ...LEVANT, C.iraq, C.egypt, C.libya, ...ARABIA],
      note: 'キプロスはイギリスの管理下、エジプトは自治（境界データでは属国のエジプトを含めない）',
      geo: { year: 1880, names: ['Ottoman Empire'] } },
    { year: 1913, label: 'バルカン戦争後（ヨーロッパ領をほぼ失う）',
      countries: [C.turkey, ...LEVANT, C.iraq, C.saudi, C.yemen],
      geo: { year: 1914, names: ['Ottoman Empire'] } },
    { year: 1923, label: '滅亡（トルコ共和国へ）', countries: [] },
  ]),

  P('hre', '神聖ローマ帝国', ['神聖ローマ', 'ドイツ王国'], [
    { year: 962, label: 'オットー1世の戴冠',
      countries: [C.germany, C.austria, C.czechia, C.switzerland, C.netherlands, C.belgium, C.luxembourg, C.italy],
      note: 'イタリアは北部のみ' },
    { year: 1250, label: 'フリードリヒ2世の死（最大）',
      countries: [C.germany, C.austria, C.czechia, C.switzerland, C.netherlands, C.belgium, C.luxembourg, C.italy, C.slovenia] },
    { year: 1648, label: 'ウェストファリア条約（スイス・オランダの独立）',
      countries: [C.germany, C.austria, C.czechia, C.belgium, C.luxembourg, C.slovenia] },
    { year: 1806, label: '解体', countries: [] },
  ]),

  P('british_empire', '大英帝国', ['イギリス帝国', 'イギリス', '英国', 'ブリテン'], [
    { year: 1607, label: '北アメリカ植民の開始', countries: [C.uk, C.ireland, C.usa], note: 'アメリカは東岸のみ' },
    { year: 1763, label: 'パリ条約（七年戦争に勝つ）',
      countries: [C.uk, C.ireland, C.usa, C.canada, C.jamaica, C.trinidad, C.bahamas, C.belize, C.india],
      note: 'インドはベンガルのみ' },
    { year: 1815, label: 'ウィーン会議',
      countries: [C.uk, C.ireland, C.canada, C.jamaica, C.trinidad, C.bahamas, C.belize, C.guyana, C.india,
                  C.srilanka, C.southafrica, C.malta, C.australia] },
    { year: 1920, label: '最大版図（第一次世界大戦後）',
      countries: [C.uk, C.ireland, C.canada, C.jamaica, C.trinidad, C.bahamas, C.belize, C.guyana,
                  C.india, C.pakistan, C.bangladesh, C.myanmar, C.srilanka, C.malaysia, C.singapore, C.brunei,
                  C.australia, C.nz, C.png, C.southafrica, C.zimbabwe, C.zambia, C.malawi, C.botswana, C.lesotho,
                  C.eswatini, C.kenya, C.uganda, C.tanzania, C.nigeria, C.ghana, C.sierraleone, C.gambia, C.egypt,
                  C.sudan, C.somalia, C.malta, C.cyprus, C.israel, C.palestine, C.jordan, C.iraq, C.kuwait, C.qatar,
                  C.bahrain, C.uae, C.oman, C.yemen],
      note: 'エジプト・イラクなどは保護国・委任統治' },
    { year: 1947, label: 'インド・パキスタンの独立',
      countries: [C.uk, C.canada, C.jamaica, C.trinidad, C.bahamas, C.belize, C.guyana, C.malaysia, C.singapore,
                  C.brunei, C.australia, C.nz, C.png, C.southafrica, C.zimbabwe, C.zambia, C.malawi, C.botswana,
                  C.lesotho, C.eswatini, C.kenya, C.uganda, C.tanzania, C.nigeria, C.ghana, C.sierraleone, C.gambia,
                  C.sudan, C.somalia, C.malta, C.cyprus, C.kuwait, C.qatar, C.bahrain, C.uae, C.oman, C.yemen] },
    { year: 1965, label: '「アフリカの年」の後（植民地の大半が独立）',
      countries: [C.uk, C.canada, C.australia, C.nz, C.guyana, C.belize, C.bahamas, C.botswana, C.lesotho, C.eswatini,
                  C.png, C.brunei, C.qatar, C.bahrain, C.uae, C.oman, C.yemen],
      note: 'カナダなどは自治領' },
    { year: 1997, label: '香港返還', countries: [C.uk], note: '海外領土はわずか' },
  ]),

  P('spanish_empire', 'スペイン帝国', ['スペイン', 'イスパニア'], [
    { year: 1492, label: 'レコンキスタの完了', countries: [C.spain] },
    { year: 1580, label: 'ポルトガル併合（フェリペ2世・最大版図）',
      countries: [C.spain, C.portugal, C.brazil, C.mexico, C.cuba, C.dominican, C.haiti, C.jamaica, C.guatemala,
                  C.honduras, C.elsalvador, C.nicaragua, C.costarica, C.panama, C.colombia, C.venezuela, C.ecuador,
                  C.peru, C.bolivia, C.chile, C.argentina, C.paraguay, C.uruguay, C.philippines, C.netherlands,
                  C.belgium, C.luxembourg, C.italy, C.angola, C.mozambique, C.guineabissau],
      note: 'イタリアは南部。内陸の多くは名目' },
    { year: 1648, label: 'オランダ独立（ポルトガルも 1640 年に分離）',
      countries: [C.spain, C.mexico, C.cuba, C.dominican, C.haiti, C.guatemala, C.honduras, C.elsalvador, C.nicaragua,
                  C.costarica, C.panama, C.colombia, C.venezuela, C.ecuador, C.peru, C.bolivia, C.chile, C.argentina,
                  C.paraguay, C.uruguay, C.philippines, C.belgium, C.luxembourg, C.italy] },
    { year: 1825, label: 'ラテンアメリカ諸国の独立', countries: [C.spain, C.cuba, C.philippines] },
    { year: 1898, label: '米西戦争（キューバ・フィリピンを失う）', countries: [C.spain] },
  ]),

  P('mughal', 'ムガル帝国', ['ムガル', 'ムガール帝国'], [
    { year: 1526, label: 'バーブルの建国', countries: [C.afghanistan, C.pakistan, C.india], note: 'インドは北部のみ' },
    { year: 1605, label: 'アクバルの死', countries: [C.afghanistan, C.pakistan, C.india, C.bangladesh] },
    { year: 1707, label: 'アウラングゼーブの死（最大版図）', countries: [C.pakistan, C.india, C.bangladesh, C.afghanistan] },
    { year: 1757, label: 'プラッシーの戦い（イギリスが進出）', countries: [C.india], note: 'デリー周辺のみ' },
    { year: 1858, label: '滅亡（インド大反乱後）', countries: [] },
  ]),

  P('qing', '清', ['清朝', '大清', '清帝国'], [
    { year: 1644, label: '北京入城', countries: [C.china], note: '東北部と華北' },
    { year: 1683, label: '台湾平定（中国本土の統一）', countries: [C.china, C.taiwan] },
    { year: 1759, label: '乾隆帝（最大版図）', countries: [C.china, C.taiwan, C.mongolia, C.kyrgyzstan], note: '外モンゴル・新疆を含む' },
    { year: 1860, label: '北京条約（沿海州をロシアへ）', countries: [C.china, C.taiwan, C.mongolia] },
    { year: 1895, label: '下関条約（台湾を日本へ）', countries: [C.china, C.mongolia] },
    { year: 1912, label: '滅亡（中華民国へ）', countries: [] },
  ]),

  P('japan_empire', '大日本帝国', ['日本', '日本帝国', '帝国日本'], [
    { year: 1868, label: '明治維新', countries: [C.japan] },
    { year: 1895, label: '台湾領有（下関条約）', countries: [C.japan, C.taiwan] },
    { year: 1910, label: '韓国併合', countries: [C.japan, C.taiwan, C.nkorea, C.skorea] },
    { year: 1932, label: '満洲国の建国（実質支配）', countries: [C.japan, C.taiwan, C.nkorea, C.skorea, C.china], note: '中国は東北部' },
    { year: 1942, label: '最大版図（太平洋戦争）',
      countries: [C.japan, C.taiwan, C.nkorea, C.skorea, C.china, C.philippines, C.vietnam, C.laos, C.cambodia,
                  C.malaysia, C.singapore, C.brunei, C.indonesia, C.myanmar, C.png],
      note: '中国は沿岸・東部' },
    { year: 1945, label: '敗戦', countries: [C.japan] },
  ]),

  P('ussr', 'ソ連', ['ソビエト連邦', 'ソヴィエト連邦', 'ソビエト', 'ソヴィエト'], [
    { year: 1922, label: '成立', countries: [C.russia, C.ukraine, C.belarus, C.georgia, C.armenia, C.azerbaijan] },
    { year: 1940, label: 'バルト三国併合（15共和国）',
      countries: [C.russia, C.ukraine, C.belarus, C.georgia, C.armenia, C.azerbaijan, C.kazakhstan, ...CENTRAL_ASIA,
                  C.moldova, C.estonia, C.latvia, C.lithuania] },
    { year: 1991, label: '解体', countries: [] },
  ]),

  P('nazi_germany', 'ナチス=ドイツ', ['ナチス', 'ナチ', '第三帝国', 'ヒトラー'], [
    { year: 1933, label: 'ヒトラー政権の成立', countries: [C.germany] },
    { year: 1938, label: 'オーストリア併合', countries: [C.germany, C.austria] },
    { year: 1939, label: 'チェコ解体・ポーランド侵攻', countries: [C.germany, C.austria, C.czechia, C.poland] },
    { year: 1942, label: '最大占領（独ソ戦）',
      countries: [C.germany, C.austria, C.czechia, C.poland, C.france, C.belgium, C.netherlands, C.luxembourg,
                  C.denmark, C.norway, C.ukraine, C.belarus, C.estonia, C.latvia, C.lithuania, C.greece, C.serbia,
                  C.bosnia, C.croatia, C.slovenia],
      note: '同盟国・傀儡は含まない' },
    { year: 1945, label: '敗戦', countries: [] },
  ]),

  P('han', '漢', ['前漢', '後漢', '漢王朝', '漢帝国'], [
    { year: -202, label: '高祖（劉邦）の建国', countries: [C.china], note: '東部のみ' },
    { year: -100, label: '武帝（最大版図）', countries: [C.china, C.nkorea, C.vietnam], note: '朝鮮北部・ベトナム北部' },
    { year: 220, label: '滅亡（三国へ）', countries: [] },
  ]),

  P('tang', '唐', ['唐王朝', '唐帝国'], [
    { year: 618, label: '建国', countries: [C.china] },
    { year: 660, label: '高宗（最大版図）', countries: [C.china, C.mongolia, C.uzbekistan, C.kyrgyzstan, C.nkorea],
      note: '西域は都護府による間接支配' },
    { year: 755, label: '安史の乱', countries: [C.china] },
    { year: 907, label: '滅亡', countries: [] },
  ]),

  P('french_empire', 'フランス植民地帝国', ['フランス', '仏', 'フランス帝国'], [
    { year: 1830, label: 'アルジェリア出兵', countries: [C.france, C.algeria] },
    { year: 1914, label: '最大に近い（第一次世界大戦前）',
      countries: [C.france, C.algeria, C.tunisia, C.morocco, C.senegal, C.mali, C.niger, C.chad, C.burkina,
                  C.ivorycoast, C.benin, C.guinea, C.mauritania, C.gabon, C.congo, C.car, C.madagascar, C.djibouti,
                  C.vietnam, C.laos, C.cambodia] },
    { year: 1920, label: '委任統治領を得る（最大版図）',
      countries: [C.france, C.algeria, C.tunisia, C.morocco, C.senegal, C.mali, C.niger, C.chad, C.burkina,
                  C.ivorycoast, C.benin, C.guinea, C.mauritania, C.gabon, C.congo, C.car, C.madagascar, C.djibouti,
                  C.vietnam, C.laos, C.cambodia, C.syria, C.lebanon, C.togo, C.cameroon] },
    { year: 1954, label: 'インドシナを失う（ディエンビエンフー）',
      countries: [C.france, C.algeria, C.tunisia, C.morocco, C.senegal, C.mali, C.niger, C.chad, C.burkina,
                  C.ivorycoast, C.benin, C.guinea, C.mauritania, C.gabon, C.congo, C.car, C.madagascar, C.djibouti,
                  C.togo, C.cameroon] },
    { year: 1962, label: 'アルジェリア独立', countries: [C.france], note: '海外県・海外領土は残る' },
  ]),

  P('timurid', 'ティムール朝', ['ティムール', 'ティムール帝国'], [
    { year: 1370, label: 'ティムールの即位（サマルカンド）', countries: [C.uzbekistan] },
    { year: 1405, label: 'ティムールの死（最大版図）',
      countries: [C.uzbekistan, C.turkmenistan, C.tajikistan, C.kyrgyzstan, C.afghanistan, C.iran, C.iraq,
                  C.armenia, C.azerbaijan, C.georgia, C.pakistan] },
    { year: 1507, label: '滅亡（ウズベクに倒される）', countries: [] },
  ]),
]

const norm = (s: string) => s.replace(/\s+/g, '').toLowerCase()

/**
 * 国名で版図を引く。表記ゆれ（別名）にも当て、確からしい順に返す。
 * 「オスマン帝国の版図」のように語が名前を含む場合も当てる。
 */
export function findPolities(query: string, limit = 3): Polity[] {
  const q = norm(query)
  if (q === '') return []
  const score = (p: Polity): number => {
    const names = [p.label, ...p.aliases].map(norm)
    if (names.some(n => n === q)) return 3
    if (names.some(n => n.startsWith(q) || q.startsWith(n))) return 2
    if (names.some(n => n.includes(q) || q.includes(n))) return 1
    return 0
  }
  return POLITIES
    .map(p => ({ p, s: score(p) }))
    .filter(x => x.s > 0)
    .sort((a, b) => b.s - a.s || a.p.label.localeCompare(b.p.label, 'ja'))
    .slice(0, limit)
    .map(x => x.p)
}

/** 前の段階と比べて、得た国と失った国 */
export function diffSnapshots(
  prev: TerritorySnapshot | null, cur: TerritorySnapshot,
): { gained: string[]; lost: string[] } {
  const before = new Set(prev?.countries ?? [])
  const after = new Set(cur.countries)
  return {
    gained: [...after].filter(c => !before.has(c)),
    lost: [...before].filter(c => !after.has(c)),
  }
}

export const polityById = (id: string): Polity | undefined => POLITIES.find(p => p.id === id)
