
CREATE OR REPLACE FUNCTION get_store_revenue(
	start_year INT,
    start_month_code INT,
	end_year INT,
    end_month_code INT,
	country_filter VARCHAR(50) DEFAULT NULL,
    region_filter VARCHAR(50) DEFAULT NULL,
    city_filter VARCHAR(50) DEFAULT NULL,
	store_filter 	VARCHAR(50) DEFAULT NULL
)
RETURNS TABLE (
    store_name VARCHAR(100),
    revenue DECIMAL(15, 2),
	country VARCHAR(50),
	region VARCHAR(50),
	city VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ds.name AS store_name,
        SUM(sf.total_amount) AS revenue,
		ds.country as country,
		ds.region as region,
		ds.city as city
    FROM 
        sales_facts sf
    INNER JOIN 
        dim_stores ds ON sf.store_id = ds.store_id
    INNER JOIN 
        dim_time dt ON sf.time_id = dt.time_id
    WHERE
		(start_year < dt.year OR ((start_year=dt.year) AND (start_month_code <= dt.month_code)))
		AND (dt.year < end_year OR (dt.year=end_year AND dt.month_code <= end_month_code))
        AND (region_filter IS NULL OR ds.region = region_filter)
        AND (country_filter IS NULL OR ds.country = country_filter)
        AND (city_filter IS NULL OR ds.city = city_filter)
		AND (store_filter IS NULL OR ds.name = store_filter)
    GROUP BY 
        ds.name, ds.country, ds.region, ds.city
    ORDER BY 
        revenue DESC;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION get_store_revenue(
    INTEGER, INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR
);


SELECT * FROM get_store_revenue(1991, 01, 2204, 12, 'Россия', 'Краснодарский', 'Геленджик')



CREATE OR REPLACE FUNCTION add_sale(
    p_product_id INT,
    p_user_id INT,
    p_quantity INT,
    p_total_amount DECIMAL,
	p_store_id INT,	
	p_year INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE), -- по умолчанию текущий год
    p_month_code INT DEFAULT EXTRACT(MONTH FROM CURRENT_DATE) -- по умолчанию текущий месяц
)
RETURNS VOID AS $$
DECLARE
    v_time_id INT;
    v_store_id INT;
    v_store_count INT;
    v_product_name VARCHAR;
BEGIN
	SELECT time_id INTO v_time_id
    FROM dim_time 
    WHERE year = p_year AND month_code = p_month_code
    LIMIT 1;
	
	IF v_time_id IS NULL THEN
		RAISE EXCEPTION 'There are no time object % %', p_year, p_month_code;
	END IF;

    INSERT INTO sales_facts (product_id, time_id, store_id, user_id, quantity, total_amount)
    VALUES (p_product_id, v_time_id, p_store_id, p_user_id, p_quantity, p_total_amount);
END;
$$ LANGUAGE plpgsql;




SELECT setval('sales_facts_fact_id_seq', (SELECT MAX(fact_id) FROM sales_facts) + 1);
SELECT add_sale(
	p_product_id := 1,
	p_store_id := 1,
	p_user_id := 1,
	p_quantity := 1,
	p_total_amount := 404.0
	,p_year := 2022
	,p_month_code := 9
);


SELECT * FROM sales_facts
WHERE product_id = 1 
		--AND time_id = 1
		AND store_id = 1
		AND quantity = 1

SELECT add_sale(
    p_product_id := 1,
	user_id := 4,
    p_country := 'Россия',
    p_region := 'Краснодарский',
    p_city := 'Геленджик',
    p_shop_name := 'Garcia, Burns and Thomas',
    p_quantity := 10,
    p_total_amount := 1500.00
);











--===============================--

