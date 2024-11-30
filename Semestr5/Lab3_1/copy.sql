
COPY dim_users (user_id, name, age, gender)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/data/dim_users.csv' DELIMITER ',' CSV HEADER;

--SELECT * from dim_users WHERE age = 19

COPY dim_stores (store_id, name, country, region, city, geo_lat, geo_lon)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/data/dim_stores_cleaned__.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',  -- Добавляем обработку кавычек для правильного чтения данных с запятыми внутри
    NULL ''     -- Пустые строки будут интерпретироваться как NULL
);

--SELECT * FROM dim_stores WHERE city = 'Советский'


COPY dim_products (product_id, name, category, price)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/data/dim_products.csv' 
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',  -- Добавляем обработку кавычек для правильного чтения данных с запятыми внутри
    NULL ''     -- Пустые строки будут интерпретироваться как NULL
);



COPY dim_time (time_id,month_code,  month, year)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/data/dim_time.csv' DELIMITER ',' CSV HEADER;



COPY sales_facts (fact_id, product_id, time_id, store_id, quantity, user_id, total_amount)
FROM '/Users/leonidberezin/Desktop/DataBase/Semestr5/Lab3_1/data/sales_facts.csv' DELIMITER ',' CSV HEADER;


SELECT * 
FROM sa


--=============--