CREATE DOMAIN grade AS SMALLINT
    CHECK (VALUE BETWEEN 2 AND 5);

CREATE TABLE groups (
                        group_id SERIAL PRIMARY KEY,
                        code VARCHAR(10) NOT NULL UNIQUE,
                        title VARCHAR(64) NOT NULL,
                        admin_id INTEGER UNIQUE
);

CREATE TABLE students (
                          student_id SERIAL PRIMARY KEY,
                          name VARCHAR(64) NOT NULL,
                          surname VARCHAR(64) NOT NULL,
                          birthday DATE NOT NULL,
                          group_id INTEGER NOT NULL REFERENCES groups,
                          UNIQUE (group_id, student_id)
);

ALTER TABLE groups
    ADD FOREIGN KEY (group_id, admin_id)
        REFERENCES students (group_id, student_id);

CREATE TABLE teachers (
                          teacher_id SERIAL PRIMARY KEY,
                          name VARCHAR(64) NOT NULL,
                          surname VARCHAR(64) NOT NULL
);

CREATE TABLE exams (
                       exam_id SERIAL PRIMARY KEY,
                       title VARCHAR(255) NOT NULL,
                       duration INTERVAL NOT NULL
        CHECK (duration > INTERVAL '0 seconds')
);

CREATE TABLE attempts (
                          attempt_id SERIAL PRIMARY KEY,
                          final_grade grade NOT NULL,
                          date_of_attempt DATE NOT NULL,
                          exam_id INTEGER NOT NULL REFERENCES exams,
                          student_id INTEGER NOT NULL REFERENCES students,
                          teacher_id INTEGER NOT NULL REFERENCES teachers
);

INSERT INTO groups (code, title) VALUES
                                     ('P3221', 'Первая группа'),
                                     ('P3222', 'Вторая группа'),
                                     ('P3223', 'Третья группа');

INSERT INTO students (name, surname, birthday, group_id) VALUES
                                                             ('Иван',  'Иванов',  '2006-01-01', 1),
                                                             ('Петр', 'Петров',   '2006-02-01', 1),
                                                             ('Федор',  'Федоров', '2006-03-01', 1),
                                                             ('Дарья',  'Алексеева',    '2006-04-01', 2),
                                                             ('Елена',  'Волкова',  '2006-05-01', 2),
                                                             ('Егор',  'Морозов',  '2006-06-01', 2),
                                                             ('Анна',  'Смирнова', '2006-07-01', 1),
                                                             ('Дмитрий',  'Дмитриев',   '2006-08-01', 2);

UPDATE groups SET admin_id = 1 WHERE group_id = 1;
UPDATE groups SET admin_id = 4 WHERE group_id = 2;

INSERT INTO teachers (name, surname) VALUES
                                         ('Ольга', 'Лебедева'),
                                         ('Павел', 'Зайцев'),
                                         ('Мария', 'Новикова');

INSERT INTO exams (title, duration) VALUES
                                        ('Базы данных',        INTERVAL '90 minutes'),
                                        ('Математический анализ',         INTERVAL '120 minutes'),
                                        ('Программирование',   INTERVAL '90 minutes'),
                                        ('Операционные системы',  INTERVAL '60 minutes');

INSERT INTO attempts
(student_id, exam_id, teacher_id, date_of_attempt, final_grade)
VALUES
    (1, 1, 1, '2026-09-01', 2),
    (1, 1, 1, '2026-09-08', 4),
    (1, 1, 1, '2026-09-15', 5),
    (1, 2, 2, '2026-09-02', 4),
    (1, 2, 2, '2026-09-09', 4),
    (2, 1, 1, '2026-09-01', 2),
    (4, 1, 1, '2026-09-01', 5),
    (4, 2, 2, '2026-09-02', 5),
    (5, 1, 1, '2026-09-01', 3),
    (7, 2, 2, '2026-09-02', 4),
    (8, 3, 1, '2026-09-03', 2),
    (8, 3, 1, '2026-09-10', 5),
    (8, 1, 1, '2026-09-04', 4);