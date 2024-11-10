SELECT * FROM discipline

--Распределение предметов
SELECT d.name, s.name, s.index
FROM discipline as d
JOIN subject as s ON s.disc_id = d.index
WHERE d.name = 'Математический анализ'

--Учебные планы
SELECT * FROM study_plan

--Типы часов
SELECT * FROM hours_type

SELECT * FROM schedule

--Распределение студентов по группам
SELECT g.name, s.full_name, s.index
FROM group_ as g
JOIN student as s ON s.group_id = g.index



--Распределение преподавателей по кафедрам
SELECT d.name, t.full_name, t.index
FROM department as d
JOIN teacher_department as dt ON dt.department_id = d.index
JOIN teacher as t ON t.index = dt.teacher_id
--WHERE 
--AND



--Распределение часов в предметах
SELECT sp.name as study_plan, sem.name as semestr, sub.name as subject, h.name as hour_type, disth.volume as volume
FROM subject as sub
JOIN distribution as dist ON dist.subject_id = sub.index
JOIN distribution_hours as disth ON disth.distr_id = dist.index
JOIN hours_type as h ON h.index = disth.hours_type_id
JOIN discipline as disc ON disc.index = sub.disc_id
JOIN semestr as sem ON sem.index = dist.semestr_id
JOIN study_plan as sp ON dist.plan_id = sp.index
WHERE  sp.name = 'ВМК ПМИ'
ORDER BY sem.name
--AND sem.name  = '1 семестр'
--AND sp.name = 'ВМК ПМИ'
--AND disc.name = 'Математический анализ'
--AND ...

--Расписание для группы
SELECT g.name as group, TO_CHAR(sch.time, 'DD/MM/YYYY HH24:MI:SS') as time, sub.name as subject, r.name as room
FROM group_ as g
JOIN group_schedule as gsch ON g.index= gsch.group_id
JOIN schedule as sch ON sch.index = gsch.lesson_id
JOIN subject as sub ON sub.index = sch.subject_id
JOIN room as r ON r.index = sch.room_id
WHERE g.name = '107'


--Расписание для преподавателей
SELECT t.full_name as teacher, TO_CHAR(sch.time, 'DD/MM/YYYY HH24:MI:SS') as time, sub.name as subject, r.name as room
FROM teacher as t
JOIN teacher_schedule as ts ON t.index= ts.teacher_id
JOIN schedule as sch ON sch.index = ts.lesson_id
JOIN subject as sub ON sub.index = sch.subject_id
JOIN room as r ON r.index = sch.room_id
WHERE t.full_name = 'Иванов Иван Иванович'


SELECT d.name, t.full_name, t.index
FROM department as d
JOIN teacher_department as dt ON dt.department_id = d.index
JOIN teacher as t ON t.index = dt.teacher_id








--Реальное число часов в предмете
SELECT g.name as group_name, sub.name as subject, Count(*) * 2 as real_academic_hourse
FROM group_ as g
JOIN group_schedule as gsch ON g.index= gsch.group_id
JOIN schedule as sch ON sch.index = gsch.lesson_id
JOIN subject as sub ON sub.index = sch.subject_id
JOIN room as r ON r.index = sch.room_id
--WHERE g.name = '307'
GROUP BY (group_name, subject)
ORDER BY group_name

