--Create user
CREATE USER test WITH PASSWORD 'dbbd';



--Let connect to db
GRANT CONNECT ON DATABASE lab_3_1 TO test;


--Connect to db
\c lab_3_1

GRANT SELECT, INSERT, UPDATE ON dim_products TO test;
GRANT SELECT ON dim_time TO test;
GRANT SELECT ON dim_users TO test;


GRANT UPDATE (name) ON dim_stores TO test;
GRANT UPDATE (name) ON dim_stores TO test;


--Create new base role
CREATE ROLE default_role;
GRANT SELECT ON dim_time TO default_role;
GRANT SELECT ON dim_users TO default_role;
GRANT UPDATE (name) ON dim_users TO default_role;
GRANT SELECT ON sales_facts TO default_role;

