DROP TABLE IF EXISTS sales_facts;
DROP TABLE IF EXISTS dim_stores;
DROP TABLE IF EXISTS dim_users;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_time;
DROP TABLE IF EXISTS dim_locations;




----------
-- Таблица измерений: Пользователи
CREATE TABLE dim_users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10)
);

-- Таблица измерений: Магазины
CREATE TABLE dim_stores (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
	country VARCHAR(50),
	region VARCHAR (50),
	city VARCHAR(50),
	geo_lat DECIMAL(9, 6),
	geo_lon DECIMAL(9, 6)
);

-- Таблица измерений: Продукты
CREATE TABLE dim_products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);

-- Таблица измерений: Время
CREATE TABLE dim_time (
    time_id SERIAL PRIMARY KEY,
	month_code INT,
    month VARCHAR(20),
    year INT
);

-- Таблица фактов: Продажи
CREATE TABLE sales_facts (
    fact_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    time_id INT NOT NULL,
    store_id INT NOT NULL,
    quantity INT NOT NULL,
	user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
	
    FOREIGN KEY (user_id) REFERENCES dim_users(user_id),
    FOREIGN KEY (product_id) REFERENCES dim_products(product_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (store_id) REFERENCES dim_stores(store_id)
);

----------



SET enable_nestloop=0;SELECT 'postgresql' AS dbms,t.table_catalog,t.table_schema,t.table_name,c.column_name,c.ordinal_position,c.data_type,c.character_maximum_length,n.constraint_type,k2.table_schema,k2.table_name,k2.column_name FROM information_schema.tables t NATURAL LEFT JOIN information_schema.columns c LEFT JOIN(information_schema.key_column_usage k NATURAL JOIN information_schema.table_constraints n NATURAL LEFT JOIN information_schema.referential_constraints r)ON c.table_catalog=k.table_catalog AND c.table_schema=k.table_schema AND c.table_name=k.table_name AND c.column_name=k.column_name LEFT JOIN information_schema.key_column_usage k2 ON k.position_in_unique_constraint=k2.ordinal_position AND r.unique_constraint_catalog=k2.constraint_catalog AND r.unique_constraint_schema=k2.constraint_schema AND r.unique_constraint_name=k2.constraint_name WHERE t.TABLE_TYPE='BASE TABLE' AND t.table_schema NOT IN('information_schema','pg_catalog');







