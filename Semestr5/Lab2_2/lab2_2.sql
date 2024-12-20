DROP TABLE IF EXISTS group_schedule;
DROP TABLE IF EXISTS teacher_schedule;
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS department_discipline;
DROP TABLE IF EXISTS teacher_department;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS teacher;
DROP TABLE IF EXISTS room;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS group_;
DROP TABLE IF EXISTS distribution_hours;
DROP TABLE IF EXISTS hours_type;
DROP TABLE IF EXISTS distribution;
DROP TABLE IF EXISTS semestr;
DROP TABLE IF EXISTS study_plan;
DROP TABLE IF EXISTS subject_varparts;
DROP TABLE IF EXISTS subject;
DROP TABLE IF EXISTS discipline;
DROP TABLE IF EXISTS variativity_part;




CREATE TABLE discipline (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE subject (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
	disc_id INTEGER NOT NULL,
	
    FOREIGN KEY (disc_id) REFERENCES discipline(index),
	CONSTRAINT unique_name_subject UNIQUE (name)
);

CREATE TABLE variativity_part (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
	
	CONSTRAINT unique_name_varpart UNIQUE (name)
);

CREATE TABLE subject_varparts (
    index SERIAL PRIMARY KEY,
    varpart_id INTEGER NOT NULL,
    subject_id INTEGER NOT NULL,
	
    FOREIGN KEY (subject_id) REFERENCES subject(index),
	FOREIGN KEY (varpart_id) REFERENCES variativity_part(index)
);



CREATE TABLE semestr (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

	CONSTRAINT unique_name_semestr UNIQUE (name)
	
);

CREATE TABLE study_plan (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    varpart_id INTEGER NOT NULL,
	
    FOREIGN KEY (varpart_id) REFERENCES variativity_part(index),
	CONSTRAINT unique_name_plan UNIQUE (name)
);

CREATE TABLE distribution (
    index SERIAL PRIMARY KEY,
    plan_id INTEGER NOT NULL,
    subject_id INTEGER NOT NULL,
    semestr_id INTEGER NOT NULL,
	
    FOREIGN KEY (plan_id) REFERENCES study_plan(index),
    FOREIGN KEY (subject_id) REFERENCES subject(index),
    FOREIGN KEY (semestr_id) REFERENCES semestr(index)
);

CREATE TABLE hours_type (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

	CONSTRAINT unique_name_hours_type UNIQUE (name)
);

CREATE TABLE distribution_hours (
    index SERIAL PRIMARY KEY,
    distr_id INTEGER NOT NULL,
    hours_type_id INTEGER NOT NULL,
	
    volume INTEGER CONSTRAINT positive CHECK (volume > 0),
    FOREIGN KEY (distr_id) REFERENCES distribution(index),
    FOREIGN KEY (hours_type_id) REFERENCES hours_type(index)
);

CREATE TABLE group_(
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
	semestr_id INTEGER NOT NULL,
	
	FOREIGN KEY (semestr_id) REFERENCES semestr(index),
	CONSTRAINT unique_name_group UNIQUE (name)
);

CREATE TABLE student (
    index SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    plan_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
	
    FOREIGN KEY (plan_id) REFERENCES study_plan(index),
    FOREIGN KEY (group_id) REFERENCES group_(index)
);

CREATE TABLE room (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
	volume INTEGER,

	CONSTRAINT unique_name_room UNIQUE (name),
	CONSTRAINT pos_vol_room CHECK (volume > 0)
);

CREATE TABLE teacher (
    index SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE department (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

	CONSTRAINT unique_name_department UNIQUE (name)
);

CREATE TABLE schedule (
    index SERIAL PRIMARY KEY,
    subject_id INTEGER,
    time TIMESTAMP NOT NULL,
	hours_type_id INTEGER NOT NULL,
    room_id INTEGER,
	
    FOREIGN KEY (subject_id) REFERENCES subject(index),
	FOREIGN KEY (hours_type_id) REFERENCES hours_type(index),
    FOREIGN KEY (room_id) REFERENCES room(index)
);

CREATE TABLE teacher_department (
    index SERIAL PRIMARY KEY,
    teacher_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teacher(index),
    FOREIGN KEY (department_id) REFERENCES department(index)
);

CREATE TABLE department_discipline (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    discipline_id INTEGER NOT NULL,
    FOREIGN KEY (discipline_id) REFERENCES discipline(index)
);

CREATE TABLE teacher_schedule (
    index SERIAL PRIMARY KEY,
    teacher_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teacher(index),
	FOREIGN KEY (lesson_id) REFERENCES schedule(index)
);

CREATE TABLE group_schedule (
    index SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,
    FOREIGN KEY (group_id) REFERENCES group_(index),
	FOREIGN KEY (lesson_id) REFERENCES schedule(index)
);


INSERT INTO discipline (name)
VALUES
    ('Математический анализ'), --1
    ('Современное естествознание'),   --2
    ('Информатика'), --3
	('Гуманитарный, социальный и экономический'); --4
---
INSERT INTO subject (name, disc_id)
	SELECT 'Математический анализ I', discipline.index FROM discipline
	WHERE discipline.name = 'Математический анализ'
	UNION ALL
	SELECT 'Математический анализ II', discipline.index FROM discipline
	WHERE discipline.name = 'Математический анализ'
	UNION ALL
	SELECT 'Математический анализ III', discipline.index FROM discipline
	WHERE discipline.name = 'Математический анализ'
	UNION ALL
	SELECT 'Математический анализ и Теория функций комплексного переменного', discipline.index FROM discipline
	WHERE discipline.name = 'Математический анализ'
	UNION ALL

	SELECT 'Электродинамика', discipline.index FROM discipline
	WHERE discipline.name = 'Современное естествознание'
	UNION ALL
	SELECT 'Классическая механика', discipline.index FROM discipline
	WHERE discipline.name = 'Современное естествознание'
	UNION ALL
	
	SELECT 'Архитектура ЭВМ', discipline.index FROM discipline
	WHERE discipline.name = 'Информатика'
	UNION ALL
	SELECT 'Операционные системы', discipline.index FROM discipline
	WHERE discipline.name = 'Информатика'
	UNION ALL
	SELECT 'Системное программирование', discipline.index FROM discipline
	WHERE discipline.name = 'Информатика'
	UNION ALL
	
	SELECT 'Социология', discipline.index FROM discipline
	WHERE discipline.name = 'Гуманитарный, социальный и экономический'
	UNION ALL
	SELECT 'Лингвистическая культура', discipline.index FROM discipline
	WHERE discipline.name = 'Гуманитарный, социальный и экономический'
	UNION ALL
	SELECT 'Межфакультетские курсы', discipline.index FROM discipline
	WHERE discipline.name = 'Гуманитарный, социальный и экономический'
	UNION ALL
	SELECT 'Гумманитарные курсы по выбору', discipline.index FROM discipline
	WHERE discipline.name = 'Гуманитарный, социальный и экономический';
	
    --('Математический анализ I', 1), --1
	--('Математический анализ II', 1), --2
	--('Математический анализ III', 1), --3
	
    --('Электродинамика', 2), --4
	--('Классическая Механика', 2), --5
	
    --('Архитектура ЭВМ', 3), --6
	--('Операционные системы', 3), --7
	
	--('Социология', 4), --8
	--('Лингвистическая культура', 4), --9
	--('Межфакультетские курсы', 4), --10
	--('Гумманитарные курсы по выбору', 4), --11

	--('Математический анализ и Теория функций комплексного переменного', 1), --12
	--('Системное программирование', 3), --13


INSERT INTO variativity_part (name)
VALUES
	('Гуманитарный, социальный и экономический'); --1
----
INSERT INTO subject_varparts (varpart_id ,subject_id)
	SELECT v.index AS varpart_id, s.index AS subject_id FROM variativity_part as v
	JOIN subject AS s ON v.name = 'Гуманитарный, социальный и экономический' AND s.name = 'Социология'
	UNION ALL
	SELECT v.index AS varpart_id, s.index AS subject_id FROM variativity_part as v
	JOIN subject AS s ON v.name = 'Гуманитарный, социальный и экономический' AND s.name = 'Лингвистическая культура'
	UNION ALL
	SELECT v.index AS varpart_id, s.index AS subject_id FROM variativity_part as v
	JOIN subject AS s ON v.name = 'Гуманитарный, социальный и экономический' AND s.name = 'Межфакультетские курсы'
	UNION ALL
	SELECT v.index AS varpart_id, s.index AS subject_id FROM variativity_part as v
	JOIN subject AS s ON v.name = 'Гуманитарный, социальный и экономический' AND s.name = 'Гумманитарные курсы по выбору';
		

INSERT INTO semestr (name)
VALUES
	('1 семестр'),
	('2 семестр'),
	('3 семестр'),
	('4 семестр'),
	('5 семестр'),
	('6 семестр'),
	('7 семестр'),
	('8 семестр');


	
INSERT INTO study_plan (name, varpart_id)
VALUES
    ('ВМК ПМИ', 1);


	

INSERT INTO distribution (plan_id, subject_id, semestr_id)
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Математический анализ I'
	JOIN semestr AS sem ON sem.name = '1 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Математический анализ II'
	JOIN semestr AS sem ON sem.name = '2 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Математический анализ III'
	JOIN semestr AS sem ON sem.name = '3 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Математический анализ и Теория функций комплексного переменного'
	JOIN semestr AS sem ON sem.name = '4 семестр'
	WHERE p.name = 'ВМК ПМИ'

	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Электродинамика'
	JOIN semestr AS sem ON sem.name = '4 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Классическая механика'
	JOIN semestr AS sem ON sem.name = '3 семестр'
	WHERE p.name = 'ВМК ПМИ'

	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Архитектура ЭВМ'
	JOIN semestr AS sem ON sem.name = '1 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Архитектура ЭВМ'
	JOIN semestr AS sem ON sem.name = '2 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Операционные системы'
	JOIN semestr AS sem ON sem.name = '3 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Системное программирование'
	JOIN semestr AS sem ON sem.name = '4 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	

	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Лингвистическая культура'
	JOIN semestr AS sem ON sem.name = '7 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Межфакультетские курсы'
	JOIN semestr AS sem ON sem.name = '5 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Межфакультетские курсы'
	JOIN semestr AS sem ON sem.name = '6 семестр'
	WHERE p.name = 'ВМК ПМИ'
	UNION ALL
	SELECT p.index as pl_id, sub.index as sub_i, sem.index as sem_i FROM study_plan as p
	JOIN subject as sub ON sub.name = 'Гумманитарные курсы по выбору'
	JOIN semestr AS sem ON sem.name = '2 семестр'
	WHERE p.name = 'ВМК ПМИ';


INSERT INTO hours_type (name)
VALUES
	('Лекции'),
	('Лабороторные занятия'),
	('Практические занятия'),
	('Семинары'),
	('Самостоятельная работа студентов');



INSERT INTO distribution_hours (distr_id, hours_type_id, volume)
--Matan I
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ I' AND sem.name = '1 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ I' AND sem.name = '1 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ I' AND sem.name = '1 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ I' AND sem.name = '1 семестр')
	UNION ALL
--Matan II	
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ II' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ II' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ II' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ II' AND sem.name = '2 семестр')
	UNION ALL
--Matan III
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ III' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ III' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ III' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ III' AND sem.name = '3 семестр')
	UNION ALL
