SELECT * FROM sales_facts



SELECT current_user;


SELECT rolname FROM pg_roles;
SET ROLE postgres;
SET ROLE test;



CREATE OR REPLACE VIEW store_views_krasn AS
SELECT store_id, name, region, city, geo_lat, geo_lon
FROM dim_stores
WHERE region = 'Краснодарский'
WITH CHECK OPTION;


SELECT * FROM store_views_krasn

GRANT UPDATE (city, geo_lat, geo_lon) ON store_views_krasn TO test;


