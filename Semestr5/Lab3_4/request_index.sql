SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_seqscan = ON;


--Запрос по дате
EXPLAIN
--ANALYZE
SELECT 
    t.month, 
    t.year,
    SUM(s.total_amount) AS total_revenue,
    SUM(s.quantity) AS total_sales
FROM 
    sales_facts s
JOIN 
    dim_time t ON s.time_id = t.time_id
JOIN dim_stores as ds ON s.store_id = ds.store_id
WHERE t.year = 2024 AND
		ds.country = 'Россия' 
		--AND ds.country = 'Краснодарский'	
GROUP BY 
    t.month, t.year
ORDER BY 
    t.year, t.month;



--========



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




	

SET enable_indexscan = ON;
SET enable_bitmapscan = ON;
SET enable_seqscan = ON;