--Математический анализ и Теория функций комплексного переменного
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ и Теория функций комплексного переменного' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ и Теория функций комплексного переменного' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ и Теория функций комплексного переменного' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Математический анализ и Теория функций комплексного переменного' AND sem.name = '4 семестр')
	UNION ALL
--Класс мех
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Классическая механика' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Классическая механика' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Классическая механика' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Классическая механика' AND sem.name = '3 семестр')
	UNION ALL
--Электрод
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Электродинамика' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Электродинамика' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Электродинамика' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Электродинамика' AND sem.name = '4 семестр')
	UNION ALL
--Архитектура ЭВМ I
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Архитектура ЭВМ' AND sem.name = '1 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Архитектура ЭВМ' AND sem.name = '1 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Архитектура ЭВМ' AND sem.name = '1 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Архитектура ЭВМ' AND sem.name = '1 семестр')
	UNION ALL
--Архитектура ЭВМ II
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Архитектура ЭВМ' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Архитектура ЭВМ' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Архитектура ЭВМ' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Архитектура ЭВМ' AND sem.name = '2 семестр')
	UNION ALL

--Операционные системы
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Операционные системы' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Операционные системы' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Операционные системы' AND sem.name = '3 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Операционные системы' AND sem.name = '3 семестр')
	UNION ALL

