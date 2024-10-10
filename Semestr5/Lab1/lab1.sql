--Задание 1

SELECT DISTINCT
		t2.passenger_name,
		b2.ticket_no,
		SUM(ST_DistanceSphere(
			GEOMETRY(a1.coordinates),
			GEOMETRY(a2.coordinates)
		)) AS distance
FROM boarding_passes as b2
JOIN flights as f2 ON b2.flight_id=f2.flight_id
JOIN tickets as t2 ON b2.ticket_no = t2.ticket_no
JOIN airports as a1 ON a1.airport_code=f2.departure_airport
JOIN airports as a2 ON a2.airport_code=f2.arrival_airport
GROUP BY t2.passenger_name, b2.ticket_no
ORDER BY distance DESC
==========================================================

SELECT t.airport_name,
		COUNT(tf.departure_airport) as cnt
FROM airports as t
JOIN flights as tf ON tf.departure_airport=t.airport_code

GROUP BY t.airport_name
ORDER BY cnt DESC



=============================

SELECT 	DISTINCT
		f.departure_airport as depart_airpt,
		a1.city as city_departure,
		f.arrival_airport as arr_airpt,
		a2.city as city_arrival,
    
		ST_DistanceSphere(
 			GEOMETRY(a1.coordinates),
			GEOMETRY(a2.coordinates)
    	) AS distance
FROM flights as f
INNER JOIN 
		airports as a1 ON a1.airport_code=f.departure_airport
INNER JOIN 
		airports as a2 ON a2.airport_code=f.arrival_airport
ORDER BY distance

===========================================================
SELECT  ST_X(GEOMETRY(a.coordinates)),
		ST_Y(GEOMETRY(a.coordinates)),
		a.coordinates
from Airports as a


SELECT
    column_name,
    data_type
FROM
    information_schema.columns
WHERE
    table_name = 'flights';














SELECT flight_no from flights
 

--Задание 2

SELECT
	f3.flight_no,
	AVG(tab.procent) as average_procent
FROM flights as f3
JOIN(
	SELECT DISTINCT
		t.flight_id,
		t1.num as passanger_board,
		t2.num as capacity_of_plain,
		ROUND((CAST(t1.num AS DECIMAL) / CAST(t2.num AS DECIMAL))*100,5) as procent
	FROM ticket_flights as t
	JOIN 
		(SELECT
			flight_id,
			COUNT(*) as num
		FROM boarding_passes	
		GROUP BY flight_id
		ORDER BY flight_id) as t1 ON t1.flight_id = t.flight_id
	JOIN 
		(SELECT
			flight_id,
			COUNT(*) as num
		FROM ticket_flights
		GROUP BY flight_id
		ORDER BY flight_id) as t2 ON t2.flight_id = t.flight_id
	ORDER BY procent
	) as tab ON f3.flight_id=tab.flight_id
GROUP BY f3.flight_no
ORDER BY average_procent
--------------

SELECT 
	f0.flight_no,
	AVG(c.capacity_ratio)
FROM flights as f0

JOIN 
	(SELECT
		flight_no,
		COUNT(*)
	FROM boarding_passes	
	GROUP BY flight_no
	ORDER BY flight_id) as t1 ON t1.flight_id = t.flight_id



















