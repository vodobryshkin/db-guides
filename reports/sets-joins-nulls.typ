#import "@preview/primeone:1.0.0": *
#import "@preview/fletcher:0.5.8" as cf
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-venn:0.2.0"

#let venn-op(a: false, b: false, ab: false) = cetz.canvas({
  let selected = rgb("#d9e9ff")
  cetz-venn.venn2(
    name: "sets",
    padding: 0.15,
    stroke: 0.7pt,
    not-ab-stroke: none,
    not-ab-fill: none,
    a-fill: if a { selected } else { white },
    b-fill: if b { selected } else { white },
    ab-fill: if ab { selected } else { white },
  )
  cetz.draw.content("sets.a", [$A$])
  cetz.draw.content("sets.b", [$B$])
})

#show: article.with(
  title: "Множества, JOIN и NULL в PostgreSQL",
  subtitle: underline(link("https://github.com/vodobryshkin/db-guides")[Репозиторий c докладами]),
  authors: (
    (name: "Владимир Добрышкин", email: link("https://t.me/vodobryshkin")[t.me/vodobryshkin]),
  ),
  date: "Версия 0.0.0",
  abstract: [Данный документ представляет из себя практическую памятку по:
   - Множествам и мультимножествам.
   - Соединениям таблиц.
   - NULL и трёхзначной логике.],
  abstract-title: "Аннотация",
  titlepage: true,
  toc: true,
  toc-title: "Содержание",
  toc-depth: 2,
  theme: theme-lara-green
)

= База данных для примеров

В этой памятке мы рассмотрим дополнительный материал к лабораторной работе №2, который поможет глубже разобраться в SQL и соединениях таблиц.

#messages(severity: "info")[
    Тема практическая, поэтому я решил разобрать все примеры на одной учебной базе данных и приложить файлы для её запуска. При желании вы сможете самостоятельно повторить все запросы из памятки.
]

Все примеры используют одну учебную базу данных о сдаче экзаменов. Эта предметная область уже рассматривалась в #underline(link("https://github.com/vodobryshkin/db-guides/blob/main/reports/chart-formatting-and-styleguide.typ")[памятке по оформлению моделей и SQL-кода]).

== Предметная область
- Студенты сдают экзамены преподавателям. Каждая попытка сдачи связывает студента, экзамен и преподавателя, а также содержит дату и оценку. Повторная сдача того же экзамена сохраняется как отдельная попытка.
- Каждый студент состоит ровно в одной учебной группе. Группа может быть пустой, для неё можно указать старосту из числа её студентов.
- У группы может быть один староста, выбранный из числа студентов этой же группы. Назначать старосту необязательно.

#figure(
    image("images/physical.png"),
    supplement: [Изображение],
    caption: [Физическая модель базы данных]
)

\

== Запуск базы данных

Для запуска понадобится #underline(link("https://docs.docker.com/get-started/get-docker/")[Docker]).

+ Скачайте файлы `compose.yaml` и `init.sql` из #underline(link("https://github.com/vodobryshkin/db-guides/tree/main/reports/sets-joins-nulls")[репозитория]) и сохраните их в *одну директорию*.

+ Откройте терминал в этой директории и запустите БД:

  ```shell-unix-generic
  docker compose up -d --wait
  ```

+ После завершения запуска подключитесь к БД через `psql`:

  ```shell-unix-generic
  docker compose exec db psql -U report -d exams-db
  ```

#pagebreak()

= Множества и мультимножества
== Определения
Результат SQL-запроса может содержать повторяющиеся строки. Чтобы понимать, когда повторения важны, а когда их нужно убрать, разберём простой пример.

Выведем идентификаторы студентов, у которых есть попытки сдачи экзамена по Базам данных (`exam_id = 1`):

```sql
SELECT student_id
  FROM attempts
  WHERE exam_id = 1
  ORDER BY student_id;
 ```

Ожидаемый вывод:

```text
 student_id
------------
          1
          1
          1
          2
          4
          5
          8
(7 rows)
```

Студент, у которого `student_id = 1`, встречается три раза, потому что у него три попытки сдачи.

Если нам нужен список студентов, достаточно оставить каждый идентификатор один раз. Если мы считаем попытки, повторения необходимо сохранить. Для описания этих двух случаев можно использовать понятия *множества* и *мультимножества*.

*Множество* (англ. _set_) -- структура данных, которая предстваляет собой совокупность элементов без повторений.

Посмотрим на примере на C++:
```cpp
std::set<int> numbers;

// insert добавляет элемент в множество
numbers.insert(1); // {1}
numbers.insert(1); // {1}
numbers.insert(2); // {1, 2}
numbers.insert(3); // {1, 2, 3}
```

*Мультимножество* (англ. _multiset_) -- структура данных, которая хранит совокупность элементов с учётом повторений.

