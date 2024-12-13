SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_seqscan = ON;

SET enable_indexscan = ON;
SET enable_bitmapscan = ON;
SET enable_seqscan = ON;


--======== Бизнес процесс


EXPLAIN
ANALYZE
SELECT --COUNT(*)
	ds.name as store_name,
	SUM(sf.total_amount) as total_amount
FROM sales_facts as sf
JOIN dim_stores as ds ON sf.store_id = ds.store_id
JOIN dim_time as dt ON sf.time_id = dt.time_id
JOIN dim_products as dp ON dp.product_id = sf.product_id
WHERE 
		--dim_stores
		ds.country = 'Россия' AND 
		ds.region = 'Московская' AND 
		--city = 'Сочи' AND
		--dim_time
		dt.year = 2000 AND
		--dim_product
		dp.category = 'Electronics'
GROUP BY store_name





SELECT region FROM dim_stores
WHERE region =  'Московская'
GROUP BY region

SELECT 
    COUNT(CASE WHEN region = 'Московская' THEN 1 END)::DECIMAL / COUNT(*) * 100 AS store_percentage
FROM 
    dim_stores;



SELECT * FROM sales_facts
LIMIT 1;



--=========




EXPLAIN
--ANALYZE
SELECT * FROM sales_facts as s
WHERE store_id = 5 
	AND time_id = 141

--Пример сортировки
EXPLAIN
SELECT * FROM dim_stores as ds
ORDER BY country, region, city


EXPLAIN
SELECT * FROM sales_facts as sf
WHERE sf.product_id = 4
ORDER BY time_id



--============= fast delete
--Создаем секционированную таблицу sales_facts
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
) PARTITION BY RANGE (time_id);


--Функция для создания секций на основе данных из dim_time
CREATE OR REPLACE FUNCTION create_sales_facts_partitions()
RETURNS VOID AS $$
DECLARE
    rec RECORD;
    min_time_id INT;
    max_time_id INT;
BEGIN
    -- Проходим по всем уникальным годам в таблице dim_time
    FOR rec IN
        SELECT DISTINCT year FROM dim_time ORDER BY year
    LOOP
        -- Находим минимальное и максимальное значение time_id для текущего года
        SELECT MIN(time_id), MAX(time_id)
        INTO min_time_id, max_time_id
        FROM dim_time
        WHERE year = rec.year;

        -- Генерируем SQL для создания секции для текущего года
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS sales_facts_%s PARTITION OF sales_facts
            FOR VALUES FROM (%s) TO (%s);',
            rec.year, min_time_id, max_time_id + 1
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;


--Создаем руками
CREATE TABLE sales_facts_2025 PARTITION OF sales_facts
FOR VALUES FROM (SELECT MIN(time_id) FROM dim_time WHERE year = 2025)
           TO (SELECT MAX(time_id) + 1 FROM dim_time WHERE year = 2025);


--Удаляем устаревшие данные
DROP TABLE IF EXISTS sales_facts_2023;
	


SELECT * FROM dim_stores
LIMIT 1
