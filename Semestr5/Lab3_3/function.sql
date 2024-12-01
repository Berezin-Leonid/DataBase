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


SELECT * FROM get_store_revenue(1991, 01, 1991, 9, 'Россия', 'Краснодарский', 'Геленджик')



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