--Системное программирование
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Системное программирование' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Системное программирование' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Системное программирование' AND sem.name = '4 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Системное программирование' AND sem.name = '4 семестр')
	UNION ALL

--Лингвистическая культура
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Лингвистическая культура' AND sem.name = '7 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Лингвистическая культура' AND sem.name = '7 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Лингвистическая культура' AND sem.name = '7 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Лингвистическая культура' AND sem.name = '7 семестр')
	UNION ALL

--Межфакультетские курсы I
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Межфакультетские курсы' AND sem.name = '5 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Межфакультетские курсы' AND sem.name = '5 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Межфакультетские курсы' AND sem.name = '5 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Межфакультетские курсы' AND sem.name = '5 семестр')
	UNION ALL
--Межфакультетские курсы II
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Межфакультетские курсы' AND sem.name = '6 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Межфакультетские курсы' AND sem.name = '6 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Межфакультетские курсы' AND sem.name = '6 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Межфакультетские курсы' AND sem.name = '6 семестр')
	UNION ALL
--Гумманитарные курсы по выбору
	SELECT d.index as distr_id, h.index as hours_type, 10 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лекции' AND p.name='ВМК ПМИ' AND subj.name='Гумманитарные курсы по выбору' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 16 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Семинары' AND p.name='ВМК ПМИ' AND subj.name='Гумманитарные курсы по выбору' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 12 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Лабороторные занятия' AND p.name='ВМК ПМИ' AND subj.name='Гумманитарные курсы по выбору' AND sem.name = '2 семестр')
	UNION ALL
	SELECT d.index as distr_id, h.index as hours_type, 100 as volume
	FROM distribution as d
	CROSS JOIN hours_type as h
	JOIN study_plan as p ON p.index = d.plan_id
	JOIN subject as subj ON subj.index = d.subject_id
	JOIN semestr as sem ON sem.index = d.semestr_id
	WHERE (h.name='Самостоятельная работа студентов' AND p.name='ВМК ПМИ' AND subj.name='Гумманитарные курсы по выбору' AND sem.name = '2 семестр');


