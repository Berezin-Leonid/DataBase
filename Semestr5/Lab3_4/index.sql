--Создание индексов на таблицу фактов
CREATE INDEX idx_sales_facts_product_id ON sales_facts(product_id);
CREATE INDEX idx_sales_facts_time_id ON sales_facts(time_id);
CREATE INDEX idx_sales_facts_store_id ON sales_facts(store_id);
CREATE INDEX idx_sales_facts_user_id ON sales_facts(user_id);

--Таблица магазинов
CREATE INDEX idx_dim_stores_full
ON dim_stores (country, region, city);

CREATE INDEX idx_dim_stores_name_fulltext
ON dim_stores USING GIN (to_tsvector('english', name));

--Таблица продуктов
CREATE INDEX idx_dim_products_category_name_order
ON dim_products (category, name);


SELECT 
    p.category, 
    SUM(s.total_amount) AS total_sales, 
    COUNT(s.fact_id) AS total_transactions
FROM 
    sales_facts s
JOIN 
    dim_products p ON s.product_id = p.product_id
GROUP BY 
    p.category
ORDER BY 
    total_sales DESC;




SELECT * FROM dim_stores
WHERE to_tsvector('english', name) @@ to_tsquery('english', 'Carr');