--Поиск записи
CREATE OR REPLACE FUNCTION search_sales_facts(
    p_product_id INT DEFAULT NULL,
    p_time_id INT DEFAULT NULL,
    p_store_id INT DEFAULT NULL,
    p_user_id INT DEFAULT NULL
)
RETURNS TABLE (
    fact_id INT,
    product_id INT,
    time_id INT,
    store_id INT,
    quantity INT,
    user_id INT,
    total_amount DECIMAL(10, 2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.fact_id, 
        s.product_id, 
        s.time_id, 
        s.store_id, 
        s.quantity, 
        s.user_id, 
        s.total_amount
    FROM sales_facts AS s
    WHERE 
        NOT (s.product_id IS DISTINCT FROM p_product_id) AND
        NOT (s.time_id IS DISTINCT FROM p_time_id) AND
        NOT (s.store_id IS DISTINCT FROM p_store_id) AND
        NOT (s.user_id IS DISTINCT FROM p_user_id);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM sales_facts
WHERE product_id = 147
	AND time_id = 154


SELECT * FROM search_sales_facts(
    p_product_id => 147,
	p_time_id => 154,
    p_store_id => 2711,
	p_user_id => 7205
);


--Корректировка индексов
SELECT setval('sales_facts_fact_id_seq', (SELECT MAX(fact_id) FROM sales_facts) + 1);
SELECT setval('dim_users_user_id_seq', (SELECT MAX(user_id) FROM dim_users) + 1);
SELECT setval('dim_stores_store_id_seq', (SELECT MAX(store_id) FROM dim_stores) + 1);
SELECT setval('dim_products_product_id_seq', (SELECT MAX(product_id) FROM dim_products) + 1);
SELECT setval('dim_time_time_id_seq', (SELECT MAX(time_id) FROM dim_time) + 1);



BEGIN;
--Процедура загрузки базовых агрегаций
CREATE OR REPLACE PROCEDURE insert_null_products()
LANGUAGE plpgsql AS $$
DECLARE
    country_name VARCHAR(50);
    category_name VARCHAR(50);
	region_name VARCHAR(50);
	year_value INT;
BEGIN

	--Вставка объединений по категориям 
    -- Цикл по всем категориям
    FOR category_name IN
        SELECT DISTINCT category FROM dim_products
    LOOP
        -- Вставка значения для каждой категории
        INSERT INTO dim_products (name, category, price)
        VALUES (NULL, category_name, NULL);
    END LOOP;

	--Группировка по странам
	FOR country_name IN
        SELECT DISTINCT country FROM dim_stores WHERE country IS NOT NULL
    LOOP
        -- Вставка значения для каждой страны
        INSERT INTO dim_stores (name, country, region, city, geo_lat, geo_lon)
        VALUES (NULL, country_name, NULL, NULL, NULL, NULL);
    END LOOP;

	--Группировка по регионам
	FOR region_name IN
        SELECT DISTINCT region FROM dim_stores WHERE region IS NOT NULL
    LOOP
        -- Вставка значения для каждого региона
        INSERT INTO dim_stores (name, country, region, city, geo_lat, geo_lon)
        VALUES (NULL, country_name, region_name, NULL, NULL, NULL);
    END LOOP;

	--Вставка группировки по полу
	INSERT INTO dim_users (name, age, gender) VALUES
	(NULL, NULL, 'Female'),
	(NULL, NULL, 'Male');

	--Вставка группировки по годам
	FOR year_value IN
        SELECT DISTINCT year FROM dim_time WHERE year IS NOT NULL
    LOOP
        -- Вставка значения для каждого года
        INSERT INTO dim_time (month_code, month, year)
        VALUES (NULL, NULL, year_value);
    END LOOP;
	
END;
$$;

CALL insert_null_products();


CREATE OR REPLACE FUNCTION get_statistic(
	input_year INT DEFAULT NULL,
    input_month_code INT DEFAULT NULL,
	
	input_country VARCHAR(100) DEFAULT NULL,
	input_region VARCHAR(100) DEFAULT NULL,
	input_city VARCHAR(100) DEFAULT NULL,
	input_store_name VARCHAR(100) DEFAULT NULL,
	
	
    input_product_name VARCHAR(100) DEFAULT NULL,
    input_category VARCHAR(50) DEFAULT NULL,
    input_user_name VARCHAR(100) DEFAULT NULL,
	input_gender BOOLEAN DEFAULT NULL
)RETURNS TABLE (
    fact_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    time_id INT NOT NULL,
    store_id INT NOT NULL,
    quantity INT NOT NULL,
	user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
) AS $$
DECLARE
	dim_time_id INT,
	dim_store_id INT,
	dim_product_id INT,
	dim_user_id INT
BEGIN

    SELECT d.time_id
	INTO dim_time_id
    FROM dim_time AS d
    WHERE 
        NOT (d.year IS DISTINCT FROM input_year) AND
        NOT (d.month_code IS DISTINCT FROM input_month_code);

    -- Получение ID магазина
    SELECT d.store_id
    INTO dim_store_id
    FROM dim_store AS d
    WHERE 
        NOT (input_country IS DISTINCT FROM NULL OR d.country IS DISTINCT FROM input_country) AND
        NOT (input_region IS DISTINCT FROM NULL OR d.region IS DISTINCT FROM input_region) AND
        NOT (input_city IS DISTINCT FROM NULL OR d.city IS DISTINCT FROM input_city) AND
        NOT (input_store_name IS DISTINCT FROM NULL OR d.store_name IS DISTINCT FROM input_store_name);

    -- Получение ID продукта
    SELECT p.product_id
    INTO dim_product_id
    FROM dim_product AS p
    WHERE 
        NOT (input_product_name IS DISTINCT FROM NULL OR p.product_name IS DISTINCT FROM input_product_name) AND
        NOT (input_category IS DISTINCT FROM NULL OR p.category IS DISTINCT FROM input_category);

    -- Получение ID пользователя
    SELECT u.user_id
    INTO dim_user_id
    FROM dim_user AS u
    WHERE 
        NOT (input_user_name IS DISTINCT FROM NULL OR u.user_name IS DISTINCT FROM input_user_name) AND
        NOT (input_gender IS DISTINCT FROM NULL OR u.gender IS DISTINCT FROM input_gender);

    -- Возвращение данных, выбирая из sales_facts на основе найденных ID
    RETURN QUERY
    SELECT 
        sf.fact_id, 
        sf.product_id, 
        sf.time_id, 
        sf.store_id, 
        sf.quantity, 
        sf.user_id, 
        sf.total_amount
    FROM sales_facts sf
    WHERE
        NOT (sf.time_id IS DISTINCT FROM dim_time_id) AND
        NOT (sf.store_id IS DISTINCT FROM dim_store_id) AND
        NOT (sf.product_id IS DISTINCT FROM dim_product_id) AND
        NOT (sf.user_id IS DISTINCT FROM dim_user_id);

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION validate_sales_facts(
    p_product_id INT,
    p_time_id INT,
    p_store_id INT,
    p_user_id INT,
	recomp BOOLEAN DEFAULT FALSE
)
RETURNS RECORD AS $$
DECLARE
    result_count INT := 0;  -- Счётчик строк
    temp_result RECORD;     -- Для сохранения первой строки результата
BEGIN
    -- Выполняем вызов функции и обрабатываем результаты
    FOR temp_result IN
        SELECT * FROM search_sales_facts(p_product_id, p_time_id, p_store_id, p_user_id)
    LOOP
        result_count := result_count + 1; -- Увеличиваем счётчик
        -- Если это первая строка, сохраняем её
        IF result_count = 1 THEN
            RAISE NOTICE 'First result: %', temp_result;
        END IF;
        -- Если больше одной строки, выходим из цикла (оптимизация)
        IF result_count > 1 THEN
			RAISE NOTICE 'Get second result: %', temp_result;
            EXIT;
        END IF;
    END LOOP;

	IF result_count > 1 THEN 
		RAISE EXCEPTION 'More then one result';
    ELSIF (result_count = 0) THEN
		RAISE NOTICE 'No such record: %', temp_result;
		--RAISE EXCEPTION 'No realization';	
    ELSIF result_count = 1 THEN
		RAISE NOTICE 'Find record: %', temp_result;
		IF recomp = FALSE THEN
			RETURN temp_result;	
		END IF;
		RAISE NOTICE 'Rewrite record: %', temp_result;
		RAISE EXCEPTION 'No realization';
		--DROP
    END IF;

	
	CALL count_num(p_product_id, p_time_id, p_store_id, p_user_id);
	--SELECT temp_result.f1, temp_result.f2, temp_result.f3, temp_result.f4, temp_result.f5, temp_result.f6
	--INTO temp_result;
	
	--RAISE NOTICE 'INSERT RECORD: %', temp_result;
	--RAISE NOTICE 'INSERT RECORD LIKE: %', (temp_result.f1, temp_result.f2, temp_result.f3, temp_result.f4, temp_result.f5, temp_result.f6);
	--INSERT INTO sales_facts (product_id, time_id, store_id, user_id, quantity, total_amount)
	--VALUES (temp_result.f1, temp_result.f2, temp_result.f3, temp_result.f4, temp_result.f5, temp_result.f6);
	RAISE NOTICE 'DONE INSERTING: %', temp_result;
	RETURN NULL;
	
END;
$$ LANGUAGE plpgsql;


SELECT * FROM search_sales_facts(
    p_product_id => 147,
	p_time_id => 154,
    p_store_id => 2711,
	p_user_id => 7205
);


--EXPLAIN ANALYZE 
SELECT * FROM validate_sales_facts(
	p_product_id => 10032, --Electronics
    p_time_id => 628, --2022
    p_store_id => 10390, -- Краснодарский
    p_user_id => 10015 -- Male
--    p_product_id => 147,
--    p_time_id => 154,
--    p_store_id => 2711,
--    p_user_id => 7205
	--, recomp => TRUE
	) AS result(
    fact_id INT, 
    product_id INT, 
    time_id INT, 
    store_id INT, 
    quantity INT, 
    user_id INT, 
    total_amount DECIMAL
);

SELECT * FROM sales_facts AS sf
WHERE sf.product_id = 10033


SELECT * FROM dim_products as d
WHERE NOT (d.name IS DISTINCT FROM NULL)

SELECT * FROM dim_stores as d
WHERE NOT (d.name IS DISTINCT FROM NULL)

SELECT * FROM dim_time as d
WHERE NOT (d.month IS DISTINCT FROM NULL)
ORDER BY time_id

--Функция кеширования-подсчета информации по дате


CREATE OR REPLACE PROCEDURE count_num(
    p_product_id INT,
    p_time_id INT,
    p_store_id INT,
    p_user_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Выполнение вызова функции soft_search_sales_facts и подсчет суммы
    RAISE NOTICE 'INSERT RECORD';
    
    INSERT INTO sales_facts(product_id, time_id, store_id, user_id, quantity, total_amount)
    SELECT  
        p_product_id,
        p_time_id,
        p_store_id,
        p_user_id,
        SUM(sf.quantity),         
        SUM(sf.total_amount) 
    FROM soft_search_sales_facts(p_product_id, p_time_id, p_store_id, p_user_id) AS sf;
    
    -- Здесь нет необходимости в RETURN, так как процедура не возвращает данные
END;
$$;

SELECT * FROM dim_products as d
WHERE NOT (d.name IS DISTINCT FROM NULL)

SELECT * FROM dim_stores as d
WHERE NOT (d.name IS DISTINCT FROM NULL)
ORDER BY region

SELECT * FROM dim_time as d
WHERE NOT (d.month IS DISTINCT FROM NULL)
ORDER BY year

SELECT * FROM dim_users as d
WHERE NOT (d.name IS DISTINCT FROM NULL)




SELECT * FROM soft_search_sales_facts(p_product_id => 10033, p_time_id => 628, p_store_id => 10390, p_user_id => 10015) AS tb
--JOIN dim_products as dp ON dp.product_id = tb.product_id;
--JOIN dim_time as dt ON dt.time_id =tb.time_id
JOIN dim_stores as ds ON ds.store_id =tb.store_id


--==Проверка работы count_num -> soft_search
SELECT *
FROM count_num(
    p_product_id => 10033, --Electronics
    p_time_id => 628, --2022
    p_store_id => 10390, -- Краснодарский
    p_user_id => 10015 -- Male
) AS result(
    product_id INT,
    time_id INT,
    store_id INT,
    user_id INT,
	quantity INT,
    total_amount DECIMAL(10, 2)
);

SELECT SUM(quantity) FROM sales_facts as sf
JOIN dim_products as dp ON sf.product_id = dp.product_id
JOIN dim_time as dt ON sf.time_id = dt.time_id
JOIN dim_users as du ON sf.user_id = du.user_id
JOIN dim_stores as ds ON sf.store_id = ds.store_id
WHERE 
	dp.category = 'Electronics' AND
	dt.year = 2022 AND 
	du.gender = 'Male' AND
	ds.region = 'Краснодарский'




SELECT SUM(quantity) FROM sales_facts
WHERE product_id = 147

ROLLBACK;



CREATE OR REPLACE FUNCTION soft_search_sales_facts(
	    p_product_id INT,
	    p_time_id INT,
	    p_store_id INT,
	    p_user_id INT)
	RETURNS TABLE(
	    fact_id INT,
	    product_id INT,
	    time_id INT,
	    store_id INT,
	    user_id INT,
	    quantity INT,
	    total_amount DECIMAL(10, 2)
	) AS $$
	DECLARE
	    product_name VARCHAR(100);
	    product_category VARCHAR(50);
	    product_price DECIMAL(10, 2);
		--
	    time_month_code INT;
	    time_month VARCHAR(20);
	    time_year INT;
	
	    store_name VARCHAR(100);
	    store_country VARCHAR(50);
	    store_region VARCHAR(50);
	    store_city VARCHAR(50);
	    store_geo_lat DECIMAL(9, 6);
	    store_geo_lon DECIMAL(9, 6);
	
	    user_name VARCHAR(100);
	    user_age INT;
	    user_gender VARCHAR(10);
	BEGIN
	    -- Вычисляем значения для фильтрации
	    SELECT gg1.name, gg1.category, gg1.price
	    INTO product_name, product_category, product_price
	    FROM dim_products as gg1
	    WHERE gg1.product_id = p_product_id;
	
	    SELECT gg2.month_code, gg2.month, gg2.year
	    INTO time_month_code, time_month, time_year
	    FROM dim_time AS gg2
	    WHERE gg2.time_id = p_time_id;
	
	    SELECT gg3.name, gg3.country, gg3.region, gg3.city, gg3.geo_lat, gg3.geo_lon
	    INTO store_name, store_country, store_region, store_city, store_geo_lat, store_geo_lon
	    FROM dim_stores AS gg3
	    WHERE gg3.store_id = p_store_id;
	
	    SELECT gg4.name, gg4.age, gg4.gender
	    INTO user_name, user_age, user_gender
	    FROM dim_users as gg4
	    WHERE gg4.user_id = p_user_id;
	
	    -- Основной запрос
	    RETURN QUERY
	    SELECT 
	        s.fact_id,
	        s.product_id,
	        s.time_id,
	        s.store_id,
	        s.user_id,
	        s.quantity,
	        s.total_amount
	    FROM sales_facts AS s
		JOIN dim_products dp ON dp.product_id = s.product_id
	    JOIN dim_time dt ON dt.time_id = s.time_id
	    JOIN dim_stores ds ON ds.store_id = s.store_id
	    JOIN dim_users du ON du.user_id = s.user_id
	    WHERE
			(product_name IS NULL OR dp.name = product_name) AND
			(product_category IS NULL OR dp.category = product_category) AND
			(product_price IS NULL OR dp.price = product_price) AND
			
			(time_month_code IS NULL OR dt.month_code = time_month_code) AND
			(time_year IS NULL OR dt.year = time_year) AND
	
			(store_name IS NULL OR ds.name = store_name) AND
			(store_country IS NULL OR ds.country = store_country) AND
			(store_region IS NULL OR ds.region = store_region) AND
			(store_city IS NULL OR ds.city = store_city) AND
			(store_geo_lat IS NULL OR ds.geo_lat = store_geo_lat) AND
			(store_geo_lon IS NULL OR ds.geo_lon = store_geo_lon) AND
	
			(user_name IS NULL OR du.name = user_name) AND
			(user_age IS NULL OR du.age = user_age) AND
			(user_gender IS NULL OR du.gender = user_gender);
	     
END;
$$ LANGUAGE plpgsql;





SELECT * FROM soft_search_sales_facts(
					p_product_id => NULL,
					p_time_id => NULL,
					p_store_id => NULL, 
					p_user_id => NULL)



ROLLBACK;








