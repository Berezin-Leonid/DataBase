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
    name VARCHAR(100)
);

CREATE TABLE subject (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100),
    disc_id INTEGER,
    FOREIGN KEY (disc_id) REFERENCES discipline(index)
);

CREATE TABLE variativity_part (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE subject_varparts (
    index SERIAL PRIMARY KEY,
    varpart_id INTEGER,
    subject_id INTEGER,
    FOREIGN KEY (subject_id) REFERENCES subject(index),
	FOREIGN KEY (varpart_id) REFERENCES variativity_part(index)
);



CREATE TABLE semestr (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE study_plan (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100),
    varpart_id INTEGER,
    FOREIGN KEY (varpart_id) REFERENCES variativity_part(index)
);

CREATE TABLE distribution (
    index SERIAL PRIMARY KEY,
    plan_id INTEGER,
    subject_id INTEGER,
    semestr_id INTEGER,
    FOREIGN KEY (plan_id) REFERENCES study_plan(index),
    FOREIGN KEY (subject_id) REFERENCES subject(index),
    FOREIGN KEY (semestr_id) REFERENCES semestr(index)
);

CREATE TABLE hours_type (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE distribution_hours (
    index SERIAL PRIMARY KEY,
    distr_id INTEGER,
    horse_type_id INTEGER,
    volume INTEGER,
    FOREIGN KEY (distr_id) REFERENCES distribution(index),
    FOREIGN KEY (horse_type_id) REFERENCES hours_type(index)
);

CREATE TABLE group_(
    index SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE student (
    index SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    plan_id INTEGER,
    group_id INTEGER,
    FOREIGN KEY (plan_id) REFERENCES study_plan(index),
    FOREIGN KEY (group_id) REFERENCES group_(index)
);

CREATE TABLE room (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE teacher (
    index SERIAL PRIMARY KEY,
    full_name VARCHAR(100)
);

CREATE TABLE department (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE schedule (
    index SERIAL PRIMARY KEY,
    subject_id INTEGER,
    time TIME,
    room_id INTEGER,
    FOREIGN KEY (subject_id) REFERENCES subject(index),
    FOREIGN KEY (room_id) REFERENCES room(index)
);

CREATE TABLE teacher_department (
    index SERIAL PRIMARY KEY,
    teacher_id INTEGER,
    department_id INTEGER,
    FOREIGN KEY (teacher_id) REFERENCES teacher(index),
    FOREIGN KEY (department_id) REFERENCES department(index)
);

CREATE TABLE department_discipline (
    index SERIAL PRIMARY KEY,
    name VARCHAR(100),
    discipline_id INTEGER,
    FOREIGN KEY (discipline_id) REFERENCES discipline(index)
);

CREATE TABLE teacher_schedule (
    index SERIAL PRIMARY KEY,
    teacher_id INTEGER,
    lesson_id INTEGER,
    FOREIGN KEY (teacher_id) REFERENCES teacher(index),
	FOREIGN KEY (lesson_id) REFERENCES schedule(index)
);

CREATE TABLE group_schedule (
    index SERIAL PRIMARY KEY,
    group_id INTEGER,
    lesson_id INTEGER,
    FOREIGN KEY (group_id) REFERENCES group_(index),
	FOREIGN KEY (lesson_id) REFERENCES schedule(index)
);


INSERT INTO discipline (name)
VALUES
    ('Математический анализ'), --1
    ('Современное естествознание'),   --2
    ('Информатика'), --3
	('Гуманитарный, социальный и экономический'); --4


INSERT INTO subject (name, disc_id)
Values
(SELECT 'Математический анализ I', discipline.index
FROM discipline
WHERE discipline.name = 'Математический анализ'),
(SELECT 'Математический анализ II', discipline.index
FROM discipline
WHERE discipline.name = 'Математический анализ');

SELECT * from subject

    ('Математический анализ I', 1), --1
	('Математический анализ II', 1), --2
	('Математический анализ III', 1), --3
	
    ('Электродинамика', 2), --4
	('Классическая Механика', 2), --5
	
    ('Архитектура ЭВМ', 3), --6
	('Операционные системы', 3), --7
	
	('Социология', 4), --8
	('Лингвистическая культура', 4), --9
	('Межфакультетские курсы', 4), --10
	('Гумманитарные курсы по выбору', 4), --11

	('Математический анализ и Теория функций комплексного переменного', 1), --12
	('Системное программирование', 3), --13

INSERT INTO variativity_part (name)
VALUES
	('Гуманитарный, социальный и экономический'); --1

INSERT INTO subject_varparts (varpart_id ,subject_id)
VALUES
	(1, 8),
	(1, 9),
	(1, 10),
	(1, 11);

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
VALUES
    (1, 1, 1), --Матан
    (1, 2, 2),
    (1, 3, 3),
	(1, 12, 4),

	(1, 4, 4), --Физика
	(1, 5, 3),

	(1, 6, 1), --информатика
	(1, 6, 2),
	(1, 7, 3),
	(1, 13, 4),

	(1, 8, ),
	(1, 9, ),
	(1, 10, 5),
	(1, 10, 6),
	(1, 11, ),
	
	