---Несоотвествие часов

	--Распределение часов в учебном плане
	(
	SELECT  sp.name as study_plan, sp.index as plan_id,
			sem.name as semestr, sem.index as sem_id, 
			sub.name as subject, sub.index as subject_id, 
			h.name as hour_type, h.index as hour_index,
			(disth.volume) as volume
	FROM subject as sub
	JOIN distribution as dist ON dist.subject_id = sub.index
	JOIN distribution_hours as disth ON disth.distr_id = dist.index
	JOIN hours_type as h ON h.index = disth.hours_type_id
	JOIN discipline as disc ON disc.index = sub.disc_id
	JOIN semestr as sem ON sem.index = dist.semestr_id
	JOIN study_plan as sp ON dist.plan_id = sp.index
	WHERE  sp.name = 'ВМК ПМИ'
		AND h.name != 'Самостоятельная работа студентов'
	--GROUP BY sp.name, sem.name, subject
	ORDER BY sem.name
	)


	--Распределение часов в расписании
	WITH ranked_students AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (PARTITION BY s.group_id ORDER BY s.index) AS rn
    FROM
        student AS s
	)
	SELECT  s.plan_id,
			g.name AS group_name, g.index AS group_id,
			sub.name AS subject, sub.index AS subject_id,
			COUNT(*) * 2 AS real_academic_hours, sch.hours_type_id
	FROM group_ AS g
	JOIN ranked_students AS s ON s.group_id = g.index AND s.rn = 1
	JOIN group_schedule AS gsch ON g.index = gsch.group_id
	JOIN schedule AS sch ON sch.index = gsch.lesson_id
	JOIN subject AS sub ON sub.index = sch.subject_id
	JOIN room AS r ON r.index = sch.room_id
	-- WHERE g.name = '307'
	GROUP BY s.plan_id, g.name,g.index, sch.hours_type_id, sub.name, sub.index
	ORDER BY group_name;



	--Проверка соответствия часов в расписании и в учебном плане
	WITH ranked_students AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (PARTITION BY s.group_id ORDER BY s.index) AS rn
    FROM
        student AS s
	)
	SELECT  s.plan_id,
			g.name AS group_name, g.index AS group_id,
			sub.name AS subject, sub.index AS subject_id,
			sch.hours_type_id,
			COUNT(*) * 2 AS real_academic_hours,  
			disth.volume as plan_academic_hours
			
	FROM group_ AS g
	JOIN ranked_students AS s ON s.group_id = g.index AND s.rn = 1
	JOIN group_schedule AS gsch ON g.index = gsch.group_id
	JOIN schedule AS sch ON sch.index = gsch.lesson_id
	JOIN subject AS sub ON sub.index = sch.subject_id
	JOIN room AS r ON r.index = sch.room_id
	JOIN distribution as d ON d.plan_id = s.plan_id
			AND d.subject_id = sub.index
			AND d.semestr_id = g.semestr_id
	JOIN distribution_hours as disth ON d.index = disth.distr_id
			AND disth.hours_type_id = sch.hours_type_id
		--Наложение условий на
	-- WHERE g.name = '307'
	GROUP BY s.plan_id, g.name,g.index, sch.hours_type_id, sub.name, sub.index, disth.volume
	ORDER BY group_name;





--Процесс составления расписания (Бизнес процесс) 
--start


--searching free time for groups
SELECT  g.name as group,
		TO_CHAR(sch.time, 'DD/MM/YYYY HH24:MI:SS')
FROM group_schedule as gs
JOIN group_ as g ON gs.group_id = g.index
JOIN schedule AS sch ON gs.lesson_id = sch.index
WHERE g.name = '107' AND TO_CHAR(sch.time, 'DD/MM/YYYY') = '01/10/2023'
ORDER BY g.name


INSERT INTO schedule (subject_id, time, room_id, hours_type_id)
VALUES
    (
		(SELECT index FROM subject WHERE name = 'Математический анализ I'), 
		TO_TIMESTAMP('01-10-2023 12:15:00', 'DD-MM-YYYY HH24:MI:SS'),
		NULL, --room
		(SELECT index FROM hours_type WHERE name ='Семинары')
	)


	--Назначаем группам пару
