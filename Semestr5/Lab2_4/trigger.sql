


--Тригеры

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


INSERT INTO schedule (subject_id, time, room_id, hours_type_id)
VALUES
    (
		(SELECT index FROM subject WHERE name = 'Математический анализ I'), 
		TO_TIMESTAMP('01-10-2023 7:15:00', 'DD-MM-YYYY HH24:MI:SS'),
		NULL, --room
		(SELECT index FROM hours_type WHERE name ='Семинары')
	)
	


