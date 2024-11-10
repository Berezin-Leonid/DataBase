---------------- Тригеры ---------------





-- Проверка корректости времени в интервале
CREATE OR REPLACE FUNCTION check_lesson_time()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем, что время урока в пределах от 8:00 до 20:00
    IF EXTRACT(HOUR FROM NEW.time) < 8 OR EXTRACT(HOUR FROM NEW.time) >= 20 THEN
        RAISE EXCEPTION 'Lesson time must be between 08:00 and 20:00';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER before_schedule_insert_update
BEFORE INSERT OR UPDATE ON schedule
FOR EACH ROW
EXECUTE FUNCTION check_lesson_time();

-- Проверка работы тригера
INSERT INTO schedule (subject_id, time, room_id, hours_type_id)
VALUES
    (
		(SELECT index FROM subject WHERE name = 'Математический анализ I'), 
		TO_TIMESTAMP('01-10-2023 7:15:00', 'DD-MM-YYYY HH24:MI:SS'),
		NULL, --room
		(SELECT index FROM hours_type WHERE name ='Семинары')
	)



-- Триггер на проверку наложения пар у групп
CREATE OR REPLACE FUNCTION check_conflicting_lessons_group()
RETURNS TRIGGER AS $$
DECLARE
    conflicting_lesson RECORD;
    new_time TIMESTAMP;
BEGIN
    --Время новой пары
    SELECT time INTO new_time
    FROM schedule
    WHERE index = NEW.lesson_id;

    -- Найти конфликтующее занятие за 1 час 45 минут до и после новой пары
    SELECT gs.group_id, s.time, gs.lesson_id INTO conflicting_lesson
    FROM group_schedule gs
    JOIN schedule s ON gs.lesson_id = s.index
    WHERE gs.group_id = NEW.group_id
      AND s.time BETWEEN new_time - INTERVAL '1 hour 45 minutes'
                    AND new_time + INTERVAL '1 hour 45 minutes'
    LIMIT 1;

    IF FOUND THEN
	RAISE EXCEPTION USING MESSAGE = 
	    concat(
	        'Наложение пар у групп:', chr(10),
	        'Попытка вставить:', chr(10),
	        'Group ID: ', NEW.group_id, 
	        ', Lesson ID: ', NEW.lesson_id, 
	        ', Time: ', TO_CHAR(new_time, 'DD/MM/YYYY HH24:MI:SS'), chr(10),
	        'Наложение с существующей парой:', chr(10),
	        'Group ID: ', conflicting_lesson.group_id, 
	        ', Lesson ID: ', conflicting_lesson.lesson_id, 
	        ', Time: ', TO_CHAR(conflicting_lesson.time, 'DD/MM/YYYY HH24:MI:SS')
	    );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--Назначаем триггер
DROP TRIGGER IF EXISTS check_conflicting_lessons_trigger ON group_schedule;
CREATE TRIGGER check_conflicting_lessons_trigger
BEFORE INSERT OR UPDATE ON group_schedule
FOR EACH ROW
EXECUTE FUNCTION check_conflicting_lessons_group();





--Расписание для группы
SELECT g.name as group, TO_CHAR(sch.time, 'DD/MM/YYYY HH24:MI:SS') as time, sub.name as subject, r.name as room
FROM group_ as g
JOIN group_schedule as gsch ON g.index= gsch.group_id
JOIN schedule as sch ON sch.index = gsch.lesson_id
JOIN subject as sub ON sub.index = sch.subject_id
JOIN room as r ON r.index = sch.room_id
WHERE g.name = '207'


--Вставляем пару в расписание
INSERT INTO schedule (subject_id, time, room_id, hours_type_id)
VALUES
    (
		(SELECT index FROM subject WHERE name = 'Математический анализ I'), 
		TO_TIMESTAMP('10/01/2023 11:45:00', 'DD-MM-YYYY HH24:MI:SS'),
		NULL, --room
		(SELECT index FROM hours_type WHERE name ='Семинары')
	)


--Проверяем триггер
INSERT INTO group_schedule (group_id, lesson_id)
VALUES
	(
		(SELECT index FROM group_ WHERE name = '207'), 
		(SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
			AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') 
			AND TO_CHAR(time, 'DD/MM/YYYY HH24:MI:SS') = '10/01/2023 11:45:00')
	)




-- Триггер на проверку наложения пар у преподавателей
CREATE OR REPLACE FUNCTION check_conflicting_lessons_teacher()
RETURNS TRIGGER AS $$
DECLARE
    conflicting_lesson RECORD;
    new_time TIMESTAMP;
BEGIN
    --Время новой пары
    SELECT time INTO new_time
    FROM schedule
    WHERE index = NEW.lesson_id;

    -- Найти конфликтующее занятие за 1 час 45 минут до и после новой пары
    SELECT ts.teacher_id, s.time, ts.lesson_id INTO conflicting_lesson
    FROM teacher_schedule ts
    JOIN schedule s ON ts.lesson_id = s.index
    WHERE ts.teacher_id = NEW.teacher_id
      AND s.time BETWEEN new_time - INTERVAL '1 hour 45 minutes'
                    AND new_time + INTERVAL '1 hour 45 minutes'
    LIMIT 1;

    IF FOUND THEN
	RAISE EXCEPTION USING MESSAGE = 
	    concat(
	        'Наложение пар у преподавателей:', chr(10),
	        'Попытка вставить:', chr(10),
	        'Teacher ID: ', NEW.teacher_id, 
	        ', Lesson ID: ', NEW.lesson_id, 
	        ', Time: ', new_time, chr(10),
	        'Наложение с существующей парой:', chr(10),
	        'Teacher ID: ', conflicting_lesson.teacher_id, 
	        ', Lesson ID: ', conflicting_lesson.lesson_id, 
	        ', Time: ', conflicting_lesson.time
	    );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



DROP TRIGGER IF EXISTS check_conflicting_lessons_trigger_teacher ON teacher_schedule;
CREATE TRIGGER check_conflicting_lessons_trigger_teacher
BEFORE INSERT OR UPDATE ON teacher_schedule
FOR EACH ROW
EXECUTE FUNCTION check_conflicting_lessons_teacher();


--Расписание для преподавателей
SELECT t.full_name as teacher, TO_CHAR(sch.time, 'DD/MM/YYYY HH24:MI:SS') as time, sub.name as subject, r.name as room
FROM teacher as t
JOIN teacher_schedule as ts ON t.index= ts.teacher_id
JOIN schedule as sch ON sch.index = ts.lesson_id
JOIN subject as sub ON sub.index = sch.subject_id
JOIN room as r ON r.index = sch.room_id
WHERE t.full_name = 'Иванов Иван Иванович'


--Добавим пару из предыдущего запроса
INSERT INTO teacher_schedule (teacher_id, lesson_id)
VALUES
	(
		(SELECT index FROM teacher WHERE full_name = 'Иванов Иван Иванович'), 
		7
	)



--Проверяем триггер
INSERT INTO teacher_schedule (teacher_id, lesson_id)
VALUES
	(
		(SELECT index FROM teacher WHERE full_name = 'Иванов Иван Иванович'), 
		(SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
			AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') 
			AND TO_CHAR(time, 'DD/MM/YYYY HH24:MI:SS') = '10/01/2023 11:45:00')
	)



Group ID: 3, Lesson ID: 7, Time: 2023-01-10 11:00:00