INSERT INTO group_schedule (group_id, lesson_id)
VALUES
    (
		(SELECT index FROM group_ WHERE name = '107'), 
		(SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
			AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') AND time = '01-10-2023 12:15:00')
	)

--...

	--Назначаем преподавателям пару пару
INSERT INTO teacher_schedule (teacher_id, lesson_id)
VALUES
    (
		(SELECT index FROM teacher WHERE full_name = 'Иванов Иван Иванович'),
		(SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
			AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') AND time = '01-10-2023 12:15:00' )
	)
	
--...

--searching auditory for lesson

--Количество учеников на занятии
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

SELECT * from schedule

--Свободные комнаты для !одного предмета
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


UPDATE schedule s
SET room_id = 10
WHERE s.subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I')
	AND s.time = '01-10-2023 12:15:00'
	AND s.hours_type_id = (SELECT index FROM hours_type WHERE name ='Семинары')




--Группы у которых недостаток часов в предметах
WITH ranked_students AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (PARTITION BY s.group_id ORDER BY s.index) AS rn
    FROM
        student AS s
),
group_data AS (
    SELECT
        s.plan_id,
        g.name AS group_name,
        g.index AS group_id,
        sub.name AS subject,
        sub.index AS subject_id,
        sch.hours_type_id,
        COUNT(*) * 2 AS real_academic_hours,
        disth.volume
    FROM
        group_ AS g
    JOIN
        ranked_students AS s ON s.group_id = g.index AND s.rn = 1
    JOIN
        group_schedule AS gsch ON g.index = gsch.group_id
    JOIN
        schedule AS sch ON sch.index = gsch.lesson_id
    JOIN
        subject AS sub ON sub.index = sch.subject_id
    JOIN
        room AS r ON r.index = sch.room_id
    JOIN
        distribution as d ON d.plan_id = s.plan_id
            AND d.subject_id = sub.index
            AND d.semestr_id = g.semestr_id
    JOIN
        distribution_hours as disth ON d.index = disth.distr_id
            AND disth.hours_type_id = sch.hours_type_id
    GROUP BY
        s.plan_id, g.name, g.index, sch.hours_type_id, sub.name, sub.index, disth.volume
)
SELECT
    plan_id,
    group_name,
    group_id,
    subject,
    subject_id,
    hours_type_id,
    real_academic_hours,
    volume,
    CASE
        WHEN real_academic_hours = volume THEN TRUE
        ELSE FALSE
    END AS comparison_result
FROM
    group_data
WHERE real_academic_hours != volume
ORDER BY
    group_name

--Группы у которых хватает часов в предметах
WITH ranked_students AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (PARTITION BY s.group_id ORDER BY s.index) AS rn
    FROM
        student AS s
),
group_data AS (
    SELECT
        s.plan_id,
        g.name AS group_name,
        g.index AS group_id,
        sub.name AS subject,
        sub.index AS subject_id,
        sch.hours_type_id,
        COUNT(*) * 2 AS real_academic_hours,
        disth.volume
    FROM
        group_ AS g
    JOIN
        ranked_students AS s ON s.group_id = g.index AND s.rn = 1
    JOIN
        group_schedule AS gsch ON g.index = gsch.group_id
    JOIN
        schedule AS sch ON sch.index = gsch.lesson_id
    JOIN
        subject AS sub ON sub.index = sch.subject_id
    JOIN
        room AS r ON r.index = sch.room_id
    JOIN
        distribution as d ON d.plan_id = s.plan_id
            AND d.subject_id = sub.index
            AND d.semestr_id = g.semestr_id
    JOIN
        distribution_hours as disth ON d.index = disth.distr_id
            AND disth.hours_type_id = sch.hours_type_id
    GROUP BY
        s.plan_id, g.name, g.index, sch.hours_type_id, sub.name, sub.index, disth.volume
)
SELECT
    plan_id,
    group_name,
    group_id,
    subject,
    subject_id,
    hours_type_id,
    real_academic_hours,
    volume,
    CASE
        WHEN real_academic_hours = volume THEN TRUE
        ELSE FALSE
    END AS comparison_result
FROM
    group_data
WHERE real_academic_hours >= volume
ORDER BY
    group_name


--Процесс составления расписания (Бизнес процесс)) 
--end


SELECT * from schedule



--Расписание для группы
SELECT TO_CHAR(sch.time, 'DD/MM/YYYY HH24:MI:SS') as time, sub.name as subject, r.name as room
FROM group_ as g
JOIN group_schedule as gsch ON g.index= gsch.group_id
JOIN schedule as sch ON sch.index = gsch.lesson_id
JOIN subject as sub ON sub.index = sch.subject_id
JOIN room as r ON r.index = sch.room_id
WHERE g.name = '107'



--Расписание для групп
SELECT g.name, s.name, TO_CHAR(sc.time, 'DD/MM/YYYY HH24:MI:SS')
FROM group_ as g
JOIN group_schedule as gs ON gs.group_id = g.index
JOIN schedule as sc ON gs.lesson_id = sc.index
JOIN subject as s ON s.index = sc.subject_id
--WHERE sc.time::DATE = '01-10-2023'
--AND sc.time::TIME > '14:00:00'
--AND g.name='407'



--Количесвто человек в группах
SELECT g.name as group_number,
		COUNT(*)
FROM group_ as g
JOIN student as s ON s.group_id = g.index
GROUP BY group_number
ORDER BY group_number;

--Студенты
SELECT * FROM student
ORDER BY index


---------------------Корректировка-------------------

