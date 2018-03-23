SELECT stations.name,
       stations.address,
       COUNT(parks.name) p,
       FLOOR(ST_Area(ST_Transform(stations.nearby, 4326)::geography)) area,
       FLOOR(COUNT(parks.name) / (ST_Area(ST_Transform(stations.nearby, 4326)::geography) / (1000 * 1000))) p_sqkm
FROM stations
LEFT OUTER JOIN parks ON st_contains(stations.nearby, parks.geom)
WHERE prefecture_code = 13
GROUP BY stations.address,
         stations.name,
         stations.nearby
ORDER BY p_sqkm ASC
