SELECT * FROM sales_facts






DROP USER test;
REVOKE ALL PRIVILEGES ON DATABASE lab_3_1 FROM test;

SELECT rolname FROM pg_roles;
SET ROLE postgres;
SET ROLE test;



SELECT * FROM store_views_krasn

GRANT UPDATE (city, geo_lat, geo_lon) ON store_views_krasn TO test;


---=======================

SELECT usename FROM pg_user;
CREATE ROLE basic_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON dim_users TO basic_role;

-- Назначаем права на таблицу dim_stores
GRANT SELECT, INSERT, UPDATE, DELETE ON dim_stores TO basic_role;


CREATE USER user1
CREATE USER user2

GRANT basic_role TO user1;
GRANT basic_role TO user2;
SET ROLE user1;
SET ROLE user2;
SET ROLE postgres;

SELECT * FROM sales_facts;
SELECT * FROM dim_stores;
SELECT * FROM dim_users;
SELECT current_user;

ALTER TABLE dim_stores DISABLE ROW LEVEL SECURITY;
ALTER TABLE dim_stores ENABLE ROW LEVEL SECURITY;

SELECT * FROM pg_policies WHERE tablename = 'dim_stores';

DROP POLICY allow_all_except_user1 ON dim_stores;
CREATE POLICY allow_all_except_user1
ON dim_stores
FOR ALL  -- Для всех операций (SELECT, INSERT, UPDATE, DELETE)
USING (current_user <> 'user1');

CREATE POLICY allow_access_for_others
ON dim_stores
FOR ALL
TO PUBLIC
USING (true); 


DROP POLICY deny_dim_stores ON dim_stores;
CREATE POLICY deny_dim_stores
ON dim_stores
FOR ALL  -- Для всех операций (SELECT, INSERT, UPDATE, DELETE)
TO user1
USING (false);