SELECT disth.index as id, sp.name as study_plan, sem.name as semestr, sub.name as subject, h.name as hour_type, disth.volume as volume
FROM subject as sub
JOIN distribution as dist ON dist.subject_id = sub.index
JOIN distribution_hours as disth ON disth.distr_id = dist.index
JOIN hours_type as h ON h.index = disth.hours_type_id
JOIN discipline as disc ON disc.index = sub.disc_id
JOIN semestr as sem ON sem.index = dist.semestr_id
JOIN study_plan as sp ON dist.plan_id = sp.index
WHERE  sp.name = 'ВМК ПМИ'
ORDER BY id







--Корректировка объема часов
WITH updated_dh AS (
	SELECT disth.index as idx, sp.name as study_plan, sem.name as semestr, sub.name as subject, h.name as hour_type, disth.volume as volume
	FROM subject as sub
	JOIN distribution as dist ON dist.subject_id = sub.index
	JOIN distribution_hours as disth ON disth.distr_id = dist.index
	JOIN hours_type as h ON h.index = disth.hours_type_id
	JOIN discipline as disc ON disc.index = sub.disc_id
	JOIN semestr as sem ON sem.index = dist.semestr_id
	JOIN study_plan as sp ON dist.plan_id = sp.index
	WHERE  sp.name = 'ВМК ПМИ'
		AND sem.name = '1 семестр'
		AND sub.name = 'Математический анализ I'
		AND h.name = 'Самостоятельная работа студентов'
)
UPDATE distribution_hours dh
SET volume = dh.volume - 7
WHERE dh.index IN (SELECT idx FROM updated_dh);

--Корректировка имени/информации о студенте
WITH updated_students AS (
    SELECT s.index
    FROM student AS s
    JOIN group_ AS g ON s.group_id = g.index
    WHERE s.full_name = 'Иванов Иван Иванович'
	AND g.name = '107'
)
UPDATE student
SET full_name = 'Ivanov Ivan Ivanovich'
WHERE index IN (SELECT index FROM updated_students);

--Изменение учебного плана у определенного круга студентов
WITH group_names AS (
    SELECT g.name
    FROM group_ AS g
),
updated_students AS (
    SELECT s.index
    FROM student AS s
    JOIN group_ AS g ON s.group_id = g.index
    WHERE s.full_name = 'Ivanov Ivan Ivanovich'
      AND g.name IN (SELECT name FROM group_names)
),
plans AS (
    SELECT * FROM study_plan
)
UPDATE student
SET --full_name = 'Иванов Иван Иванович',
    plan_id = plans.index
FROM updated_students us
JOIN plans ON plans.name = 'ВМК ПМИ'
WHERE student.index = us.index;


--При прохождении курсовой программы информация меняется следующим образом
--В расписании зашиты id групп поэтому необходимо перемещать студентов из одной группы в другую
--4XX -> выпускаются те информация удаляется \ убираются либо в магистерскую группы с соотвественным учебным планом
--3XX -> 4XX
--2XX -> 3XX
--1XX -> 2XX
--INSERT 1XX

--Все действия происходят с таблицей student

--Распределение студентов по группам
SELECT g.name, s.full_name, s.index
FROM group_ as g
JOIN student as s ON s.group_id = g.index
WHERE g.name LIKE '4%'

--Удаляем студентов 4XX
WITH groups_to_delete AS (
    SELECT g.index as idx
    FROM group_ AS g
    WHERE g.name LIKE '4%'
)
DELETE FROM student s
WHERE s.group_id IN (SELECT idx FROM groups_to_delete);

--Распределение студентов по группам
SELECT g.name, s.full_name, s.index
FROM group_ as g
JOIN student as s ON s.group_id = g.index
WHERE g.name LIKE '4%'


--3XX -> 4XX
WITH groups_to_move AS (
	SELECT g.index as idx
	FROM group_ as g
	WHERE g.name LIKE '307'
)
UPDATE student s
SET group_id = g.index
FROM group_ as g
WHERE s.group_id in (SELECT idx FROM groups_to_move)
AND g.name = '407'

--2XX -> 3XX
WITH groups_to_move AS (
	SELECT g.index as idx
	FROM group_ as g
	WHERE g.name LIKE '207'
)
UPDATE student s
SET group_id = g.index
FROM group_ as g
WHERE s.group_id in (SELECT idx FROM groups_to_move)
AND g.name = '307'

--1XX -> 2XX
WITH groups_to_move AS (
	SELECT g.index as idx
	FROM group_ as g
	WHERE g.name LIKE '107'
)
UPDATE student s
SET group_id = g.index
FROM group_ as g
WHERE s.group_id in (SELECT idx FROM groups_to_move)
AND g.name = '207'

--INSERT 1XX