INSERT INTO group_ (name, semestr_id)
VALUES
	('107', (SELECT index FROM semestr WHERE name = '1 семестр')),
	('108', (SELECT index FROM semestr WHERE name = '1 семестр')),

	('207', (SELECT index FROM semestr WHERE name = '2 семестр')),
	('208', (SELECT index FROM semestr WHERE name = '2 семестр')),

	('307', (SELECT index FROM semestr WHERE name = '3 семестр')),
	('308', (SELECT index FROM semestr WHERE name = '3 семестр')),

	('407', (SELECT index FROM semestr WHERE name = '4 семестр')),
	('408', (SELECT index FROM semestr WHERE name = '4 семестр'));

--SELECT * FROM group_
-- Вставка данных для группы 107
INSERT INTO student (full_name, plan_id, group_id)
VALUES
    ('Иванов Иван Иванович',(SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Петров Петр Петрович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Сидоров Сидор Сидорович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Кузнецов Кузьма Кузьмич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Смирнов Смир Смирович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Попов Поп Попович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Соколов Сокол Соколович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Лебедев Лебедь Лебедевич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Козлов Козел Козлович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
    ('Степанов Степан Степанович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '107')),
-- Вставка данных для группы 108
    ('Федоров Федор Федорович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Морозов Мороз Морозович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Волков Волк Волкович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Алексеев Алексей Алексеевич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Лебедев Лебедь Лебедевич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Семенов Семен Семенович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Павлов Павел Павлович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Степанов Степан Степанович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Соколов Сокол Соколович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),
    ('Кузнецов Кузьма Кузьмич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '108')),

-- Вставка данных для группы 207

    ('Иванов Иван Иванович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Петров Петр Петрович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Сидоров Сидор Сидорович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Кузнецов Кузьма Кузьмич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Смирнов Смир Смирович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Попов Поп Попович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Соколов Сокол Соколович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Лебедев Лебедь Лебедевич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Козлов Козел Козлович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),
    ('Степанов Степан Степанович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '207')),

-- Вставка данных для группы 208

    ('Федоров Федор Федорович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Морозов Мороз Морозович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Волков Волк Волкович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Алексеев Алексей Алексеевич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Лебедев Лебедь Лебедевич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Семенов Семен Семенович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Павлов Павел Павлович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Степанов Степан Степанович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Соколов Сокол Соколович', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
    ('Кузнецов Кузьма Кузьмич', (SELECT index FROM study_plan WHERE name='ВМК ПМИ'), (SELECT index FROM group_ WHERE name = '208')),
-- Вставка данных для группы 307

    ('Иванов Иван Иванович', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Петров Петр Петрович', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Сидоров Сидор Сидорович', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Кузнецов Кузьма Кузьмич', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Смирнов Смир Смирович', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Попов Поп Попович', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Соколов Сокол Соколович', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Лебедев Лебедь Лебедевич', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Козлов Козел Козлович', 1, (SELECT index FROM group_ WHERE name = '307')),
    ('Степанов Степан Степанович', 1, (SELECT index FROM group_ WHERE name = '307')),

-- Вставка данных для группы 308

    ('Федоров Федор Федорович', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Морозов Мороз Морозович', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Волков Волк Волкович', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Алексеев Алексей Алексеевич', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Лебедев Лебедь Лебедевич', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Семенов Семен Семенович', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Павлов Павел Павлович', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Степанов Степан Степанович', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Соколов Сокол Соколович', 1, (SELECT index FROM group_ WHERE name = '308')),
    ('Кузнецов Кузьма Кузьмич', 1, (SELECT index FROM group_ WHERE name = '308')),

-- Вставка данных для группы 407

    ('Иванов Иван Иванович', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Петров Петр Петрович', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Сидоров Сидор Сидорович', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Кузнецов Кузьма Кузьмич', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Смирнов Смир Смирович', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Попов Поп Попович', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Соколов Сокол Соколович', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Лебедев Лебедь Лебедевич', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Козлов Козел Козлович', 1, (SELECT index FROM group_ WHERE name = '407')),
    ('Степанов Степан Степанович', 1, (SELECT index FROM group_ WHERE name = '407')),

-- Вставка данных для группы 408

    ('Федоров Федор Федорович', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Морозов Мороз Морозович', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Волков Волк Волкович', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Алексеев Алексей Алексеевич', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Лебедев Лебедь Лебедевич', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Семенов Семен Семенович', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Павлов Павел Павлович', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Степанов Степан Степанович', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Соколов Сокол Соколович', 1, (SELECT index FROM group_ WHERE name = '408')),
    ('Кузнецов Кузьма Кузьмич', 1, (SELECT index FROM group_ WHERE name = '408'));



INSERT INTO room (name, volume)
VALUES
    ('Аудитория 303', 15),
    ('Аудитория 504', 25),
    ('Аудитория 701', 25),
    ('Аудитория 304', 25),
    ('Аудитория 505', 35),
    ('Аудитория 702', 35),
    ('Аудитория 305', 35),
    ('Аудитория 506', 35),
    ('Аудитория 703', 35),
	('П-5', 100),
	('П-13', 666),
    ('Аудитория 306', 35);


INSERT INTO teacher (full_name) VALUES
	('Иванов Иван Иванович'),
	('Петров Петр Петрович'),
	('Сидоров Сидор Сидорович'),
	('Кузнецова Анна Сергеевна'),
	('Смирнова Елена Владимировна'),
	('Попова Мария Александровна'),
	('Васильев Дмитрий Алексеевич'),
	('Соколова Ольга Ивановна'),
	('Михайлов Андрей Викторович'),
	('Федорова Наталья Сергеевна');


INSERT INTO department (name)
VALUES
    ('Кафедра математического анализа'),
    ('Кафедра физики'),
    ('Кафедра информатики'),
    ('Кафедра гуманитарных наук');


INSERT INTO schedule (subject_id, time, room_id, hours_type_id)
VALUES
    ((SELECT index FROM subject WHERE name = 'Математический анализ I'), '01-10-2023 08:00:00', (SELECT index FROM room WHERE name = 'Аудитория 303'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Математический анализ I'), '01-11-2023 08:00:00', (SELECT index FROM room WHERE name = 'Аудитория 303'), (SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Математический анализ II'), '01-10-2023 09:00:00', (SELECT index FROM room WHERE name = 'Аудитория 504'),(SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Математический анализ II'), '01-11-2023 09:00:00', (SELECT index FROM room WHERE name = 'Аудитория 504'),(SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Математический анализ III'), '01-10-2023 10:00:00', (SELECT index FROM room WHERE name = 'Аудитория 701'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Математический анализ III'), '01-11-2023 10:00:00', (SELECT index FROM room WHERE name = 'Аудитория 701'), (SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Электродинамика'), '01-10-2023 11:00:00', (SELECT index FROM room WHERE name = 'Аудитория 304'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Электродинамика'), '01-11-2023 11:00:00', (SELECT index FROM room WHERE name = 'Аудитория 304'), (SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Классическая механика'), '01-10-2023 12:00:00', (SELECT index FROM room WHERE name = 'Аудитория 505'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Классическая механика'), '01-11-2023 12:00:00', (SELECT index FROM room WHERE name = 'Аудитория 505'), (SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Архитектура ЭВМ'), '01-10-2023 13:00:00', (SELECT index FROM room WHERE name = 'Аудитория 702'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Архитектура ЭВМ'), '01-11-2023 13:00:00', (SELECT index FROM room WHERE name = 'Аудитория 702'), (SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Операционные системы'), '01-10-2023 14:00:00', (SELECT index FROM room WHERE name = 'Аудитория 305'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Операционные системы'), '01-11-2023 14:00:00', (SELECT index FROM room WHERE name = 'Аудитория 305'), (SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Социология'), '01-10-2023 15:00:00', (SELECT index FROM room WHERE name = 'Аудитория 506'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Социология'), '01-11-2023 15:00:00', (SELECT index FROM room WHERE name = 'Аудитория 506'), (SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Лингвистическая культура'), '01-10-2023 16:00:00', (SELECT index FROM room WHERE name = 'Аудитория 703'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Лингвистическая культура'), '01-11-2023 16:00:00', (SELECT index FROM room WHERE name = 'Аудитория 703'), (SELECT index FROM hours_type WHERE name ='Лекции')),
    ((SELECT index FROM subject WHERE name = 'Межфакультетские курсы'), '01-10-2023 17:00:00', (SELECT index FROM room WHERE name = 'Аудитория 306'), (SELECT index FROM hours_type WHERE name ='Семинары')),
	((SELECT index FROM subject WHERE name = 'Межфакультетские курсы'), '01-11-2023 17:00:00', (SELECT index FROM room WHERE name = 'Аудитория 306'), (SELECT index FROM hours_type WHERE name ='Лекции'));

INSERT INTO teacher_department (teacher_id, department_id)
VALUES
    ((SELECT index FROM teacher WHERE full_name = 'Иванов Иван Иванович'), (SELECT index FROM department WHERE name = 'Кафедра математического анализа')),
    ((SELECT index FROM teacher WHERE full_name = 'Петров Петр Петрович'), (SELECT index FROM department WHERE name = 'Кафедра математического анализа')),
	((SELECT index FROM teacher WHERE full_name = 'Васильев Дмитрий Алексеевич'), (SELECT index FROM department WHERE name = 'Кафедра математического анализа')),
    ((SELECT index FROM teacher WHERE full_name = 'Сидоров Сидор Сидорович'), (SELECT index FROM department WHERE name = 'Кафедра математического анализа')),
    ((SELECT index FROM teacher WHERE full_name = 'Кузнецова Анна Сергеевна'), (SELECT index FROM department WHERE name = 'Кафедра физики')),
    ((SELECT index FROM teacher WHERE full_name = 'Смирнова Елена Владимировна'), (SELECT index FROM department WHERE name = 'Кафедра физики')),
    ((SELECT index FROM teacher WHERE full_name = 'Попова Мария Александровна'), (SELECT index FROM department WHERE name = 'Кафедра информатики')),
    ((SELECT index FROM teacher WHERE full_name = 'Васильев Дмитрий Алексеевич'), (SELECT index FROM department WHERE name = 'Кафедра информатики')),
    ((SELECT index FROM teacher WHERE full_name = 'Соколова Ольга Ивановна'), (SELECT index FROM department WHERE name = 'Кафедра гуманитарных наук')),
    ((SELECT index FROM teacher WHERE full_name = 'Михайлов Андрей Викторович'), (SELECT index FROM department WHERE name = 'Кафедра гуманитарных наук')),
    ((SELECT index FROM teacher WHERE full_name = 'Федорова Наталья Сергеевна'), (SELECT index FROM department WHERE name = 'Кафедра гуманитарных наук'));




INSERT INTO department_discipline (name, discipline_id)
VALUES
    ('Кафедра математического анализа', (SELECT index FROM discipline WHERE name = 'Математический анализ')),
    ('Кафедра физики', (SELECT index FROM discipline WHERE name = 'Современное естествознание')),
    ('Кафедра информатики', (SELECT index FROM discipline WHERE name = 'Информатика')),
    ('Кафедра гуманитарных наук', (SELECT index FROM discipline WHERE name = 'Гуманитарный, социальный и экономический'));

INSERT INTO teacher_schedule (teacher_id, lesson_id)
VALUES
    ((SELECT index FROM teacher WHERE full_name = 'Иванов Иван Иванович'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Петров Петр Петрович'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ II') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Сидоров Сидор Сидорович'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ III') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Кузнецова Анна Сергеевна'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Электродинамика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Смирнова Елена Владимировна'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Классическая механика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Попова Мария Александровна'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Архитектура ЭВМ') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Васильев Дмитрий Алексеевич'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Операционные системы') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Соколова Ольга Ивановна'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Социология') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Михайлов Андрей Викторович'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Лингвистическая культура') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM teacher WHERE full_name = 'Федорова Наталья Сергеевна'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Межфакультетские курсы') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') ));




--begin transaction;
-- Вставка данных для расписания занятий для групп
--update subject
--set name = 'Математический анализ I';
INSERT INTO group_schedule (group_id, lesson_id)
VALUES
    ((SELECT index FROM group_ WHERE name = '107'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '107'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ II') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '107'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ III') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '108'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '108'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ II') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '108'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ III') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '207'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Электродинамика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '207'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Классическая механика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '208'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Электродинамика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '208'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Классическая механика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '307'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Архитектура ЭВМ') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '307'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Операционные системы') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '308'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Архитектура ЭВМ') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '308'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Операционные системы') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '407'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Социология') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '407'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Лингвистическая культура') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '408'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Социология') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
    ((SELECT index FROM group_ WHERE name = '408'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Лингвистическая культура') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Семинары') )),
 ((SELECT index FROM group_ WHERE name = '107'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '107'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ II') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '107'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ III') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '108'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ I') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '108'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ II') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '108'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Математический анализ III') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '207'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Электродинамика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '207'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Классическая механика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '208'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Электродинамика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '208'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Классическая механика') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '307'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Архитектура ЭВМ') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '307'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Операционные системы') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '308'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Архитектура ЭВМ') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '308'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Операционные системы') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '407'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Социология') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '407'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Лингвистическая культура') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '408'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Социология') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') )),
    ((SELECT index FROM group_ WHERE name = '408'), (SELECT index FROM schedule WHERE subject_id = (SELECT index FROM subject WHERE name = 'Лингвистическая культура') 
		AND hours_type_id = (SELECT index FROM hours_type WHERE name = 'Лекции') ));


