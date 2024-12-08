
COPY dim_users (user_id, name, age, gender)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/little_data/dim_users.csv' DELIMITER ',' CSV HEADER;

--SELECT * from dim_users WHERE age = 19

COPY dim_stores (store_id, name, country, region, city, geo_lat, geo_lon)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/little_data/dim_stores.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',  -- Добавляем обработку кавычек для правильного чтения данных с запятыми внутри
    NULL ''     -- Пустые строки будут интерпретироваться как NULL
);

--SELECT * FROM dim_stores WHERE city = 'Советский'


COPY dim_products (product_id, name, category, price)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/little_data/dim_products.csv' 
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',  -- Добавляем обработку кавычек для правильного чтения данных с запятыми внутри
    NULL ''     -- Пустые строки будут интерпретироваться как NULL
);



COPY dim_time (time_id,month_code,  month, year)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/little_data/dim_time.csv' DELIMITER ',' CSV HEADER;



COPY sales_facts (fact_id, product_id, time_id, store_id, quantity, user_id, total_amount)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/little_data/sales_facts.csv' DELIMITER ',' CSV HEADER;





DROP TABLE IF EXISTS sales_facts;
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


DO $$
DECLARE
    i INT; 
    file_path TEXT;
BEGIN
	PERFORM set_config('session_replication_role', 'replica', true);
    FOR i IN 14..100 LOOP
        BEGIN
			file_path := '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/data_chunk/chunk_' || i || '.csv';
            RAISE NOTICE 'Загрузка данных из файла: %', file_path;
            EXECUTE format(
                'COPY sales_facts(fact_id, product_id, time_id, store_id, quantity, user_id, total_amount) FROM %L DELIMITER '','' CSV HEADER',
                file_path
            );
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Ошибка загрузки из файла: %', file_path;
        END;
    END LOOP;
	PERFORM set_config('session_replication_role', 'origin', true);
END $$;



COPY sales_facts(fact_id, product_id, time_id, store_id, quantity, user_id, total_amount)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/data_chunk/chunk_1.csv' DELIMITER ',' CSV HEADER


--=============--