SELECT s1.name, s2.name,
       ST_Distance_Sphere(s1.geom, s2.geom) AS distance
FROM stations s1
CROSS JOIN stations s2
WHERE s1.name = '代々木公園' AND s1.name <> s2.name
ORDER BY distance
LIMIT 5;
