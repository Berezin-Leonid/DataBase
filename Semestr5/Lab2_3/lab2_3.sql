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
ORDER BY group_number

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
--4XX -> выпускаются те информация удаляется \ убираются либо в магистерскую группы с соотвественным учебным планом либо 
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
