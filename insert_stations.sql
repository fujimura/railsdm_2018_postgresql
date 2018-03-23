-- Get data from http://www.ekidata.jp/

CREATE temporary TABLE tmp  (
  station_cd integer,
  station_g_cd integer,
  station_name varchar,
  station_name_k varchar,
  station_name_r varchar,
  line_cd integer,
  pref_cd integer,
  post varchar,
  add varchar,
  lon numeric,
  lat numeric,
  open_ymd timestamp without time zone,
  close_ymd timestamp without time zone,
  e_status integer,
  e_sort integer
);

CREATE TABLE IF NOT EXISTS stations  (
  code integer,
  name varchar,
  prefecture_code integer,
  address varchar,
  geom geometry(Point, 4326),
  nearby geometry(Polygon, 4326)
);

CREATE INDEX IF NOT EXISTS index_stations_geom ON stations using gist(geom);

\copy tmp from 'data/station20171109free.csv' csv header;

INSERT INTO stations
(code, name, address, prefecture_code, geom)
SELECT DISTINCT ON (station_g_cd)
station_g_cd,
station_name,
add,
pref_cd,
ST_SetSRID(ST_MakePoint(lon, lat), 4326)
from tmp;

CREATE
TEMPORARY TABLE polygons (geom geometry(Polygon, 4326));

INSERT INTO polygons (geom)
SELECT g.geom
FROM
  (SELECT (st_dump(ST_VoronoiPolygons(st_union(geom)))).geom AS geom
   FROM stations
) as g;

CREATE INDEX index_polygons_geom ON polygons USING gist (geom);

UPDATE stations
SET nearby = polygons.geom
FROM polygons
where ST_Contains(polygons.geom, stations.geom);
