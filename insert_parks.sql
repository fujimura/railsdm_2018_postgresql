-- Get data from http://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P13.html and
-- $ unar -s ./data/P13-11_13_GML.zip -o ./data
-- $ shp2pgsql -W CP932 ./data/P13-11_13_GML/P13-11_13.shp p13 | psql

CREATE TABLE IF NOT EXISTS parks (
  prefecture varchar,
  city varchar,
  name varchar,
  type varchar,
  geom geometry(Point, 4326)
);

CREATE INDEX IF NOT EXISTS index_parks_geom ON parks using gist(geom);

INSERT INTO parks
  (prefecture, city, name, type, geom)
SELECT
  p13_005, p13_006, p13_003, p13_004, st_setsrid(geom, 4326)
FROM p13
