DROP TABLE IF EXISTS categories;


CREATE TABLE categories ( name varchar, POSITION integer, updated_at TIMESTAMP WITHOUT TIME ZONE);


ALTER TABLE categories ADD CONSTRAINT constraint_category_name_unique UNIQUE (name);


ALTER TABLE categories ADD CONSTRAINT constraint_category_position_unique UNIQUE (POSITION) DEFERRABLE INITIALLY DEFERRED;


INSERT INTO categories (name, POSITION, updated_at)
VALUES
('A', 1, now() - interval '36 hour'),
('B', 2, now() - interval '36 hour'),
('C', 3, now() - interval '36 hour'),
('D', 4, now() - interval '36 hour'),
('E', 5, now() - interval '36 hour'),
('F', 6, now() - interval '36 hour')
;


SELECT *
FROM categories
ORDER BY POSITION,
         updated_at DESC;

/*

 name | position |         updated_at
------+----------+----------------------------
 A    |        1 | 2018-02-18 12:45:45.423774
 B    |        2 | 2018-02-18 12:45:45.423774
 C    |        3 | 2018-02-18 12:45:45.423774
 D    |        4 | 2018-02-18 12:45:45.423774
 E    |        5 | 2018-02-18 12:45:45.423774
 F    |        6 | 2018-02-18 12:45:45.423774
*/ BEGIN;

-- 'F' を三番目に移動

UPDATE categories
SET position = 3, updated_at = now()
WHERE name = 'F';

-- `position = 3` が重複してしまう

SELECT *
FROM categories
ORDER BY position,
         updated_at DESC;
/*
 name | position |         updated_at
------+----------+----------------------------
 A    |        1 | 2018-02-18 12:45:45.423774
 B    |        2 | 2018-02-18 12:45:45.423774
 F    |        3 | 2018-02-18 12:45:45.426292
 C    |        3 | 2018-02-18 12:45:45.423774
 D    |        4 | 2018-02-18 12:45:45.423774
 E    |        5 | 2018-02-18 12:45:45.423774
 */

-- ROW_NUMBER() で現在の行の番号を取得できる

SELECT name,
       position,
       ROW_NUMBER() OVER ( ORDER BY POSITION, updated_at DESC) AS i,
       updated_at
FROM categories;

/*
  name | position | i |         updated_at
------+----------+---+----------------------------
 A    |        1 | 1 | 2018-02-18 12:45:45.423774
 B    |        2 | 2 | 2018-02-18 12:45:45.423774
 F    |        3 | 3 | 2018-02-18 12:45:45.426292
 C    |        3 | 4 | 2018-02-18 12:45:45.423774
 D    |        4 | 5 | 2018-02-18 12:45:45.423774
 E    |        5 | 6 | 2018-02-18 12:45:45.423774
 */

-- 行番号を使って`position`を再設定
UPDATE categories
SET POSITION = c.row_number
FROM
  (SELECT name,
          ROW_NUMBER() OVER (ORDER BY POSITION, updated_at DESC) AS row_number
   FROM categories) AS c
WHERE c.name = categories.name;

-- `position`の重複がなくなった
SELECT *
FROM categories
ORDER BY POSITION,
         updated_at DESC;
/*
  name | position |         updated_at
------+----------+----------------------------
 A    |        1 | 2018-02-18 12:45:45.423774
 B    |        2 | 2018-02-18 12:45:45.423774
 F    |        3 | 2018-02-18 12:45:45.426292
 C    |        4 | 2018-02-18 12:45:45.423774
 D    |        5 | 2018-02-18 12:45:45.423774
 E    |        6 | 2018-02-18 12:45:45.423774
 */ --COMMIT;
