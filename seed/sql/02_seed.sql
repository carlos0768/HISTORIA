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

-- KC 408 件（承認済みのみ。未承認 0 件は含めない）
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
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.prehist.hominid_stages', '猿人・原人・旧人・新人の区別', 'distinction', 1, NULL,
   NULL, 'unknown', '{}'::text[], 0.9)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.prehist.human_dispersal_geo', '新人がアフリカから拡散した経路', 'geo', 1, NULL,
   NULL, 'unknown', ARRAY['kc.prehist.hominid_stages']::text[], 0.8)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.prehist.bipedalism_effects', '直立二足歩行が人類にもたらした変化', 'causal', 1, NULL,
   NULL, 'unknown', '{}'::text[], 0.8)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.prehist.fire_burial_art', '火の使用・埋葬・洞穴絵画の担い手', 'fact', 1, NULL,
   NULL, 'unknown', ARRAY['kc.prehist.hominid_stages']::text[], 0.8)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.prehist.stone_age_division', '旧石器・中石器・新石器の区分基準', 'distinction', 1, NULL,
   NULL, 'unknown', '{}'::text[], 0.8)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.neolithic.food_production_causes', '獲得経済から生産経済へ転換した要因', 'causal', 1, -9000,
   -8000, 'century', '{}'::text[], 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.neolithic.neolithic_toolkit', '新石器時代を特徴づける道具', 'fact', 1, -9000,
   -3000, 'century', ARRAY['kc.prehist.stone_age_division']::text[], 0.9)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.neolithic.fertile_crescent_geo', '農耕の起源地とその伝播', 'geo', 1, -9000,
   -4000, 'century', ARRAY['kc.neolithic.food_production_causes']::text[], 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.neolithic.irrigation_to_state', '灌漑農業が階級と国家を生んだ因果', 'causal', 1, -4000,
   -3000, 'century', ARRAY['kc.neolithic.food_production_causes']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.neolithic.metal_age_order', '石器から青銅器・鉄器へ移る順序', 'chronology', 1, -3000,
   -1200, 'century', ARRAY['kc.neolithic.neolithic_toolkit']::text[], 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.source.primary_vs_secondary', '一次史料と二次史料の区別', 'distinction', 1, NULL,
   NULL, 'unknown', '{}'::text[], 0.8)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.source.material_vs_written', '文字史料と考古資料でわかることの違い', 'distinction', 1, NULL,
   NULL, 'unknown', ARRAY['kc.source.primary_vs_secondary']::text[], 0.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.source.bias_in_records', '記録が残る側に偏る理由', 'causal', 1, NULL,
   NULL, 'unknown', ARRAY['kc.source.primary_vs_secondary']::text[], 0.8)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.source.periodization_problem', '時代区分が地域ごとに一致しないこと', 'distinction', 1, NULL,
   NULL, 'unknown', '{}'::text[], 0.9)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.turkiran.samanid_to_ghaznavid', 'イラン系・トルコ系王朝の交替順序', 'chronology', 1, 875,
   1187, 'exact', ARRAY['kc.islam.abbasid_decline_order']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.turkiran.turkification_causes', '中央アジアがトルコ化・イスラーム化した要因', 'causal', 1, 840,
   1000, 'century', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.turkiran.seljuk_sultanate', 'セルジューク朝がスルタン位を得た経緯', 'fact', 1, 1038,
   1157, 'exact', ARRAY['kc.islam.abbasid_decline_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.turkiran.mamluk_and_iqta', 'マムルークとイクター制の結びつき', 'distinction', 1, 946,
   1250, 'century', ARRAY['kc.islam.iqta_system']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.turkiran.anatolia_turkification_geo', 'トルコ系勢力がアナトリアへ進出した範囲', 'geo', 1, 1071,
   1300, 'exact', ARRAY['kc.turkiran.seljuk_sultanate']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.turkiran.ghaznavid_india_causes', 'ガズナ朝の侵入が北インドに与えた影響', 'causal', 1, 998,
   1206, 'exact', ARRAY['kc.turkiran.samanid_to_ghaznavid']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islamize.delhi_sultanate_order', 'デリー=スルタン朝5王朝の順序', 'chronology', 1, 1206,
   1526, 'exact', ARRAY['kc.turkiran.ghaznavid_india_causes']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islamize.bhakti_and_sufism', 'インドでイスラームが民衆に定着した経路', 'causal', 1, 1200,
   1600, 'century', ARRAY['kc.islamize.delhi_sultanate_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islamize.sea_route_islam_geo', '東南アジアがイスラーム化した順序と範囲', 'geo', 1, 1290,
   1600, 'century', ARRAY['kc.sea.port_polities_geo']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islamize.west_africa_states', 'ガーナ・マリ・ソンガイ王国の違い', 'distinction', 1, 700,
   1591, 'century', '{}'::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islamize.swahili_coast_geo', '東アフリカ海岸の海港都市の位置', 'geo', 1, 1000,
   1500, 'century', '{}'::text[], 1.1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.islamize.sufi_role', 'スーフィーが布教で果たした役割', 'fact', 1, 1100,
   1600, 'century', ARRAY['kc.islamize.bhakti_and_sufism']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.song.civil_supremacy_causes', '文治主義が軍事的弱体を招いた因果', 'causal', 1, 960,
   1127, 'exact', ARRAY['kc.china.tang_system_collapse']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.song.northern_peoples', '遼・西夏・金の民族と文字', 'distinction', 1, 916,
   1234, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.song.wang_anshi_reform', '王安石の新法の内容と挫折', 'fact', 1, 1069,
   1085, 'exact', ARRAY['kc.song.civil_supremacy_causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.song.north_to_south_geo', '北宋と南宋の領域の違い', 'geo', 1, 960,
   1279, 'exact', ARRAY['kc.song.northern_peoples']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.song.economic_revolution', '江南の開発と商業の発展が生んだ変化', 'causal', 1, 960,
   1279, 'century', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.song.scholar_officials', '士大夫と門閥貴族の違い', 'distinction', 1, 960,
   1279, 'century', ARRAY['kc.song.civil_supremacy_causes']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mongol.expansion_order', 'モンゴルの征服とウルス成立の順序', 'chronology', 1, 1206,
   1279, 'exact', '{}'::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mongol.four_khanates_geo', '4ハン国の位置', 'geo', 1, 1240,
   1502, 'exact', ARRAY['kc.mongol.expansion_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mongol.yuan_hierarchy', '元の身分序列', 'fact', 1, 1271,
   1368, 'exact', ARRAY['kc.mongol.expansion_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mongol.pax_mongolica', 'ユーラシアの東西交流が活発化した要因', 'causal', 1, 1240,
   1350, 'century', ARRAY['kc.mongol.four_khanates_geo']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mongol.yuan_fall_causes', '元が短期間で中国から退いた要因', 'causal', 1, 1351,
   1368, 'exact', ARRAY['kc.mongol.yuan_hierarchy']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mongol.khanate_religion', 'イル=ハン国とキプチャク=ハン国の宗教的帰結', 'distinction', 1, 1258,
   1502, 'century', ARRAY['kc.mongol.four_khanates_geo']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.crusade.first_crusade_causes', '十字軍が起こされた要因', 'causal', 1, 1071,
   1099, 'exact', ARRAY['kc.euro.agricultural_growth_effects']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.crusade.expedition_order', '主要な十字軍の回次と結果', 'chronology', 1, 1096,
   1291, 'exact', ARRAY['kc.crusade.first_crusade_causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.crusade.consequences', '十字軍が結果として変えたもの', 'causal', 1, 1096,
   1300, 'century', ARRAY['kc.crusade.expedition_order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.crusade.two_trade_zones', '地中海商業圏と北ヨーロッパ商業圏の違い', 'distinction', 1, 1100,
   1400, 'century', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.crusade.trade_routes_geo', '東方貿易と内陸交易路の結節点', 'geo', 1, 1100,
   1400, 'century', ARRAY['kc.crusade.two_trade_zones']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.crusade.manor_decline', '貨幣経済の浸透が荘園制を崩した因果', 'causal', 1, 1200,
   1400, 'century', ARRAY['kc.euro.feudal_two_layers']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medstate.papal_decline_order', '教皇権の絶頂から衰退までの順序', 'chronology', 1, 1198,
   1417, 'exact', ARRAY['kc.euro.investiture_controversy']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medstate.parliament_vs_etats', 'イギリス議会とフランス三部会の違い', 'distinction', 1, 1265,
   1302, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medstate.hundred_years_war', '百年戦争が両国の王権を強めた因果', 'causal', 1, 1339,
   1453, 'exact', ARRAY['kc.medstate.parliament_vs_etats']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medstate.hre_vs_france', '神聖ローマ帝国とフランス王権の集権度の違い', 'distinction', 1, 1250,
   1500, 'century', ARRAY['kc.medstate.hundred_years_war']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medstate.europe_1500_geo', '15世紀末のヨーロッパ主要国の版図', 'geo', 1, 1450,
   1500, 'century', ARRAY['kc.medstate.hre_vs_france']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medstate.reconquista', 'レコンキスタがスペイン王国を生んだ因果', 'causal', 1, 1085,
   1492, 'exact', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medcult.black_death_effects', '黒死病が社会構造を変えた因果', 'causal', 1, 1347,
   1400, 'exact', ARRAY['kc.crusade.manor_decline']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medcult.realism_vs_nominalism', 'スコラ学の実在論と唯名論', 'distinction', 1, 1100,
   1350, 'century', '{}'::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medcult.medieval_universities', '中世大学の成立と得意分野', 'fact', 1, 1088,
   1300, 'century', ARRAY['kc.medcult.realism_vs_nominalism']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medcult.romanesque_vs_gothic', 'ロマネスクとゴシックの違い', 'distinction', 1, 1000,
   1400, 'century', '{}'::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medcult.wyclif_and_hus', '教会批判が宗教改革の先駆となった経緯', 'causal', 1, 1376,
   1415, 'exact', ARRAY['kc.medstate.papal_decline_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mingqing.ming_vs_qing_rule', '明と清の中国支配の方法の違い', 'distinction', 2, 1368,
   1912, 'exact', '{}'::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mingqing.haijin_and_tribute', '明の海禁と朝貢体制', 'fact', 2, 1368,
   1567, 'exact', ARRAY['kc.mingqing.ming_vs_qing_rule']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mingqing.tax_silver_reform', '一条鞭法と地丁銀が生まれた因果', 'causal', 2, 1581,
   1717, 'exact', ARRAY['kc.mingqing.haijin_and_tribute']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mingqing.ming_fall_order', '明の滅亡から清の支配確立までの順序', 'chronology', 2, 1616,
   1683, 'exact', ARRAY['kc.mingqing.ming_vs_qing_rule']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mingqing.qing_territory_geo', '清の最大版図と藩部', 'geo', 2, 1683,
   1759, 'exact', ARRAY['kc.mingqing.ming_fall_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mingqing.new_crops_population', '明清期の人口増加を支えた要因', 'causal', 2, 1550,
   1800, 'century', ARRAY['kc.mingqing.tax_silver_reform']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ottoman.expansion_order', 'オスマン帝国が拡大した順序', 'chronology', 2, 1299,
   1683, 'exact', '{}'::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ottoman.devshirme_and_timar', 'オスマン帝国の支配制度', 'fact', 2, 1400,
   1600, 'century', ARRAY['kc.ottoman.expansion_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ottoman.millet_system', 'ミッレト制とジズヤの関係', 'distinction', 2, 1450,
   1800, 'century', ARRAY['kc.ottoman.devshirme_and_timar']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ottoman.sunni_vs_shia_states', 'オスマン朝とサファヴィー朝の宗派の対立', 'distinction', 2, 1501,
   1736, 'exact', ARRAY['kc.islam.sunni_vs_shia_origin']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ottoman.three_empires_geo', '3イスラーム帝国の版図', 'geo', 2, 1500,
   1700, 'century', ARRAY['kc.ottoman.sunni_vs_shia_states']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ottoman.mediterranean_decline', '地中海商業圏の地位が下がった要因', 'causal', 2, 1500,
   1600, 'century', ARRAY['kc.ottoman.expansion_order']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mughal.emperor_order', 'ムガル帝国の皇帝と政策の順序', 'chronology', 2, 1526,
   1707, 'exact', ARRAY['kc.islamize.delhi_sultanate_order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mughal.akbar_vs_aurangzeb', 'アクバルとアウラングゼーブの宗教政策の違い', 'distinction', 2, 1556,
   1707, 'exact', ARRAY['kc.mughal.emperor_order']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mughal.mansabdar', 'マンサブダール制の内容', 'fact', 2, 1571,
   1707, 'century', ARRAY['kc.mughal.emperor_order']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mughal.decline_causes', 'ムガル帝国が解体した要因', 'causal', 2, 1707,
   1764, 'exact', ARRAY['kc.mughal.akbar_vs_aurangzeb']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.mughal.indo_islamic_culture', 'インド=イスラーム文化の融合の表れ', 'distinction', 2, 1526,
   1707, 'century', ARRAY['kc.mughal.emperor_order']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.voyage.motives', 'ヨーロッパが海へ出た要因', 'causal', 2, 1415,
   1498, 'exact', ARRAY['kc.ottoman.mediterranean_decline']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.voyage.two_routes_geo', 'ポルトガルとスペインの航路の違い', 'geo', 2, 1488,
   1522, 'exact', ARRAY['kc.voyage.motives']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.voyage.tordesillas', 'トルデシリャス条約の内容', 'fact', 2, 1494,
   1529, 'exact', ARRAY['kc.voyage.two_routes_geo']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.voyage.commercial_revolution', '商業革命と価格革命が起きた因果', 'causal', 2, 1500,
   1600, 'century', ARRAY['kc.voyage.two_routes_geo']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.voyage.east_india_companies', '各国の東インド会社の違い', 'distinction', 2, 1600,
   1799, 'exact', ARRAY['kc.voyage.commercial_revolution']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.voyage.gutsherrschaft', '東欧で農場領主制が強まった因果', 'causal', 2, 1500,
   1700, 'century', ARRAY['kc.voyage.commercial_revolution']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.atlantic.three_civilizations', 'アステカ・インカ・マヤの違い', 'distinction', 2, 300,
   1533, 'century', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.atlantic.conquest_order', 'アメリカ大陸征服の順序', 'chronology', 2, 1492,
   1533, 'exact', ARRAY['kc.atlantic.three_civilizations']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.atlantic.conquest_causes', '少数の征服者が大帝国を倒せた要因', 'causal', 2, 1519,
   1533, 'exact', ARRAY['kc.atlantic.conquest_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.atlantic.encomienda', 'エンコミエンダ制とアシエンダ制', 'fact', 2, 1503,
   1700, 'century', ARRAY['kc.atlantic.conquest_causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.atlantic.triangular_trade_geo', '大西洋三角貿易の三辺', 'geo', 2, 1600,
   1800, 'century', ARRAY['kc.atlantic.encomienda']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.atlantic.columbian_exchange', '新旧大陸の作物と病原体の交換が生んだ影響', 'causal', 2, 1500,
   1800, 'century', ARRAY['kc.atlantic.triangular_trade_geo']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.renaissance.why_italy', 'ルネサンスがイタリアで始まった要因', 'causal', 2, 1300,
   1450, 'century', ARRAY['kc.crusade.two_trade_zones']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.renaissance.humanism', '人文主義とスコラ学の違い', 'distinction', 2, 1350,
   1550, 'century', ARRAY['kc.medcult.realism_vs_nominalism']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.renaissance.three_inventions', '三大発明の改良と影響', 'fact', 2, 1450,
   1500, 'century', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.renaissance.northern', '各国のルネサンスの担い手', 'distinction', 2, 1450,
   1600, 'century', ARRAY['kc.renaissance.humanism']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.renaissance.printing_effects', '活版印刷が社会を変えた因果', 'causal', 2, 1450,
   1550, 'century', ARRAY['kc.renaissance.three_inventions']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.reformation.luther_causes', 'ルターが教会を批判した理由', 'causal', 2, 1517,
   1521, 'exact', ARRAY['kc.medcult.wyclif_and_hus']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.reformation.luther_vs_calvin', 'ルター派とカルヴァン派の違い', 'distinction', 2, 1517,
   1560, 'exact', ARRAY['kc.reformation.luther_causes']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.reformation.settlement_order', '宗教改革が政治的に決着する順序', 'chronology', 2, 1521,
   1648, 'exact', ARRAY['kc.reformation.luther_vs_calvin']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.reformation.anglican', 'イギリス国教会の成立の特殊性', 'distinction', 2, 1534,
   1559, 'exact', ARRAY['kc.reformation.luther_vs_calvin']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.reformation.counter_reformation', '対抗宗教改革が生んだもの', 'causal', 2, 1534,
   1563, 'exact', ARRAY['kc.reformation.luther_causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.reformation.wars_to_state', '宗教戦争が主権国家を用意した因果', 'causal', 2, 1562,
   1648, 'exact', ARRAY['kc.reformation.settlement_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.absolutism.sovereign_state', '主権国家体制と中世の秩序の違い', 'distinction', 2, 1648,
   1700, 'exact', ARRAY['kc.reformation.wars_to_state']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.absolutism.machinery', '絶対王政を支えた仕組み', 'fact', 2, 1600,
   1750, 'century', ARRAY['kc.absolutism.sovereign_state']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.absolutism.mercantilism_types', '重商主義の2つの型', 'distinction', 2, 1500,
   1700, 'century', ARRAY['kc.absolutism.machinery']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.absolutism.hegemony_order', 'ヨーロッパの覇権が移った順序', 'chronology', 2, 1580,
   1763, 'exact', ARRAY['kc.absolutism.mercantilism_types']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.absolutism.english_revolution', 'イギリスで議会が王権に勝った因果', 'causal', 2, 1628,
   1689, 'exact', ARRAY['kc.absolutism.machinery']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.absolutism.europe_1700_geo', '18世紀初頭のヨーロッパ列強の版図', 'geo', 2, 1683,
   1721, 'exact', ARRAY['kc.absolutism.hegemony_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.industrial.why_britain', '産業革命がイギリスで最初に起きた要因', 'causal', 2, 1700,
   1760, 'century', '{}'::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.industrial.textile_inventions', '綿工業の技術革新の順序', 'chronology', 2, 1733,
   1785, 'exact', ARRAY['kc.industrial.why_britain']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.industrial.steam_to_transport', '蒸気機関が交通革命を生んだ因果', 'causal', 2, 1769,
   1830, 'exact', ARRAY['kc.industrial.textile_inventions']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.industrial.social_change', '産業革命前後の社会構造の違い', 'distinction', 2, 1760,
   1850, 'century', ARRAY['kc.industrial.steam_to_transport']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.industrial.regions_geo', 'イギリスの工業地帯の位置', 'geo', 2, 1760,
   1850, 'century', ARRAY['kc.industrial.textile_inventions']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.industrial.labour_to_socialism', '労働問題から社会主義が生まれた因果', 'causal', 2, 1811,
   1848, 'exact', ARRAY['kc.industrial.social_change']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.usrev.causes', '本国との対立が深まった要因', 'causal', 2, 1763,
   1775, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.usrev.war_order', '独立戦争の経過', 'chronology', 2, 1773,
   1783, 'exact', ARRAY['kc.usrev.causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.usrev.declaration_vs_constitution', '独立宣言と合衆国憲法の性格の違い', 'distinction', 2, 1776,
   1788, 'exact', ARRAY['kc.usrev.war_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.usrev.world_impact', '独立が世界に与えた影響', 'causal', 2, 1776,
   1810, 'exact', ARRAY['kc.usrev.declaration_vs_constitution']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.usrev.foreign_support', '独立を助けた外国の動き', 'fact', 2, 1777,
   1783, 'exact', ARRAY['kc.usrev.war_order']::text[], 1.1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.frrev.causes', 'フランス革命が起きた要因', 'causal', 2, 1774,
   1789, 'exact', ARRAY['kc.usrev.world_impact']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.frrev.stages_order', '革命の段階と主導勢力の順序', 'chronology', 2, 1789,
   1799, 'exact', ARRAY['kc.frrev.causes']::text[], 1.8)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.frrev.declaration_vs_code', '人権宣言とナポレオン法典の違い', 'distinction', 2, 1789,
   1804, 'exact', ARRAY['kc.frrev.stages_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.frrev.terror_causes', '恐怖政治が生まれた因果', 'causal', 2, 1792,
   1794, 'exact', ARRAY['kc.frrev.stages_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.frrev.napoleonic_europe_geo', 'ナポレオン支配下のヨーロッパ', 'geo', 2, 1804,
   1812, 'exact', ARRAY['kc.frrev.declaration_vs_code']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.frrev.napoleon_fall', 'ナポレオンが没落した要因', 'causal', 2, 1806,
   1815, 'exact', ARRAY['kc.frrev.napoleonic_europe_geo']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.vienna.principles', '正統主義と勢力均衡の違い', 'distinction', 2, 1814,
   1815, 'exact', ARRAY['kc.frrev.napoleon_fall']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.vienna.map_1815_geo', 'ウィーン議定書後のヨーロッパの版図', 'geo', 2, 1815,
   1830, 'exact', ARRAY['kc.vienna.principles']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.vienna.liberal_movements_order', '自由主義運動が起きた順序', 'chronology', 2, 1820,
   1848, 'exact', ARRAY['kc.vienna.principles']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.vienna.1848_spread', '二月革命がヨーロッパへ波及した因果', 'causal', 2, 1848,
   1849, 'exact', ARRAY['kc.vienna.liberal_movements_order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.vienna.latin_america', 'ラテンアメリカ諸国が独立できた要因', 'causal', 2, 1804,
   1826, 'exact', ARRAY['kc.usrev.world_impact']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.vienna.british_reforms', 'イギリスの自由主義的改革の内容', 'distinction', 2, 1828,
   1846, 'exact', ARRAY['kc.vienna.liberal_movements_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.unification.italy_vs_germany', 'イタリア統一とドイツ統一の主導勢力の違い', 'distinction', 2, 1859,
   1871, 'exact', ARRAY['kc.vienna.1848_spread']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.unification.three_wars', 'ドイツ統一の3戦争の順序', 'chronology', 2, 1864,
   1871, 'exact', ARRAY['kc.unification.italy_vs_germany']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.unification.garibaldi', 'ガリバルディの南部併合が統一を早めた因果', 'causal', 2, 1860,
   1861, 'exact', ARRAY['kc.unification.italy_vs_germany']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.unification.irredenta_geo', '統一後に残った未回収の地', 'geo', 2, 1866,
   1919, 'exact', ARRAY['kc.unification.garibaldi']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.unification.bismarck_system', 'ビスマルク外交がフランスを孤立させた因果', 'causal', 2, 1873,
   1890, 'exact', ARRAY['kc.unification.three_wars']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.c19soc.us_expansion_order', 'アメリカの領土拡大の順序', 'chronology', 2, 1803,
   1867, 'exact', '{}'::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.c19soc.civil_war_causes', '南北戦争が起きた要因', 'causal', 2, 1820,
   1861, 'exact', ARRAY['kc.c19soc.us_expansion_order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.c19soc.north_vs_south', '北部と南部の経済構造の違い', 'distinction', 2, 1800,
   1865, 'century', ARRAY['kc.c19soc.civil_war_causes']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.c19soc.russian_reform', 'ロシアで農奴解放が行われた因果', 'causal', 2, 1853,
   1881, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.c19soc.science_and_thought', '19世紀の科学と思想', 'fact', 2, 1830,
   1900, 'century', ARRAY['kc.industrial.labour_to_socialism']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.c19soc.migration_geo', '19世紀後半の移民の流れ', 'geo', 2, 1840,
   1900, 'century', ARRAY['kc.c19soc.north_vs_south']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.westasia19.reform_order', 'オスマン帝国の改革の順序', 'chronology', 2, 1839,
   1908, 'exact', ARRAY['kc.ottoman.expansion_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.westasia19.eastern_question', '東方問題が列強の介入を招いた因果', 'causal', 2, 1821,
   1878, 'exact', ARRAY['kc.westasia19.reform_order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.westasia19.balkan_geo', 'バルカン半島の民族と国家の分布', 'geo', 2, 1878,
   1913, 'exact', ARRAY['kc.westasia19.eastern_question']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.westasia19.egypt_vs_iran', 'エジプトとイランの半植民地化の違い', 'distinction', 2, 1805,
   1907, 'exact', ARRAY['kc.westasia19.eastern_question']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.westasia19.islamic_revival', 'ワッハーブ運動とパン=イスラーム主義の違い', 'causal', 2, 1744,
   1897, 'exact', ARRAY['kc.westasia19.reform_order']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indiacol.conquest_order', 'イギリスがインドを支配する過程の順序', 'chronology', 2, 1757,
   1858, 'exact', ARRAY['kc.mughal.decline_causes']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indiacol.sepoy_mutiny', 'シパーヒーの反乱が体制を変えた因果', 'causal', 2, 1857,
   1877, 'exact', ARRAY['kc.indiacol.conquest_order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indiacol.zamindari_vs_ryotwari', '地税制度の2つの型', 'distinction', 2, 1793,
   1820, 'exact', ARRAY['kc.indiacol.conquest_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indiacol.deindustrialization', 'インドが原料供給地に変えられた因果', 'causal', 2, 1813,
   1900, 'century', ARRAY['kc.indiacol.zamindari_vs_ryotwari']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indiacol.congress_shift', 'インド国民会議の性格の変化', 'fact', 2, 1885,
   1906, 'exact', ARRAY['kc.indiacol.sepoy_mutiny']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.qingfall.opium_war_causes', 'アヘン戦争が起きた要因', 'causal', 2, 1793,
   1842, 'exact', ARRAY['kc.mingqing.qing_territory_geo']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.qingfall.unequal_treaties', '不平等条約が積み重なる順序', 'chronology', 2, 1842,
   1860, 'exact', ARRAY['kc.qingfall.opium_war_causes']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.qingfall.taiping', '太平天国の乱が清を変質させた因果', 'causal', 2, 1851,
   1864, 'exact', ARRAY['kc.qingfall.unequal_treaties']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.qingfall.yangwu_vs_meiji', '洋務運動と明治維新の違い', 'distinction', 2, 1861,
   1895, 'exact', ARRAY['kc.qingfall.taiping']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.qingfall.spheres_geo', '列強の中国分割と勢力範囲', 'geo', 2, 1895,
   1900, 'exact', ARRAY['kc.qingfall.yangwu_vs_meiji']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.qingfall.opening_chain', '東アジアの開国が連鎖した因果', 'causal', 2, 1842,
   1876, 'exact', ARRAY['kc.qingfall.unequal_treaties']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.imperialism.causes', '帝国主義が生まれた要因', 'causal', 2, 1873,
   1900, 'exact', ARRAY['kc.industrial.labour_to_socialism']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.imperialism.second_industrial', '第1次産業革命と第2次産業革命の違い', 'distinction', 2, 1870,
   1900, 'century', ARRAY['kc.imperialism.causes']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.imperialism.alliance_order', '三国同盟と三国協商が固まる順序', 'chronology', 2, 1882,
   1907, 'exact', ARRAY['kc.unification.bismarck_system']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.imperialism.weltpolitik', 'ドイツの世界政策が対立を激化させた因果', 'causal', 2, 1890,
   1911, 'exact', ARRAY['kc.imperialism.alliance_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.imperialism.3b_3c_geo', '3B政策と3C政策の経路', 'geo', 2, 1899,
   1914, 'exact', ARRAY['kc.imperialism.weltpolitik']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.imperialism.us_vs_russia', 'アメリカとロシアの膨張の方向の違い', 'distinction', 2, 1898,
   1905, 'exact', ARRAY['kc.imperialism.causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.partition.africa_order', 'アフリカ分割が進む順序', 'chronology', 2, 1884,
   1912, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.partition.longitudinal_geo', '縦断政策と横断政策の経路', 'geo', 2, 1881,
   1898, 'exact', ARRAY['kc.partition.africa_order']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.partition.two_independent', '独立を保った2国', 'fact', 2, 1847,
   1912, 'exact', ARRAY['kc.partition.africa_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.partition.boer_war', '南アフリカ戦争が起きた要因', 'causal', 2, 1899,
   1902, 'exact', ARRAY['kc.partition.longitudinal_geo']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.partition.pacific_geo', '太平洋地域の分割', 'geo', 2, 1840,
   1902, 'exact', ARRAY['kc.partition.africa_order']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.partition.sea_colonies', '東南アジアの植民地化の型の違い', 'distinction', 2, 1830,
   1900, 'exact', ARRAY['kc.partition.pacific_geo']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asianation.boxer', '義和団事件が清の運命を決めた因果', 'causal', 2, 1899,
   1901, 'exact', ARRAY['kc.qingfall.spheres_geo']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asianation.xinhai_order', '辛亥革命に至る順序', 'chronology', 2, 1894,
   1912, 'exact', ARRAY['kc.asianation.boxer']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asianation.leaders', '各国の民族運動の担い手の違い', 'distinction', 2, 1885,
   1908, 'exact', ARRAY['kc.indiacol.congress_shift']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asianation.russo_japanese_impact', '日露戦争がアジアに与えた影響', 'causal', 2, 1905,
   1911, 'exact', ARRAY['kc.asianation.leaders']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asianation.three_principles', '三民主義の内容', 'fact', 2, 1905,
   1912, 'exact', ARRAY['kc.asianation.xinhai_order']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww1.causes', '第一次世界大戦が起きた要因', 'causal', 3, 1908,
   1914, 'exact', ARRAY['kc.imperialism.alliance_order']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww1.total_war', '従来の戦争と総力戦の違い', 'distinction', 3, 1914,
   1918, 'exact', ARRAY['kc.ww1.causes']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww1.turning_points', '大戦の転機の順序', 'chronology', 3, 1914,
   1918, 'exact', ARRAY['kc.ww1.total_war']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww1.british_promises', 'イギリスの三枚舌外交', 'fact', 3, 1915,
   1917, 'exact', ARRAY['kc.ww1.turning_points']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww1.fronts_geo', '大戦の戦線の位置', 'geo', 3, 1914,
   1918, 'exact', ARRAY['kc.ww1.turning_points']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww1.empires_collapse', '大戦が帝国を解体させた因果', 'causal', 3, 1917,
   1922, 'exact', ARRAY['kc.ww1.turning_points']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rusrev.two_revolutions', '二月革命から十月革命までの順序', 'chronology', 3, 1917,
   1918, 'exact', ARRAY['kc.ww1.turning_points']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rusrev.bolshevik_causes', 'ボリシェヴィキが権力を握れた要因', 'causal', 3, 1917,
   1917, 'exact', ARRAY['kc.rusrev.two_revolutions']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rusrev.war_communism_vs_nep', '戦時共産主義とネップの違い', 'distinction', 3, 1918,
   1928, 'exact', ARRAY['kc.rusrev.bolshevik_causes']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rusrev.intervention', '諸外国の干渉が革命政権を固めた因果', 'causal', 3, 1918,
   1922, 'exact', ARRAY['kc.rusrev.bolshevik_causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.rusrev.ussr_and_comintern', 'ソ連の成立とコミンテルン', 'fact', 3, 1919,
   1922, 'exact', ARRAY['kc.rusrev.intervention']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.versailles.two_systems', 'ヴェルサイユ体制とワシントン体制の違い', 'distinction', 3, 1919,
   1922, 'exact', ARRAY['kc.ww1.empires_collapse']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.versailles.german_terms', 'ヴェルサイユ条約がドイツに課したもの', 'fact', 3, 1919,
   1921, 'exact', ARRAY['kc.versailles.two_systems']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.versailles.league_weakness', '国際連盟が機能しなかった要因', 'causal', 3, 1920,
   1935, 'exact', ARRAY['kc.versailles.two_systems']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.versailles.new_states_geo', '大戦後の東欧に生まれた国', 'geo', 3, 1918,
   1920, 'exact', ARRAY['kc.versailles.two_systems']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.versailles.mandate_system', '委任統治がアラブの不信を生んだ因果', 'causal', 3, 1920,
   1932, 'exact', ARRAY['kc.ww1.british_promises']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.versailles.cooperation_order', '1920年代の国際協調の順序', 'chronology', 3, 1924,
   1929, 'exact', ARRAY['kc.versailles.league_weakness']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.depression.spread', '世界恐慌が世界へ広がった因果', 'causal', 3, 1929,
   1933, 'exact', ARRAY['kc.versailles.cooperation_order']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.depression.responses', '各国の恐慌対策の違い', 'distinction', 3, 1932,
   1936, 'exact', ARRAY['kc.depression.spread']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.depression.fascism_causes', 'ファシズムが支持された要因', 'causal', 3, 1922,
   1933, 'exact', ARRAY['kc.depression.responses']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.depression.italy_vs_germany', 'イタリアとドイツのファシズムの違い', 'distinction', 3, 1922,
   1939, 'exact', ARRAY['kc.depression.fascism_causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.depression.german_revision', 'ドイツが条約を破棄していく順序', 'chronology', 3, 1933,
   1939, 'exact', ARRAY['kc.depression.italy_vs_germany']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.depression.appeasement', '宥和政策がとられた因果', 'causal', 3, 1935,
   1939, 'exact', ARRAY['kc.depression.german_revision']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww2.turning_points', '戦争の拡大と転機の順序', 'chronology', 3, 1939,
   1945, 'exact', ARRAY['kc.depression.german_revision']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww2.axis_vs_allies', '枢軸国と連合国の性格の違い', 'distinction', 3, 1940,
   1945, 'exact', ARRAY['kc.ww2.turning_points']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww2.axis_extent_geo', '枢軸国の最大勢力圏', 'geo', 3, 1942,
   1942, 'exact', ARRAY['kc.ww2.turning_points']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww2.eastern_front', '独ソ戦が戦局を決めた因果', 'causal', 3, 1941,
   1945, 'exact', ARRAY['kc.ww2.axis_extent_geo']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww2.conferences', '戦後構想を決めた会談', 'fact', 3, 1941,
   1945, 'exact', ARRAY['kc.ww2.turning_points']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ww2.holocaust', 'ホロコーストに至る段階', 'causal', 3, 1935,
   1945, 'exact', ARRAY['kc.ww2.axis_vs_allies']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.coldwar.origin', '冷戦が始まった要因', 'causal', 3, 1946,
   1949, 'exact', ARRAY['kc.ww2.conferences']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.coldwar.marshall_vs_comecon', 'マーシャル=プランとコメコンの対応', 'distinction', 3, 1947,
   1949, 'exact', ARRAY['kc.coldwar.origin']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.coldwar.blocs_geo', '東西両陣営の分布', 'geo', 3, 1949,
   1955, 'exact', ARRAY['kc.coldwar.marshall_vs_comecon']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.coldwar.german_division', 'ドイツと朝鮮の分断が生まれた因果', 'causal', 3, 1948,
   1953, 'exact', ARRAY['kc.coldwar.blocs_geo']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.coldwar.china_prc', '中華人民共和国の成立と冷戦', 'causal', 3, 1945,
   1950, 'exact', ARRAY['kc.coldwar.german_division']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.coldwar.arms_race', '核開発競争が抑止に転じた因果', 'chronology', 3, 1945,
   1962, 'exact', ARRAY['kc.coldwar.origin']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.decolonize.india_partition', 'インドが分離独立した因果', 'causal', 3, 1935,
   1948, 'exact', ARRAY['kc.indiacol.congress_shift']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.decolonize.sea_independence', '東南アジアの独立の型の違い', 'distinction', 3, 1945,
   1954, 'exact', ARRAY['kc.partition.sea_colonies']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.decolonize.africa_year_geo', 'アフリカ諸国が独立した順序と範囲', 'geo', 3, 1951,
   1975, 'exact', ARRAY['kc.partition.africa_order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.decolonize.bandung', '第三勢力が形をとった順序', 'chronology', 3, 1954,
   1961, 'exact', ARRAY['kc.decolonize.sea_independence']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.decolonize.artificial_borders', '植民地の境界がそのまま国境になった因果', 'causal', 3, 1960,
   1994, 'exact', ARRAY['kc.decolonize.africa_year_geo']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.decolonize.apartheid', 'アパルトヘイトの成立と廃止', 'fact', 3, 1948,
   1994, 'exact', ARRAY['kc.partition.boer_war']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.regionalwar.middle_east_geo', '中東戦争で動いた領域', 'geo', 3, 1948,
   1979, 'exact', ARRAY['kc.versailles.mandate_system']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.regionalwar.middle_east_order', '中東戦争の順序と争点', 'chronology', 3, 1948,
   1979, 'exact', ARRAY['kc.regionalwar.middle_east_geo']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.regionalwar.vietnam_causes', 'ベトナム戦争が長期化した要因', 'causal', 3, 1954,
   1975, 'exact', ARRAY['kc.decolonize.sea_independence']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.regionalwar.oil_shock', '石油危機が世界経済を変えた因果', 'causal', 3, 1973,
   1979, 'exact', ARRAY['kc.regionalwar.middle_east_order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.regionalwar.sino_soviet', '中ソ対立が冷戦の構図を崩した因果', 'causal', 3, 1956,
   1972, 'exact', ARRAY['kc.coldwar.china_prc']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.regionalwar.latin_america_coldwar', 'ラテンアメリカが冷戦の場になった経緯', 'fact', 3, 1959,
   1973, 'exact', ARRAY['kc.coldwar.arms_race']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.detente.detente_causes', '緊張緩和が進んだ要因', 'causal', 3, 1963,
   1975, 'exact', ARRAY['kc.coldwar.arms_race']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.detente.second_cold_war', '緊張緩和が一度崩れた因果', 'causal', 3, 1979,
   1985, 'exact', ARRAY['kc.detente.detente_causes']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.detente.perestroika', 'ペレストロイカが体制を崩した因果', 'causal', 3, 1985,
   1991, 'exact', ARRAY['kc.detente.second_cold_war']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.detente.east_europe_1989', '東欧革命が連鎖した順序', 'chronology', 3, 1989,
   1991, 'exact', ARRAY['kc.detente.perestroika']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.detente.germany_and_ussr_geo', '冷戦終結で変わった地図', 'geo', 3, 1990,
   1993, 'exact', ARRAY['kc.detente.east_europe_1989']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.detente.yugoslavia_causes', 'ユーゴスラヴィアが解体した要因', 'causal', 3, 1991,
   1999, 'exact', ARRAY['kc.detente.germany_and_ussr_geo']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.global.eu_integration_order', 'ヨーロッパ統合の順序', 'chronology', 3, 1952,
   2002, 'exact', ARRAY['kc.coldwar.marshall_vs_comecon']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.global.multipolar', '冷戦後の秩序が多極化した因果', 'causal', 3, 1991,
   2020, 'century', ARRAY['kc.detente.germany_and_ussr_geo']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.global.regional_blocs_geo', '地域経済統合の枠組み', 'geo', 3, 1967,
   2020, 'century', ARRAY['kc.global.eu_integration_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.global.terror_and_intervention', '9・11以後の介入が生んだもの', 'causal', 3, 2001,
   2011, 'exact', ARRAY['kc.global.multipolar']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.global.common_issues', '人類共通の課題の広がり', 'distinction', 3, 1972,
   2020, 'century', ARRAY['kc.global.multipolar']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ghsource.chronology_tools', '年代の表し方の違い', 'distinction', 1, NULL,
   NULL, 'unknown', ARRAY['kc.source.primary_vs_secondary']::text[], 0.9)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ghsource.statistics_reading', '統計資料を読むときの落とし穴', 'causal', 1, NULL,
   NULL, 'unknown', ARRAY['kc.source.bias_in_records']::text[], 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ghsource.map_as_argument', '地図が主張を含むこと', 'distinction', 1, NULL,
   NULL, 'unknown', ARRAY['kc.source.periodization_problem']::text[], 0.9)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.ghsource.multiple_perspectives', '同じ出来事が立場で違って見えること', 'causal', 1, NULL,
   NULL, 'unknown', ARRAY['kc.source.bias_in_records']::text[], 1)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asia18.three_empires_prosperity', '18世紀のアジア3帝国の状態', 'distinction', 2, 1700,
   1800, 'century', ARRAY['kc.mingqing.qing_territory_geo']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asia18.silver_flow_geo', '18世紀の銀と物産の流れ', 'geo', 2, 1700,
   1800, 'century', ARRAY['kc.mingqing.tax_silver_reform']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asia18.edo_isolation', '江戸幕府の対外関係の実態', 'distinction', 2, 1639,
   1854, 'exact', '{}'::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asia18.asian_trade_causes', 'アジア域内交易が活発だった要因', 'causal', 2, 1700,
   1800, 'century', ARRAY['kc.asia18.silver_flow_geo']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.asia18.prosperity_to_crisis', '繁栄が19世紀の危機に転じた因果', 'causal', 2, 1750,
   1840, 'century', ARRAY['kc.asia18.three_empires_prosperity']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.triangle.slave_trade_scale', '奴隷貿易の規模と経路', 'geo', 2, 1500,
   1867, 'exact', ARRAY['kc.atlantic.triangular_trade_geo']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.triangle.plantation_system', 'プランテーションの成り立ち', 'causal', 2, 1600,
   1800, 'century', ARRAY['kc.triangle.slave_trade_scale']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.triangle.africa_impact', '奴隷貿易がアフリカに与えた影響', 'causal', 2, 1600,
   1800, 'century', ARRAY['kc.triangle.slave_trade_scale']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.triangle.abolition_order', '奴隷貿易と奴隷制が廃止される順序', 'chronology', 2, 1807,
   1888, 'exact', ARRAY['kc.triangle.africa_impact']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.triangle.capital_to_industry', '三角貿易の利益が産業革命を支えた因果', 'causal', 2, 1700,
   1800, 'century', ARRAY['kc.triangle.plantation_system']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indsoc.work_and_time', '工場労働が生活を変えた因果', 'causal', 2, 1780,
   1850, 'century', ARRAY['kc.industrial.social_change']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indsoc.urban_problems', '都市化が生んだ問題', 'fact', 2, 1800,
   1900, 'century', ARRAY['kc.indsoc.work_and_time']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indsoc.family_and_gender', '性別役割分業が形をとった因果', 'causal', 2, 1800,
   1900, 'century', ARRAY['kc.indsoc.work_and_time']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indsoc.spread_geo', '産業革命が各国へ広がった順序と地域', 'geo', 2, 1760,
   1900, 'century', ARRAY['kc.industrial.regions_geo']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.indsoc.labour_movement', '労働運動と社会政策の対応', 'distinction', 2, 1833,
   1900, 'exact', ARRAY['kc.indsoc.urban_problems']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.nationstate.what_is_nation', '国民国家という枠組みの新しさ', 'distinction', 2, 1789,
   1900, 'century', ARRAY['kc.frrev.declaration_vs_code']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.nationstate.making_citizens', '国民を作る仕組み', 'causal', 2, 1800,
   1900, 'century', ARRAY['kc.nationstate.what_is_nation']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.nationstate.suffrage_order', '参政権が広がる順序', 'chronology', 2, 1832,
   1928, 'exact', ARRAY['kc.vienna.british_reforms']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.nationstate.nationalism_two_faces', 'ナショナリズムの2つの顔', 'distinction', 2, 1848,
   1918, 'exact', ARRAY['kc.nationstate.what_is_nation']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.nationstate.japan_comparison', '日本の国民国家化の特徴', 'distinction', 2, 1868,
   1890, 'exact', ARRAY['kc.nationstate.making_citizens']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.bakumatsu.opening_causes', '日本が開国した要因', 'causal', 2, 1840,
   1858, 'exact', ARRAY['kc.qingfall.opening_chain']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.bakumatsu.two_treaties', '和親条約と修好通商条約の違い', 'distinction', 2, 1854,
   1858, 'exact', ARRAY['kc.bakumatsu.opening_causes']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.bakumatsu.trade_impact', '貿易の開始が経済を混乱させた因果', 'causal', 2, 1859,
   1867, 'exact', ARRAY['kc.bakumatsu.two_treaties']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.bakumatsu.sonno_joi_shift', '尊王攘夷から倒幕へ転じた因果', 'causal', 2, 1863,
   1868, 'exact', ARRAY['kc.bakumatsu.trade_impact']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.bakumatsu.treaty_ports_geo', '開港場の位置と役割', 'geo', 2, 1854,
   1867, 'exact', ARRAY['kc.bakumatsu.two_treaties']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.meiji.centralization', '版籍奉還と廃藩置県の違い', 'distinction', 2, 1869,
   1871, 'exact', ARRAY['kc.bakumatsu.sonno_joi_shift']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.meiji.three_reforms', '地租改正・徴兵令・学制の目的', 'causal', 2, 1872,
   1873, 'exact', ARRAY['kc.meiji.centralization']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.meiji.westernization_limits', '文明開化が及んだ範囲', 'distinction', 2, 1871,
   1890, 'exact', ARRAY['kc.meiji.three_reforms']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.meiji.opposition', '士族反乱と自由民権運動の違い', 'distinction', 2, 1874,
   1884, 'exact', ARRAY['kc.meiji.three_reforms']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.meiji.treaty_revision', '条約改正が長引いた因果', 'causal', 2, 1871,
   1911, 'exact', ARRAY['kc.bakumatsu.two_treaties']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.constitution.model_choice', 'ドイツ型憲法を選んだ因果', 'causal', 2, 1882,
   1889, 'exact', ARRAY['kc.meiji.opposition']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.constitution.emperor_and_diet', '天皇大権と議会の権限の関係', 'distinction', 2, 1889,
   1890, 'exact', ARRAY['kc.constitution.model_choice']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.constitution.early_diet_conflict', '初期議会が対立した争点', 'fact', 2, 1890,
   1894, 'exact', ARRAY['kc.constitution.emperor_and_diet']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.constitution.education_rescript', '教育勅語が果たした役割', 'causal', 2, 1890,
   1945, 'exact', ARRAY['kc.nationstate.making_citizens']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.constitution.compare_asia', 'アジアの立憲運動との比較', 'distinction', 2, 1889,
   1908, 'exact', ARRAY['kc.asianation.russo_japanese_impact']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpwars.sino_japanese_causes', '日清戦争が起きた要因', 'causal', 2, 1876,
   1894, 'exact', ARRAY['kc.qingfall.opening_chain']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpwars.shimonoseki_and_triple', '下関条約と三国干渉の帰結', 'causal', 2, 1895,
   1898, 'exact', ARRAY['kc.jpwars.sino_japanese_causes']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpwars.russo_japanese_causes', '日露戦争が起きた要因', 'causal', 2, 1900,
   1904, 'exact', ARRAY['kc.jpwars.shimonoseki_and_triple']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpwars.portsmouth_limits', 'ポーツマス条約の内容と国内の反発', 'distinction', 2, 1905,
   1905, 'exact', ARRAY['kc.jpwars.russo_japanese_causes']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpwars.korea_annexation', '韓国併合に至る段階', 'chronology', 2, 1904,
   1910, 'exact', ARRAY['kc.jpwars.portsmouth_limits']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpwars.northeast_asia_geo', '日清・日露戦争で動いた勢力範囲', 'geo', 2, 1895,
   1910, 'exact', ARRAY['kc.jpwars.korea_annexation']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.totalwar.japan_ww1', '日本の第一次世界大戦への関わり方', 'distinction', 3, 1914,
   1919, 'exact', ARRAY['kc.ww1.total_war']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.totalwar.21_demands', '二十一か条の要求とその帰結', 'fact', 3, 1915,
   1919, 'exact', ARRAY['kc.totalwar.japan_ww1']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.totalwar.self_determination_asia', '民族自決がアジアで運動を呼んだ因果', 'causal', 3, 1918,
   1919, 'exact', ARRAY['kc.totalwar.21_demands']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.totalwar.japan_league', '国際連盟における日本の位置', 'distinction', 3, 1919,
   1933, 'exact', ARRAY['kc.versailles.league_weakness']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.totalwar.wartime_boom', '大戦景気とその反動', 'causal', 3, 1915,
   1920, 'exact', ARRAY['kc.totalwar.japan_ww1']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.totalwar.japan_mandate_geo', '大戦後に日本が得た地域', 'geo', 3, 1919,
   1922, 'exact', ARRAY['kc.totalwar.japan_league']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.masssoc.causes', '大衆社会が成立した要因', 'causal', 3, 1918,
   1930, 'exact', ARRAY['kc.totalwar.self_determination_asia']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.masssoc.us_1920s', 'アメリカの繁栄の光と影', 'distinction', 3, 1920,
   1929, 'exact', ARRAY['kc.masssoc.causes']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.masssoc.japan_culture', '日本の大衆文化', 'fact', 3, 1920,
   1930, 'exact', ARRAY['kc.masssoc.causes']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.masssoc.womens_suffrage', '女性参政権が広がった因果', 'causal', 3, 1918,
   1945, 'exact', ARRAY['kc.nationstate.suffrage_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.masssoc.media_power', 'メディアが世論を作る力', 'distinction', 3, 1920,
   1940, 'exact', ARRAY['kc.masssoc.japan_culture']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.taisho.party_politics_order', '政党政治が確立し崩れるまでの順序', 'chronology', 3, 1912,
   1932, 'exact', ARRAY['kc.constitution.early_diet_conflict']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.taisho.two_laws', '普通選挙法と治安維持法が同時に成立した因果', 'causal', 3, 1925,
   1925, 'exact', ARRAY['kc.taisho.party_politics_order']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.taisho.social_movements', '社会運動の担い手の違い', 'distinction', 3, 1920,
   1925, 'exact', ARRAY['kc.taisho.two_laws']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.taisho.minpon', '大正デモクラシーを支えた思想', 'fact', 3, 1916,
   1925, 'exact', ARRAY['kc.taisho.party_politics_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.taisho.great_quake', '関東大震災が社会に与えた影響', 'causal', 3, 1923,
   1927, 'exact', ARRAY['kc.taisho.social_movements']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.taisho.japan_vs_west', '日本の政党政治と欧米議会政治の違い', 'distinction', 3, 1918,
   1932, 'exact', ARRAY['kc.taisho.party_politics_order']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpdep.showa_depression', '日本が昭和恐慌に陥った因果', 'causal', 3, 1927,
   1931, 'exact', ARRAY['kc.depression.spread']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpdep.rural_crisis', '農村の窮乏の実態', 'fact', 3, 1930,
   1934, 'exact', ARRAY['kc.jpdep.showa_depression']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpdep.army_rise', '恐慌が軍部の台頭を招いた因果', 'causal', 3, 1930,
   1936, 'exact', ARRAY['kc.jpdep.rural_crisis']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpdep.takahashi', '高橋財政と各国の恐慌対策の比較', 'distinction', 3, 1931,
   1936, 'exact', ARRAY['kc.jpdep.showa_depression']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpdep.export_shift_geo', '日本の輸出先の変化', 'geo', 3, 1929,
   1937, 'exact', ARRAY['kc.jpdep.takahashi']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.manchuria.order', '満洲事変から国際連盟脱退までの順序', 'chronology', 3, 1931,
   1933, 'exact', ARRAY['kc.jpdep.army_rise']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.manchuria.domestic_impact', '満洲事変が国内政治を変えた因果', 'causal', 3, 1931,
   1936, 'exact', ARRAY['kc.manchuria.order']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.manchuria.puppet_state', '満洲国の建前と実態', 'distinction', 3, 1932,
   1945, 'exact', ARRAY['kc.manchuria.order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.manchuria.geo', '満洲と華北の位置関係', 'geo', 3, 1931,
   1937, 'exact', ARRAY['kc.manchuria.puppet_state']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.manchuria.league_failure', '国際連盟の無力が示された因果', 'causal', 3, 1931,
   1937, 'exact', ARRAY['kc.manchuria.order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sinojp.prolongation', '日中戦争が長期化した要因', 'causal', 3, 1937,
   1941, 'exact', ARRAY['kc.manchuria.geo']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sinojp.order', '戦争の拡大と和平工作の順序', 'chronology', 3, 1937,
   1940, 'exact', ARRAY['kc.sinojp.prolongation']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sinojp.supply_routes_geo', '援蒋ルートと戦線の広がり', 'geo', 3, 1937,
   1941, 'exact', ARRAY['kc.sinojp.prolongation']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sinojp.mobilization', '国家総動員体制の中身', 'fact', 3, 1938,
   1941, 'exact', ARRAY['kc.sinojp.order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sinojp.two_regimes', '日本と中国の戦時体制の違い', 'distinction', 3, 1937,
   1945, 'exact', ARRAY['kc.sinojp.prolongation']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sinojp.to_us_conflict', '日中戦争が対米関係を悪化させた因果', 'causal', 3, 1939,
   1941, 'exact', ARRAY['kc.sinojp.supply_routes_geo']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.pacificwar.causes', '開戦に至った要因', 'causal', 3, 1940,
   1941, 'exact', ARRAY['kc.sinojp.to_us_conflict']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.pacificwar.co_prosperity', '大東亜共栄圏の建前と占領の実態', 'distinction', 3, 1941,
   1945, 'exact', ARRAY['kc.pacificwar.causes']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.pacificwar.extent_geo', '日本の最大占領範囲と後退線', 'geo', 3, 1942,
   1945, 'exact', ARRAY['kc.pacificwar.co_prosperity']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.pacificwar.home_front', '戦時下の国民生活と動員', 'fact', 3, 1943,
   1945, 'exact', ARRAY['kc.pacificwar.co_prosperity']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.pacificwar.end_order', '終戦に至る順序', 'chronology', 3, 1945,
   1945, 'exact', ARRAY['kc.pacificwar.extent_geo']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.pacificwar.postwar_division', '戦後処理が東アジアの分断を生んだ因果', 'causal', 3, 1945,
   1952, 'exact', ARRAY['kc.pacificwar.end_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.occupation.policy_shift', '占領初期と後期の政策の違い', 'distinction', 3, 1945,
   1952, 'exact', ARRAY['kc.coldwar.china_prc']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.occupation.three_reforms', '三大改革の内容', 'fact', 3, 1945,
   1950, 'exact', ARRAY['kc.occupation.policy_shift']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.occupation.two_constitutions', '大日本帝国憲法と日本国憲法の違い', 'distinction', 3, 1946,
   1947, 'exact', ARRAY['kc.occupation.three_reforms']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.occupation.independence_order', '独立を回復するまでの順序', 'chronology', 3, 1950,
   1956, 'exact', ARRAY['kc.occupation.policy_shift']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.occupation.korean_war_boom', '朝鮮戦争が日本の復興を早めた因果', 'causal', 3, 1950,
   1953, 'exact', ARRAY['kc.occupation.independence_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.occupation.territory_geo', '平和条約で確定しなかった地域', 'geo', 3, 1951,
   1972, 'exact', ARRAY['kc.occupation.independence_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.growth.causes', '高度経済成長が可能になった要因', 'causal', 3, 1955,
   1973, 'exact', ARRAY['kc.occupation.korean_war_boom']::text[], 1.7)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.growth.pollution', '成長の光と影', 'distinction', 3, 1955,
   1975, 'exact', ARRAY['kc.growth.causes']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.growth.diplomacy_order', '国際社会に戻る順序', 'chronology', 3, 1956,
   1978, 'exact', ARRAY['kc.occupation.independence_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.growth.end', '高度成長が終わった因果', 'causal', 3, 1971,
   1975, 'exact', ARRAY['kc.growth.causes']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.growth.belt_geo', '太平洋ベルトへの産業と人口の集中', 'geo', 3, 1955,
   1975, 'exact', ARRAY['kc.growth.pollution']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpcwend.new_role', '冷戦終結が日本の立場を変えた因果', 'causal', 3, 1989,
   1992, 'exact', ARRAY['kc.detente.east_europe_1989']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpcwend.bubble', 'バブル経済が生まれ崩壊した因果', 'causal', 3, 1985,
   1993, 'exact', ARRAY['kc.growth.end']::text[], 1.6)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpcwend.1955_system', '55年体制とその終わり', 'distinction', 3, 1955,
   1993, 'exact', ARRAY['kc.jpcwend.new_role']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jpcwend.east_asia_order', '東アジアの緊張と和解の順序', 'chronology', 3, 1989,
   2002, 'exact', ARRAY['kc.jpcwend.new_role']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jptoday.aging', '少子高齢化が社会保障を圧迫する因果', 'causal', 3, 1990,
   2020, 'century', ARRAY['kc.jpcwend.bubble']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jptoday.globalization', 'グローバル化が生む利益と格差', 'distinction', 3, 1990,
   2020, 'century', ARRAY['kc.global.multipolar']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jptoday.disaster_energy', '災害と原子力政策の転換', 'causal', 3, 1995,
   2020, 'exact', ARRAY['kc.jptoday.aging']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.jptoday.regional_geo', '現代日本をめぐる地域の課題', 'geo', 3, 1990,
   2020, 'century', ARRAY['kc.occupation.territory_geo']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.orient.unification_extent_geo', 'オリエントを統一した2帝国の版図', 'geo', 1, -670,
   -330, 'century', ARRAY['kc.orient.assyria_vs_achaemenid_rule']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.china.warring_states_geo', '戦国七雄の位置', 'geo', 1, -403,
   -221, 'century', ARRAY['kc.china.fengjian_vs_junxian']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.frankish_partition_geo', 'フランク王国の分割線', 'geo', 1, 843,
   870, 'exact', ARRAY['kc.euro.verdun_and_mersen']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.medcult.plague_route_geo', '黒死病が広がった経路', 'geo', 1, 1347,
   1351, 'exact', ARRAY['kc.medcult.black_death_effects']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.reformation.confession_map_geo', '宗派の分布', 'geo', 2, 1550,
   1650, 'century', ARRAY['kc.reformation.settlement_order']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.usrev.thirteen_colonies_geo', '13植民地の位置と性格', 'geo', 2, 1607,
   1776, 'exact', ARRAY['kc.usrev.causes']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sea.mainland_vs_island', '大陸部と諸島部の国家の性格の違い', 'distinction', 1, 100,
   1500, 'century', ARRAY['kc.sea.port_polities_geo']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.sea.vietnam_independence', 'ベトナムが中国から自立する順序', 'chronology', 1, -111,
   1428, 'century', ARRAY['kc.eastasia.tang_cultural_sphere']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.eastasia.ritsuryo_reception', '律令を受け入れた国と受け入れ方の違い', 'distinction', 1, 600,
   900, 'century', ARRAY['kc.eastasia.tang_cultural_sphere']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.eastasia.tributary_logic', '冊封体制が成り立った理由', 'causal', 1, 100,
   1400, 'century', ARRAY['kc.eastasia.tang_cultural_sphere']::text[], 1.5)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.eastasia.sphere_geo', '東アジア文化圏の広がり', 'geo', 1, 600,
   1000, 'century', ARRAY['kc.eastasia.tang_cultural_sphere']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.innerasia.steppe_geo', '遊牧国家が興亡した地域', 'geo', 1, -200,
   900, 'century', ARRAY['kc.innerasia.nomad_vs_oasis']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.innerasia.nomad_military', '遊牧国家の軍事的な強さの理由', 'distinction', 1, -200,
   1200, 'century', ARRAY['kc.innerasia.nomad_vs_oasis']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.trade.two_directions', '西へ伝わったものと東へ伝わったもの', 'distinction', 1, -100,
   1400, 'century', ARRAY['kc.trade.three_routes_geo']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.trade.paper_westward', '製紙法が西へ伝わった経緯', 'causal', 1, 751,
   1150, 'exact', ARRAY['kc.trade.sogdian_role']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.byzantine_longevity', 'ビザンツ帝国が1000年続いた要因', 'causal', 1, 476,
   1453, 'exact', ARRAY['kc.euro.byzantine_institutions']::text[], 1.4)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.russia_order', 'ロシアが自立するまでの順序', 'chronology', 1, 882,
   1480, 'exact', ARRAY['kc.euro.slav_division_geo']::text[], 1.3)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.monastery_vs_church', '修道院と司教座教会の役割の違い', 'distinction', 1, 500,
   1200, 'century', ARRAY['kc.euro.feudal_two_layers']::text[], 1.2)
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;
INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES
  ('kc.euro.church_power', '教会が世俗の権力を持った因果', 'causal', 1, 800,
   1200, 'century', ARRAY['kc.euro.feudal_two_layers']::text[], 1.4)
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
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.prehist.hominid_stages', 'wh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.prehist.human_dispersal_geo', 'wh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.prehist.bipedalism_effects', 'wh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.prehist.fire_burial_art', 'wh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.prehist.stone_age_division', 'wh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.neolithic.food_production_causes', 'wh.1.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.neolithic.neolithic_toolkit', 'wh.1.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.neolithic.fertile_crescent_geo', 'wh.1.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.neolithic.irrigation_to_state', 'wh.1.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.neolithic.metal_age_order', 'wh.1.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.source.primary_vs_secondary', 'wh.1.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.source.material_vs_written', 'wh.1.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.source.bias_in_records', 'wh.1.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.source.periodization_problem', 'wh.1.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.turkiran.samanid_to_ghaznavid', 'wh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.turkiran.turkification_causes', 'wh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.turkiran.seljuk_sultanate', 'wh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.turkiran.mamluk_and_iqta', 'wh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.turkiran.anatolia_turkification_geo', 'wh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.turkiran.ghaznavid_india_causes', 'wh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islamize.delhi_sultanate_order', 'wh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islamize.bhakti_and_sufism', 'wh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islamize.sea_route_islam_geo', 'wh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islamize.west_africa_states', 'wh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islamize.swahili_coast_geo', 'wh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.islamize.sufi_role', 'wh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.song.civil_supremacy_causes', 'wh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.song.northern_peoples', 'wh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.song.wang_anshi_reform', 'wh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.song.north_to_south_geo', 'wh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.song.economic_revolution', 'wh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.song.scholar_officials', 'wh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mongol.expansion_order', 'wh.3.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mongol.four_khanates_geo', 'wh.3.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mongol.yuan_hierarchy', 'wh.3.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mongol.pax_mongolica', 'wh.3.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mongol.yuan_fall_causes', 'wh.3.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mongol.khanate_religion', 'wh.3.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.crusade.first_crusade_causes', 'wh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.crusade.expedition_order', 'wh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.crusade.consequences', 'wh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.crusade.two_trade_zones', 'wh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.crusade.trade_routes_geo', 'wh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.crusade.manor_decline', 'wh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medstate.papal_decline_order', 'wh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medstate.parliament_vs_etats', 'wh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medstate.hundred_years_war', 'wh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medstate.hre_vs_france', 'wh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medstate.europe_1500_geo', 'wh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medstate.reconquista', 'wh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medcult.black_death_effects', 'wh.3.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medcult.realism_vs_nominalism', 'wh.3.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medcult.medieval_universities', 'wh.3.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medcult.romanesque_vs_gothic', 'wh.3.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medcult.wyclif_and_hus', 'wh.3.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mingqing.ming_vs_qing_rule', 'wh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mingqing.haijin_and_tribute', 'wh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mingqing.tax_silver_reform', 'wh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mingqing.ming_fall_order', 'wh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mingqing.qing_territory_geo', 'wh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mingqing.new_crops_population', 'wh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ottoman.expansion_order', 'wh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ottoman.devshirme_and_timar', 'wh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ottoman.millet_system', 'wh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ottoman.sunni_vs_shia_states', 'wh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ottoman.three_empires_geo', 'wh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ottoman.mediterranean_decline', 'wh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mughal.emperor_order', 'wh.3.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mughal.akbar_vs_aurangzeb', 'wh.3.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mughal.mansabdar', 'wh.3.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mughal.decline_causes', 'wh.3.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.mughal.indo_islamic_culture', 'wh.3.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.voyage.motives', 'wh.3.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.voyage.two_routes_geo', 'wh.3.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.voyage.tordesillas', 'wh.3.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.voyage.commercial_revolution', 'wh.3.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.voyage.east_india_companies', 'wh.3.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.voyage.gutsherrschaft', 'wh.3.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.atlantic.three_civilizations', 'wh.3.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.atlantic.conquest_order', 'wh.3.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.atlantic.conquest_causes', 'wh.3.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.atlantic.encomienda', 'wh.3.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.atlantic.triangular_trade_geo', 'wh.3.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.atlantic.columbian_exchange', 'wh.3.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.renaissance.why_italy', 'wh.3.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.renaissance.humanism', 'wh.3.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.renaissance.three_inventions', 'wh.3.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.renaissance.northern', 'wh.3.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.renaissance.printing_effects', 'wh.3.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.reformation.luther_causes', 'wh.3.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.reformation.luther_vs_calvin', 'wh.3.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.reformation.settlement_order', 'wh.3.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.reformation.anglican', 'wh.3.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.reformation.counter_reformation', 'wh.3.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.reformation.wars_to_state', 'wh.3.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.absolutism.sovereign_state', 'wh.3.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.absolutism.machinery', 'wh.3.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.absolutism.mercantilism_types', 'wh.3.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.absolutism.hegemony_order', 'wh.3.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.absolutism.english_revolution', 'wh.3.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.absolutism.europe_1700_geo', 'wh.3.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.industrial.why_britain', 'wh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.industrial.textile_inventions', 'wh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.industrial.steam_to_transport', 'wh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.industrial.social_change', 'wh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.industrial.regions_geo', 'wh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.industrial.labour_to_socialism', 'wh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.usrev.causes', 'wh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.usrev.war_order', 'wh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.usrev.declaration_vs_constitution', 'wh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.usrev.world_impact', 'wh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.usrev.foreign_support', 'wh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.frrev.causes', 'wh.4.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.frrev.stages_order', 'wh.4.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.frrev.declaration_vs_code', 'wh.4.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.frrev.terror_causes', 'wh.4.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.frrev.napoleonic_europe_geo', 'wh.4.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.frrev.napoleon_fall', 'wh.4.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.vienna.principles', 'wh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.vienna.map_1815_geo', 'wh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.vienna.liberal_movements_order', 'wh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.vienna.1848_spread', 'wh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.vienna.latin_america', 'wh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.vienna.british_reforms', 'wh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.unification.italy_vs_germany', 'wh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.unification.three_wars', 'wh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.unification.garibaldi', 'wh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.unification.irredenta_geo', 'wh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.unification.bismarck_system', 'wh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.c19soc.us_expansion_order', 'wh.4.2.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.c19soc.civil_war_causes', 'wh.4.2.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.c19soc.north_vs_south', 'wh.4.2.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.c19soc.russian_reform', 'wh.4.2.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.c19soc.science_and_thought', 'wh.4.2.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.c19soc.migration_geo', 'wh.4.2.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.westasia19.reform_order', 'wh.4.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.westasia19.eastern_question', 'wh.4.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.westasia19.balkan_geo', 'wh.4.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.westasia19.egypt_vs_iran', 'wh.4.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.westasia19.islamic_revival', 'wh.4.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indiacol.conquest_order', 'wh.4.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indiacol.sepoy_mutiny', 'wh.4.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indiacol.zamindari_vs_ryotwari', 'wh.4.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indiacol.deindustrialization', 'wh.4.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indiacol.congress_shift', 'wh.4.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.qingfall.opium_war_causes', 'wh.4.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.qingfall.unequal_treaties', 'wh.4.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.qingfall.taiping', 'wh.4.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.qingfall.yangwu_vs_meiji', 'wh.4.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.qingfall.spheres_geo', 'wh.4.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.qingfall.opening_chain', 'wh.4.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.imperialism.causes', 'wh.4.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.imperialism.second_industrial', 'wh.4.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.imperialism.alliance_order', 'wh.4.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.imperialism.weltpolitik', 'wh.4.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.imperialism.3b_3c_geo', 'wh.4.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.imperialism.us_vs_russia', 'wh.4.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.partition.africa_order', 'wh.4.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.partition.longitudinal_geo', 'wh.4.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.partition.two_independent', 'wh.4.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.partition.boer_war', 'wh.4.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.partition.pacific_geo', 'wh.4.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.partition.sea_colonies', 'wh.4.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asianation.boxer', 'wh.4.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asianation.xinhai_order', 'wh.4.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asianation.leaders', 'wh.4.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asianation.russo_japanese_impact', 'wh.4.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asianation.three_principles', 'wh.4.4.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww1.causes', 'wh.4.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww1.total_war', 'wh.4.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww1.turning_points', 'wh.4.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww1.british_promises', 'wh.4.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww1.fronts_geo', 'wh.4.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww1.empires_collapse', 'wh.4.5.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rusrev.two_revolutions', 'wh.4.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rusrev.bolshevik_causes', 'wh.4.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rusrev.war_communism_vs_nep', 'wh.4.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rusrev.intervention', 'wh.4.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.rusrev.ussr_and_comintern', 'wh.4.5.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.versailles.two_systems', 'wh.4.5.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.versailles.german_terms', 'wh.4.5.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.versailles.league_weakness', 'wh.4.5.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.versailles.new_states_geo', 'wh.4.5.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.versailles.mandate_system', 'wh.4.5.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.versailles.cooperation_order', 'wh.4.5.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.depression.spread', 'wh.4.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.depression.responses', 'wh.4.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.depression.fascism_causes', 'wh.4.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.depression.italy_vs_germany', 'wh.4.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.depression.german_revision', 'wh.4.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.depression.appeasement', 'wh.4.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww2.turning_points', 'wh.4.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww2.axis_vs_allies', 'wh.4.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww2.axis_extent_geo', 'wh.4.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww2.eastern_front', 'wh.4.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww2.conferences', 'wh.4.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ww2.holocaust', 'wh.4.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.coldwar.origin', 'wh.5.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.coldwar.marshall_vs_comecon', 'wh.5.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.coldwar.blocs_geo', 'wh.5.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.coldwar.german_division', 'wh.5.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.coldwar.china_prc', 'wh.5.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.coldwar.arms_race', 'wh.5.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.decolonize.india_partition', 'wh.5.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.decolonize.sea_independence', 'wh.5.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.decolonize.africa_year_geo', 'wh.5.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.decolonize.bandung', 'wh.5.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.decolonize.artificial_borders', 'wh.5.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.decolonize.apartheid', 'wh.5.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.regionalwar.middle_east_geo', 'wh.5.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.regionalwar.middle_east_order', 'wh.5.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.regionalwar.vietnam_causes', 'wh.5.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.regionalwar.oil_shock', 'wh.5.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.regionalwar.sino_soviet', 'wh.5.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.regionalwar.latin_america_coldwar', 'wh.5.1.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.detente.detente_causes', 'wh.5.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.detente.second_cold_war', 'wh.5.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.detente.perestroika', 'wh.5.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.detente.east_europe_1989', 'wh.5.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.detente.germany_and_ussr_geo', 'wh.5.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.detente.yugoslavia_causes', 'wh.5.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.global.eu_integration_order', 'wh.5.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.global.multipolar', 'wh.5.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.global.regional_blocs_geo', 'wh.5.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.global.terror_and_intervention', 'wh.5.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.global.common_issues', 'wh.5.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ghsource.chronology_tools', 'gh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ghsource.statistics_reading', 'gh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ghsource.map_as_argument', 'gh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.ghsource.multiple_perspectives', 'gh.1.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asia18.three_empires_prosperity', 'gh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asia18.silver_flow_geo', 'gh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asia18.edo_isolation', 'gh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asia18.asian_trade_causes', 'gh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.asia18.prosperity_to_crisis', 'gh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.triangle.slave_trade_scale', 'gh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.triangle.plantation_system', 'gh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.triangle.africa_impact', 'gh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.triangle.abolition_order', 'gh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.triangle.capital_to_industry', 'gh.2.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indsoc.work_and_time', 'gh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indsoc.urban_problems', 'gh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indsoc.family_and_gender', 'gh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indsoc.spread_geo', 'gh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.indsoc.labour_movement', 'gh.2.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.nationstate.what_is_nation', 'gh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.nationstate.making_citizens', 'gh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.nationstate.suffrage_order', 'gh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.nationstate.nationalism_two_faces', 'gh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.nationstate.japan_comparison', 'gh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.bakumatsu.opening_causes', 'gh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.bakumatsu.two_treaties', 'gh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.bakumatsu.trade_impact', 'gh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.bakumatsu.sonno_joi_shift', 'gh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.bakumatsu.treaty_ports_geo', 'gh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.meiji.centralization', 'gh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.meiji.three_reforms', 'gh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.meiji.westernization_limits', 'gh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.meiji.opposition', 'gh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.meiji.treaty_revision', 'gh.2.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.constitution.model_choice', 'gh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.constitution.emperor_and_diet', 'gh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.constitution.early_diet_conflict', 'gh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.constitution.education_rescript', 'gh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.constitution.compare_asia', 'gh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpwars.sino_japanese_causes', 'gh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpwars.shimonoseki_and_triple', 'gh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpwars.russo_japanese_causes', 'gh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpwars.portsmouth_limits', 'gh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpwars.korea_annexation', 'gh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpwars.northeast_asia_geo', 'gh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.totalwar.japan_ww1', 'gh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.totalwar.21_demands', 'gh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.totalwar.self_determination_asia', 'gh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.totalwar.japan_league', 'gh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.totalwar.wartime_boom', 'gh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.totalwar.japan_mandate_geo', 'gh.3.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.masssoc.causes', 'gh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.masssoc.us_1920s', 'gh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.masssoc.japan_culture', 'gh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.masssoc.womens_suffrage', 'gh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.masssoc.media_power', 'gh.3.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.taisho.party_politics_order', 'gh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.taisho.two_laws', 'gh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.taisho.social_movements', 'gh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.taisho.minpon', 'gh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.taisho.great_quake', 'gh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.taisho.japan_vs_west', 'gh.3.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpdep.showa_depression', 'gh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpdep.rural_crisis', 'gh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpdep.army_rise', 'gh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpdep.takahashi', 'gh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpdep.export_shift_geo', 'gh.3.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.manchuria.order', 'gh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.manchuria.domestic_impact', 'gh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.manchuria.puppet_state', 'gh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.manchuria.geo', 'gh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.manchuria.league_failure', 'gh.3.3.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sinojp.prolongation', 'gh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sinojp.order', 'gh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sinojp.supply_routes_geo', 'gh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sinojp.mobilization', 'gh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sinojp.two_regimes', 'gh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sinojp.to_us_conflict', 'gh.3.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.pacificwar.causes', 'gh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.pacificwar.co_prosperity', 'gh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.pacificwar.extent_geo', 'gh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.pacificwar.home_front', 'gh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.pacificwar.end_order', 'gh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.pacificwar.postwar_division', 'gh.3.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.occupation.policy_shift', 'gh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.occupation.three_reforms', 'gh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.occupation.two_constitutions', 'gh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.occupation.independence_order', 'gh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.occupation.korean_war_boom', 'gh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.occupation.territory_geo', 'gh.4.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.growth.causes', 'gh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.growth.pollution', 'gh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.growth.diplomacy_order', 'gh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.growth.end', 'gh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.growth.belt_geo', 'gh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpcwend.new_role', 'gh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpcwend.bubble', 'gh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpcwend.1955_system', 'gh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jpcwend.east_asia_order', 'gh.4.2.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jptoday.aging', 'gh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jptoday.globalization', 'gh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jptoday.disaster_energy', 'gh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.jptoday.regional_geo', 'gh.4.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.orient.unification_extent_geo', 'wh.2.1.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.china.warring_states_geo', 'wh.2.3.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.frankish_partition_geo', 'wh.2.6.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.medcult.plague_route_geo', 'wh.3.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.reformation.confession_map_geo', 'wh.3.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.usrev.thirteen_colonies_geo', 'wh.4.1.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sea.mainland_vs_island', 'wh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.sea.vietnam_independence', 'wh.2.2.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.eastasia.ritsuryo_reception', 'wh.2.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.eastasia.tributary_logic', 'wh.2.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.eastasia.sphere_geo', 'wh.2.3.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.innerasia.steppe_geo', 'wh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.innerasia.nomad_military', 'wh.2.4.1') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.trade.two_directions', 'wh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.trade.paper_westward', 'wh.2.4.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.byzantine_longevity', 'wh.2.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.russia_order', 'wh.2.6.2') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.monastery_vs_church', 'wh.2.6.3') ON CONFLICT DO NOTHING;
INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES ('kc.euro.church_power', 'wh.2.6.3') ON CONFLICT DO NOTHING;

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
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.hominid_stages', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.hominid_stages', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.hominid_stages', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.human_dispersal_geo', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.human_dispersal_geo', 9, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.human_dispersal_geo', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.human_dispersal_geo', 6, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.bipedalism_effects', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.fire_burial_art', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.fire_burial_art', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.fire_burial_art', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.stone_age_division', 9, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.prehist.stone_age_division', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.food_production_causes', 9, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.neolithic_toolkit', 9, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.fertile_crescent_geo', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.fertile_crescent_geo', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.fertile_crescent_geo', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.fertile_crescent_geo', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.irrigation_to_state', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.irrigation_to_state', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.metal_age_order', 9, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.neolithic.metal_age_order', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.source.primary_vs_secondary', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.source.material_vs_written', 9, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.source.bias_in_records', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.source.periodization_problem', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.source.periodization_problem', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.samanid_to_ghaznavid', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.samanid_to_ghaznavid', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.samanid_to_ghaznavid', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.turkification_causes', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.seljuk_sultanate', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.seljuk_sultanate', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.mamluk_and_iqta', 14, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.mamluk_and_iqta', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.anatolia_turkification_geo', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.anatolia_turkification_geo', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.anatolia_turkification_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.ghaznavid_india_causes', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.turkiran.ghaznavid_india_causes', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.delhi_sultanate_order', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.bhakti_and_sufism', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.sea_route_islam_geo', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.sea_route_islam_geo', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.west_africa_states', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.west_africa_states', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.swahili_coast_geo', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.swahili_coast_geo', 12, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.swahili_coast_geo', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.sufi_role', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.sufi_role', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.islamize.sufi_role', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.song.civil_supremacy_causes', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.song.northern_peoples', 20, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.song.northern_peoples', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.song.wang_anshi_reform', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.song.north_to_south_geo', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.song.north_to_south_geo', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.song.economic_revolution', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.song.scholar_officials', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.expansion_order', 20, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.expansion_order', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.expansion_order', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.expansion_order', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.four_khanates_geo', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.four_khanates_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.four_khanates_geo', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.yuan_hierarchy', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.yuan_hierarchy', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.pax_mongolica', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.pax_mongolica', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.pax_mongolica', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.yuan_fall_causes', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.yuan_fall_causes', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.khanate_religion', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mongol.khanate_religion', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.first_crusade_causes', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.first_crusade_causes', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.expedition_order', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.expedition_order', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.consequences', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.consequences', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.two_trade_zones', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.two_trade_zones', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.two_trade_zones', 5, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.trade_routes_geo', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.trade_routes_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.trade_routes_geo', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.crusade.manor_decline', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.papal_decline_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.papal_decline_order', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.parliament_vs_etats', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.hundred_years_war', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.hre_vs_france', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.europe_1500_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.europe_1500_geo', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.europe_1500_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.reconquista', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medstate.reconquista', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.black_death_effects', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.black_death_effects', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.realism_vs_nominalism', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.medieval_universities', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.medieval_universities', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.romanesque_vs_gothic', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.wyclif_and_hus', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.wyclif_and_hus', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.ming_vs_qing_rule', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.ming_vs_qing_rule', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.haijin_and_tribute', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.haijin_and_tribute', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.tax_silver_reform', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.tax_silver_reform', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.ming_fall_order', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.ming_fall_order', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.qing_territory_geo', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.qing_territory_geo', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.qing_territory_geo', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.new_crops_population', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mingqing.new_crops_population', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.expansion_order', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.expansion_order', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.expansion_order', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.devshirme_and_timar', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.devshirme_and_timar', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.millet_system', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.millet_system', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.sunni_vs_shia_states', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.sunni_vs_shia_states', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.three_empires_geo', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.three_empires_geo', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.three_empires_geo', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.mediterranean_decline', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.mediterranean_decline', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ottoman.mediterranean_decline', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mughal.emperor_order', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mughal.akbar_vs_aurangzeb', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mughal.mansabdar', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mughal.decline_causes', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.mughal.indo_islamic_culture', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.motives', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.motives', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.motives', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.two_routes_geo', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.two_routes_geo', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.two_routes_geo', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.two_routes_geo', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.tordesillas', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.tordesillas', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.commercial_revolution', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.commercial_revolution', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.commercial_revolution', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.east_india_companies', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.east_india_companies', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.east_india_companies', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.gutsherrschaft', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.voyage.gutsherrschaft', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.three_civilizations', 8, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.conquest_order', 8, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.conquest_order', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.conquest_causes', 8, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.encomienda', 8, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.triangular_trade_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.triangular_trade_geo', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.triangular_trade_geo', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.triangular_trade_geo', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.columbian_exchange', 8, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.columbian_exchange', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.atlantic.columbian_exchange', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.why_italy', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.why_italy', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.humanism', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.humanism', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.three_inventions', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.three_inventions', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.northern', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.northern', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.renaissance.printing_effects', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.luther_causes', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.luther_causes', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.luther_vs_calvin', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.settlement_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.anglican', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.counter_reformation', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.counter_reformation', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.counter_reformation', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.counter_reformation', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.wars_to_state', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.sovereign_state', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.machinery', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.mercantilism_types', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.mercantilism_types', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.hegemony_order', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.hegemony_order', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.english_revolution', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.europe_1700_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.europe_1700_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.absolutism.europe_1700_geo', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.why_britain', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.why_britain', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.why_britain', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.textile_inventions', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.steam_to_transport', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.steam_to_transport', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.social_change', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.regions_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.industrial.labour_to_socialism', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.causes', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.causes', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.war_order', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.war_order', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.declaration_vs_constitution', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.world_impact', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.world_impact', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.world_impact', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.foreign_support', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.foreign_support', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.foreign_support', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.causes', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.causes', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.stages_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.declaration_vs_code', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.terror_causes', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.napoleonic_europe_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.napoleonic_europe_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.napoleonic_europe_geo', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.napoleon_fall', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.napoleon_fall', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.frrev.napoleon_fall', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.principles', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.principles', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.map_1815_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.map_1815_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.map_1815_geo', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.liberal_movements_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.liberal_movements_order', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.liberal_movements_order', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.1848_spread', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.1848_spread', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.latin_america', 8, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.latin_america', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.latin_america', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.vienna.british_reforms', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.italy_vs_germany', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.italy_vs_germany', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.three_wars', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.three_wars', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.garibaldi', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.irredenta_geo', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.irredenta_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.bismarck_system', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.bismarck_system', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.unification.bismarck_system', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.us_expansion_order', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.us_expansion_order', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.us_expansion_order', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.civil_war_causes', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.north_vs_south', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.north_vs_south', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.russian_reform', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.russian_reform', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.science_and_thought', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.migration_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.migration_geo', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.migration_geo', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.c19soc.migration_geo', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.reform_order', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.eastern_question', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.eastern_question', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.eastern_question', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.balkan_geo', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.balkan_geo', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.egypt_vs_iran', 14, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.egypt_vs_iran', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.egypt_vs_iran', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.islamic_revival', 12, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.westasia19.islamic_revival', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indiacol.conquest_order', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indiacol.conquest_order', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indiacol.sepoy_mutiny', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indiacol.sepoy_mutiny', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indiacol.zamindari_vs_ryotwari', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indiacol.deindustrialization', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indiacol.deindustrialization', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indiacol.congress_shift', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.opium_war_causes', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.opium_war_causes', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.opium_war_causes', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.unequal_treaties', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.unequal_treaties', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.unequal_treaties', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.taiping', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.yangwu_vs_meiji', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.yangwu_vs_meiji', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.spheres_geo', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.spheres_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.spheres_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.spheres_geo', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.opening_chain', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.opening_chain', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.opening_chain', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.qingfall.opening_chain', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.causes', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.second_industrial', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.second_industrial', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.alliance_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.alliance_order', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.weltpolitik', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.weltpolitik', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.weltpolitik', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.3b_3c_geo', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.3b_3c_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.3b_3c_geo', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.3b_3c_geo', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.us_vs_russia', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.us_vs_russia', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.imperialism.us_vs_russia', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.africa_order', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.africa_order', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.longitudinal_geo', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.longitudinal_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.longitudinal_geo', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.two_independent', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.two_independent', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.two_independent', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.boer_war', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.boer_war', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.pacific_geo', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.pacific_geo', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.pacific_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.sea_colonies', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.partition.sea_colonies', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.boxer', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.boxer', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.boxer', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.boxer', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.xinhai_order', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.xinhai_order', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.leaders', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.leaders', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.leaders', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.russo_japanese_impact', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.russo_japanese_impact', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.russo_japanese_impact', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.russo_japanese_impact', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asianation.three_principles', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.causes', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.causes', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.causes', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.total_war', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.turning_points', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.turning_points', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.turning_points', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.british_promises', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.british_promises', 12, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.british_promises', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.fronts_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.fronts_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.fronts_geo', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.empires_collapse', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.empires_collapse', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww1.empires_collapse', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.two_revolutions', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.bolshevik_causes', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.war_communism_vs_nep', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.intervention', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.intervention', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.intervention', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.intervention', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.ussr_and_comintern', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.ussr_and_comintern', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.rusrev.ussr_and_comintern', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.two_systems', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.two_systems', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.two_systems', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.german_terms', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.league_weakness', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.league_weakness', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.new_states_geo', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.new_states_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.mandate_system', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.mandate_system', 12, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.mandate_system', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.cooperation_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.versailles.cooperation_order', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.spread', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.spread', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.spread', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.responses', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.responses', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.responses', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.fascism_causes', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.fascism_causes', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.italy_vs_germany', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.italy_vs_germany', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.german_revision', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.german_revision', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.appeasement', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.depression.appeasement', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.turning_points', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.turning_points', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.turning_points', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.turning_points', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.axis_vs_allies', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.axis_vs_allies', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.axis_vs_allies', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.axis_vs_allies', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.axis_extent_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.axis_extent_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.axis_extent_geo', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.axis_extent_geo', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.eastern_front', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.eastern_front', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.conferences', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.conferences', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.conferences', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.holocaust', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ww2.holocaust', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.origin', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.origin', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.origin', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.marshall_vs_comecon', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.marshall_vs_comecon', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.marshall_vs_comecon', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.blocs_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.blocs_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.blocs_geo', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.blocs_geo', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.german_division', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.german_division', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.german_division', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.china_prc', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.china_prc', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.china_prc', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.china_prc', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.arms_race', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.coldwar.arms_race', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.india_partition', 16, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.india_partition', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.sea_independence', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.sea_independence', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.sea_independence', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.africa_year_geo', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.africa_year_geo', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.africa_year_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.bandung', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.bandung', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.bandung', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.artificial_borders', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.apartheid', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.decolonize.apartheid', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.middle_east_geo', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.middle_east_geo', 12, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.middle_east_geo', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.middle_east_order', 11, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.middle_east_order', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.middle_east_order', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.vietnam_causes', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.vietnam_causes', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.vietnam_causes', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.oil_shock', 12, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.oil_shock', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.oil_shock', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.oil_shock', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.sino_soviet', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.sino_soviet', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.sino_soviet', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.latin_america_coldwar', 8, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.latin_america_coldwar', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.regionalwar.latin_america_coldwar', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.detente_causes', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.detente_causes', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.detente_causes', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.second_cold_war', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.second_cold_war', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.second_cold_war', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.perestroika', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.perestroika', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.east_europe_1989', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.east_europe_1989', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.germany_and_ussr_geo', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.germany_and_ussr_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.yugoslavia_causes', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.detente.yugoslavia_causes', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.eu_integration_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.eu_integration_order', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.multipolar', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.multipolar', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.multipolar', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.multipolar', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.regional_blocs_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.regional_blocs_geo', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.regional_blocs_geo', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.regional_blocs_geo', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.terror_and_intervention', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.terror_and_intervention', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.terror_and_intervention', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.common_issues', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.common_issues', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.global.common_issues', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ghsource.chronology_tools', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ghsource.chronology_tools', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ghsource.statistics_reading', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ghsource.statistics_reading', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ghsource.map_as_argument', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ghsource.multiple_perspectives', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.ghsource.multiple_perspectives', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.three_empires_prosperity', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.three_empires_prosperity', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.three_empires_prosperity', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.silver_flow_geo', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.silver_flow_geo', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.silver_flow_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.silver_flow_geo', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.edo_isolation', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.edo_isolation', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.edo_isolation', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.edo_isolation', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.asian_trade_causes', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.asian_trade_causes', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.asian_trade_causes', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.asian_trade_causes', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.prosperity_to_crisis', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.prosperity_to_crisis', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.asia18.prosperity_to_crisis', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.slave_trade_scale', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.slave_trade_scale', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.slave_trade_scale', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.slave_trade_scale', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.plantation_system', 8, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.plantation_system', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.plantation_system', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.africa_impact', 15, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.africa_impact', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.abolition_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.abolition_order', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.abolition_order', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.capital_to_industry', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.capital_to_industry', 15, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.triangle.capital_to_industry', 8, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indsoc.work_and_time', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indsoc.urban_problems', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indsoc.family_and_gender', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indsoc.spread_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indsoc.spread_geo', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indsoc.spread_geo', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.indsoc.labour_movement', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.what_is_nation', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.making_citizens', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.making_citizens', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.suffrage_order', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.suffrage_order', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.nationalism_two_faces', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.nationalism_two_faces', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.nationalism_two_faces', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.japan_comparison', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.nationstate.japan_comparison', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.opening_causes', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.opening_causes', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.opening_causes', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.two_treaties', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.two_treaties', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.two_treaties', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.trade_impact', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.trade_impact', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.sonno_joi_shift', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.sonno_joi_shift', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.treaty_ports_geo', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.treaty_ports_geo', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.bakumatsu.treaty_ports_geo', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.meiji.centralization', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.meiji.three_reforms', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.meiji.three_reforms', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.meiji.westernization_limits', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.meiji.westernization_limits', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.meiji.opposition', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.meiji.treaty_revision', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.meiji.treaty_revision', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.model_choice', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.model_choice', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.emperor_and_diet', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.early_diet_conflict', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.education_rescript', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.compare_asia', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.compare_asia', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.compare_asia', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.constitution.compare_asia', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.sino_japanese_causes', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.sino_japanese_causes', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.sino_japanese_causes', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.sino_japanese_causes', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.shimonoseki_and_triple', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.shimonoseki_and_triple', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.shimonoseki_and_triple', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.shimonoseki_and_triple', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.russo_japanese_causes', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.russo_japanese_causes', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.russo_japanese_causes', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.russo_japanese_causes', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.portsmouth_limits', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.portsmouth_limits', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.portsmouth_limits', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.korea_annexation', 23, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.korea_annexation', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.korea_annexation', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.northeast_asia_geo', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.northeast_asia_geo', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.northeast_asia_geo', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpwars.northeast_asia_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_ww1', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_ww1', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_ww1', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.21_demands', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.21_demands', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.self_determination_asia', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.self_determination_asia', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.self_determination_asia', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.self_determination_asia', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_league', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_league', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_league', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.wartime_boom', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.wartime_boom', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_mandate_geo', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_mandate_geo', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.totalwar.japan_mandate_geo', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.causes', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.causes', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.causes', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.us_1920s', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.japan_culture', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.womens_suffrage', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.womens_suffrage', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.womens_suffrage', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.media_power', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.media_power', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.masssoc.media_power', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.party_politics_order', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.two_laws', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.two_laws', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.social_movements', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.minpon', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.minpon', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.great_quake', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.japan_vs_west', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.taisho.japan_vs_west', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.showa_depression', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.showa_depression', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.rural_crisis', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.rural_crisis', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.army_rise', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.army_rise', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.takahashi', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.takahashi', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.takahashi', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.export_shift_geo', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.export_shift_geo', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.export_shift_geo', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpdep.export_shift_geo', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.order', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.order', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.order', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.domestic_impact', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.puppet_state', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.puppet_state', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.geo', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.geo', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.geo', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.league_failure', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.league_failure', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.manchuria.league_failure', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.prolongation', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.prolongation', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.prolongation', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.prolongation', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.order', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.order', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.supply_routes_geo', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.supply_routes_geo', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.supply_routes_geo', 16, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.supply_routes_geo', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.mobilization', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.two_regimes', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.two_regimes', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.to_us_conflict', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.to_us_conflict', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sinojp.to_us_conflict', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.causes', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.causes', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.causes', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.co_prosperity', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.co_prosperity', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.extent_geo', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.extent_geo', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.extent_geo', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.home_front', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.home_front', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.end_order', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.end_order', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.end_order', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.postwar_division', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.postwar_division', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.postwar_division', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.pacificwar.postwar_division', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.policy_shift', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.policy_shift', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.policy_shift', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.three_reforms', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.two_constitutions', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.two_constitutions', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.independence_order', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.independence_order', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.independence_order', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.korean_war_boom', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.korean_war_boom', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.korean_war_boom', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.territory_geo', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.territory_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.occupation.territory_geo', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.causes', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.causes', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.causes', 12, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.pollution', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.diplomacy_order', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.diplomacy_order', 21, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.diplomacy_order', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.end', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.end', 12, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.end', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.growth.belt_geo', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.new_role', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.new_role', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.new_role', 12, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.bubble', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.bubble', 7, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.1955_system', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.east_asia_order', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.east_asia_order', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.east_asia_order', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jpcwend.east_asia_order', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.aging', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.aging', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.globalization', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.globalization', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.globalization', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.disaster_energy', 24, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.regional_geo', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.regional_geo', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.regional_geo', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.jptoday.regional_geo', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.orient.unification_extent_geo', 10, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.orient.unification_extent_geo', 14, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.orient.unification_extent_geo', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.china.warring_states_geo', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.frankish_partition_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.plague_route_geo', 3, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.plague_route_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.plague_route_geo', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.medcult.plague_route_geo', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.confession_map_geo', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.confession_map_geo', 4, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.confession_map_geo', 5, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.reformation.confession_map_geo', 3, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.thirteen_colonies_geo', 7, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.usrev.thirteen_colonies_geo', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sea.mainland_vs_island', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sea.vietnam_independence', 17, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.sea.vietnam_independence', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.ritsuryo_reception', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.ritsuryo_reception', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.ritsuryo_reception', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.tributary_logic', 22, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.tributary_logic', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.tributary_logic', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.tributary_logic', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.sphere_geo', 21, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.sphere_geo', 23, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.sphere_geo', 24, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.eastasia.sphere_geo', 17, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.steppe_geo', 20, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.steppe_geo', 19, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.steppe_geo', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.nomad_military', 20, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.innerasia.nomad_military', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.two_directions', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.two_directions', 22, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.two_directions', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.paper_westward', 19, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.paper_westward', 10, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.trade.paper_westward', 2, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.byzantine_longevity', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.byzantine_longevity', 11, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.russia_order', 4, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.russia_order', 20, false) ON CONFLICT DO NOTHING;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.monastery_vs_church', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.church_power', 2, true)
  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;
INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.euro.church_power', 3, false) ON CONFLICT DO NOTHING;

-- 正典イベント 1180 件（承認されず除外 0）
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.hammurabi_code', 'ハンムラビ法典', ARRAY['ハンムラビ法典の制定']::text[], -1750, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.babylon1_unify', 'バビロン第1王朝のメソポタミア統一', ARRAY['古バビロニア王国']::text[], -1750, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.akkad_unify', 'アッカドのメソポタミア統一', ARRAY['サルゴン1世の統一']::text[], -2300, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.hittite_iron', 'ヒッタイトの鉄器使用', '{}'::text[], -1600, -1200, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.assyria_unify', 'アッシリアのオリエント統一', ARRAY['アッシリア帝国']::text[], -670, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.assyria_fall', 'アッシリアの滅亡', '{}'::text[], -612, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.achaemenid_found', 'アケメネス朝の建国', ARRAY['アケメネス朝ペルシアの成立']::text[], -550, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.achaemenid_unify', 'アケメネス朝のオリエント再統一', '{}'::text[], -525, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.darius_satrap', 'ダレイオス1世のサトラップ制', ARRAY['知事制','王の目・王の耳']::text[], -522, -486, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.achaemenid_fall', 'アケメネス朝の滅亡', '{}'::text[], -330, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.parthia_found', 'パルティアの建国', ARRAY['アルサケス朝']::text[], -248, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.sasan_found', 'ササン朝の建国', ARRAY['ササン朝ペルシア']::text[], 226, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.sasan_fall', 'ササン朝の滅亡', '{}'::text[], 651, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.phoenicia_alphabet', 'フェニキア文字の成立', '{}'::text[], -1000, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.orient.hebrew_babylon_captivity', 'バビロン捕囚', '{}'::text[], -586, -538, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.egypt.old_kingdom', 'エジプト古王国', '{}'::text[], -2700, -2200, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.egypt.middle_kingdom', 'エジプト中王国', '{}'::text[], -2050, -1650, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.egypt.new_kingdom', 'エジプト新王国', '{}'::text[], -1550, -1070, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.egypt.amarna_reform', 'アマルナ改革', ARRAY['アメンホテプ4世の宗教改革','イクナートン']::text[], -1350, NULL, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.egypt.ptolemaic_found', 'プトレマイオス朝の成立', '{}'::text[], -304, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.egypt.ptolemaic_fall', 'プトレマイオス朝の滅亡', '{}'::text[], -30, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.polis_formation', 'ポリスの成立', '{}'::text[], -800, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.solon_reform', 'ソロンの改革', ARRAY['財産政治']::text[], -594, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.peisistratos', 'ペイシストラトスの僭主政', '{}'::text[], -561, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.cleisthenes_reform', 'クレイステネスの改革', '{}'::text[], -508, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.persian_wars', 'ペルシア戦争', '{}'::text[], -500, -449, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.marathon', 'マラトンの戦い', '{}'::text[], -490, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.salamis', 'サラミスの海戦', '{}'::text[], -480, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.delian_league', 'デロス同盟の結成', '{}'::text[], -478, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.pericles_age', 'ペリクレス時代', '{}'::text[], -443, -429, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.peloponnesian_war', 'ペロポネソス戦争', '{}'::text[], -431, -404, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.chaeronea', 'カイロネイアの戦い', '{}'::text[], -338, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.alexander_east', 'アレクサンドロスの東方遠征', ARRAY['東方遠征']::text[], -334, -324, 'exact', ARRAY[3,10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.issus', 'イッソスの戦い', '{}'::text[], -333, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.greece.gaugamela', 'アルベラの戦い', ARRAY['ガウガメラの戦い']::text[], -331, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.republic_found', 'ローマ共和政の成立', '{}'::text[], -509, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.twelve_tables', '十二表法', '{}'::text[], -450, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.licinius_sextius', 'リキニウス・セクスティウス法', ARRAY['リキニウス法']::text[], -367, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.hortensius', 'ホルテンシウス法', '{}'::text[], -287, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.punic_war1', '第1回ポエニ戦争', '{}'::text[], -264, -241, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.punic_war2', '第2回ポエニ戦争', ARRAY['ハンニバル戦争']::text[], -218, -201, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.punic_war3', '第3回ポエニ戦争', '{}'::text[], -149, -146, 'exact', ARRAY[3,14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.gracchus_reform', 'グラックス兄弟の改革', '{}'::text[], -133, -121, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.first_triumvirate', '第1回三頭政治', '{}'::text[], -60, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.caesar_assassination', 'カエサルの暗殺', '{}'::text[], -44, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.actium', 'アクティウムの海戦', '{}'::text[], -31, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.principate_start', '元首政の開始', ARRAY['プリンキパトゥス','アウグストゥスの称号授与']::text[], -27, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.pax_romana', 'ローマの平和', ARRAY['パクス・ロマーナ']::text[], -27, 180, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.five_good_emperors', '五賢帝時代', '{}'::text[], 96, 180, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.caracalla_citizenship', 'アントニヌス勅令', ARRAY['カラカラ帝の市民権付与']::text[], 212, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.military_anarchy', '軍人皇帝時代', '{}'::text[], 235, 284, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.dominate_start', '専制君主政の開始', ARRAY['ドミナトゥス','四帝分治制']::text[], 284, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.milan_edict', 'ミラノ勅令', '{}'::text[], 313, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.nicaea_council', 'ニケーア公会議', '{}'::text[], 325, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.constantinople_capital', 'コンスタンティノープル遷都', ARRAY['ビザンティウム改称']::text[], 330, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.christianity_state', 'キリスト教の国教化', '{}'::text[], 392, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.empire_division', 'ローマ帝国の東西分割', '{}'::text[], 395, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.west_fall', '西ローマ帝国の滅亡', '{}'::text[], 476, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.ephesus_council', 'エフェソス公会議', '{}'::text[], 431, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rome.chalcedon_council', 'カルケドン公会議', '{}'::text[], 451, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.indus_civilization', 'インダス文明', ARRAY['ハラッパー','モエンジョ・ダーロ']::text[], -2600, -1800, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.aryan_migration', 'アーリヤ人のインド侵入', '{}'::text[], -1500, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.buddhism_founded', '仏教の成立', ARRAY['ガウタマ・シッダールタ','ブッダ']::text[], -500, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.jainism_founded', 'ジャイナ教の成立', ARRAY['ヴァルダマーナ']::text[], -500, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.maurya_found', 'マウリヤ朝の成立', '{}'::text[], -317, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.ashoka_reign', 'アショーカ王の治世', '{}'::text[], -268, -232, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.kushan_rise', 'クシャーナ朝の成立', '{}'::text[], 60, NULL, 'century', ARRAY[16,19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.gupta_found', 'グプタ朝の成立', '{}'::text[], 320, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.harsha', 'ヴァルダナ朝', ARRAY['ハルシャ・ヴァルダナ']::text[], 606, 647, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.delhi_sultanate', 'デリー・スルタン朝の成立', ARRAY['奴隷王朝']::text[], 1206, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.mughal_found', 'ムガル帝国の成立', ARRAY['パーニーパットの戦い']::text[], 1526, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.akbar_reign', 'アクバルの治世', '{}'::text[], 1556, 1605, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.aurangzeb_jizya', 'アウラングゼーブの人頭税復活', ARRAY['ジズヤ復活']::text[], 1679, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.plassey', 'プラッシーの戦い', '{}'::text[], 1757, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.sepoy_mutiny', 'インド大反乱', ARRAY['シパーヒーの反乱','セポイの反乱']::text[], 1857, 1859, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.british_raj', 'インド帝国の成立', '{}'::text[], 1877, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.bengal_partition', 'ベンガル分割令', ARRAY['カーゾン法']::text[], 1905, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.congress_calcutta', 'インド国民会議カルカッタ大会', ARRAY['四綱領']::text[], 1906, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.amritsar', 'アムリットサール事件', '{}'::text[], 1919, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.salt_march', '塩の行進', '{}'::text[], 1930, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.india.independence', 'インド・パキスタンの分離独立', '{}'::text[], 1947, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.yin_shang', '殷', ARRAY['殷王朝']::text[], -1600, -1050, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.zhou_found', '周の成立', ARRAY['西周']::text[], -1050, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.spring_autumn', '春秋時代', '{}'::text[], -770, -403, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.warring_states', '戦国時代', '{}'::text[], -403, -221, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.qin_unify', '秦の中国統一', ARRAY['始皇帝の統一']::text[], -221, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.chen_sheng', '陳勝・呉広の乱', '{}'::text[], -209, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.former_han', '前漢の成立', '{}'::text[], -202, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.wudi_confucian', '武帝の儒学官学化', ARRAY['五経博士']::text[], -136, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.zhang_qian', '張騫の西域派遣', '{}'::text[], -139, NULL, 'exact', ARRAY[22,19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.wang_mang_xin', '新の建国', '{}'::text[], 8, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.later_han', '後漢の成立', '{}'::text[], 25, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.yellow_turban', '黄巾の乱', '{}'::text[], 184, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.three_kingdoms', '三国時代', '{}'::text[], 220, 280, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.jin_unify', '晋の中国統一', ARRAY['西晋']::text[], 280, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.eight_princes', '八王の乱', '{}'::text[], 291, 306, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.northern_southern', '南北朝時代', '{}'::text[], 439, 589, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.northern_wei_unify', '北魏の華北統一', '{}'::text[], 439, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.xiaowen_reform', '孝文帝の漢化政策', ARRAY['洛陽遷都']::text[], 494, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.sui_unify', '隋の中国統一', '{}'::text[], 589, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.grand_canal', '大運河の完成', '{}'::text[], 610, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.tang_found', '唐の建国', '{}'::text[], 618, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.zhenguan', '貞観の治', '{}'::text[], 627, 649, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.kaiyuan', '開元の治', '{}'::text[], 713, 741, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.an_lushan', '安史の乱', ARRAY['安禄山の乱']::text[], 755, 763, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.liangshui', '両税法', '{}'::text[], 780, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.huang_chao', '黄巣の乱', '{}'::text[], 875, 884, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.tang_fall', '唐の滅亡', '{}'::text[], 907, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.song_found', '宋の建国', ARRAY['北宋']::text[], 960, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.wang_anshi', '王安石の新法', '{}'::text[], 1069, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.jingkang', '靖康の変', '{}'::text[], 1126, 1127, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.southern_song', '南宋の成立', '{}'::text[], 1127, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.mongol_found', 'モンゴル帝国の成立', '{}'::text[], 1206, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.yuan_found', '元の建国', '{}'::text[], 1271, NULL, 'exact', ARRAY[22,20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.southern_song_fall', '南宋の滅亡', '{}'::text[], 1279, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.red_turban', '紅巾の乱', '{}'::text[], 1351, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.ming_found', '明の建国', '{}'::text[], 1368, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.yongle_beijing', '永楽帝の北京遷都', '{}'::text[], 1421, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.zheng_he_voyage', '鄭和の南海遠征', '{}'::text[], 1405, 1433, 'exact', ARRAY[22,17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.tumu', '土木の変', '{}'::text[], 1449, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.ming_fall', '明の滅亡', ARRAY['李自成の乱']::text[], 1644, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.qing_found', '後金の建国', '{}'::text[], 1616, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.three_feudatories', '三藩の乱', '{}'::text[], 1673, 1681, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.nerchinsk', 'ネルチンスク条約', '{}'::text[], 1689, NULL, 'exact', ARRAY[22,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.kyakhta', 'キャフタ条約', '{}'::text[], 1727, NULL, 'exact', ARRAY[22,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.canton_system', '広州一港への制限', '{}'::text[], 1757, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.opium_war', 'アヘン戦争', '{}'::text[], 1840, 1842, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.nanjing_treaty', '南京条約', '{}'::text[], 1842, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.taiping', '太平天国の乱', '{}'::text[], 1851, 1864, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.arrow_war', 'アロー戦争', ARRAY['第2次アヘン戦争']::text[], 1856, 1860, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.beijing_treaty', '北京条約', '{}'::text[], 1860, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.self_strengthening', '洋務運動', '{}'::text[], 1861, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.sino_japanese_war', '日清戦争', '{}'::text[], 1894, 1895, 'exact', ARRAY[22,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.shimonoseki', '下関条約', '{}'::text[], 1895, NULL, 'exact', ARRAY[22,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.hundred_days', '戊戌の変法', ARRAY['変法運動']::text[], 1898, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.boxer', '義和団事件', ARRAY['義和団の乱']::text[], 1900, 1901, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.beijing_protocol', '北京議定書', ARRAY['辛丑和約']::text[], 1901, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.xinhai', '辛亥革命', '{}'::text[], 1911, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.roc_found', '中華民国の成立', '{}'::text[], 1912, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.may_fourth', '五・四運動', '{}'::text[], 1919, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.ccp_found', '中国共産党の成立', '{}'::text[], 1921, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.first_united_front', '第1次国共合作', '{}'::text[], 1924, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.northern_expedition', '北伐', '{}'::text[], 1926, 1928, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.manchurian_incident', '満州事変', ARRAY['柳条湖事件']::text[], 1931, NULL, 'exact', ARRAY[22,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.long_march', '長征', '{}'::text[], 1934, 1936, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.xian_incident', '西安事件', '{}'::text[], 1936, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.second_sino_japanese', '日中戦争', '{}'::text[], 1937, 1945, 'exact', ARRAY[22,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.prc_found', '中華人民共和国の成立', '{}'::text[], 1949, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.great_leap', '大躍進政策', '{}'::text[], 1958, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.cultural_revolution', '文化大革命', '{}'::text[], 1966, 1976, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.reform_opening', '改革開放', '{}'::text[], 1978, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.china.tiananmen', '天安門事件', ARRAY['第2次天安門事件']::text[], 1989, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.hijra', 'ヒジュラ', ARRAY['聖遷']::text[], 622, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.muhammad_death', 'ムハンマドの死', '{}'::text[], 632, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.rashidun', '正統カリフ時代', '{}'::text[], 632, 661, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.nihavand', 'ニハーヴァンドの戦い', '{}'::text[], 642, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.umayyad_found', 'ウマイヤ朝の成立', '{}'::text[], 661, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.tours_poitiers', 'トゥール・ポワティエ間の戦い', '{}'::text[], 732, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.abbasid_found', 'アッバース朝の成立', '{}'::text[], 750, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.talas', 'タラス河畔の戦い', '{}'::text[], 751, NULL, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.baghdad_found', 'バグダードの建設', '{}'::text[], 762, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.later_umayyad', '後ウマイヤ朝の成立', '{}'::text[], 756, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.fatimid_found', 'ファーティマ朝の成立', '{}'::text[], 909, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.buyid_baghdad', 'ブワイフ朝のバグダード入城', '{}'::text[], 946, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.seljuk_baghdad', 'セルジューク朝のバグダード入城', '{}'::text[], 1055, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.manzikert', 'マンジケルトの戦い', ARRAY['マラズギルトの戦い']::text[], 1071, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.ayyubid_found', 'アイユーブ朝の成立', '{}'::text[], 1169, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.jerusalem_recapture', 'サラディンのイェルサレム奪回', '{}'::text[], 1187, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.mamluk_found', 'マムルーク朝の成立', '{}'::text[], 1250, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.abbasid_fall', 'アッバース朝の滅亡', '{}'::text[], 1258, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.ilkhan_found', 'イル・ハン国の成立', '{}'::text[], 1258, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.ain_jalut', 'アイン・ジャールートの戦い', '{}'::text[], 1260, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.timur_found', 'ティムール朝の成立', '{}'::text[], 1370, NULL, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.ankara', 'アンカラの戦い', '{}'::text[], 1402, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.granada_fall', 'グラナダの陥落', ARRAY['ナスル朝の滅亡','レコンキスタの完了']::text[], 1492, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.safavid_found', 'サファヴィー朝の成立', '{}'::text[], 1501, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.abbas1', 'アッバース1世の治世', '{}'::text[], 1587, 1629, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.ottoman_found', 'オスマン帝国の成立', ARRAY['オスマン朝の成立']::text[], 1299, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.kosovo', 'コソヴォの戦い', '{}'::text[], 1389, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.constantinople_fall', 'コンスタンティノープルの陥落', ARRAY['ビザンツ帝国の滅亡']::text[], 1453, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.mamluk_fall', 'マムルーク朝の滅亡', '{}'::text[], 1517, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.mohacs', 'モハーチの戦い', '{}'::text[], 1526, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.vienna_siege1', '第1次ウィーン包囲', '{}'::text[], 1529, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.preveza', 'プレヴェザの海戦', '{}'::text[], 1538, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.lepanto', 'レパントの海戦', '{}'::text[], 1571, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.vienna_siege2', '第2次ウィーン包囲', '{}'::text[], 1683, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.karlowitz', 'カルロヴィッツ条約', '{}'::text[], 1699, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.wahhab', 'ワッハーブ運動', ARRAY['ワッハーブ王国']::text[], 1744, NULL, 'century', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.tanzimat', 'タンジマート', ARRAY['恩恵改革']::text[], 1839, 1876, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.ottoman_constitution', 'ミドハト憲法', ARRAY['オスマン帝国憲法']::text[], 1876, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.young_turk', '青年トルコ革命', '{}'::text[], 1908, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.sevres', 'セーヴル条約', '{}'::text[], 1920, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.lausanne', 'ローザンヌ条約', '{}'::text[], 1923, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.turkey_republic', 'トルコ共和国の成立', '{}'::text[], 1923, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.caliphate_abolished', 'カリフ制の廃止', '{}'::text[], 1924, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.pahlavi_found', 'パフレヴィー朝の成立', '{}'::text[], 1925, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.islam.saudi_found', 'サウジアラビア王国の成立', '{}'::text[], 1932, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.germanic_migration', 'ゲルマン人の大移動', '{}'::text[], 375, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.frank_found', 'フランク王国の成立', ARRAY['メロヴィング朝']::text[], 481, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.clovis_conversion', 'クローヴィスの改宗', '{}'::text[], 496, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.benedict_order', 'ベネディクトゥス修道会', ARRAY['モンテ・カシノ修道院']::text[], 529, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.pippin_donation', 'ピピンの寄進', '{}'::text[], 756, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.charlemagne_coronation', 'カール大帝の戴冠', '{}'::text[], 800, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.verdun', 'ヴェルダン条約', '{}'::text[], 843, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.mersen', 'メルセン条約', '{}'::text[], 870, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.hre_found', '神聖ローマ帝国の成立', '{}'::text[], 962, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.capet_found', 'カペー朝の成立', '{}'::text[], 987, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.norman_conquest', 'ノルマン・コンクェスト', ARRAY['ヘースティングズの戦い']::text[], 1066, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.great_schism_1054', '東西教会の分裂', '{}'::text[], 1054, NULL, 'exact', ARRAY[2,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.canossa', 'カノッサの屈辱', ARRAY['カノッサ事件']::text[], 1077, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.worms_concordat', 'ヴォルムス協約', '{}'::text[], 1122, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.crusade1', '第1回十字軍', '{}'::text[], 1096, 1099, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.clermont', 'クレルモン宗教会議', '{}'::text[], 1095, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.crusade3', '第3回十字軍', '{}'::text[], 1189, 1192, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.crusade4', '第4回十字軍', '{}'::text[], 1202, 1204, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.crusade_end', '十字軍の終結', ARRAY['アッコンの陥落']::text[], 1291, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.magna_carta', 'マグナ・カルタ', ARRAY['大憲章']::text[], 1215, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.simon_montfort', 'シモン・ド・モンフォールの議会', '{}'::text[], 1265, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.model_parliament', '模範議会', '{}'::text[], 1295, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.estates_general', 'フィリップ4世の三部会招集', ARRAY['最初の三部会']::text[], 1302, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.avignon', '教皇のバビロン捕囚', ARRAY['アヴィニョン捕囚']::text[], 1309, 1377, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.western_schism', '教会大分裂', ARRAY['大シスマ']::text[], 1378, 1417, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.constance_council', 'コンスタンツ公会議', '{}'::text[], 1414, 1418, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.black_death', '黒死病', ARRAY['ペストの大流行']::text[], 1348, 1350, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.hundred_years', '百年戦争', '{}'::text[], 1339, 1453, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.jacquerie', 'ジャックリーの乱', '{}'::text[], 1358, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.wat_tyler', 'ワット・タイラーの乱', '{}'::text[], 1381, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.roses_war', 'バラ戦争', '{}'::text[], 1455, 1485, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.tudor_found', 'テューダー朝の成立', '{}'::text[], 1485, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.golden_bull', '金印勅書', '{}'::text[], 1356, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.hanseatic', 'ハンザ同盟', '{}'::text[], 1250, NULL, 'century', ARRAY[2,5]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.lombard_league', 'ロンバルディア同盟', '{}'::text[], 1167, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.reconquista_start', 'レコンキスタの本格化', ARRAY['国土回復運動']::text[], 1085, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.medieval.spain_unify', 'スペイン王国の成立', '{}'::text[], 1479, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.justinian_reconquest', 'ユスティニアヌスの地中海再征服', '{}'::text[], 533, 555, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.corpus_juris', 'ローマ法大全', '{}'::text[], 534, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.hagia_sophia', 'ハギア・ソフィア聖堂の完成', ARRAY['聖ソフィア大聖堂']::text[], 537, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.theme_system', '軍管区制', ARRAY['テマ制']::text[], 7, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.iconoclasm', '聖像禁止令', ARRAY['偶像崇拝禁止令']::text[], 726, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.latin_empire', 'ラテン帝国の成立', '{}'::text[], 1204, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.byz_restore', 'ビザンツ帝国の復活', '{}'::text[], 1261, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.kiev_rus', 'キエフ公国', ARRAY['キエフ・ルーシ']::text[], 882, NULL, 'century', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.vladimir_conversion', 'ウラディミル1世の改宗', '{}'::text[], 988, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.mongol_yoke', 'タタールのくびき', ARRAY['キプチャク・ハン国の支配']::text[], 1240, 1480, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.moscow_independence', 'モスクワ大公国の自立', '{}'::text[], 1480, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.ivan4_tsar', 'イヴァン4世のツァーリ戴冠', ARRAY['雷帝']::text[], 1547, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.byz.romanov_found', 'ロマノフ朝の成立', '{}'::text[], 1613, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.funan', '扶南', '{}'::text[], 1, NULL, 'century', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.champa', 'チャンパー', ARRAY['林邑','占城']::text[], 192, NULL, 'century', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.srivijaya', 'シュリーヴィジャヤ王国', ARRAY['室利仏逝']::text[], 670, NULL, 'century', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.borobudur', 'ボロブドゥール', '{}'::text[], 800, NULL, 'century', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.angkor_wat', 'アンコール・ワット', '{}'::text[], 1113, 1150, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.pagan', 'パガン朝', '{}'::text[], 1044, 1287, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.majapahit', 'マジャパヒト王国', '{}'::text[], 1293, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.malacca', 'マラッカ王国', '{}'::text[], 1400, NULL, 'century', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.malacca_portugal', 'ポルトガルのマラッカ占領', '{}'::text[], 1511, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.ayutthaya', 'アユタヤ朝', '{}'::text[], 1351, 1767, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.le_dynasty', '黎朝', '{}'::text[], 1428, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.nguyen', '阮朝', '{}'::text[], 1802, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.dutch_batavia', 'オランダのバタヴィア建設', '{}'::text[], 1619, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.amboina', 'アンボイナ事件', '{}'::text[], 1623, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.culture_system', '強制栽培制度', ARRAY['政府栽培制度']::text[], 1830, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.sino_french', '清仏戦争', '{}'::text[], 1884, 1885, 'exact', ARRAY[17,22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.french_indochina', 'フランス領インドシナ連邦', '{}'::text[], 1887, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.philippine_revolution', 'フィリピン革命', '{}'::text[], 1896, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sea.spanish_american', 'アメリカ・スペイン戦争', ARRAY['米西戦争']::text[], 1898, NULL, 'exact', ARRAY[17,7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.xiongnu', '匈奴の強盛', ARRAY['冒頓単于']::text[], -209, NULL, 'century', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.turk_khaganate', '突厥の成立', '{}'::text[], 552, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.uighur', 'ウイグルの成立', ARRAY['回鶻']::text[], 744, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.khitan_liao', '遼の建国', ARRAY['契丹']::text[], 916, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.chanyuan', '澶淵の盟', '{}'::text[], 1004, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.xixia', '西夏の建国', '{}'::text[], 1038, NULL, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.jurchen_jin', '金の建国', ARRAY['女真']::text[], 1115, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.karakhanid', 'カラハン朝', '{}'::text[], 999, NULL, 'century', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.chagatai', 'チャガタイ・ハン国', '{}'::text[], 1227, NULL, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.kipchak', 'キプチャク・ハン国', ARRAY['ジョチ・ウルス']::text[], 1243, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.wahlstatt', 'ワールシュタットの戦い', ARRAY['リーグニッツの戦い']::text[], 1241, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.inner.dzungar', 'ジュンガルの滅亡', '{}'::text[], 1758, NULL, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.kush', 'クシュ王国', ARRAY['メロエ王国']::text[], -750, NULL, 'century', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.axum', 'アクスム王国', '{}'::text[], 1, NULL, 'century', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.ghana', 'ガーナ王国', '{}'::text[], 700, NULL, 'century', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.mali', 'マリ王国', '{}'::text[], 1240, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.songhai', 'ソンガイ王国', '{}'::text[], 1464, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.great_zimbabwe', '大ジンバブエ', ARRAY['モノモタパ王国']::text[], 1100, NULL, 'century', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.berlin_conference', 'ベルリン=コンゴ会議', ARRAY['1884年のベルリン会議']::text[], 1884, 1885, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.fashoda', 'ファショダ事件', '{}'::text[], 1898, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.boer_war', '南アフリカ戦争', ARRAY['ブール戦争']::text[], 1899, 1902, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.morocco_crisis1', '第1次モロッコ事件', ARRAY['タンジール事件']::text[], 1905, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.morocco_crisis2', '第2次モロッコ事件', ARRAY['アガディール事件']::text[], 1911, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.ethiopia_invasion', 'イタリアのエチオピア侵攻', '{}'::text[], 1935, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.year_of_africa', 'アフリカの年', '{}'::text[], 1960, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.algeria_independence', 'アルジェリア独立', '{}'::text[], 1962, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.oau', 'アフリカ統一機構の結成', ARRAY['OAU']::text[], 1963, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.africa.apartheid_end', 'アパルトヘイトの廃止', '{}'::text[], 1991, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.america.maya', 'マヤ文明', '{}'::text[], 300, 900, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.america.teotihuacan', 'テオティワカン文明', '{}'::text[], 1, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.america.aztec', 'アステカ王国', '{}'::text[], 1325, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.america.inca', 'インカ帝国', '{}'::text[], 1200, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.america.aztec_fall', 'アステカ王国の滅亡', '{}'::text[], 1521, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.america.inca_fall', 'インカ帝国の滅亡', '{}'::text[], 1533, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.america.potosi', 'ポトシ銀山の発見', '{}'::text[], 1545, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.renaissance_start', 'ルネサンスの開始', '{}'::text[], 1300, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.gutenberg', 'グーテンベルクの活版印刷', ARRAY['活版印刷術']::text[], 1450, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.toscanelli', 'トスカネリの地球球体説', '{}'::text[], 1474, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.dias_cape', 'バルトロメウ・ディアスの喜望峰到達', ARRAY['喜望峰の発見']::text[], 1488, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.columbus_voyage', 'コロンブスの新大陸到達', '{}'::text[], 1492, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.tordesillas', 'トルデシリャス条約', '{}'::text[], 1494, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.gama_india', 'ヴァスコ・ダ・ガマのインド航路開拓', ARRAY['カリカット到達']::text[], 1498, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.magellan_voyage', 'マゼランの世界周航', '{}'::text[], 1519, 1522, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.price_revolution', '価格革命', '{}'::text[], 1500, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.commercial_revolution', '商業革命', '{}'::text[], 1500, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.95_theses', '九十五カ条の論題', '{}'::text[], 1517, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.worms_diet', 'ヴォルムス帝国議会', '{}'::text[], 1521, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.german_peasants', 'ドイツ農民戦争', '{}'::text[], 1524, 1525, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.augsburg_peace', 'アウクスブルクの和議', '{}'::text[], 1555, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.act_supremacy', '首長法', ARRAY['国王至上法']::text[], 1534, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.calvin_geneva', 'カルヴァンのジュネーヴ改革', '{}'::text[], 1541, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.trent_council', 'トリエント公会議', '{}'::text[], 1545, 1563, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.jesuit_found', 'イエズス会の結成', '{}'::text[], 1534, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.act_uniformity', '統一法', '{}'::text[], 1559, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.huguenot_wars', 'ユグノー戦争', '{}'::text[], 1562, 1598, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.st_bartholomew', 'サンバルテルミの虐殺', '{}'::text[], 1572, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.nantes_edict', 'ナントの王令', ARRAY['ナントの勅令']::text[], 1598, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.nantes_revoke', 'ナントの王令の廃止', '{}'::text[], 1685, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.dutch_independence', 'オランダ独立宣言', ARRAY['ネーデルラント連邦共和国']::text[], 1581, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.armada', 'アルマダの海戦', ARRAY['無敵艦隊の敗北']::text[], 1588, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.eic_found', 'イギリス東インド会社の設立', '{}'::text[], 1600, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.voc_found', 'オランダ東インド会社の設立', '{}'::text[], 1602, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.thirty_years', '三十年戦争', '{}'::text[], 1618, 1648, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.westphalia', 'ウェストファリア条約', ARRAY['ヴェストファーレン条約']::text[], 1648, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.puritan_revolution', 'ピューリタン革命', ARRAY['清教徒革命']::text[], 1642, 1649, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.charles1_execution', 'チャールズ1世の処刑', '{}'::text[], 1649, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.navigation_act', '航海法', '{}'::text[], 1651, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.anglo_dutch_war', 'イギリス・オランダ戦争', ARRAY['英蘭戦争']::text[], 1652, 1674, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.restoration', '王政復古', '{}'::text[], 1660, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.glorious_revolution', '名誉革命', '{}'::text[], 1688, 1689, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.bill_of_rights', '権利の章典', '{}'::text[], 1689, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.responsible_cabinet', '責任内閣制の成立', ARRAY['王は君臨すれども統治せず']::text[], 1721, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.spanish_succession', 'スペイン継承戦争', '{}'::text[], 1701, 1713, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.utrecht', 'ユトレヒト条約', '{}'::text[], 1713, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.austrian_succession', 'オーストリア継承戦争', '{}'::text[], 1740, 1748, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.diplomatic_revolution', '外交革命', '{}'::text[], 1756, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.seven_years', '七年戦争', '{}'::text[], 1756, 1763, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.french_indian_war', 'フレンチ・インディアン戦争', '{}'::text[], 1754, 1763, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.paris_treaty_1763', '1763年のパリ条約', ARRAY['七年戦争の講和']::text[], 1763, NULL, 'exact', ARRAY[2,7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.poland_partition1', '第1回ポーランド分割', '{}'::text[], 1772, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.poland_partition3', '第3回ポーランド分割', '{}'::text[], 1795, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.north_war', '北方戦争', ARRAY['大北方戦争']::text[], 1700, 1721, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.st_petersburg', 'ペテルブルクの建設', '{}'::text[], 1703, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.early.pugachev', 'プガチョフの反乱', '{}'::text[], 1773, 1775, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.stamp_act', '印紙法', '{}'::text[], 1765, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.boston_tea', 'ボストン茶会事件', '{}'::text[], 1773, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.continental_congress1', '第1回大陸会議', '{}'::text[], 1774, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.lexington', 'レキシントンの戦い', '{}'::text[], 1775, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.declaration_independence', 'アメリカ独立宣言', '{}'::text[], 1776, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.saratoga', 'サラトガの戦い', '{}'::text[], 1777, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.yorktown', 'ヨークタウンの戦い', '{}'::text[], 1781, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.paris_treaty_1783', '1783年のパリ条約', ARRAY['アメリカ独立の承認']::text[], 1783, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.us_constitution', 'アメリカ合衆国憲法の制定', '{}'::text[], 1787, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.estates_general_1789', '1789年の三部会招集', '{}'::text[], 1789, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.tennis_court', '球戯場の誓い', ARRAY['テニスコートの誓い']::text[], 1789, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.bastille', 'バスティーユ牢獄の襲撃', '{}'::text[], 1789, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.declaration_rights', '人権宣言', ARRAY['人間と市民の権利の宣言']::text[], 1789, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.constitution_1791', '1791年憲法', '{}'::text[], 1791, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.varennes', 'ヴァレンヌ逃亡事件', '{}'::text[], 1791, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.first_republic', '第一共和政の成立', '{}'::text[], 1792, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.louis16_execution', 'ルイ16世の処刑', '{}'::text[], 1793, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.reign_of_terror', '恐怖政治', '{}'::text[], 1793, 1794, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.thermidor', 'テルミドールの反動', ARRAY['テルミドール9日のクーデタ']::text[], 1794, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.directory', '総裁政府', '{}'::text[], 1795, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.brumaire', 'ブリュメール18日のクーデタ', '{}'::text[], 1799, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.napoleonic_code', 'ナポレオン法典', ARRAY['フランス民法典']::text[], 1804, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.first_empire', '第一帝政の成立', '{}'::text[], 1804, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.trafalgar', 'トラファルガーの海戦', '{}'::text[], 1805, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.austerlitz', 'アウステルリッツの戦い', ARRAY['三帝会戦']::text[], 1805, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.rhine_confederation', 'ライン同盟', '{}'::text[], 1806, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.continental_system', '大陸封鎖令', ARRAY['ベルリン勅令']::text[], 1806, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.russia_campaign', 'ロシア遠征', '{}'::text[], 1812, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.leipzig', 'ライプツィヒの戦い', ARRAY['諸国民戦争']::text[], 1813, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.waterloo', 'ワーテルローの戦い', '{}'::text[], 1815, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.vienna_congress', 'ウィーン会議', '{}'::text[], 1814, 1815, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.holy_alliance', '神聖同盟', '{}'::text[], 1815, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.industrial_revolution', '産業革命の開始', '{}'::text[], 1760, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.spinning_jenny', 'ジェニー紡績機', '{}'::text[], 1764, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.watt_steam', 'ワットの蒸気機関', '{}'::text[], 1769, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.power_loom', '力織機', '{}'::text[], 1785, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.stephenson_locomotive', 'スティーヴンソンの蒸気機関車', '{}'::text[], 1825, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.enclosure2', '第2次囲い込み', ARRAY['第2次エンクロージャー']::text[], 1760, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.latin_america_independence', 'ラテンアメリカ諸国の独立', '{}'::text[], 1810, 1826, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.monroe_doctrine', 'モンロー宣言', ARRAY['モンロー主義']::text[], 1823, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.greek_independence', 'ギリシア独立戦争', '{}'::text[], 1821, 1829, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.july_revolution', '七月革命', '{}'::text[], 1830, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.belgium_independence', 'ベルギーの独立', '{}'::text[], 1830, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.february_revolution', '二月革命', '{}'::text[], 1848, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.1848_revolutions', '諸国民の春', ARRAY['1848年革命']::text[], 1848, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.communist_manifesto', '共産党宣言', '{}'::text[], 1848, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.reform_act1', '第1回選挙法改正', '{}'::text[], 1832, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.chartism', 'チャーティスト運動', ARRAY['人民憲章']::text[], 1838, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.corn_law_repeal', '穀物法の廃止', '{}'::text[], 1846, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.rev.navigation_act_repeal', '航海法の廃止', '{}'::text[], 1849, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.crimean_war', 'クリミア戦争', '{}'::text[], 1853, 1856, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.paris_treaty_1856', '1856年のパリ条約', ARRAY['クリミア戦争の講和']::text[], 1856, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.emancipation_edict', '農奴解放令', '{}'::text[], 1861, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.russo_turkish', 'ロシア・トルコ戦争', ARRAY['露土戦争']::text[], 1877, 1878, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.berlin_congress', '1878年のベルリン会議', ARRAY['ベルリン条約']::text[], 1878, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.second_empire', '第二帝政の成立', '{}'::text[], 1852, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.third_republic', '第三共和政の成立', '{}'::text[], 1870, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.paris_commune', 'パリ・コミューン', '{}'::text[], 1871, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.dreyfus', 'ドレフュス事件', '{}'::text[], 1894, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.sardinia_reform', 'サルデーニャ王国の近代化', ARRAY['カヴールの改革']::text[], 1852, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.italy_unification', 'イタリア王国の成立', '{}'::text[], 1861, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.venetia', 'ヴェネツィアの併合', '{}'::text[], 1866, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.rome_annexation', '教皇領の併合', ARRAY['ローマ併合']::text[], 1870, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.zollverein', 'ドイツ関税同盟', '{}'::text[], 1834, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.frankfurt_assembly', 'フランクフルト国民議会', '{}'::text[], 1848, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.danish_war', 'デンマーク戦争', '{}'::text[], 1864, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.austro_prussian', 'プロイセン・オーストリア戦争', ARRAY['普墺戦争']::text[], 1866, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.franco_prussian', 'ドイツ・フランス戦争', ARRAY['普仏戦争']::text[], 1870, 1871, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.german_empire', 'ドイツ帝国の成立', '{}'::text[], 1871, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.kulturkampf', '文化闘争', '{}'::text[], 1871, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.anti_socialist_law', '社会主義者鎮圧法', '{}'::text[], 1878, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.triple_alliance', '三国同盟', '{}'::text[], 1882, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.reinsurance_treaty', '再保険条約', ARRAY['独露再保障条約']::text[], 1887, NULL, 'exact', ARRAY[2,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.wilhelm2_new_course', 'ヴィルヘルム2世の新航路政策', ARRAY['世界政策']::text[], 1890, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.franco_russian', '露仏同盟', '{}'::text[], 1894, NULL, 'exact', ARRAY[2,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.entente_cordiale', '英仏協商', '{}'::text[], 1904, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.anglo_russian', '英露協商', '{}'::text[], 1907, NULL, 'exact', ARRAY[2,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.louisiana_purchase', 'ルイジアナ買収', '{}'::text[], 1803, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.mexican_war', 'アメリカ・メキシコ戦争', ARRAY['米墨戦争']::text[], 1846, 1848, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.gold_rush', 'ゴールドラッシュ', '{}'::text[], 1849, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.kansas_nebraska', 'カンザス・ネブラスカ法', '{}'::text[], 1854, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.civil_war', '南北戦争', '{}'::text[], 1861, 1865, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.emancipation_proclamation', '奴隷解放宣言', '{}'::text[], 1863, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.gettysburg', 'ゲティスバーグの戦い', '{}'::text[], 1863, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.homestead_act', 'ホームステッド法', ARRAY['自営農地法']::text[], 1862, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.transcontinental_railroad', '大陸横断鉄道の完成', '{}'::text[], 1869, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.frontier_close', 'フロンティアの消滅', '{}'::text[], 1890, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.suez_canal', 'スエズ運河の開通', '{}'::text[], 1869, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.suez_shares', 'イギリスのスエズ運河株買収', '{}'::text[], 1875, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.egypt_protectorate', 'イギリスのエジプト保護国化', '{}'::text[], 1882, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.congo_free_state', 'コンゴ自由国', '{}'::text[], 1885, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.cape_cairo', 'アフリカ縦断政策', ARRAY['3C政策']::text[], 1880, NULL, 'century', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.baghdad_railway', 'バグダード鉄道', ARRAY['3B政策']::text[], 1899, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.first_international', '第1インターナショナル', ARRAY['国際労働者協会']::text[], 1864, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.second_international', '第2インターナショナル', '{}'::text[], 1889, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.origin_of_species', '種の起源', '{}'::text[], 1859, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.das_kapital', '資本論', '{}'::text[], 1867, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.telephone', '電話の発明', '{}'::text[], 1876, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.incandescent_lamp', '白熱電球の実用化', '{}'::text[], 1879, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.c19.wright_flight', 'ライト兄弟の初飛行', '{}'::text[], 1903, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.russo_japanese', '日露戦争', '{}'::text[], 1904, 1905, 'exact', ARRAY[21,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.portsmouth', 'ポーツマス条約', '{}'::text[], 1905, NULL, 'exact', ARRAY[21]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.bloody_sunday', '血の日曜日事件', '{}'::text[], 1905, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.october_manifesto', '十月宣言', '{}'::text[], 1905, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.stolypin', 'ストルイピンの改革', '{}'::text[], 1906, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.korea_annexation', '韓国併合', '{}'::text[], 1910, NULL, 'exact', ARRAY[23,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.iran_constitutional', 'イラン立憲革命', '{}'::text[], 1905, 1911, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.balkan_war1', '第1次バルカン戦争', '{}'::text[], 1912, 1913, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.imp.balkan_war2', '第2次バルカン戦争', '{}'::text[], 1913, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.sarajevo', 'サライェヴォ事件', '{}'::text[], 1914, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.outbreak', '第一次世界大戦の開始', '{}'::text[], 1914, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.marne', 'マルヌの戦い', '{}'::text[], 1914, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.verdun_battle', 'ヴェルダンの戦い', '{}'::text[], 1916, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.unrestricted_submarine', '無制限潜水艦作戦', '{}'::text[], 1917, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.us_entry', 'アメリカの参戦', '{}'::text[], 1917, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.february_revolution_ru', 'ロシア二月革命', ARRAY['三月革命']::text[], 1917, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.april_theses', '四月テーゼ', '{}'::text[], 1917, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.october_revolution', 'ロシア十月革命', ARRAY['十一月革命']::text[], 1917, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.peace_decree', '平和に関する布告', '{}'::text[], 1917, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.brest_litovsk', 'ブレスト・リトフスク条約', '{}'::text[], 1918, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.fourteen_points', '十四カ条', '{}'::text[], 1918, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.german_revolution', 'ドイツ革命', ARRAY['キール軍港の水兵反乱']::text[], 1918, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.armistice', '第一次世界大戦の終結', '{}'::text[], 1918, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.paris_peace', 'パリ講和会議', '{}'::text[], 1919, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.versailles', 'ヴェルサイユ条約', '{}'::text[], 1919, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.league_of_nations', '国際連盟の発足', '{}'::text[], 1920, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.weimar_constitution', 'ヴァイマル憲法', ARRAY['ワイマール憲法']::text[], 1919, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.comintern', 'コミンテルンの結成', ARRAY['第3インターナショナル']::text[], 1919, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.war_communism', '戦時共産主義', '{}'::text[], 1918, 1921, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.nep', '新経済政策', ARRAY['ネップ']::text[], 1921, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.ussr_found', 'ソヴィエト社会主義共和国連邦の成立', ARRAY['ソ連の成立']::text[], 1922, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.washington_conference', 'ワシントン会議', '{}'::text[], 1921, 1922, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.ruhr_occupation', 'ルール占領', '{}'::text[], 1923, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.german_hyperinflation', 'ドイツの超インフレーション', '{}'::text[], 1923, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.dawes_plan', 'ドーズ案', '{}'::text[], 1924, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.locarno', 'ロカルノ条約', '{}'::text[], 1925, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.kellogg_briand', '不戦条約', ARRAY['ブリアン・ケロッグ協定']::text[], 1928, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.young_plan', 'ヤング案', '{}'::text[], 1929, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.march_on_rome', 'ローマ進軍', '{}'::text[], 1922, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.turkish_war_independence', 'トルコ革命', '{}'::text[], 1919, 1923, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.balfour', 'バルフォア宣言', '{}'::text[], 1917, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.mcmahon', 'フサイン・マクマホン協定', '{}'::text[], 1915, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.sykes_picot', 'サイクス・ピコ協定', '{}'::text[], 1916, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.great_depression', '世界恐慌', ARRAY['大恐慌']::text[], 1929, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.new_deal', 'ニューディール政策', '{}'::text[], 1933, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.wagner_act', 'ワグナー法', ARRAY['全国労働関係法']::text[], 1935, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.ottawa_conference', 'オタワ連邦会議', ARRAY['イギリス連邦経済会議']::text[], 1932, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.five_year_plan1', '第1次五カ年計画', '{}'::text[], 1928, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.enabling_act', '全権委任法', ARRAY['授権法']::text[], 1933, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.nazi_power', 'ナチ党の政権掌握', '{}'::text[], 1933, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.germany_league_exit', 'ドイツの国際連盟脱退', '{}'::text[], 1933, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.rearmament', 'ドイツの再軍備宣言', '{}'::text[], 1935, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.rhineland', 'ラインラント進駐', '{}'::text[], 1936, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.spanish_civil_war', 'スペイン内戦', '{}'::text[], 1936, 1939, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww1.popular_front', '人民戦線', '{}'::text[], 1935, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.anschluss', 'オーストリア併合', ARRAY['アンシュルス']::text[], 1938, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.munich_conference', 'ミュンヘン会談', '{}'::text[], 1938, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.czech_dismember', 'チェコスロヴァキア解体', '{}'::text[], 1939, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.nazi_soviet_pact', '独ソ不可侵条約', '{}'::text[], 1939, NULL, 'exact', ARRAY[2,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.poland_invasion', 'ドイツのポーランド侵攻', '{}'::text[], 1939, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.france_fall', 'フランスの降伏', '{}'::text[], 1940, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.battle_of_britain', 'バトル・オブ・ブリテン', '{}'::text[], 1940, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.tripartite_pact', '日独伊三国同盟', '{}'::text[], 1940, NULL, 'exact', ARRAY[2,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.barbarossa', '独ソ戦の開始', ARRAY['バルバロッサ作戦']::text[], 1941, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.atlantic_charter', '大西洋憲章', '{}'::text[], 1941, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.pearl_harbor', '真珠湾攻撃', '{}'::text[], 1941, NULL, 'exact', ARRAY[7,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.midway', 'ミッドウェー海戦', '{}'::text[], 1942, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.stalingrad', 'スターリングラードの戦い', '{}'::text[], 1942, 1943, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.italy_surrender', 'イタリアの降伏', '{}'::text[], 1943, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.cairo_conference', 'カイロ会談', '{}'::text[], 1943, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.teheran_conference', 'テヘラン会談', '{}'::text[], 1943, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.normandy', 'ノルマンディー上陸作戦', '{}'::text[], 1944, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.bretton_woods', 'ブレトン・ウッズ会議', '{}'::text[], 1944, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.yalta_conference', 'ヤルタ会談', '{}'::text[], 1945, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.germany_surrender', 'ドイツの降伏', '{}'::text[], 1945, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.potsdam_conference', 'ポツダム会談', ARRAY['ポツダム宣言']::text[], 1945, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.hiroshima', '広島への原子爆弾投下', '{}'::text[], 1945, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.japan_surrender', '日本の降伏', '{}'::text[], 1945, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.un_found', '国際連合の成立', '{}'::text[], 1945, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.nuremberg', 'ニュルンベルク裁判', ARRAY['国際軍事裁判']::text[], 1945, 1946, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ww2.holocaust', 'ホロコースト', '{}'::text[], 1941, 1945, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.iron_curtain', '鉄のカーテン演説', '{}'::text[], 1946, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.truman_doctrine', 'トルーマン・ドクトリン', ARRAY['封じ込め政策']::text[], 1947, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.marshall_plan', 'マーシャル・プラン', ARRAY['ヨーロッパ経済復興援助計画']::text[], 1947, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.cominform', 'コミンフォルムの結成', ARRAY['共産党情報局']::text[], 1947, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.berlin_blockade', 'ベルリン封鎖', '{}'::text[], 1948, 1949, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.nato', '北大西洋条約機構の成立', ARRAY['NATO']::text[], 1949, NULL, 'exact', ARRAY[2,7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.germany_division', '東西ドイツの分裂', '{}'::text[], 1949, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.comecon', '経済相互援助会議', ARRAY['コメコン']::text[], 1949, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.warsaw_pact', 'ワルシャワ条約機構の成立', '{}'::text[], 1955, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.korean_war', '朝鮮戦争', '{}'::text[], 1950, 1953, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.san_francisco', 'サンフランシスコ平和条約', '{}'::text[], 1951, NULL, 'exact', ARRAY[7,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.stalin_criticism', 'スターリン批判', '{}'::text[], 1956, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.hungary_uprising', 'ハンガリー事件', ARRAY['ハンガリー動乱']::text[], 1956, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.suez_crisis', 'スエズ戦争', ARRAY['第2次中東戦争','スエズ動乱']::text[], 1956, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.sputnik', 'スプートニク1号の打ち上げ', '{}'::text[], 1957, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.berlin_wall', 'ベルリンの壁の建設', '{}'::text[], 1961, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.cuban_crisis', 'キューバ危機', '{}'::text[], 1962, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.ptbt', '部分的核実験禁止条約', '{}'::text[], 1963, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.npt', '核拡散防止条約', ARRAY['NPT']::text[], 1968, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.prague_spring', 'プラハの春', ARRAY['チェコ事件']::text[], 1968, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.vietnam_war', 'ベトナム戦争', '{}'::text[], 1965, 1975, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.tonkin', 'トンキン湾事件', '{}'::text[], 1964, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.paris_peace_vietnam', 'ベトナム和平協定', ARRAY['パリ和平協定']::text[], 1973, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.saigon_fall', 'サイゴン陥落', '{}'::text[], 1975, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.nixon_china', 'ニクソンの訪中', '{}'::text[], 1972, NULL, 'exact', ARRAY[22,7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.dollar_shock', 'ドル・ショック', ARRAY['ニクソン・ショック','金ドル交換停止']::text[], 1971, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.floating_rate', '変動相場制への移行', '{}'::text[], 1973, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.oil_crisis1', '第1次石油危機', ARRAY['オイル・ショック']::text[], 1973, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cold.helsinki', '全欧安全保障協力会議', ARRAY['ヘルシンキ宣言','CSCE']::text[], 1975, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.israel_found', 'イスラエルの建国', '{}'::text[], 1948, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.arab_israeli1', '第1次中東戦争', ARRAY['パレスチナ戦争']::text[], 1948, 1949, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.arab_israeli3', '第3次中東戦争', ARRAY['六日戦争']::text[], 1967, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.arab_israeli4', '第4次中東戦争', '{}'::text[], 1973, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.plo', 'パレスチナ解放機構の結成', ARRAY['PLO']::text[], 1964, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.camp_david', 'キャンプ・デーヴィッド合意', '{}'::text[], 1978, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.oslo_accords', 'パレスチナ暫定自治協定', ARRAY['オスロ合意']::text[], 1993, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.iran_revolution', 'イラン革命', ARRAY['イスラーム革命']::text[], 1979, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.iran_iraq', 'イラン・イラク戦争', '{}'::text[], 1980, 1988, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.gulf_war', '湾岸戦争', '{}'::text[], 1991, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.iraq_war', 'イラク戦争', '{}'::text[], 2003, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.afghan_invasion', 'ソ連のアフガニスタン侵攻', '{}'::text[], 1979, NULL, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.arab_spring', 'アラブの春', '{}'::text[], 2011, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.ecsc', 'ヨーロッパ石炭鉄鋼共同体', ARRAY['ECSC']::text[], 1952, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.eec', 'ヨーロッパ経済共同体', ARRAY['EEC','ローマ条約']::text[], 1958, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.ec', 'ヨーロッパ共同体', ARRAY['ヨーロッパ諸共同体']::text[], 1967, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.uk_ec_join', 'イギリスの EC 加盟', '{}'::text[], 1973, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.maastricht', 'マーストリヒト条約', '{}'::text[], 1992, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.eu_found', 'ヨーロッパ連合の発足', ARRAY['ヨーロッパ連合']::text[], 1993, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.euro', 'ユーロの導入', '{}'::text[], 1999, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.brexit', 'イギリスの EU 離脱', ARRAY['ブレグジット']::text[], 2020, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.perestroika', 'ペレストロイカ', '{}'::text[], 1985, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.chernobyl', 'チェルノブイリ原子力発電所事故', '{}'::text[], 1986, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.inf_treaty', '中距離核戦力全廃条約', ARRAY['INF 条約']::text[], 1987, NULL, 'exact', ARRAY[7,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.east_europe_1989', '東欧革命', '{}'::text[], 1989, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.berlin_wall_fall', 'ベルリンの壁の崩壊', '{}'::text[], 1989, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.malta', 'マルタ会談', '{}'::text[], 1989, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.germany_unification', '東西ドイツの統一', ARRAY['ドイツ再統一']::text[], 1990, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.ussr_collapse', 'ソ連の解体', '{}'::text[], 1991, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.yugoslav_wars', 'ユーゴスラヴィア内戦', '{}'::text[], 1991, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.bandung', 'アジア・アフリカ会議', ARRAY['バンドン会議']::text[], 1955, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.non_aligned', '非同盟諸国首脳会議', '{}'::text[], 1961, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.peaceful_coexistence', '平和五原則', '{}'::text[], 1954, NULL, 'exact', ARRAY[22,16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.sino_soviet_split', '中ソ対立', '{}'::text[], 1959, NULL, 'exact', ARRAY[22,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.sino_indian', '中印国境紛争', '{}'::text[], 1962, NULL, 'exact', ARRAY[22,16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.indo_pakistani', 'インド・パキスタン戦争', '{}'::text[], 1971, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.korea_normalization', '日韓基本条約', '{}'::text[], 1965, NULL, 'exact', ARRAY[23,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.japan_china_normalization', '日中共同声明', ARRAY['日中国交正常化']::text[], 1972, NULL, 'exact', ARRAY[22,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.asean', '東南アジア諸国連合の結成', ARRAY['ASEAN']::text[], 1967, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.nafta', '北米自由貿易協定', ARRAY['NAFTA']::text[], 1994, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.wto', '世界貿易機関の発足', ARRAY['WTO']::text[], 1995, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.gatt', '関税と貿易に関する一般協定', ARRAY['GATT']::text[], 1947, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.oapec', 'アラブ石油輸出国機構', ARRAY['OAPEC']::text[], 1968, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.opec', '石油輸出国機構', ARRAY['OPEC']::text[], 1960, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.september_11', '同時多発テロ事件', ARRAY['9・11 事件']::text[], 2001, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.lehman', '世界金融危機', ARRAY['リーマン・ショック']::text[], 2008, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.paris_agreement', 'パリ協定', '{}'::text[], 2015, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.kyoto_protocol', '京都議定書', '{}'::text[], 1997, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.civil_rights_act', '公民権法', '{}'::text[], 1964, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.cultural_revolution_end', '文化大革命の終結', '{}'::text[], 1976, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.hong_kong_return', '香港の返還', '{}'::text[], 1997, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.now.wto_china', '中国の WTO 加盟', '{}'::text[], 2001, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.confucius', '孔子', '{}'::text[], -551, -479, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.hundred_schools', '諸子百家', '{}'::text[], -500, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.laozi', '老子', '{}'::text[], -500, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.mencius', '孟子', '{}'::text[], -372, -289, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.xunzi', '荀子', '{}'::text[], -298, -238, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.han_feizi', '韓非', ARRAY['韓非子']::text[], -280, -233, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.sima_qian', '司馬遷の史記', ARRAY['史記']::text[], -91, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.ban_gu', '班固の漢書', ARRAY['漢書']::text[], 82, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.paper_cai_lun', '蔡倫の製紙法改良', '{}'::text[], 105, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.buddhism_china', '仏教の中国伝来', '{}'::text[], 1, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.xuanzang', '玄奘の入竺', ARRAY['大唐西域記']::text[], 629, 645, 'exact', ARRAY[22,16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.yijing', '義浄の入竺', ARRAY['南海寄帰内法伝']::text[], 671, 695, 'exact', ARRAY[22,17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.faxian', '法顕の入竺', ARRAY['仏国記']::text[], 399, 412, 'exact', ARRAY[22,16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.zhu_xi', '朱熹の朱子学', ARRAY['宋学']::text[], 1130, 1200, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.wang_yangming', '王守仁の陽明学', ARRAY['王陽明']::text[], 1472, 1529, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.kaozheng', '考証学', '{}'::text[], 1644, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.three_inventions', '火薬・羅針盤・活版印刷の実用化', ARRAY['宋の三大発明']::text[], 960, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.imperial_exam_start', '科挙の開始', '{}'::text[], 587, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.imperial_exam_end', '科挙の廃止', '{}'::text[], 1905, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.socrates', 'ソクラテス', '{}'::text[], -469, -399, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.plato', 'プラトン', '{}'::text[], -427, -347, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.aristotle', 'アリストテレス', '{}'::text[], -384, -322, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.herodotus', 'ヘロドトスの歴史', '{}'::text[], -440, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.thucydides', 'トゥキディデスの歴史', '{}'::text[], -400, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.hippocrates', 'ヒッポクラテス', '{}'::text[], -460, -370, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.euclid', 'エウクレイデス', ARRAY['ユークリッド']::text[], -300, NULL, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.archimedes', 'アルキメデス', '{}'::text[], -287, -212, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.eratosthenes', 'エラトステネス', '{}'::text[], -276, -194, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.museion', 'ムセイオン', ARRAY['アレクサンドリア図書館']::text[], -300, NULL, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.stoicism', 'ストア派', ARRAY['ゼノン']::text[], -300, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.epicureanism', 'エピクロス派', '{}'::text[], -300, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.cicero', 'キケロ', '{}'::text[], -106, -43, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.vergil', 'ウェルギリウス', '{}'::text[], -70, -19, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.livy', 'リウィウス', '{}'::text[], -59, 17, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.tacitus', 'タキトゥス', '{}'::text[], 55, 120, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.ptolemy_astronomy', 'プトレマイオスの天動説', '{}'::text[], 150, NULL, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.augustine', 'アウグスティヌス', '{}'::text[], 354, 430, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.scholasticism', 'スコラ学', '{}'::text[], 1100, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.thomas_aquinas', 'トマス・アクィナス', ARRAY['神学大全']::text[], 1225, 1274, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.abelard', 'アベラール', '{}'::text[], 1079, 1142, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.roger_bacon', 'ロジャー・ベーコン', '{}'::text[], 1214, 1294, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.university_bologna', 'ボローニャ大学', '{}'::text[], 1088, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.dante', 'ダンテの神曲', ARRAY['神曲']::text[], 1307, 1321, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.petrarca', 'ペトラルカ', '{}'::text[], 1304, 1374, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.boccaccio', 'ボッカチオのデカメロン', ARRAY['デカメロン']::text[], 1350, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.machiavelli', 'マキァヴェリの君主論', ARRAY['君主論']::text[], 1532, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.erasmus', 'エラスムスの愚神礼讃', ARRAY['愚神礼讃']::text[], 1511, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.thomas_more', 'トマス・モアのユートピア', ARRAY['ユートピア']::text[], 1516, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.leonardo', 'レオナルド・ダ・ヴィンチ', '{}'::text[], 1452, 1519, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.michelangelo', 'ミケランジェロ', '{}'::text[], 1475, 1564, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.raphael', 'ラファエロ', '{}'::text[], 1483, 1520, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.shakespeare', 'シェークスピア', '{}'::text[], 1564, 1616, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.cervantes', 'セルバンテスのドン・キホーテ', ARRAY['ドン・キホーテ']::text[], 1605, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.galilei', 'ガリレイの地動説擁護', ARRAY['ガリレオ・ガリレイ']::text[], 1633, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.kepler', 'ケプラーの惑星運動の法則', '{}'::text[], 1609, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.principia', 'ニュートンのプリンキピア', ARRAY['自然哲学の数学的原理']::text[], 1687, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.bacon_novum', 'フランシス・ベーコン', ARRAY['新オルガヌム']::text[], 1561, 1626, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.descartes', 'デカルト', ARRAY['方法序説']::text[], 1596, 1650, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.hobbes', 'ホッブズのリヴァイアサン', ARRAY['リヴァイアサン']::text[], 1651, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.locke', 'ロックの統治二論', ARRAY['市民政府二論']::text[], 1690, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.montesquieu', 'モンテスキューの法の精神', ARRAY['法の精神']::text[], 1748, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.voltaire', 'ヴォルテール', '{}'::text[], 1694, 1778, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.rousseau', 'ルソーの社会契約論', ARRAY['社会契約論']::text[], 1762, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.encyclopedie', '百科全書', '{}'::text[], 1751, 1772, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.adam_smith', 'アダム・スミスの国富論', ARRAY['諸国民の富']::text[], 1776, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.malthus', 'マルサスの人口論', ARRAY['人口論']::text[], 1798, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.ricardo', 'リカードの比較生産費説', '{}'::text[], 1817, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.kant', 'カント', ARRAY['純粋理性批判']::text[], 1724, 1804, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.hegel', 'ヘーゲル', ARRAY['弁証法']::text[], 1770, 1831, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.bentham', 'ベンサムの功利主義', ARRAY['最大多数の最大幸福']::text[], 1789, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.list', 'リストの保護貿易論', '{}'::text[], 1841, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.ranke', 'ランケの近代歴史学', '{}'::text[], 1824, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.comte', 'コントの実証主義', '{}'::text[], 1830, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.pasteur', 'パストゥールの細菌学', '{}'::text[], 1861, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.koch', 'コッホの結核菌発見', '{}'::text[], 1882, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.roentgen', 'レントゲンのX線発見', '{}'::text[], 1895, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.curie', 'キュリー夫妻のラジウム発見', '{}'::text[], 1898, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.einstein_relativity', 'アインシュタインの相対性理論', '{}'::text[], 1905, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.freud', 'フロイトの精神分析', '{}'::text[], 1900, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.marconi', 'マルコーニの無線電信', '{}'::text[], 1895, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.upanishad', 'ウパニシャッド哲学', '{}'::text[], -700, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.mahayana', '大乗仏教の成立', '{}'::text[], 1, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.gandhara', 'ガンダーラ美術', '{}'::text[], 1, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.nalanda', 'ナーランダー僧院', '{}'::text[], 427, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.sanskrit_literature', 'サンスクリット文学の隆盛', ARRAY['シャクンタラー']::text[], 320, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.zoroastrianism', 'ゾロアスター教', ARRAY['拝火教']::text[], -600, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.manichaeism', 'マニ教', '{}'::text[], 240, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.house_of_wisdom', '知恵の館', ARRAY['バイト・アルヒクマ']::text[], 830, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.ibn_sina', 'イブン・シーナー', ARRAY['アヴィケンナ','医学典範']::text[], 980, 1037, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.ibn_rushd', 'イブン・ルシュド', ARRAY['アヴェロエス']::text[], 1126, 1198, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.ibn_khaldun', 'イブン・ハルドゥーン', ARRAY['世界史序説']::text[], 1332, 1406, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.ibn_battuta', 'イブン・バットゥータ', ARRAY['三大陸周遊記']::text[], 1304, 1368, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.al_khwarizmi', 'フワーリズミー', ARRAY['代数学']::text[], 780, 850, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.cul.arabic_numerals', 'アラビア数字の成立', '{}'::text[], 800, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.juntian', '均田制', '{}'::text[], 485, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.zuyongdiao', '租庸調制', '{}'::text[], 624, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.fubing', '府兵制', '{}'::text[], 550, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.mubing', '募兵制', '{}'::text[], 749, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.jiedushi', '節度使の設置', '{}'::text[], 710, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.sancheng', '三省六部', '{}'::text[], 618, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.yitiaobian', '一条鞭法', '{}'::text[], 1580, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.diding', '地丁銀制', '{}'::text[], 1717, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.lijia', '里甲制', '{}'::text[], 1381, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.baojia', '保甲制', '{}'::text[], 1070, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.eight_banners', '八旗', '{}'::text[], 1601, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.tribute_system', '朝貢体制', ARRAY['冊封体制']::text[], 1, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.haijin', '海禁政策', '{}'::text[], 1371, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.canton_hong', '公行', '{}'::text[], 1720, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.manor_system', '荘園制', '{}'::text[], 800, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.serfdom', '農奴制', '{}'::text[], 900, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.three_field', '三圃制', '{}'::text[], 800, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.feudalism', '封建制', ARRAY['主従関係と荘園制']::text[], 900, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.guild', 'ギルド', ARRAY['同職組合']::text[], 1100, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.commutation', '地代の金納化', '{}'::text[], 1300, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.yeoman', '独立自営農民', ARRAY['ヨーマン']::text[], 1400, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.gutsherrschaft', '農場領主制', ARRAY['グーツヘルシャフト']::text[], 1500, NULL, 'century', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.mercantilism', '重商主義', '{}'::text[], 1600, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.putting_out', '問屋制家内工業', '{}'::text[], 1600, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.manufacture', '工場制手工業', ARRAY['マニュファクチュア']::text[], 1600, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.factory_system', '工場制機械工業', '{}'::text[], 1800, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.triangular_trade', '大西洋三角貿易', '{}'::text[], 1600, NULL, 'century', ARRAY[2,15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.slave_trade_abolition', '奴隷貿易の廃止', '{}'::text[], 1807, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.us_slavery_abolition', 'アメリカの奴隷制廃止', ARRAY['憲法修正第13条']::text[], 1865, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.gold_standard', '金本位制の確立', '{}'::text[], 1816, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.factory_act', '工場法', '{}'::text[], 1833, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.combination_act_repeal', '団結禁止法の廃止', '{}'::text[], 1824, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.catholic_emancipation', 'カトリック教徒解放法', '{}'::text[], 1829, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.reform_act2', '第2回選挙法改正', '{}'::text[], 1867, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.reform_act3', '第3回選挙法改正', '{}'::text[], 1884, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.reform_act4', '第4回選挙法改正', '{}'::text[], 1918, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.reform_act5', '第5回選挙法改正', '{}'::text[], 1928, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.irish_free_state', 'アイルランド自由国', '{}'::text[], 1922, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sys.statute_westminster', 'ウェストミンスター憲章', '{}'::text[], 1931, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.perry', 'ペリーの来航', ARRAY['黒船来航']::text[], 1853, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.kanagawa_treaty', '日米和親条約', '{}'::text[], 1854, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.harris_treaty', '日米修好通商条約', '{}'::text[], 1858, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.meiji_restoration', '明治維新', '{}'::text[], 1868, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.haihan_chiken', '廃藩置県', '{}'::text[], 1871, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.iwakura_mission', '岩倉使節団', '{}'::text[], 1871, 1873, 'exact', ARRAY[24,7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.chiso_kaisei', '地租改正', '{}'::text[], 1873, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.seikanron', '征韓論政変', ARRAY['明治六年の政変']::text[], 1873, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.ganghwa', '日朝修好条規', ARRAY['江華島条約']::text[], 1876, NULL, 'exact', ARRAY[23,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.satsuma_rebellion', '西南戦争', '{}'::text[], 1877, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.freedom_rights', '自由民権運動', '{}'::text[], 1874, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.meiji_constitution', '大日本帝国憲法', ARRAY['明治憲法']::text[], 1889, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.first_diet', '第1回帝国議会', '{}'::text[], 1890, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.treaty_revision_extra', '領事裁判権の撤廃', ARRAY['日英通商航海条約']::text[], 1894, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.tariff_autonomy', '関税自主権の回復', '{}'::text[], 1911, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.triple_intervention', '三国干渉', '{}'::text[], 1895, NULL, 'exact', ARRAY[24,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.anglo_japanese', '日英同盟', '{}'::text[], 1902, NULL, 'exact', ARRAY[24,2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.taisho_democracy', '大正デモクラシー', '{}'::text[], 1912, 1926, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.rice_riots', '米騒動', '{}'::text[], 1918, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.universal_suffrage_jp', '普通選挙法', '{}'::text[], 1925, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.peace_preservation', '治安維持法', '{}'::text[], 1925, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.showa_depression', '昭和恐慌', '{}'::text[], 1930, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.may15', '五・一五事件', '{}'::text[], 1932, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.feb26', '二・二六事件', '{}'::text[], 1936, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.league_exit_jp', '日本の国際連盟脱退', '{}'::text[], 1933, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.national_mobilization', '国家総動員法', '{}'::text[], 1938, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.tripartite_jp', '日ソ中立条約', '{}'::text[], 1941, NULL, 'exact', ARRAY[24,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.gyokuon', 'ポツダム宣言の受諾', '{}'::text[], 1945, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.constitution_jp', '日本国憲法の公布', '{}'::text[], 1946, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.land_reform', '農地改革', '{}'::text[], 1946, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.zaibatsu_dissolution', '財閥解体', '{}'::text[], 1945, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.security_treaty', '日米安全保障条約', '{}'::text[], 1951, NULL, 'exact', ARRAY[24,7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.anpo_1960', '安保闘争', ARRAY['日米安保条約の改定']::text[], 1960, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.high_growth', '高度経済成長', '{}'::text[], 1955, 1973, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.tokyo_olympic', '東京オリンピック', '{}'::text[], 1964, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.okinawa_return', '沖縄返還', '{}'::text[], 1972, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.plaza_accord', 'プラザ合意', '{}'::text[], 1985, NULL, 'exact', ARRAY[7,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.bubble_collapse', 'バブル経済の崩壊', '{}'::text[], 1991, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.tokugawa_sakoku', '鎖国の完成', '{}'::text[], 1639, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.dejima', '出島でのオランダ貿易', '{}'::text[], 1641, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.jp.silver_export', '日本銀の輸出', '{}'::text[], 1500, NULL, 'century', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.sumer_cities', 'シュメール都市国家', ARRAY['ウルク','シュメール人']::text[], -3500, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.cuneiform', '楔形文字', '{}'::text[], -3200, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.hieroglyph', '神聖文字', ARRAY['ヒエログリフ']::text[], -3000, NULL, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.rosetta_decipher', 'シャンポリオンの神聖文字解読', '{}'::text[], 1822, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.new_babylonia', '新バビロニア', ARRAY['カルデア']::text[], -625, -538, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.lydia_coin', 'リディアの金属貨幣', '{}'::text[], -670, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.aramaic', 'アラム人の内陸交易', ARRAY['アラム文字']::text[], -1200, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.mycenae', 'ミケーネ文明', '{}'::text[], -1600, -1200, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.crete', 'クレタ文明', ARRAY['ミノア文明']::text[], -2000, -1400, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.homer', 'ホメロス', ARRAY['イリアス','オデュッセイア']::text[], -800, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.sparta', 'スパルタの国制', ARRAY['リュクルゴスの制']::text[], -700, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.corinthian_league', 'コリントス同盟', ARRAY['ヘラス同盟']::text[], -337, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.diadochi', 'ディアドコイ戦争', ARRAY['後継者戦争']::text[], -323, -301, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.seleucid', 'セレウコス朝シリア', '{}'::text[], -312, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.antigonid', 'アンティゴノス朝マケドニア', '{}'::text[], -276, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.bactria', 'バクトリア', '{}'::text[], -255, NULL, 'century', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.latifundium', 'ラティフンディウム', '{}'::text[], -200, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.colonatus', 'コロナトゥス', '{}'::text[], 200, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.spartacus', 'スパルタクスの反乱', '{}'::text[], -73, -71, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.second_triumvirate', '第2回三頭政治', '{}'::text[], -43, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.jesus', 'イエスの処刑', '{}'::text[], 30, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.paul_mission', 'パウロの伝道', '{}'::text[], 50, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.nero_persecution', 'ネロのキリスト教徒迫害', '{}'::text[], 64, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.jewish_war', 'ユダヤ戦争', ARRAY['エルサレム神殿の破壊']::text[], 66, 70, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.arianism', 'アリウス派', '{}'::text[], 320, NULL, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.nestorianism', 'ネストリウス派', ARRAY['景教']::text[], 431, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.monophysite', '単性論', ARRAY['コプト教会']::text[], 451, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.vulgate', 'ウルガタ聖書', '{}'::text[], 405, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.visigoth', '西ゴート王国', '{}'::text[], 418, 711, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.vandal', 'ヴァンダル王国', '{}'::text[], 429, 534, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.ostrogoth', '東ゴート王国', '{}'::text[], 493, 555, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.lombard', 'ランゴバルド王国', '{}'::text[], 568, 774, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.anglo_saxon', 'アングロ・サクソン七王国', ARRAY['ヘプターキー']::text[], 449, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.alfred', 'アルフレッド大王', '{}'::text[], 871, 899, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.canute', 'クヌートの北海帝国', ARRAY['カヌート']::text[], 1016, 1035, 'exact', ARRAY[2,5]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.normandy_duchy', 'ノルマンディー公国', '{}'::text[], 911, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.two_sicilies', '両シチリア王国', ARRAY['ノルマン朝シチリア王国']::text[], 1130, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.novgorod', 'ノヴゴロド国', '{}'::text[], 862, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.tours_of_toledo', 'トレド翻訳学校', '{}'::text[], 1100, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.twelfth_renaissance', '12世紀ルネサンス', '{}'::text[], 1100, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.gothic', 'ゴシック様式', '{}'::text[], 1150, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.romanesque', 'ロマネスク様式', '{}'::text[], 1000, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.wycliffe', 'ウィクリフの教会批判', '{}'::text[], 1380, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.hus', 'フスの改革', ARRAY['フス戦争']::text[], 1415, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.medici', 'メディチ家', '{}'::text[], 1434, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.fugger', 'フッガー家', '{}'::text[], 1500, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.antwerp', 'アントウェルペンの繁栄', '{}'::text[], 1500, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.amsterdam', 'アムステルダムの繁栄', '{}'::text[], 1600, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.wool_industry', '毛織物工業', '{}'::text[], 1300, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.aztec_tribute', 'アステカの貢納制', '{}'::text[], 1400, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.encomienda', 'エンコミエンダ制', '{}'::text[], 1503, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.hacienda', 'アシエンダ制', '{}'::text[], 1600, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.las_casas', 'ラス・カサスの告発', ARRAY['インディアスの破壊についての簡潔な報告']::text[], 1552, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.plantation', 'プランテーション', '{}'::text[], 1600, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.jamestown', 'ジェームズタウンの建設', '{}'::text[], 1607, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.mayflower', 'ピルグリム・ファーザーズの渡来', ARRAY['メイフラワー号']::text[], 1620, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.thirteen_colonies', '13植民地の成立', '{}'::text[], 1732, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.qing_new_policy', '光緒新政', '{}'::text[], 1901, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.railway_nationalization', '幹線鉄道国有化', '{}'::text[], 1911, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.twenty_one_demands', '二十一カ条の要求', '{}'::text[], 1915, NULL, 'exact', ARRAY[22,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.new_culture', '新文化運動', ARRAY['文学革命']::text[], 1915, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.northern_warlords', '北洋軍閥の割拠', '{}'::text[], 1916, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.shanghai_coup', '上海クーデタ', ARRAY['四・一二事件']::text[], 1927, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.manchukuo', '満州国の建国', '{}'::text[], 1932, NULL, 'exact', ARRAY[22,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.second_united_front', '第2次国共合作', '{}'::text[], 1937, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.chinese_civil_war', '国共内戦', '{}'::text[], 1946, 1949, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.add.taiwan_retreat', '国民政府の台湾移転', '{}'::text[], 1949, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.mughal_decline', 'ムガル帝国の衰退', '{}'::text[], 1707, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.carnatic', 'カーナティック戦争', '{}'::text[], 1744, 1763, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.buxar', 'ブクサールの戦い', '{}'::text[], 1764, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.zamindari', 'ザミンダーリー制', '{}'::text[], 1793, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.ryotwari', 'ライヤットワーリー制', '{}'::text[], 1820, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.indian_cotton', 'インド綿織物業の崩壊', '{}'::text[], 1810, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.congress_found', 'インド国民会議の結成', '{}'::text[], 1885, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.muslim_league', '全インド・ムスリム連盟の結成', '{}'::text[], 1906, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.rowlatt', 'ローラット法', '{}'::text[], 1919, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.purna_swaraj', '完全独立の決議', ARRAY['プールナ・スワラージ']::text[], 1929, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.india_act_1935', '新インド統治法', ARRAY['1935年インド統治法']::text[], 1935, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.kashmir', 'カシミール紛争', '{}'::text[], 1947, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.bangladesh', 'バングラデシュの独立', '{}'::text[], 1971, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.opium_import', 'アヘンの密輸', '{}'::text[], 1820, NULL, 'century', ARRAY[22,16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.lin_zexu', '林則徐のアヘン没収', '{}'::text[], 1839, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.tianjin_treaty', '天津条約', '{}'::text[], 1858, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.aigun', 'アイグン条約', '{}'::text[], 1858, NULL, 'exact', ARRAY[22,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.russia_maritime', '沿海州の獲得', '{}'::text[], 1860, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.ili', 'イリ条約', '{}'::text[], 1881, NULL, 'exact', ARRAY[22,19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.tonghak', '甲午農民戦争', ARRAY['東学の乱']::text[], 1894, NULL, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.donghak_reform', '甲午改革', '{}'::text[], 1894, NULL, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.russo_japanese_treaty', '日露協約', '{}'::text[], 1907, NULL, 'exact', ARRAY[24,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.open_door', '門戸開放宣言', '{}'::text[], 1899, NULL, 'exact', ARRAY[7,22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.spheres_of_influence', '列強の中国分割', ARRAY['勢力範囲の設定']::text[], 1898, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.panama_canal', 'パナマ運河の開通', '{}'::text[], 1914, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.big_stick', '棍棒外交', '{}'::text[], 1901, NULL, 'century', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.dollar_diplomacy', 'ドル外交', '{}'::text[], 1909, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.good_neighbor', '善隣外交', '{}'::text[], 1933, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.mexican_revolution', 'メキシコ革命', '{}'::text[], 1910, 1917, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.cuban_revolution', 'キューバ革命', '{}'::text[], 1959, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.chile_coup', 'チリ軍事クーデタ', '{}'::text[], 1973, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.falklands', 'フォークランド紛争', ARRAY['マルビナス戦争']::text[], 1982, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.weimar_collapse', 'ヴァイマル共和国の崩壊', '{}'::text[], 1933, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.reichstag_fire', '国会議事堂放火事件', '{}'::text[], 1933, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.nuremberg_laws', 'ニュルンベルク法', '{}'::text[], 1935, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.kristallnacht', '水晶の夜', '{}'::text[], 1938, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.wannsee', 'ヴァンゼー会議', '{}'::text[], 1942, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.el_alamein', 'エル・アラメインの戦い', '{}'::text[], 1942, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.kursk', 'クルスクの戦い', '{}'::text[], 1943, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.leningrad_siege', 'レニングラード包囲戦', '{}'::text[], 1941, 1944, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.dunkirk', 'ダンケルクの撤退', '{}'::text[], 1940, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.katyn', 'カティンの森事件', '{}'::text[], 1940, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.warsaw_uprising', 'ワルシャワ蜂起', '{}'::text[], 1944, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.dumbarton_oaks', 'ダンバートン・オークス会議', '{}'::text[], 1944, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.san_francisco_conference', 'サンフランシスコ会議', ARRAY['国際連合憲章']::text[], 1945, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.udhr', '世界人権宣言', '{}'::text[], 1948, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.genocide_convention', 'ジェノサイド条約', '{}'::text[], 1948, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.tokyo_trial', '極東国際軍事裁判', ARRAY['東京裁判']::text[], 1946, 1948, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.greece_civil_war', 'ギリシア内戦', '{}'::text[], 1946, 1949, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.tito_split', 'ユーゴスラヴィアのコミンフォルム除名', '{}'::text[], 1948, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.poland_1956', 'ポズナニ暴動', ARRAY['ポーランド反ソ暴動']::text[], 1956, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.solidarity', '連帯の結成', ARRAY['ソリダリノシチ']::text[], 1980, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.romania_1989', 'ルーマニア革命', ARRAY['チャウシェスクの処刑']::text[], 1989, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.velvet_revolution', 'ビロード革命', '{}'::text[], 1989, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.czechoslovakia_split', 'チェコとスロヴァキアの分離', '{}'::text[], 1993, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.baltic_independence', 'バルト三国の独立', '{}'::text[], 1991, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.chechnya', 'チェチェン紛争', '{}'::text[], 1994, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.rwanda', 'ルワンダ内戦', ARRAY['ルワンダ虐殺']::text[], 1994, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.somalia', 'ソマリア内戦', '{}'::text[], 1991, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.darfur', 'ダルフール紛争', '{}'::text[], 2003, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.east_timor', '東ティモール独立', '{}'::text[], 2002, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.tiananmen_aftermath', '天安門事件後の経済成長', ARRAY['南巡講話']::text[], 1992, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.asian_currency_crisis', 'アジア通貨危機', '{}'::text[], 1997, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.ext.four_asian_tigers', 'アジア NIES の台頭', ARRAY['新興工業経済地域']::text[], 1970, NULL, 'century', ARRAY[21]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.neolithic', '農耕・牧畜の開始', ARRAY['新石器革命']::text[], -9000, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.four_civilizations', '四大文明', '{}'::text[], -3000, NULL, 'century', ARRAY[10,14,16,22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.bronze_age', '青銅器の使用', '{}'::text[], -3000, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.iron_age', '鉄器時代の始まり', '{}'::text[], -1200, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.silk_road', 'オアシスの道', ARRAY['シルク・ロード','絹の道']::text[], -100, NULL, 'century', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.steppe_road', '草原の道', '{}'::text[], -500, NULL, 'century', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.sea_road', '海の道', '{}'::text[], 1, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.periplus', 'エリュトゥラー海案内記', '{}'::text[], 50, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.daqin_envoy', '大秦王安敦の使者', '{}'::text[], 166, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.marco_polo', 'マルコ・ポーロの東方見聞録', ARRAY['世界の記述']::text[], 1298, NULL, 'exact', ARRAY[22,3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.pax_mongolica', 'モンゴルの平和', ARRAY['パクス・モンゴリカ']::text[], 1250, NULL, 'century', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.plano_carpini', 'プラノ・カルピニの派遣', '{}'::text[], 1245, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.rubruck', 'ルブルクの派遣', '{}'::text[], 1253, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.montecorvino', 'モンテ・コルヴィノの布教', '{}'::text[], 1294, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.matteo_ricci', 'マテオ・リッチの布教', ARRAY['坤輿万国全図']::text[], 1583, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.rites_controversy', '典礼問題', '{}'::text[], 1704, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.adam_schall', 'アダム・シャール', ARRAY['湯若望']::text[], 1591, 1666, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.castiglione', 'カスティリオーネ', ARRAY['郎世寧']::text[], 1688, 1766, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.macartney', 'マカートニーの訪中', '{}'::text[], 1793, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.amherst', 'アマーストの訪中', '{}'::text[], 1816, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.sino_soviet_treaty', '中ソ友好同盟相互援助条約', '{}'::text[], 1950, NULL, 'exact', ARRAY[22,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.great_wall', '万里の長城', '{}'::text[], -214, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.terracotta', '兵馬俑', '{}'::text[], -210, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.dunhuang', '敦煌莫高窟', '{}'::text[], 366, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.longmen', '竜門石窟', '{}'::text[], 494, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.yungang', '雲崗石窟', '{}'::text[], 460, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.tang_poetry', '唐詩の隆盛', ARRAY['李白','杜甫']::text[], 700, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.song_landscape', '宋の山水画', ARRAY['院体画','文人画']::text[], 1000, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.yuan_drama', '元曲', '{}'::text[], 1300, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.ming_novels', '明の四大奇書', ARRAY['三国志演義','水滸伝','西遊記']::text[], 1500, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.dream_red_chamber', '紅楼夢', '{}'::text[], 1750, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.yongle_encyclopedia', '永楽大典', '{}'::text[], 1408, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.siku_quanshu', '四庫全書', '{}'::text[], 1782, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.kangxi_dictionary', '康熙字典', '{}'::text[], 1716, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.zizhi_tongjian', '資治通鑑', '{}'::text[], 1084, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.tenka_kokka', '天工開物', '{}'::text[], 1637, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.bencao_gangmu', '本草綱目', '{}'::text[], 1596, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.nongzheng_quanshu', '農政全書', '{}'::text[], 1639, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.taj_mahal', 'タージ・マハル', '{}'::text[], 1653, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.sikhism', 'シク教の成立', '{}'::text[], 1500, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.bhakti', 'バクティ運動', '{}'::text[], 1200, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.urdu', 'ウルドゥー語の成立', '{}'::text[], 1500, NULL, 'century', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.alhambra', 'アルハンブラ宮殿', '{}'::text[], 1350, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.suleymaniye', 'スレイマン・モスク', '{}'::text[], 1557, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.isfahan', 'イスファハーンの繁栄', ARRAY['世界の半分']::text[], 1600, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.arabian_nights', '千夜一夜物語', ARRAY['アラビアン・ナイト']::text[], 900, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.rubaiyat', 'ルバイヤート', '{}'::text[], 1100, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.sufism', 'スーフィズム', ARRAY['神秘主義']::text[], 1100, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.madrasa', 'マドラサ', ARRAY['学院']::text[], 1065, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.qanat', 'カナート', ARRAY['地下水路']::text[], -500, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.dhow', 'ダウ船', '{}'::text[], 700, NULL, 'century', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.junk', 'ジャンク船', '{}'::text[], 1000, NULL, 'century', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.caravel', 'カラベル船', '{}'::text[], 1400, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.astrolabe', 'アストロラーベ', '{}'::text[], 800, NULL, 'century', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.zheng_he_ship', '鄭和の宝船', '{}'::text[], 1405, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.crop_exchange', 'コロンブスの交換', ARRAY['新旧大陸の作物交換']::text[], 1500, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.potato_famine', 'アイルランドのジャガイモ飢饉', '{}'::text[], 1845, 1849, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.tea_trade', '茶の貿易', '{}'::text[], 1700, NULL, 'century', ARRAY[22,2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.cotton_gin', '綿繰り機', '{}'::text[], 1793, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.railway_mania', '鉄道建設ブーム', '{}'::text[], 1840, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.great_exhibition', 'ロンドン万国博覧会', ARRAY['第1回万国博覧会']::text[], 1851, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.paris_expo', 'パリ万国博覧会', '{}'::text[], 1855, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.department_store', '百貨店の出現', '{}'::text[], 1852, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.mass_production', '大量生産方式', ARRAY['フォード・システム']::text[], 1913, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.radio_broadcast', 'ラジオ放送の開始', '{}'::text[], 1920, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.talkies', 'トーキー映画', '{}'::text[], 1927, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.television', 'テレビ放送の開始', '{}'::text[], 1936, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.computer_eniac', 'ENIAC の完成', '{}'::text[], 1946, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.internet', 'インターネットの商用化', '{}'::text[], 1990, NULL, 'century', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.human_genome', 'ヒトゲノム解読', '{}'::text[], 2003, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.moon_landing', 'アポロ11号の月面着陸', '{}'::text[], 1969, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.gagarin', 'ガガーリンの宇宙飛行', '{}'::text[], 1961, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.antarctic_treaty', '南極条約', '{}'::text[], 1959, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.stockholm_conference', '国連人間環境会議', ARRAY['ストックホルム会議']::text[], 1972, NULL, 'exact', ARRAY[5]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.rio_summit', '国連環境開発会議', ARRAY['地球サミット']::text[], 1992, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.sdgs', '持続可能な開発目標', ARRAY['SDGs']::text[], 2015, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.who_found', '世界保健機関の設立', ARRAY['WHO']::text[], 1948, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.unesco', '国際連合教育科学文化機関', ARRAY['ユネスコ']::text[], 1946, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.imf_found', '国際通貨基金の設立', ARRAY['IMF']::text[], 1945, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.world_bank', '国際復興開発銀行', ARRAY['世界銀行','IBRD']::text[], 1945, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.g7', '先進国首脳会議', ARRAY['サミット']::text[], 1975, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.fin.covid19', '新型コロナウイルスの世界的流行', '{}'::text[], 2020, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.chavin', 'チャビン文化', '{}'::text[], -1000, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.olmec', 'オルメカ文明', '{}'::text[], -1200, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.nazca', 'ナスカ文化', ARRAY['ナスカの地上絵']::text[], 1, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.tiwanaku', 'ティワナク文化', '{}'::text[], 500, NULL, 'century', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.zhou_east', '周の東遷', '{}'::text[], -770, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.jin_division', '晋の三分', '{}'::text[], -403, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.changping', '長平の戦い', '{}'::text[], -260, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.xiang_yu', '項羽と劉邦の抗争', ARRAY['楚漢戦争']::text[], -206, -202, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.wu_zhu_coin', '五銖銭', '{}'::text[], -118, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.salt_iron', '塩・鉄・酒の専売', '{}'::text[], -117, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.junguo', '郡国制', '{}'::text[], -202, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.wu_chu_rebellion', '呉楚七国の乱', '{}'::text[], -154, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.xiongnu_split', '匈奴の南北分裂', '{}'::text[], 48, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.gaogouli', '高句麗', '{}'::text[], -37, 668, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.silla_unify', '新羅の朝鮮半島統一', '{}'::text[], 676, NULL, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.goryeo', '高麗の建国', '{}'::text[], 918, NULL, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.joseon', '朝鮮王朝の成立', ARRAY['李氏朝鮮']::text[], 1392, NULL, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.hangul', '訓民正音の制定', ARRAY['ハングル']::text[], 1446, NULL, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.imjin_war', '壬辰・丁酉倭乱', ARRAY['文禄・慶長の役']::text[], 1592, 1598, 'exact', ARRAY[23,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.balhae', '渤海', '{}'::text[], 698, 926, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.jurchen_yuan_fall', '元の北走', '{}'::text[], 1368, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.oirat', 'オイラトの強盛', '{}'::text[], 1449, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.altan', 'アルタン・ハンの侵入', '{}'::text[], 1550, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.wokou', '倭寇', '{}'::text[], 1350, NULL, 'century', ARRAY[22,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.macau', 'ポルトガルのマカオ居住', '{}'::text[], 1557, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.tanegashima', '鉄砲伝来', '{}'::text[], 1543, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.xavier_japan', 'ザビエルの来日', '{}'::text[], 1549, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.shimabara', '島原の乱', '{}'::text[], 1637, 1638, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.dutch_learning', '蘭学の発達', '{}'::text[], 1720, NULL, 'century', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.tempo_reform', '天保の改革', '{}'::text[], 1841, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.eu_constitution_reject', 'EU 憲法条約の否決', '{}'::text[], 2005, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.lisbon_treaty', 'リスボン条約', '{}'::text[], 2009, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.greek_debt', 'ギリシア債務危機', '{}'::text[], 2010, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.ukraine_crimea', 'ロシアのクリミア併合', '{}'::text[], 2014, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.syria_civil_war', 'シリア内戦', '{}'::text[], 2011, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.is_declaration', 'IS の勢力拡大', ARRAY['イスラム国']::text[], 2014, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.taliban', 'ターリバーンの政権掌握', '{}'::text[], 1996, NULL, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.afghan_war_us', 'アフガニスタン戦争', '{}'::text[], 2001, NULL, 'exact', ARRAY[19]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.six_party', '六者会合', '{}'::text[], 2003, NULL, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.korea_summit', '南北首脳会談', '{}'::text[], 2000, NULL, 'exact', ARRAY[23]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.eu_enlargement', 'EU の東方拡大', '{}'::text[], 2004, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.nato_enlargement', 'NATO の東方拡大', '{}'::text[], 1999, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.start1', '戦略兵器削減条約', ARRAY['START I']::text[], 1991, NULL, 'exact', ARRAY[7,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.salt1', '戦略兵器制限交渉', ARRAY['SALT I']::text[], 1972, NULL, 'exact', ARRAY[7,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.ctbt', '包括的核実験禁止条約', ARRAY['CTBT']::text[], 1996, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.pugwash', 'パグウォッシュ会議', '{}'::text[], 1957, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.russell_einstein', 'ラッセル・アインシュタイン宣言', '{}'::text[], 1955, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.bikini', 'ビキニ環礁の水爆実験', ARRAY['第五福竜丸事件']::text[], 1954, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.vietnam_division', 'ジュネーヴ休戦協定', ARRAY['インドシナ休戦協定']::text[], 1954, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.dien_bien_phu', 'ディエンビエンフーの戦い', '{}'::text[], 1954, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.seato', '東南アジア条約機構', ARRAY['SEATO']::text[], 1954, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.cento', '中東条約機構', ARRAY['バグダード条約機構','CENTO']::text[], 1955, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.anzus', '太平洋安全保障条約', ARRAY['ANZUS']::text[], 1951, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.mccarthyism', 'マッカーシズム', ARRAY['赤狩り']::text[], 1950, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.brown_v_board', 'ブラウン判決', ARRAY['人種隔離の違憲判決']::text[], 1954, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.montgomery', 'モンゴメリーのバス・ボイコット', '{}'::text[], 1955, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.march_on_washington', 'ワシントン大行進', ARRAY['私には夢がある']::text[], 1963, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.voting_rights_act', '投票権法', '{}'::text[], 1965, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.watergate', 'ウォーターゲート事件', '{}'::text[], 1972, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.iran_hostage', 'イラン大使館人質事件', '{}'::text[], 1979, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.sdi', '戦略防衛構想', ARRAY['SDI','スターウォーズ計画']::text[], 1983, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.reykjavik', 'レイキャビク会談', '{}'::text[], 1986, NULL, 'exact', ARRAY[5]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.gulf_of_aqaba', 'アカバ湾封鎖', '{}'::text[], 1967, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.intifada', 'インティファーダ', '{}'::text[], 1987, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.hamas', 'ハマースの結成', '{}'::text[], 1987, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.hezbollah', 'ヒズボラの結成', '{}'::text[], 1982, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.lebanon_civil_war', 'レバノン内戦', '{}'::text[], 1975, 1990, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.kuwait_invasion', 'イラクのクウェート侵攻', '{}'::text[], 1990, NULL, 'exact', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.oil_crisis2', '第2次石油危機', '{}'::text[], 1979, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.stagflation', 'スタグフレーション', '{}'::text[], 1974, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.neoliberalism', '新自由主義への転換', '{}'::text[], 1979, NULL, 'century', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.welfare_state', '福祉国家の成立', ARRAY['ゆりかごから墓場まで']::text[], 1945, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.beveridge', 'ベヴァリッジ報告', '{}'::text[], 1942, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.marshall_aid_refusal', '東欧のマーシャル・プラン拒否', '{}'::text[], 1947, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.berlin_airlift', 'ベルリン空輸', '{}'::text[], 1948, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.two_germanys_un', '東西ドイツの国連同時加盟', '{}'::text[], 1973, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.basic_treaty', '東西ドイツ基本条約', '{}'::text[], 1972, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.warsaw_treaty_poland', 'ワルシャワ条約', ARRAY['西独ポーランド国交正常化']::text[], 1970, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.china_un_seat', '中華人民共和国の国連代表権獲得', '{}'::text[], 1971, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.sino_us_normalization', '米中国交正常化', '{}'::text[], 1979, NULL, 'exact', ARRAY[22,7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.vietnam_unification', 'ベトナム社会主義共和国の成立', '{}'::text[], 1976, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.cambodia_vietnam', 'カンボジア・ベトナム戦争', '{}'::text[], 1978, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.sino_vietnamese', '中越戦争', '{}'::text[], 1979, NULL, 'exact', ARRAY[22,17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.myanmar_democracy', 'ミャンマーの民主化運動', '{}'::text[], 1988, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.marcos_fall', 'マルコス政権の崩壊', ARRAY['ピープルパワー革命']::text[], 1986, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.indonesia_reformasi', 'スハルト政権の崩壊', '{}'::text[], 1998, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.apec', 'アジア太平洋経済協力', ARRAY['APEC']::text[], 1989, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.tpp', '環太平洋パートナーシップ協定', ARRAY['TPP']::text[], 2016, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.mercosur', '南米南部共同市場', ARRAY['メルコスール']::text[], 1995, NULL, 'exact', ARRAY[8]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.au', 'アフリカ連合', '{}'::text[], 2002, NULL, 'exact', ARRAY[15]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.brics', 'BRICS の台頭', '{}'::text[], 2000, NULL, 'century', ARRAY[22,16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.sup.g20', '主要20か国・地域首脳会議', ARRAY['G20']::text[], 2008, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.hittite_fall', 'ヒッタイトの滅亡', '{}'::text[], -1200, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.sea_peoples', '海の民の活動', '{}'::text[], -1200, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.israel_kingdom', 'ヘブライ王国の分裂', '{}'::text[], -922, NULL, 'century', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.carthage_found', 'カルタゴの建設', '{}'::text[], -814, NULL, 'century', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.rome_found', 'ローマの建国', '{}'::text[], -753, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.ionian_revolt', 'イオニア植民市の反乱', ARRAY['ミレトスの反乱']::text[], -499, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.thermopylae', 'テルモピレーの戦い', '{}'::text[], -480, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.plataea', 'プラタイアの戦い', '{}'::text[], -479, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.leuctra', 'レウクトラの戦い', '{}'::text[], -371, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.zama', 'ザマの戦い', '{}'::text[], -202, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.cannae', 'カンネーの戦い', '{}'::text[], -216, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.pharsalus', 'ファルサロスの戦い', '{}'::text[], -48, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.teutoburg', 'トイトブルクの戦い', '{}'::text[], 9, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.catalaunum', 'カタラウヌムの戦い', '{}'::text[], 451, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.attila', 'アッティラのイタリア侵入', '{}'::text[], 452, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.yarmuk', 'ヤルムークの戦い', '{}'::text[], 636, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.qadisiyya', 'カーディシーヤの戦い', '{}'::text[], 637, NULL, 'exact', ARRAY[10]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.covadonga', 'レコンキスタの開始', '{}'::text[], 722, NULL, 'century', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.las_navas', 'ラス・ナバス・デ・トロサの戦い', '{}'::text[], 1212, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.bouvines', 'ブーヴィーヌの戦い', '{}'::text[], 1214, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.crecy', 'クレシーの戦い', '{}'::text[], 1346, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.agincourt', 'アジャンクールの戦い', '{}'::text[], 1415, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.orleans', 'オルレアンの解放', '{}'::text[], 1429, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.nicopolis', 'ニコポリスの戦い', '{}'::text[], 1396, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.varna', 'ヴァルナの戦い', '{}'::text[], 1444, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.pavia', 'パヴィアの戦い', '{}'::text[], 1525, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.italian_wars', 'イタリア戦争', '{}'::text[], 1494, 1559, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.cateau_cambresis', 'カトー・カンブレジ条約', '{}'::text[], 1559, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.white_mountain', '白山の戦い', ARRAY['ビラー・ホラの戦い']::text[], 1620, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.breitenfeld', 'ブライテンフェルトの戦い', '{}'::text[], 1631, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.rocroi', 'ロクロワの戦い', '{}'::text[], 1643, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.pyrenees', 'ピレネー条約', '{}'::text[], 1659, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.blenheim', 'ブレンハイムの戦い', '{}'::text[], 1704, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.poltava', 'ポルタヴァの戦い', '{}'::text[], 1709, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.nystad', 'ニスタット条約', '{}'::text[], 1721, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.rossbach', 'ロスバハの戦い', '{}'::text[], 1757, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.plassey_aftermath', 'ベンガル太守の敗北', '{}'::text[], 1757, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.valmy', 'ヴァルミーの戦い', '{}'::text[], 1792, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.nile', 'アブキール湾の海戦', ARRAY['ナイルの海戦']::text[], 1798, NULL, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.egypt_expedition', 'ナポレオンのエジプト遠征', '{}'::text[], 1798, 1799, 'exact', ARRAY[14]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.jena', 'イエナの戦い', '{}'::text[], 1806, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.stein_hardenberg', 'シュタイン・ハルデンベルクの改革', ARRAY['プロイセン改革']::text[], 1807, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.spanish_uprising', 'スペイン反乱', '{}'::text[], 1808, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.borodino', 'ボロディノの戦い', '{}'::text[], 1812, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.hundred_days', '百日天下', '{}'::text[], 1815, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.carlsbad', 'カールスバート決議', '{}'::text[], 1819, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.decembrist', 'デカブリストの乱', '{}'::text[], 1825, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.november_uprising', 'ポーランド反乱', '{}'::text[], 1830, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.sepoy_delhi', 'デリー占領', '{}'::text[], 1857, NULL, 'exact', ARRAY[16]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.solferino', 'ソルフェリーノの戦い', '{}'::text[], 1859, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.red_cross', '赤十字の設立', '{}'::text[], 1864, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.sadowa', 'サドワの戦い', ARRAY['ケーニヒグレーツの戦い']::text[], 1866, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.sedan', 'セダンの戦い', ARRAY['スダンの戦い']::text[], 1870, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.frankfurt_treaty', 'フランクフルト条約', '{}'::text[], 1871, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.tsushima', '日本海海戦', '{}'::text[], 1905, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.mukden', '奉天会戦', '{}'::text[], 1905, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.port_arthur', '旅順攻囲戦', '{}'::text[], 1904, 1905, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.tannenberg', 'タンネンベルクの戦い', '{}'::text[], 1914, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.somme', 'ソンムの戦い', '{}'::text[], 1916, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.jutland', 'ユトランド沖海戦', '{}'::text[], 1916, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.gallipoli', 'ガリポリの戦い', '{}'::text[], 1915, NULL, 'exact', ARRAY[11]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.lusitania', 'ルシタニア号事件', '{}'::text[], 1915, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.zimmermann', 'ツィンメルマン電報', '{}'::text[], 1917, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.siberian_intervention', 'シベリア出兵', ARRAY['対ソ干渉戦争']::text[], 1918, 1922, 'exact', ARRAY[4,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.kronstadt', 'クロンシュタットの反乱', '{}'::text[], 1921, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.rapallo', 'ラパロ条約', '{}'::text[], 1922, NULL, 'exact', ARRAY[2,4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.corfu', 'コルフ島事件', '{}'::text[], 1923, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.manchuria_lytton', 'リットン調査団の報告', '{}'::text[], 1932, NULL, 'exact', ARRAY[22]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.guernica', 'ゲルニカ爆撃', '{}'::text[], 1937, NULL, 'exact', ARRAY[3]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.nomonhan', 'ノモンハン事件', ARRAY['ハルハ河戦争']::text[], 1939, NULL, 'exact', ARRAY[20]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.blitzkrieg', '電撃戦', '{}'::text[], 1939, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.vichy', 'ヴィシー政府の成立', '{}'::text[], 1940, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.free_france', '自由フランスの結成', '{}'::text[], 1940, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.lend_lease', '武器貸与法', ARRAY['レンドリース法']::text[], 1941, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.coral_sea', '珊瑚海海戦', '{}'::text[], 1942, NULL, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.guadalcanal', 'ガダルカナル島の戦い', '{}'::text[], 1942, 1943, 'exact', ARRAY[17]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.okinawa', '沖縄戦', '{}'::text[], 1945, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.nagasaki', '長崎への原子爆弾投下', '{}'::text[], 1945, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.soviet_japan', 'ソ連の対日参戦', '{}'::text[], 1945, NULL, 'exact', ARRAY[4,24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.berlin_fall', 'ベルリン陥落', '{}'::text[], 1945, NULL, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.security_council', '安全保障理事会の成立', ARRAY['五大国の拒否権']::text[], 1945, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.gatt_uruguay', 'ウルグアイ・ラウンド', '{}'::text[], 1986, 1994, 'exact', ARRAY[2]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.oil_dollar', 'オイル・ダラー', '{}'::text[], 1974, NULL, 'century', ARRAY[12]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.nixon_gold', '金・ドル交換の停止', '{}'::text[], 1971, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.smithsonian', 'スミソニアン協定', '{}'::text[], 1971, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.kyoto_cop3', '気候変動枠組条約第3回締約国会議', ARRAY['COP3']::text[], 1997, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.montreal_protocol', 'モントリオール議定書', '{}'::text[], 1987, NULL, 'exact', ARRAY[7]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.chernobyl_aftermath', 'ソ連の情報公開の加速', '{}'::text[], 1986, NULL, 'exact', ARRAY[4]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;
INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ('ce.last.fukushima', '福島第一原子力発電所事故', '{}'::text[], 2011, NULL, 'exact', ARRAY[24]::smallint[])
  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;

-- 正典人物 446 件（承認されず除外 0）
INSERT INTO person (label, aliases, era_id) VALUES ('ハンムラビ', ARRAY['ハンムラピ']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('キュロス2世', ARRAY['キュロス大王']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ダレイオス1世', ARRAY['ダリウス1世']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アレクサンドロス大王', ARRAY['アレクサンドロス3世','アレクサンダー大王']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アショーカ王', ARRAY['アショカ王','阿育王']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カニシカ王', ARRAY['迦膩色迦王']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('始皇帝', ARRAY['秦王政','嬴政']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('劉邦', ARRAY['高祖','漢高祖']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('武帝', ARRAY['漢の武帝']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('王莽', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ペリクレス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ソロン', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('クレイステネス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カエサル', ARRAY['ユリウス・カエサル','シーザー']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アウグストゥス', ARRAY['オクタウィアヌス']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ディオクレティアヌス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('コンスタンティヌス1世', ARRAY['コンスタンティヌス大帝']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('テオドシウス1世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ユスティニアヌス1世', ARRAY['ユスティニアヌス大帝']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ムハンマド', ARRAY['マホメット']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハールーン・アッラシード', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カール大帝', ARRAY['シャルルマーニュ','カロルス大帝']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('オットー1世', ARRAY['オットー大帝']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('グレゴリウス7世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('インノケンティウス3世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('太宗', ARRAY['李世民']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('玄宗', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('則天武后', ARRAY['武則天']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フビライ', ARRAY['クビライ','忽必烈']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('チンギス・ハン', ARRAY['ジンギス・カン','成吉思汗']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('朱元璋', ARRAY['洪武帝','太祖']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('永楽帝', ARRAY['成祖']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('鄭和', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('康熙帝', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('乾隆帝', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヌルハチ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('オスマン1世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('メフメト2世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('スレイマン1世', ARRAY['スレイマン大帝']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アクバル', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アウラングゼーブ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ルター', ARRAY['マルティン・ルター']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カルヴァン', ARRAY['カルヴィン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヘンリ8世', ARRAY['ヘンリー8世']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エリザベス1世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フェリペ2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('コロンブス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マゼラン', ARRAY['マガリャンイス']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('コルテス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ピサロ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('コペルニクス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ニュートン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ルイ14世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('クロムウェル', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ピョートル1世', ARRAY['ピョートル大帝']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エカチェリーナ2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フリードリヒ2世', ARRAY['フリードリヒ大王']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マリア・テレジア', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ワシントン', ARRAY['ジョージ・ワシントン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ロベスピエール', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ナポレオン1世', ARRAY['ナポレオン・ボナパルト','ナポレオン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('メッテルニヒ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ビスマルク', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カヴール', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ガリバルディ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('リンカン', ARRAY['リンカーン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヴィクトリア女王', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マルクス', ARRAY['カール・マルクス']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ダーウィン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ワット', ARRAY['ジェームズ・ワット']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('洪秀全', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('李鴻章', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('康有為', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('孫文', ARRAY['孫中山']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('袁世凱', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('明治天皇', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウィルソン', ARRAY['ウッドロー・ウィルソン']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('レーニン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('スターリン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('トロツキー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヒトラー', ARRAY['アドルフ・ヒトラー']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ムッソリーニ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フランクリン・ローズヴェルト', ARRAY['F・ローズヴェルト','フランクリン・ルーズベルト']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('チャーチル', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ガンディー', ARRAY['ガンジー','マハトマ・ガンディー']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ネルー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジンナー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ムスタファ・ケマル', ARRAY['ケマル・アタテュルク','アタテュルク']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('レザー・ハーン', ARRAY['レザー・シャー']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('毛沢東', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('蔣介石', ARRAY['蒋介石']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('周恩来', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('鄧小平', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('トルーマン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マーシャル', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フルシチョフ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ケネディ', ARRAY['J・F・ケネディ']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ゴルバチョフ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ナセル', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ホー・チ・ミン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('スカルノ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マンデラ', ARRAY['ネルソン・マンデラ']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('キング牧師', ARRAY['マーティン・ルーサー・キング']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ド・ゴール', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アデナウアー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ブラント', ARRAY['ヴィリー・ブラント']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('サッチャー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('レーガン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ホメイニ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ポル・ポト', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ティトー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('サルゴン1世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ネブカドネザル2世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カンビュセス2世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('クセルクセス1世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ダレイオス3世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アルデシール1世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シャープール1世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ホスロー1世', ARRAY['ホスロー1世アヌーシルヴァーン']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ゾロアスター', ARRAY['ツァラトゥストラ']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マニ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イムホテプ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('クフ王', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アメンホテプ4世', ARRAY['イクナートン']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ツタンカーメン', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ラメス2世', ARRAY['ラメセス2世']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('クレオパトラ7世', ARRAY['クレオパトラ']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('リュクルゴス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('テミストクレス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ミルティアデス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フィリッポス2世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ホメロス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヘロドトス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('トゥキディデス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ソクラテス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('プラトン', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アリストテレス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヒッポクラテス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エウクレイデス', ARRAY['ユークリッド']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アルキメデス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エラトステネス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハンニバル', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('スキピオ', ARRAY['大スキピオ']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('グラックス兄弟', ARRAY['ティベリウス・グラックス']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('スパルタクス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ポンペイウス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アントニウス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ネロ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('トラヤヌス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハドリアヌス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マルクス・アウレリウス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カラカラ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('キケロ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウェルギリウス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('タキトゥス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('プトレマイオス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イエス', ARRAY['イエス・キリスト']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('パウロ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アウグスティヌス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヒエロニムス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アタナシウス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アリウス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ネストリウス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ガウタマ・シッダールタ', ARRAY['ブッダ','釈迦']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヴァルダマーナ', ARRAY['マハーヴィーラ']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('チャンドラグプタ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('チャンドラグプタ1世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハルシャ・ヴァルダナ', ARRAY['ハルシャ王']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カーリダーサ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ナーナク', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('バーブル', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シャー・ジャハーン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('孔子', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('老子', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('孟子', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('荀子', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('墨子', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('韓非', ARRAY['韓非子']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('商鞅', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('李斯', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('董仲舒', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('司馬遷', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('班固', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('蔡倫', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('張騫', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('班超', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('曹操', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('法顕', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('玄奘', ARRAY['三蔵法師']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('義浄', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('孝文帝', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('文帝', ARRAY['楊堅']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('煬帝', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('高祖', ARRAY['李淵']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('安禄山', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('李白', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('杜甫', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('韓愈', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('趙匡胤', ARRAY['太祖']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('王安石', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('司馬光', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('朱熹', ARRAY['朱子']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('王守仁', ARRAY['王陽明']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('耶律阿保機', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('完顔阿骨打', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('バトゥ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フラグ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ティムール', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('張居正', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('李自成', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('鄭成功', ARRAY['国姓爺']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('李時珍', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('宋応星', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('徐光啓', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マテオ・リッチ', ARRAY['利瑪竇']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('曽国藩', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('西太后', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('梁啓超', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('魯迅', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('陳独秀', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('胡適', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('張学良', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('林則徐', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ホンタイジ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ムハンマド・アリー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('サラディン', ARRAY['サラーフ・アッディーン']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イブン・シーナー', ARRAY['アヴィケンナ']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イブン・ルシュド', ARRAY['アヴェロエス']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イブン・ハルドゥーン', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イブン・バットゥータ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フワーリズミー', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウマル・ハイヤーム', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ラシード・アッディーン', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シナン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アッバース1世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イスマーイール1世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('セリム1世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ミドハト・パシャ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アブデュルハミト2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('クローヴィス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カール・マルテル', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ピピン', ARRAY['小ピピン']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アルフレッド大王', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウィリアム1世', ARRAY['征服王']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヘンリ2世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジョン王', ARRAY['失地王']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エドワード1世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フィリップ4世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジャンヌ・ダルク', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヘンリ7世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カール5世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カール4世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フリードリヒ1世', ARRAY['赤髭王','バルバロッサ']::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウルバヌス2世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ボニファティウス8世', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウィクリフ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フス', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('グーテンベルク', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ダンテ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ペトラルカ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ボッカチオ', '{}'::text[], 1)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マキァヴェリ', ARRAY['マキャヴェリ']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エラスムス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('トマス・モア', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('レオナルド・ダ・ヴィンチ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ミケランジェロ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ラファエロ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ブリューゲル', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('デューラー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シェークスピア', ARRAY['シェイクスピア']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('セルバンテス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ラブレー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('モンテーニュ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('バルトロメウ・ディアス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヴァスコ・ダ・ガマ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アメリゴ・ヴェスプッチ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('バルボア', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ラス・カサス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ツヴィングリ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イグナティウス・ロヨラ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フランシスコ・ザビエル', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('オラニエ公ウィレム', ARRAY['オレンジ公ウィリアム']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アンリ4世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('リシュリュー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マザラン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('コルベール', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヴァレンシュタイン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('グスタフ・アドルフ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('チャールズ1世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('チャールズ2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジェームズ2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウィリアム3世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウォルポール', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フリードリヒ・ヴィルヘルム1世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヨーゼフ2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カール12世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ホッブズ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ロック', ARRAY['ジョン・ロック']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('モンテスキュー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヴォルテール', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ルソー', ARRAY['ジャン・ジャック・ルソー']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ディドロ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アダム・スミス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マルサス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('リカード', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ベンサム', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カント', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヘーゲル', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('デカルト', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フランシス・ベーコン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ガリレイ', ARRAY['ガリレオ・ガリレイ']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ケプラー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハーヴェー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジェンナー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('リンネ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ラヴォワジェ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハーグリーヴズ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アークライト', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('クロンプトン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カートライト', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('スティーヴンソン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フルトン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ホイットニー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('モース', ARRAY['モールス']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ベル', ARRAY['グラハム・ベル']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エディソン', ARRAY['エジソン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ノーベル', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ダイムラー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ディーゼル', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マルコーニ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ライト兄弟', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('パストゥール', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('コッホ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('レントゲン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('キュリー夫人', ARRAY['マリ・キュリー']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アインシュタイン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フロイト', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジェファソン', ARRAY['トマス・ジェファソン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フランクリン', ARRAY['ベンジャミン・フランクリン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハミルトン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('モンロー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジャクソン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シモン・ボリバル', ARRAY['ボリバル']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('サン・マルティン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イダルゴ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('トゥサン・ルヴェルチュール', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ルイ18世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シャルル10世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ルイ・フィリップ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ナポレオン3世', ARRAY['ルイ・ナポレオン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ティエール', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アレクサンドル2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ニコライ2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ストルイピン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ウィッテ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヴィルヘルム1世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヴィルヘルム2世', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ディズレーリ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('グラッドストン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('セシル・ローズ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジョゼフ・チェンバレン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('セオドア・ローズヴェルト', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('タフト', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('リスト', ARRAY['フリードリヒ・リスト']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ランケ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('コント', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ミル', ARRAY['ジョン・スチュアート・ミル']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('オーウェン', ARRAY['ロバート・オーウェン']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('サン・シモン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フーリエ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エンゲルス', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('バクーニン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ベルンシュタイン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ディケンズ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ユゴー', ARRAY['ヴィクトル・ユゴー']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('バルザック', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ゾラ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('トルストイ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ドストエフスキー', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ゲーテ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ベートーヴェン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('モネ', ARRAY['クロード・モネ']::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ゴッホ', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ピカソ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('バイロン', '{}'::text[], 2)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ケインズ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ヒンデンブルク', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シュトレーゼマン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ブリアン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ネヴィル・チェンバレン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('フランコ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ペタン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アイゼンハワー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アトリー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シューマン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジャン・モネ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('コール', ARRAY['ヘルムート・コール']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ミッテラン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エリツィン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ワレサ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハヴェル', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('チャウシェスク', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ニクソン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ジョンソン', ARRAY['リンドン・ジョンソン']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カーター', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ブッシュ', ARRAY['ジョージ・ブッシュ']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('カストロ', ARRAY['フィデル・カストロ']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ゲバラ', ARRAY['チェ・ゲバラ']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アジェンデ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ペロン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('エンクルマ', ARRAY['ンクルマ']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ルムンバ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('サダト', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アラファト', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ラビン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ベギン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('サダム・フセイン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ブット', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('インディラ・ガンディー', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('スハルト', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アウン・サン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シハヌーク', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('朴正煕', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('金日成', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('李承晩', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('劉少奇', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('林彪', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('江沢民', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('シェワルナゼ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ブレジネフ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('アンドロポフ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ドプチェク', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ナジ', ARRAY['ナジ・イムレ']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('モサデグ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('パフレヴィー2世', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('イノニュ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ベン・ベラ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ハイレ・セラシエ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ケニヤッタ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ニエレレ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('デクラーク', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ツツ', ARRAY['デズモンド・ツツ']::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('マザー・テレサ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ダライ・ラマ14世', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('サハロフ', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;
INSERT INTO person (label, aliases, era_id) VALUES ('ソルジェニーツィン', '{}'::text[], 3)
  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;

-- 共有設問 0 件（承認されず除外 408）

-- 動画のチャンネル 0 件（承認されず除外 1）

-- 動画 0 件（承認・埋め込み可のみ。除外 0）

-- 動画と KC の対応 0 件

COMMIT;

-- 確認用
-- SELECT (SELECT count(*) FROM era) AS era, (SELECT count(*) FROM region) AS region,
--        (SELECT count(*) FROM syllabus_unit) AS unit, (SELECT count(*) FROM kc) AS kc,
--        (SELECT count(*) FROM kc_region) AS kc_region,
--        (SELECT count(*) FROM canon_event) AS canon_event, (SELECT count(*) FROM person) AS person,
--        (SELECT count(*) FROM item) AS item, (SELECT count(*) FROM item_kc) AS item_kc;
-- 期待値: era=3 region=24 unit=117 kc=408 kc_region=891 canon_event=1180 person=446 item=0
