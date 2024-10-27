
--SELECT pg_sleep(10);


--Моделирование грязного чтения
	-- Не в pgAdmin
	
--TRANSACTION 1
START TRANSACTION;
	SELECT pg_sleep(500); -- занимаем время вычеслениями
--смотрим сколько учеников будет на нашем занятии
	SELECT  l.index,
			l.time,
			SUM(group_volume.volume)
	FROM schedule as l
	JOIN group_schedule as gsch ON gsch.lesson_id = l.index
	JOIN 
		(
			SELECT 	g.index,
					g.name,
					COUNT(*) as volume
			FROM group_ as g
			JOIN student as s ON s.group_id = g.index
			GROUP BY g.index
			ORDER BY g.index
		) as group_volume ON group_volume.index = gsch.group_id
	WHERE l.room_id IS NULL
	GROUP BY l.index, l.time


--смотрим свободные комнаты на свободные даты
	WITH busy_room AS (
		SELECT 	r.index,
				r.name
		FROM room as r
		JOIN schedule as s ON s.room_id = r.index
		WHERE s.time = '01-10-2023 12:15:00'
	)
	SELECT 	r.name, r.index
	FROM room as r
	WHERE r.index NOT IN (SELECT index FROM busy_room)
		AND r.volume >= 100

--Резервируем комнату на определенное количество человек
	UPDATE schedule s
	SET room_id = 10
	WHERE s.subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I')
		AND s.time = '01-10-2023 12:15:00'
		AND s.hours_type_id = (SELECT index FROM hours_type WHERE name ='Семинары')

COMMIT;

--TRANSACTION 2
START TRANSACTION;

	INSERT INTO group_schedule (group_id, lesson_id)
	VALUES
	    (
			(SELECT index FROM group_ WHERE name = '107'), 
			(SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
				AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') AND time = '01-10-2023 12:15:00')
		)

--Добавляем еще кучу групп 
-- ...

SELECT pg_sleep(+100500);
ROLLBACK;



















--Моделирование неповторяющегося чтения


--TRANSACTION 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
	SELECT pg_sleep(500); -- занимаем время вычеслениями


	INSERT INTO schedule (subject_id, time, room_id, hours_type_id)
	VALUES
	    (
			(SELECT index FROM subject WHERE name = 'Математический анализ I'), 
			TO_TIMESTAMP('01-10-2023 18:15:00', 'DD-MM-YYYY HH24:MI:SS'),
			NULL, --room
			(SELECT index FROM hours_type WHERE name ='Семинары')
		)

		--Назначаем группам пару
	INSERT INTO group_schedule (group_id, lesson_id)
	VALUES
	    (
			(SELECT index FROM group_ WHERE name = '107'), 
			(SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
				AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') AND time = '01-10-2023 18:15:00')
		)


	

--смотрим сколько учеников будет на нашем занятии
	SELECT  l.index,
			l.time,
			SUM(group_volume.volume)
	FROM schedule as l
	JOIN group_schedule as gsch ON gsch.lesson_id = l.index
	JOIN 
		(
			SELECT 	g.index,
					g.name,
					COUNT(*) as volume
			FROM group_ as g
			JOIN student as s ON s.group_id = g.index
			GROUP BY g.index
			ORDER BY g.index
		) as group_volume ON group_volume.index = gsch.group_id
	WHERE l.room_id IS NULL
	GROUP BY l.index, l.time


--смотрим свободные комнаты на свободные даты
	WITH busy_room AS (
		SELECT 	r.index,
				r.name
		FROM room as r
		JOIN schedule as s ON s.room_id = r.index
		WHERE s.time = '01-10-2023 18:15:00'
	)
	SELECT 	r.name, r.index, r.volume
	FROM room as r
	WHERE r.index NOT IN (SELECT index FROM busy_room)
		AND r.volume >= 10

--Резервируем комнату на определенное количество человек
	UPDATE schedule s
	SET room_id = 1
	WHERE s.subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I')
		AND s.time = '01-10-2023 18:15:00'
		AND s.hours_type_id = (SELECT index FROM hours_type WHERE name ='Семинары')

COMMIT; ROLLBACK;





