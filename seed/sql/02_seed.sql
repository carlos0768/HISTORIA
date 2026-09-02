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

-- 正典イベント 0 件（承認されず除外 1180）

-- 正典人物 0 件（承認されず除外 446）

COMMIT;

-- 確認用
-- SELECT (SELECT count(*) FROM era) AS era, (SELECT count(*) FROM region) AS region,
--        (SELECT count(*) FROM syllabus_unit) AS unit, (SELECT count(*) FROM kc) AS kc,
--        (SELECT count(*) FROM kc_region) AS kc_region,
--        (SELECT count(*) FROM canon_event) AS canon_event, (SELECT count(*) FROM person) AS person;
-- 期待値: era=3 region=24 unit=117 kc=408 kc_region=891 canon_event=0 person=0
