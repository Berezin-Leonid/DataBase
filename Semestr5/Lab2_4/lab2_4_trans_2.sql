--Моделирование неповторяющегося чтения

--TRANSACTION 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
	INSERT INTO group_schedule (group_id, lesson_id)
	VALUES
	    (
			(SELECT index FROM group_ WHERE name = '207'), 
			(SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
				AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') AND time = '01-10-2023 18:15:00')
		)

--Добавляем еще кучу групп 
-- ...

SELECT pg_sleep(+100500);
COMMIT; ROLLBACK;