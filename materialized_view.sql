DROP MATERIALIZED VIEW IF EXISTS beverages;

drop table if exists wines;
CREATE TABLE wines (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name varchar,
  color varchar,
  price integer
);

drop table if exists beers;
CREATE TABLE beers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name varchar,
  type varchar,
  price integer
);

CREATE MATERIALIZED VIEW beverages AS
  SELECT w.id AS id,
  w.name AS name,
  w.price AS price,
  'wines' AS type
  FROM wines AS w
UNION ALL
  SELECT b.id AS id,
  b.name AS name,
  b.price AS price,
  'beers' AS type
  FROM beers AS b
;

CREATE UNIQUE INDEX index_beverages_id ON beverages USING btree (id);

INSERT INTO wines
(name, color, price)
VALUES
('Rotten Highway', 'White', 10000),
('yellow tail Chardonnay', 'White', 1000)
;

INSERT INTO beers
(name, type, price)
VALUES
('Old Rasputin', 'Imperial Stout', 1300),
('Ichiban Shibori', 'White', 300)
;

REFRESH MATERIALIZED VIEW CONCURRENTLY beverages;

SELECT * FROM beverages
WHERE price <= 1000;
