-- HISTORIA seed（自動生成 — 手で編集しない）
-- 作り直す: npx tsx scripts/db/dump-sql.ts
--
-- 先に docs/schema.sql を流しておくこと。
-- 何度流しても結果は同じになる（ON CONFLICT で上書きする）。

BEGIN;

-- 時代 3 件
INSERT INTO era (id, label, start_year, end_year, ord) VALUES (1, '前近代（〜1500年）', -4000, 1500, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year, ord = EXCLUDED.ord;
INSERT INTO era (id, label, start_year, end_year, ord) VALUES (2, '近世・近代（1500-1900）', 1500, 1900, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year, ord = EXCLUDED.ord;
INSERT INTO era (id, label, start_year, end_year, ord) VALUES (3, '現代（1900年〜）', 1900, 2100, 3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year, ord = EXCLUDED.ord;

-- 地域 24 件（親を先に入れる）
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (1, 'ヨーロッパ', NULL, 1, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (6, 'アメリカ', NULL, 1, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (9, '西アジア', NULL, 2, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (13, 'アフリカ', NULL, 2, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (16, '南アジア', NULL, 3, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (17, '東南アジア', NULL, 3, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (18, '内陸アジア', NULL, 3, 3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (21, '東アジア', NULL, 4, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (2, '西欧', 1, 1, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (3, '南欧・地中海', 1, 1, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (4, '東欧・ロシア', 1, 1, 3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (5, '北欧', 1, 1, 4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (7, '北アメリカ', 6, 1, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (8, 'ラテンアメリカ', 6, 1, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (10, 'メソポタミア・イラン', 9, 2, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (11, 'アナトリア・シリア', 9, 2, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (12, 'アラビア半島', 9, 2, 3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (14, 'エジプト・北アフリカ', 13, 2, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (15, 'サハラ以南アフリカ', 13, 2, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (19, '中央アジア', 18, 3, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (20, 'モンゴル高原', 18, 3, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (22, '中国', 21, 4, 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (23, '朝鮮', 21, 4, 2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;
INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES (24, '日本', 21, 4, 3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;

-- 章立て 117 件（level の浅い方から。parent_id が自己参照のため）
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.1', 'world_history', NULL, 1, '世界史へのまなざし', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2', 'world_history', NULL, 1, '諸地域の歴史的特質の形成', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3', 'world_history', NULL, 1, '諸地域の交流・再編', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4', 'world_history', NULL, 1, '諸地域の結合・変容', 4)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.5', 'world_history', NULL, 1, '地球世界の課題', 5)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.1', 'general_history', NULL, 1, '歴史の扉', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2', 'general_history', NULL, 1, '近代化と私たち', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3', 'general_history', NULL, 1, '国際秩序の変化や大衆化と私たち', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.4', 'general_history', NULL, 1, 'グローバル化と私たち', 4)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.1.1', 'world_history', 'wh.1', 2, '地球環境からみる人類の歴史', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.1.2', 'world_history', 'wh.1', 2, '日常生活からみる世界の歴史', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.1', 'world_history', 'wh.2', 2, '古代オリエントと地中海世界', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.2', 'world_history', 'wh.2', 2, '南アジア・東南アジアの古代世界', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.3', 'world_history', 'wh.2', 2, '東アジア世界の形成', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.4', 'world_history', 'wh.2', 2, '内陸アジアと諸地域の交流', 4)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.5', 'world_history', 'wh.2', 2, 'イスラーム世界の形成', 5)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.6', 'world_history', 'wh.2', 2, 'ヨーロッパ世界の形成', 6)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.1', 'world_history', 'wh.3', 2, 'イスラーム世界の拡大', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.2', 'world_history', 'wh.3', 2, '東アジアの再編', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.3', 'world_history', 'wh.3', 2, '中世ヨーロッパの変容', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.4', 'world_history', 'wh.3', 2, 'アジア諸帝国の繁栄', 4)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.5', 'world_history', 'wh.3', 2, '大航海時代とヨーロッパの拡大', 5)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.6', 'world_history', 'wh.3', 2, '近世ヨーロッパの形成', 6)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.1', 'world_history', 'wh.4', 2, '産業革命と環大西洋革命', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.2', 'world_history', 'wh.4', 2, 'ヨーロッパの再編と国民国家', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.3', 'world_history', 'wh.4', 2, 'アジア諸地域の動揺', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.4', 'world_history', 'wh.4', 2, '帝国主義と世界分割', 4)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.5', 'world_history', 'wh.4', 2, '第一次世界大戦とヴェルサイユ体制', 5)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.6', 'world_history', 'wh.4', 2, '世界恐慌と第二次世界大戦', 6)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.5.1', 'world_history', 'wh.5', 2, '冷戦と第三世界', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.5.2', 'world_history', 'wh.5', 2, '冷戦の終結と現代の課題', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.1.1', 'general_history', 'gh.1', 2, '歴史と私たち', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.1', 'general_history', 'gh.2', 2, '結び付く世界とアジアの変容', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.2', 'general_history', 'gh.2', 2, '欧米の産業革命と国民国家', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.3', 'general_history', 'gh.2', 2, '日本の開国と明治維新', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.4', 'general_history', 'gh.2', 2, '立憲体制と日清・日露戦争', 4)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.1', 'general_history', 'gh.3', 2, '第一次世界大戦と大衆社会', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.2', 'general_history', 'gh.3', 2, '大正デモクラシーと政党政治', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.3', 'general_history', 'gh.3', 2, '世界恐慌と満洲事変', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.4', 'general_history', 'gh.3', 2, '第二次世界大戦とアジア太平洋戦争', 4)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.4.1', 'general_history', 'gh.4', 2, '冷戦と日本の独立・高度経済成長', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.4.2', 'general_history', 'gh.4', 2, '冷戦終結とグローバル化', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.1.1.1', 'world_history', 'wh.1.1', 3, '人類の誕生と拡散', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.1.1.2', 'world_history', 'wh.1.1', 3, '農耕・牧畜の開始と定住', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.1.2.1', 'world_history', 'wh.1.2', 3, '生活・文化から歴史を問う', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.1.1', 'world_history', 'wh.2.1', 3, '古代オリエント世界', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.1.2', 'world_history', 'wh.2.1', 3, 'ギリシア世界', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.1.3', 'world_history', 'wh.2.1', 3, 'ローマ世界とキリスト教', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.2.1', 'world_history', 'wh.2.2', 3, '南アジアの古代文明と諸王朝', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.2.2', 'world_history', 'wh.2.2', 3, '東南アジアの諸国家', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.3.1', 'world_history', 'wh.2.3', 3, '中国の古代文明と秦漢帝国', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.3.2', 'world_history', 'wh.2.3', 3, '魏晋南北朝と隋唐帝国', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.3.3', 'world_history', 'wh.2.3', 3, '東アジア文化圏の形成', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.4.1', 'world_history', 'wh.2.4', 3, '遊牧国家とオアシス都市', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.4.2', 'world_history', 'wh.2.4', 3, '東西交易路と文化の伝播', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.5.1', 'world_history', 'wh.2.5', 3, 'イスラーム教の成立と大征服', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.5.2', 'world_history', 'wh.2.5', 3, 'イスラーム諸王朝の展開', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.6.1', 'world_history', 'wh.2.6', 3, 'ゲルマン人の移動とフランク王国', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.6.2', 'world_history', 'wh.2.6', 3, 'ビザンツ帝国とスラヴ世界', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.2.6.3', 'world_history', 'wh.2.6', 3, '封建社会とローマ=カトリック教会', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.1.1', 'world_history', 'wh.3.1', 3, 'トルコ・イラン系王朝の台頭', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.1.2', 'world_history', 'wh.3.1', 3, 'アフリカ・インド・東南アジアのイスラーム化', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.2.1', 'world_history', 'wh.3.2', 3, '宋と北方民族', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.2.2', 'world_history', 'wh.3.2', 3, 'モンゴル帝国と元', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.3.1', 'world_history', 'wh.3.3', 3, '十字軍と商業の復活', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.3.2', 'world_history', 'wh.3.3', 3, '教皇権の衰退と国家の形成', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.3.3', 'world_history', 'wh.3.3', 3, '中世文化と黒死病', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.4.1', 'world_history', 'wh.3.4', 3, '明と清の成立', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.4.2', 'world_history', 'wh.3.4', 3, 'オスマン帝国とサファヴィー朝', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.4.3', 'world_history', 'wh.3.4', 3, 'ムガル帝国', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.5.1', 'world_history', 'wh.3.5', 3, '大航海時代', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.5.2', 'world_history', 'wh.3.5', 3, 'アメリカ大陸の征服と大西洋世界', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.6.1', 'world_history', 'wh.3.6', 3, 'ルネサンス', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.6.2', 'world_history', 'wh.3.6', 3, '宗教改革', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.3.6.3', 'world_history', 'wh.3.6', 3, '主権国家体制と絶対王政', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.1.1', 'world_history', 'wh.4.1', 3, '産業革命', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.1.2', 'world_history', 'wh.4.1', 3, 'アメリカ独立革命', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.1.3', 'world_history', 'wh.4.1', 3, 'フランス革命とナポレオン', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.2.1', 'world_history', 'wh.4.2', 3, 'ウィーン体制と自由主義・ナショナリズム', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.2.2', 'world_history', 'wh.4.2', 3, 'イタリア・ドイツの統一', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.2.3', 'world_history', 'wh.4.2', 3, '19世紀の欧米社会', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.3.1', 'world_history', 'wh.4.3', 3, 'オスマン帝国とイランの改革', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.3.2', 'world_history', 'wh.4.3', 3, 'インドの植民地化', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.3.3', 'world_history', 'wh.4.3', 3, '清の動揺と東アジアの開国', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.4.1', 'world_history', 'wh.4.4', 3, '帝国主義と列強の対立', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.4.2', 'world_history', 'wh.4.4', 3, 'アフリカ・太平洋の分割', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.4.3', 'world_history', 'wh.4.4', 3, 'アジアの民族運動', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.5.1', 'world_history', 'wh.4.5', 3, '第一次世界大戦', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.5.2', 'world_history', 'wh.4.5', 3, 'ロシア革命', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.5.3', 'world_history', 'wh.4.5', 3, 'ヴェルサイユ・ワシントン体制', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.6.1', 'world_history', 'wh.4.6', 3, '世界恐慌とファシズム', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.4.6.2', 'world_history', 'wh.4.6', 3, '第二次世界大戦', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.5.1.1', 'world_history', 'wh.5.1', 3, '冷戦の始まりと東西陣営', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.5.1.2', 'world_history', 'wh.5.1', 3, 'アジア・アフリカの独立', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.5.1.3', 'world_history', 'wh.5.1', 3, '冷戦下の地域紛争', 3)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.5.2.1', 'world_history', 'wh.5.2', 3, '緊張緩和と冷戦の終結', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('wh.5.2.2', 'world_history', 'wh.5.2', 3, 'グローバル化と現代の諸課題', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.1.1.1', 'general_history', 'gh.1.1', 3, '資料から歴史を考える', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.1.1', 'general_history', 'gh.2.1', 3, '18世紀のアジアの繁栄', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.1.2', 'general_history', 'gh.2.1', 3, '大西洋三角貿易と世界の一体化', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.2.1', 'general_history', 'gh.2.2', 3, '産業革命と社会の変化', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.2.2', 'general_history', 'gh.2.2', 3, '市民革命と国民国家の形成', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.3.1', 'general_history', 'gh.2.3', 3, '開国と幕末の動乱', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.3.2', 'general_history', 'gh.2.3', 3, '明治維新と近代国家の形成', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.4.1', 'general_history', 'gh.2.4', 3, '大日本帝国憲法と初期議会', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.2.4.2', 'general_history', 'gh.2.4', 3, '日清・日露戦争と国際関係', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.1.1', 'general_history', 'gh.3.1', 3, '総力戦と国際秩序の変化', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.1.2', 'general_history', 'gh.3.1', 3, '大衆社会の到来', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.2.1', 'general_history', 'gh.3.2', 3, '政党政治の展開と社会運動', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.3.1', 'general_history', 'gh.3.3', 3, '世界恐慌の影響', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.3.2', 'general_history', 'gh.3.3', 3, '満洲事変と国際的孤立', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.4.1', 'general_history', 'gh.3.4', 3, '日中戦争の長期化', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.3.4.2', 'general_history', 'gh.3.4', 3, 'アジア太平洋戦争と戦後処理', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.4.1.1', 'general_history', 'gh.4.1', 3, '占領改革と独立の回復', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.4.1.2', 'general_history', 'gh.4.1', 3, '高度経済成長と国際社会への復帰', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.4.2.1', 'general_history', 'gh.4.2', 3, '冷戦の終結と日本', 1)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;
INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ('gh.4.2.2', 'general_history', 'gh.4.2', 3, '現代日本の課題', 2)
  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;

-- KC 60 件（承認済みのみ。未承認 197 件は含めない）
-- 作者承認制については docs/02 §5 を参照
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.orient.mesopotamia_dynasty_order', 'メソポタミアの支配者交替の順序', 'chronology', 1, -3000,
   -330, 'century', '{}'::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.orient.egypt_kingdom_periods', 'エジプト古王国・中王国・新王国の区別', 'distinction', 1, -2700,
   -1100, 'century', '{}'::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.orient.assyria_vs_achaemenid_rule', 'アッシリアとアケメネス朝の統治方法の違い', 'distinction', 1, -670,
   -330, 'century', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.orient.east_med_three_peoples', 'フェニキア人・アラム人・ヘブライ人の役割分担', 'distinction', 1, -1200,
   -600, 'century', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.orient.hammurabi_code_principle', 'ハンムラビ法典の同害復讐と身分差', 'fact', 1, -1792,
   -1750, 'exact', '{}'::text[], 1.1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rome.christianity_official_steps', 'キリスト教公認から公会議までの順序', 'chronology', 1, 313,
   451, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.greece.polis_formation_causes', 'ポリスが成立し統一国家にならなかった要因', 'causal', 1, -800,
   -500, 'century', '{}'::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.greece.athens_democracy_steps', 'アテネ民主政の改革者と改革内容の順序', 'chronology', 1, -621,
   -429, 'exact', '{}'::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.greece.athens_vs_sparta', 'アテネとスパルタの政体・軍制・社会構造の違い', 'distinction', 1, -700,
   -400, 'century', ARRAY['kc.greece.athens_democracy_steps']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.greece.persian_war_to_peloponnesian', 'ペルシア戦争の勝利がペロポネソス戦争を招いた因果', 'causal', 1, -500,
   -404, 'exact', ARRAY['kc.greece.athens_vs_sparta']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.greece.hellenistic_kingdoms_geo', 'ヘレニズム3王国の版図', 'geo', 1, -323,
   -30, 'exact', '{}'::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rome.plebeian_rights_causes', '重装歩兵としての従軍が平民の地位を高めた因果', 'causal', 1, -494,
   -287, 'exact', '{}'::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rome.gracchus_to_principate', '共和政の崩壊から元首政の成立までの因果', 'causal', 1, -133,
   -27, 'exact', ARRAY['kc.rome.plebeian_rights_causes']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rome.principate_vs_dominate', '元首政と専制君主政の違い', 'distinction', 1, -27,
   284, 'exact', ARRAY['kc.rome.gracchus_to_principate']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.india.indus_vs_aryan', 'インダス文明とアーリヤ人社会の断絶', 'distinction', 1, -2600,
   -600, 'century', '{}'::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.india.varna_jati_structure', 'ヴァルナとジャーティの関係', 'fact', 1, -1000,
   0, 'century', ARRAY['kc.india.indus_vs_aryan']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.india.new_religions_vs_brahmanism', '仏教・ジャイナ教とバラモン教の対立点', 'distinction', 1, -500,
   -400, 'century', ARRAY['kc.india.varna_jati_structure']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.india.maurya_kushana_gupta', 'マウリヤ朝・クシャーナ朝・グプタ朝の宗教政策', 'distinction', 1, -317,
   550, 'century', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.india.mahayana_vs_theravada', '大乗仏教と上座部仏教の教義と伝播経路', 'distinction', 1, 0,
   500, 'century', ARRAY['kc.india.new_religions_vs_brahmanism']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sea.indianization_causes', '季節風交易がインド文化の流入を生んだ因果', 'causal', 1, 100,
   800, 'century', '{}'::text[], 1.1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sea.port_polities_geo', '扶南・チャンパー・シュリーヴィジャヤ・アンコールの位置', 'geo', 1, 100,
   1400, 'century', ARRAY['kc.sea.indianization_causes']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sea.angkor_and_pagan', 'アンコール朝とパガン朝の信仰した宗教', 'fact', 1, 849,
   1431, 'century', ARRAY['kc.sea.port_polities_geo']::text[], 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.fengjian_vs_junxian', '周の封建制と秦の郡県制の違い', 'distinction', 1, -1046,
   -206, 'century', '{}'::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.hundred_schools_positions', '諸子百家の学派と主張の対応', 'distinction', 1, -550,
   -230, 'century', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.qin_unification_causes', '秦が中国を統一できた要因', 'causal', 1, -356,
   -221, 'exact', ARRAY['kc.china.fengjian_vs_junxian']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.qin_fall_causes', '秦が短期間で崩壊した要因', 'causal', 1, -221,
   -206, 'exact', ARRAY['kc.china.qin_unification_causes']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.han_junguo_to_junxian', '郡国制から実質的な郡県制への移行', 'causal', 1, -202,
   -141, 'exact', ARRAY['kc.china.qin_fall_causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.wudi_policies', '武帝の内政・外交政策', 'fact', 1, -141,
   -87, 'exact', ARRAY['kc.china.han_junguo_to_junxian']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.division_period_order', '黄巾の乱から南北朝までの分裂期の順序', 'chronology', 1, 184,
   589, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.northern_wei_sinicization', '孝文帝の漢化政策と均田制の導入', 'causal', 1, 485,
   494, 'exact', ARRAY['kc.china.division_period_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.tang_system_collapse', '均田制・租調庸・府兵制の崩壊が両税法・募兵制を生んだ因果', 'causal', 1, 624,
   780, 'exact', ARRAY['kc.china.northern_wei_sinicization']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.sui_vs_tang_institutions', '隋と唐の制度の連続と相違', 'distinction', 1, 581,
   907, 'exact', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.eastasia.tang_cultural_sphere', '東アジア文化圏を成り立たせた4要素', 'fact', 1, 600,
   900, 'century', ARRAY['kc.china.sui_vs_tang_institutions']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.eastasia.korea_dynasty_order', '朝鮮の王朝交替の順序', 'chronology', 1, -100,
   1392, 'century', ARRAY['kc.eastasia.tang_cultural_sphere']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.innerasia.nomad_vs_oasis', '遊牧国家とオアシス都市国家の関係', 'distinction', 1, -200,
   1200, 'century', '{}'::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.innerasia.xiongnu_and_han', '匈奴の圧力が漢の対外政策を規定した因果', 'causal', 1, -209,
   -87, 'exact', ARRAY['kc.innerasia.nomad_vs_oasis']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.innerasia.turk_and_uighur', '突厥・ウイグルと唐の関係', 'fact', 1, 552,
   840, 'exact', ARRAY['kc.innerasia.xiongnu_and_han']::text[], 1.1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.trade.three_routes_geo', 'オアシスの道・草原の道・海の道の経路', 'geo', 1, -100,
   1500, 'century', '{}'::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.trade.sogdian_role', 'ソグド人の交易と文化仲介', 'fact', 1, 400,
   800, 'century', ARRAY['kc.trade.three_routes_geo']::text[], 1.1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.trade.buddhism_transmission_order', '仏教がインドから日本へ伝わった順序', 'chronology', 1, -100,
   538, 'century', ARRAY['kc.india.mahayana_vs_theravada']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.hijra_and_umma', 'ヒジュラとウンマの成立', 'fact', 1, 622,
   622, 'exact', '{}'::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.rashidun_vs_umayyad_succession', '正統カリフ時代とウマイヤ朝のカリフ選出方法の違い', 'distinction', 1, 632,
   750, 'exact', ARRAY['kc.islam.hijra_and_umma']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.sunni_vs_shia_origin', 'スンナ派とシーア派が分かれた原因', 'causal', 1, 656,
   680, 'exact', ARRAY['kc.islam.rashidun_vs_umayyad_succession']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.arab_conquest_causes', '大征服が短期間で成功した要因', 'causal', 1, 634,
   750, 'exact', ARRAY['kc.islam.hijra_and_umma']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.umayyad_vs_abbasid', 'ウマイヤ朝とアッバース朝の支配原理の違い', 'distinction', 1, 661,
   1258, 'exact', ARRAY['kc.islam.rashidun_vs_umayyad_succession']::text[], 1.8)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.abbasid_decline_order', 'アッバース朝の実権喪失からスルタンの出現までの順序', 'chronology', 1, 945,
   1055, 'exact', ARRAY['kc.islam.umayyad_vs_abbasid']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.three_caliphates_geo', '10世紀に3人のカリフが並立した位置', 'geo', 1, 909,
   1031, 'exact', ARRAY['kc.islam.umayyad_vs_abbasid']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.fatimid_vs_ayyubid', 'ファーティマ朝とアイユーブ朝の宗派の違い', 'distinction', 1, 909,
   1250, 'exact', ARRAY['kc.islam.three_caliphates_geo']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.iqta_system', 'イクター制の内容と開始時期', 'fact', 1, 946,
   1200, 'century', ARRAY['kc.islam.abbasid_decline_order']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islam.transmission_to_europe', 'イスラーム経由でギリシア古典がヨーロッパへ再流入した因果', 'causal', 1, 1085,
   1200, 'century', '{}'::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.germanic_migration_causes', 'ゲルマン人の大移動を引き起こした要因', 'causal', 1, 375,
   476, 'exact', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.frank_conversion_significance', 'クローヴィスの改宗が持った意味', 'causal', 1, 496,
   496, 'exact', ARRAY['kc.euro.germanic_migration_causes']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.carolingian_coronation_meaning', 'カールの戴冠が意味したもの', 'causal', 1, 800,
   800, 'exact', ARRAY['kc.euro.frank_conversion_significance']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.verdun_and_mersen', 'ヴェルダン条約とメルセン条約の結果', 'chronology', 1, 843,
   870, 'exact', ARRAY['kc.euro.carolingian_coronation_meaning']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.orthodox_vs_catholic', 'ギリシア正教とローマ=カトリックの違い', 'distinction', 1, 726,
   1054, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.byzantine_institutions', 'ビザンツ帝国の軍管区制と屯田兵制', 'fact', 1, 610,
   1071, 'century', ARRAY['kc.euro.orthodox_vs_catholic']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.slav_division_geo', '東・西・南スラヴの分布と受容した宗派', 'geo', 1, 800,
   1200, 'century', ARRAY['kc.euro.orthodox_vs_catholic']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.feudal_two_layers', '封建的主従関係と荘園制の違い', 'distinction', 1, 800,
   1300, 'century', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.investiture_controversy', '聖職叙任権闘争の経緯と決着', 'causal', 1, 1075,
   1122, 'exact', ARRAY['kc.euro.feudal_two_layers']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.agricultural_growth_effects', '農業技術の普及が中世の拡大を支えた因果', 'causal', 1, 1000,
   1300, 'century', ARRAY['kc.euro.feudal_two_layers']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;

-- KC と節の対応
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.orient.mesopotamia_dynasty_order', 'wh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.orient.egypt_kingdom_periods', 'wh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.orient.assyria_vs_achaemenid_rule', 'wh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.orient.east_med_three_peoples', 'wh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.orient.hammurabi_code_principle', 'wh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rome.christianity_official_steps', 'wh.2.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.greece.polis_formation_causes', 'wh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.greece.athens_democracy_steps', 'wh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.greece.athens_vs_sparta', 'wh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.greece.persian_war_to_peloponnesian', 'wh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.greece.hellenistic_kingdoms_geo', 'wh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rome.plebeian_rights_causes', 'wh.2.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rome.gracchus_to_principate', 'wh.2.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rome.principate_vs_dominate', 'wh.2.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.india.indus_vs_aryan', 'wh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.india.varna_jati_structure', 'wh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.india.new_religions_vs_brahmanism', 'wh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.india.maurya_kushana_gupta', 'wh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.india.mahayana_vs_theravada', 'wh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sea.indianization_causes', 'wh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sea.port_polities_geo', 'wh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sea.angkor_and_pagan', 'wh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.fengjian_vs_junxian', 'wh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.hundred_schools_positions', 'wh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.qin_unification_causes', 'wh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.qin_fall_causes', 'wh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.han_junguo_to_junxian', 'wh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.wudi_policies', 'wh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.division_period_order', 'wh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.northern_wei_sinicization', 'wh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.tang_system_collapse', 'wh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.sui_vs_tang_institutions', 'wh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.eastasia.tang_cultural_sphere', 'wh.2.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.eastasia.korea_dynasty_order', 'wh.2.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.innerasia.nomad_vs_oasis', 'wh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.innerasia.xiongnu_and_han', 'wh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.innerasia.turk_and_uighur', 'wh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.trade.three_routes_geo', 'wh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.trade.sogdian_role', 'wh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.trade.buddhism_transmission_order', 'wh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.hijra_and_umma', 'wh.2.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.rashidun_vs_umayyad_succession', 'wh.2.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.sunni_vs_shia_origin', 'wh.2.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.arab_conquest_causes', 'wh.2.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.umayyad_vs_abbasid', 'wh.2.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.abbasid_decline_order', 'wh.2.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.three_caliphates_geo', 'wh.2.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.fatimid_vs_ayyubid', 'wh.2.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.iqta_system', 'wh.2.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islam.transmission_to_europe', 'wh.2.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.germanic_migration_causes', 'wh.2.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.frank_conversion_significance', 'wh.2.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.carolingian_coronation_meaning', 'wh.2.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.verdun_and_mersen', 'wh.2.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.orthodox_vs_catholic', 'wh.2.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.byzantine_institutions', 'wh.2.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.slav_division_geo', 'wh.2.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.feudal_two_layers', 'wh.2.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.investiture_controversy', 'wh.2.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.agricultural_growth_effects', 'wh.2.6.3') ON CONFLICT DO NOTHING;

-- KC と地域の対応（primary は1件だけ。kc_region_one_primary が保証する）
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.orient.mesopotamia_dynasty_order', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.orient.egypt_kingdom_periods', 14, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.orient.assyria_vs_achaemenid_rule', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.orient.east_med_three_peoples', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.orient.hammurabi_code_principle', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rome.christianity_official_steps', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rome.christianity_official_steps', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.greece.polis_formation_causes', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.greece.athens_democracy_steps', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.greece.athens_vs_sparta', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.greece.persian_war_to_peloponnesian', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.greece.persian_war_to_peloponnesian', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.greece.hellenistic_kingdoms_geo', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.greece.hellenistic_kingdoms_geo', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.greece.hellenistic_kingdoms_geo', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rome.plebeian_rights_causes', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rome.gracchus_to_principate', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rome.principate_vs_dominate', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.india.indus_vs_aryan', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.india.varna_jati_structure', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.india.new_religions_vs_brahmanism', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.india.maurya_kushana_gupta', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.india.mahayana_vs_theravada', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.india.mahayana_vs_theravada', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.india.mahayana_vs_theravada', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sea.indianization_causes', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sea.indianization_causes', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sea.port_polities_geo', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sea.angkor_and_pagan', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.fengjian_vs_junxian', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.hundred_schools_positions', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.qin_unification_causes', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.qin_fall_causes', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.han_junguo_to_junxian', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.wudi_policies', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.wudi_policies', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.wudi_policies', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.division_period_order', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.northern_wei_sinicization', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.tang_system_collapse', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.sui_vs_tang_institutions', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.tang_cultural_sphere', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.tang_cultural_sphere', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.tang_cultural_sphere', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.korea_dynasty_order', 23, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.korea_dynasty_order', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.nomad_vs_oasis', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.nomad_vs_oasis', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.xiongnu_and_han', 20, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.xiongnu_and_han', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.turk_and_uighur', 20, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.turk_and_uighur', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.three_routes_geo', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.three_routes_geo', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.three_routes_geo', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.sogdian_role', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.sogdian_role', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.buddhism_transmission_order', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.buddhism_transmission_order', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.buddhism_transmission_order', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.buddhism_transmission_order', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.hijra_and_umma', 12, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.rashidun_vs_umayyad_succession', 12, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.sunni_vs_shia_origin', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.sunni_vs_shia_origin', 12, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.arab_conquest_causes', 12, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.arab_conquest_causes', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.arab_conquest_causes', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.umayyad_vs_abbasid', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.umayyad_vs_abbasid', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.abbasid_decline_order', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.three_caliphates_geo', 14, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.three_caliphates_geo', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.three_caliphates_geo', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.fatimid_vs_ayyubid', 14, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.iqta_system', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.transmission_to_europe', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.transmission_to_europe', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islam.transmission_to_europe', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.germanic_migration_causes', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.germanic_migration_causes', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.frank_conversion_significance', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.carolingian_coronation_meaning', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.carolingian_coronation_meaning', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.verdun_and_mersen', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.orthodox_vs_catholic', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.orthodox_vs_catholic', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.byzantine_institutions', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.slav_division_geo', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.feudal_two_layers', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.investiture_controversy', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.investiture_controversy', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.agricultural_growth_effects', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;

COMMIT;

-- 確認用
-- SELECT (SELECT count(*) FROM era) AS era, (SELECT count(*) FROM region) AS region,
--        (SELECT count(*) FROM syllabus_unit) AS unit, (SELECT count(*) FROM kc) AS kc,
--        (SELECT count(*) FROM kc_region) AS kc_region;
-- 期待値: era=3 region=24 unit=117 kc=60 kc_region=93
