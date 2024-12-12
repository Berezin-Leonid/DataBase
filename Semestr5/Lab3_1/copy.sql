
--user pwd here
COPY dim_users (user_id, name, age, gender)
FROM '/home/berezin/Desktop/DataBase/Semestr5/Lab3_1/data/dim_users.csv' DELIMITER ',' CSV HEADER;

--SELECT * from dim_users WHERE age = 19

COPY dim_stores (store_id, name, country, region, city, geo_lat, geo_lon)
FROM '/home/berezin/Desktop/DataBase/Semestr5/Lab3_1/data/dim_stores.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"', 
    NULL ''     
);

--SELECT * FROM dim_stores WHERE city = 'Советский'


COPY dim_products (product_id, name, category, price)
FROM '/home/berezin/Desktop/DataBase/Semestr5/Lab3_1/data/dim_products.csv' 
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',  
    NULL ''  
);



COPY dim_time (time_id,month_code,  month, year)
FROM '/home/berezin/Desktop/DataBase/Semestr5/Lab3_1/data/dim_time.csv' DELIMITER ',' CSV HEADER;



COPY sales_facts (fact_id, product_id, time_id, store_id, quantity, user_id, total_amount)
FROM '/home/berezin/Desktop/DataBase/Semestr5/Lab3_1/data/sales_facts.csv' DELIMITER ',' CSV HEADER;




--=============--
