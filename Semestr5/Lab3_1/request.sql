--Общее количество продаж и выручка по месяцам
SELECT 
    t.month, 
    t.year,
    SUM(s.total_amount) AS total_revenue,
    SUM(s.quantity) AS total_sales
FROM 
    sales_facts s
JOIN 
    dim_time t ON s.time_id = t.time_id
GROUP BY 
    t.month, t.year
ORDER BY 
    t.year, t.month;


	
--Топ самых популярных товаров по количеству продаж
SELECT 
    p.name AS product_name, 
    SUM(s.quantity) AS total_sales
FROM 
    sales_facts s
JOIN 
    dim_products p ON s.product_id = p.product_id
GROUP BY 
    p.name
ORDER BY 
    total_sales DESC
LIMIT 10;


--Общее количество продаж и выручка по регионам
SELECT 
    st.region, 
    SUM(s.total_amount) AS total_revenue,
    SUM(s.quantity) AS total_sales
FROM 
    sales_facts s
JOIN 
    dim_stores st ON s.store_id = st.store_id
GROUP BY 
    st.region
ORDER BY 
    total_revenue DESC;

--Средний чек по пользователю
SELECT 
    u.name AS user_name,
    AVG(s.total_amount) AS avg_check
FROM 
    sales_facts s
JOIN 
    dim_users u ON s.user_id = u.user_id
GROUP BY 
    u.name
ORDER BY 
    avg_check DESC;

--Продажи по возрастной группе
SELECT 
    CASE 
        WHEN u.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN u.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN u.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN u.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN u.age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+' 
    END AS age_group,
    SUM(s.total_amount) AS total_revenue,
    SUM(s.quantity) AS total_sales
FROM 
    sales_facts s
JOIN 
    dim_users u ON s.user_id = u.user_id
GROUP BY 
    age_group
ORDER BY 
    total_revenue DESC;


--Топ самых популярных категорий товаров
SELECT 
    p.category AS product_category, 
    SUM(s.quantity) AS total_sales
FROM 
    sales_facts s
JOIN 
    dim_products p ON s.product_id = p.product_id
GROUP BY 
    p.category
ORDER BY 
    total_sales DESC

UPDATE sales_facts sf
SET total_amount = sf.quantity * p.price
FROM dim_products p
WHERE sf.product_id = p.product_id;