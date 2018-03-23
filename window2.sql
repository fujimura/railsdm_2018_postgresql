drop table if exists access_logs;
create table access_logs (
  id integer,
  time timestamp
);

insert into access_logs
(id, time)
values
(1, now() - '1 minute'::interval),
(1, now() - '10 minute'::interval),
(1, now() - '40 minute'::interval),
(1, now() - '71 minute'::interval),
(1, now() - '121 minute'::interval),
(2, now() - '1 minute'::interval),
(2, now() - '11 minute'::interval),
(2, now() - '12 minute'::interval),
(2, now() - '13 minute'::interval),
(2, now() - '44 minute'::interval)
;

select * from access_logs order by time;


-- セッション開始のアクセスのみ`time`、それ以外の場合は`NULL`を取得する
SELECT
  id,
  time as current_row,
  LAG(time) OVER (PARTITION BY id ORDER BY time) as previous_row,
  (time - (LAG(time) OVER (PARTITION BY id ORDER BY time))) / 60 as difference
FROM
  access_logs
ORDER BY
id, current_row asc
;
/*
 id |      current_row       |      previous_row      | difference
----+------------------------+------------------------+------------
  1 | 2018-02-18 13:45:06+00 | ¤                      |          ¤
  1 | 2018-02-18 13:36:06+00 | 2018-02-18 13:45:06+00 |          9
  1 | 2018-02-18 13:06:06+00 | 2018-02-18 13:36:06+00 |         30
  1 | 2018-02-18 12:35:06+00 | 2018-02-18 13:06:06+00 |         31
  1 | 2018-02-18 11:45:06+00 | 2018-02-18 12:35:06+00 |         50
  2 | 2018-02-18 13:45:06+00 | ¤                      |          ¤
  2 | 2018-02-18 13:35:06+00 | 2018-02-18 13:45:06+00 |         10
  2 | 2018-02-18 13:34:06+00 | 2018-02-18 13:35:06+00 |          1
  2 | 2018-02-18 13:33:06+00 | 2018-02-18 13:34:06+00 |          1
  2 | 2018-02-18 13:02:06+00 | 2018-02-18 13:33:06+00 |         31
*/

--
SELECT
 id, s.time as timestamp
FROM (
  SELECT
    CASE
      WHEN LAG(time) OVER (PARTITION BY id ORDER BY time) IS NULL THEN time
      WHEN EXTRACT(epoch FROM time - (LAG(time) OVER (PARTITION BY id ORDER BY time))) > 60 * 30 THEN time
      ELSE NULL
    END AS time,
    id
  FROM
    access_logs
  ORDER BY
    time ) as s
WHERE
  time IS NOT NULL
  order by timestamp, id
/*
 id |       timestamp
----+------------------------
  1 | 2018-02-18 11:43:30+00
  1 | 2018-02-18 12:33:30+00
  2 | 2018-02-18 13:00:30+00
  1 | 2018-02-18 13:43:30+00
  2 | 2018-02-18 13:43:30+00
*/