```cpp
std::multiset<int> numbers;

numbers.insert(1); // {1}
numbers.insert(1); // {1, 1}
numbers.insert(2); // {1, 1, 2}
numbers.insert(3); // {1, 1, 2, 3}
numbers.insert(3); // {1, 1, 2, 3, 3}
```

#messages(severity: "warning")[
Большинство реализаций множества и мультимножества не гарантируют порядок хранения элементов.
]

В контексте SQL мы можем заметить, что обычный `SELECT` сохраняет повторяющиеся строки, поэтому его результат удобно рассматривать как мультимножество.

Такое поведение можно указать явно через `SELECT ALL`:

```sql
SELECT ALL student_id
  FROM attempts
 WHERE exam_id = 1
 ORDER BY student_id;
```

Результат будет таким же, как у предыдущего запроса. Слово `ALL` обычно опускают, поскольку это поведение по умолчанию.

Результат операции получения всех строк без повторений можно рассмотреть как множество. Для его выполнения добавим ключевое слово `DISTINCT`:

```sql
SELECT DISTINCT student_id
  FROM attempts
 WHERE exam_id = 1
 ORDER BY student_id;
```

Вывод:

```text
 student_id
------------
          1
          2
          4
          5
          8
(5 rows)
```

== Операции над множествами

Рассмотрим два множества:
- $A$ — идентификаторы студентов, у которых есть попытки сдачи экзамена по Базам данных: `1, 2, 4, 5, 8`

- $B$ — идентификаторы студентов, у которых есть попытки сдачи экзамена Математическуму анализу: `1, 4, 7`

Для работы с результатами запросов в SQL есть операции объединения, пересечения и разности. На диаграммах ниже результат каждой операции выделен голубым.

=== Объединение: UNION
Объединение $A union B$ содержит элементы, которые входят хотя бы в одно из множеств.

#align(center)[
  #venn-op(a: true, b: true, ab: true)
]

\

Получим идентификаторы студентов, у которых есть попытки сдачи баз данных или математического анализа:

```sql
SELECT student_id
  FROM attempts
 WHERE exam_id = 1
UNION
SELECT student_id
  FROM attempts
 WHERE exam_id = 2
ORDER BY student_id;
```

Результат:
```text
 student_id
------------
          1
          2
          4
          5
          7
          8
(6 rows)
```

Если студент сдавал оба экзамена или делал несколько попыток, его идентификатор всё равно появится один раз, т.к. `UNION` удаляет повторяющиеся строки.

=== Пересечение: INTERSECT

Пересечение $A inter B$ содержит элементы, которые входят в оба множества.

#align(center)[
  #venn-op(ab: true)
]

Получим идентификаторы студентов, у которых есть попытки сдачи и баз данных, и математического анализа:

```sql
SELECT student_id
  FROM attempts
 WHERE exam_id = 1
INTERSECT
SELECT student_id
  FROM attempts
 WHERE exam_id = 2
ORDER BY student_id;
```

Результат:
```text
 student_id
------------
          1
          4
```

\
\
\

=== Разность: EXCEPT

Разность $A without B$ содержит элементы первого множества, которых нет во втором.

#align(center)[
  #venn-op(a: true)
]

Получим идентификаторы студентов, у которых есть попытки сдачи баз данных, но нет попыток сдачи математического анализа:

```sql
SELECT student_id
  FROM attempts
 WHERE exam_id = 1
EXCEPT
SELECT student_id
  FROM attempts
 WHERE exam_id = 2
ORDER BY student_id;
```

Результат:
```text
student_id
------------
          2
          5
          8
(3 rows)
```

=== А что с повторениями?

По умолчанию `UNION`, `INTERSECT` и `EXCEPT` удаляют повторения. У каждой операции есть вариант с `ALL`, который учитывает количество одинаковых строк.

Например, идентификатор Ивана Иванова встречается три раза среди попыток по базам данных и два раза среди попыток по математическому анализу:
- `UNION ALL` оставит пять вхождений — сумму;
- `INTERSECT ALL` оставит два вхождения — минимум;
- `EXCEPT ALL` оставит одно вхождение — разность, но не меньше нуля.

= Обратная связь
#messages(severity: "error")[Нашли опечатку или ошибку?]

#messages(severity: "warning")[Есть идеи по улучшению материала?]

#messages(severity: "info")[Хотите предложить тему, которой можно будет дополнить доклад?]

#messages(severity: "success")[
Пишите в #underline(link("https://t.me/vodobryshkin")[личные сообщения]) или заведите issue в #underline(link("https://github.com/vodobryshkin/db-guides")[репозитории])!
]

= Источники
+ Материалы курса "Базы данных". _Лекция 2: создание Базы Данных_.

+ Материалы курса "Базы данных". _Лекция 4: Запросы и SQL_.

+ Eder, L. _Say NO to Venn Diagrams When Explaining JOINs_. #link("https://blog.jooq.org/say-no-to-venn-diagrams-when-explaining-joins/")[Статья].