#import "@preview/primeone:1.0.0": *
#import "@preview/fletcher:0.5.8" as cf
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-venn:0.2.0"

// Исходные строки.
#let join-students = (
  (tag: "S1", key: 1),
  (tag: "S3", key: 3),
  (tag: "S4", key: 4),
)

#let join-attempts = (
  (tag: "A1", key: 1),
  (tag: "A2", key: 1),
  (tag: "A7", key: 4),
  (tag: "A9", key: 5),
)

#let join-colors = (
  rgb("#BFE3D2"),
  rgb("#FFE3A3"),
  rgb("#D9CDF0"),
  rgb("#F5C7AC"),
  rgb("#BFDDF2"),
)

// Одна строка.
#let join-chip(row) = {
  let label = if row == none {
    text(size: 6pt)[NULL]
  } else {
    [
      #text(size: 7pt)[#row.tag]
      #linebreak()
      #text(size: 5.5pt)[id = #row.key]
    ]
  }

  rect(
    width: 25mm,
    height: 9mm,
    inset: 0pt,
    fill: white,
    stroke: 0.5pt + black,
    radius: 0pt,
  )[
    #set text(fill: black, weight: "regular")
    #set par(first-line-indent: 0pt, leading: 0pt)

    #align(center + horizon)[#label]
  ]
}

// Две строки, образующие пару.
#let join-pair(lhs, rhs) = grid(
  columns: (auto, auto),
  column-gutter: 0pt,
  align: center + horizon,
  join-chip(lhs),
  join-chip(rhs),
)
// Вертикальный список исходных строк.
#let join-source(title, rows) = stack(
  dir: ttb,
  spacing: 2mm,
  text(size: 8pt, weight: "bold", title),
  ..rows.map(join-chip),
)

// Формирование результата соединения.
// Условие: lhs.key == rhs.key.
#let join-matches(lhs, rhs, kind) = {
  let pairs = ()

  for l in lhs {
    let matches = rhs.filter(
      r => kind == "cross" or l.key == r.key
    )

    for r in matches {
      pairs.push((l, r))
    }

    if matches.len() == 0 and (
      kind == "left" or kind == "full"
    ) {
      pairs.push((l, none))
    }
  }

  if kind == "right" or kind == "full" {
    for r in rhs {
      let matches = lhs.filter(l => l.key == r.key)

      if matches.len() == 0 {
        pairs.push((none, r))
      }
    }
  }

  pairs
}

// Готовая схема.
// kind: "cross", "inner", "left", "right", "full".
#let join-picture(
  kind,
  students: join-students,
  attempts: join-attempts,
) = {
  assert(
    ("cross", "inner", "left", "right", "full").contains(kind),
    message: "Неизвестный вид JOIN",
  )

  let pairs = join-matches(students, attempts, kind)

  let result = if pairs.len() == 0 {
    text(size: 8pt)[Нет строк]
  } else {
    grid(
      columns: 1,
      row-gutter: 2mm,
      align: center + horizon,
      ..pairs.map(pair => join-pair(..pair)),
    )
  }

  block(
    breakable: false,
    above: 4mm,
    below: 4mm,
  )[
    #set par(first-line-indent: 0pt)

    #align(center)[
      #text(size: 10pt, weight: "bold")[#upper(kind) JOIN]

      #v(3mm)

      #grid(
        columns: (auto, 6mm, auto),
        column-gutter: 3mm,
        align: center + horizon,

        grid(
          columns: (auto, auto),
          column-gutter: 4mm,
          align: center + top,
          join-source("students", students),
          join-source("attempts", attempts),
        ),

        text(size: 18pt)[→],

        stack(
          dir: ttb,
          spacing: 2mm,
          text(size: 8pt, weight: "bold")[Результат],
          result,
        ),
      )
    ]
  ]
}

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
  date: "Версия 0.1.1",
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

== Исходные данные

Содержимое таблиц после выполнения `init.sql`.
Внешние ключи содержат идентификаторы соответствующих записей.

#block(breakable: false)[
  #set text(size: 10pt)
  #set par(leading: 0.3em, spacing: 3pt)

  #show table: set block(above: 4pt, below: 4pt)

  #show table: set table(
    inset: (x: 3pt, y: 2.5pt),
    stroke: 0.4pt + rgb("#cbd5e1"),
    fill: (_, y) => if y == 0 {
      rgb("#eef2f6")
    } else {
      none
    },
  )

  #show table.cell.where(y: 0): set table.cell(
    inset: (x: 3pt, y: 2.5pt),
  )

  #grid(
    columns: (1.7fr, 1fr),
    gutter: 10pt,
    [
      *students*

      #table(
        columns: (auto, auto, 1fr, auto, auto),
        table.header(
          [student_id],
          [name],
          [surname],
          [birthday],
          [group_id],
        ),
        [1], [Иван],    [Иванов],    [2006-01-01], [1],
        [2], [Петр],    [Петров],    [2006-02-01], [1],
        [3], [Федор],   [Федоров],   [2006-03-01], [1],
        [4], [Дарья],   [Алексеева], [2006-04-01], [2],
        [5], [Елена],   [Волкова],   [2006-05-01], [2],
        [6], [Егор],    [Морозов],   [2006-06-01], [2],
        [7], [Анна],    [Смирнова],  [2006-07-01], [1],
        [8], [Дмитрий], [Дмитриев],  [2006-08-01], [2],
      )

      #v(6pt)
      *groups*

      #table(
        columns: (auto, auto, 1fr, auto),
        table.header(
          [group_id], [code], [title], [admin_id],
        ),
        [1], [P3221], [Первая группа], [1],
        [2], [P3222], [Вторая группа], [4],
        [3], [P3223], [Третья группа], [NULL],
      )
    ],
    [
      *teachers*

      #table(
        columns: (auto, auto, 1fr),
        table.header(
          [teacher_id], [name], [surname],
        ),
        [1], [Ольга], [Лебедева],
        [2], [Павел], [Зайцев],
        [3], [Мария], [Новикова],
      )

      #v(6pt)
      *exams*

      #table(
        columns: (auto, 2fr, auto),
        table.header(
          [exam_id], [title], [duration],
        ),
        [1], [Базы данных],            [01:30:00],
        [2], [Мат. анализ], [02:00:00],
        [3], [Програм- \ мирование],      [01:30:00],
        [4], [Операционные системы],  [01:00:00],
      )
    ],
  )

  #v(6pt)
  *attempts*

  #table(
    columns: (auto, auto, auto, auto, 1fr, auto),
    table.header(
      [attempt_id],
      [student_id],
      [exam_id],
      [teacher_id],
      [date_of_attempt],
      [final_grade],
    ),
    [1],  [1], [1], [1], [2026-09-01], [2],
    [2],  [1], [1], [1], [2026-09-08], [4],
    [3],  [1], [1], [1], [2026-09-15], [5],
    [4],  [1], [2], [2], [2026-09-02], [4],
    [5],  [1], [2], [2], [2026-09-09], [4],
    [6],  [2], [1], [1], [2026-09-01], [2],
    [7],  [4], [1], [1], [2026-09-01], [5],
    [8],  [4], [2], [2], [2026-09-02], [5],
    [9],  [5], [1], [1], [2026-09-01], [3],
    [10], [7], [2], [2], [2026-09-02], [4],
    [11], [8], [3], [1], [2026-09-03], [2],
    [12], [8], [3], [1], [2026-09-10], [5],
    [13], [8], [1], [1], [2026-09-04], [4],
  )
]

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
```

== Операции над множествами

Рассмотрим два множества:
- $A$ -- идентификаторы студентов, у которых есть попытки сдачи экзамена по Базам данных: `1, 2, 4, 5, 8`

- $B$ -- идентификаторы студентов, у которых есть попытки сдачи экзамена Математическуму анализу: `1, 4, 7`

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
```

=== А что с повторениями?

По умолчанию UNION, INTERSECT и EXCEPT удаляют повторения. У каждой операции есть вариант с ALL, который учитывает количество одинаковых строк.

Например, идентификатор Ивана Иванова встречается три раза среди попыток по базам данных и два раза среди попыток по математическому анализу:
- UNION ALL оставит все пять вхождений.

- INTERSECT ALL оставит два вхождения (минимум).

- EXCEPT ALL оставит одно вхождение -- разность, но не меньше нуля.

#pagebreak()

= JOIN

Может показаться, что раз SQL уже умеет объединять, пересекать и вычитать множества, то операции соединений не нужны. На самом деле есть два принципиальных различия между JOIN и операциями с множествами.
- UNION, INTERSECT и EXCEPT -- операции над множествами, из которых состоят результаты запросов. Они определяют, какие строки из двух результатов нужно сохранить.

- JOIN -- операции над таблицами. Они решают задачи сопоставления строк таблиц по условию и формирования их сочетаний. При этом строки могут иметь разную структуру, а результат содержать данные с обеих сторон.

#messages(severity: "info")[
  Это одна из основных задач при работе с реляционной БД. Связанные сведения хранятся в разных таблицах, что позволяет уменьшать дублирование данных и поддерживать их согласованность. Соединения позволяют получать эти сведения вместе, в форме, необходимой для конкретного запроса.
]

== Визуализация JOIN

JOIN часто визуализируют с помощью диаграмм Эйлера-Венна, которые на первый взгляд кажутся наглядными, хотя изначально предназначены для изображения множеств и отношений между ними, а не таблиц.

#messages(severity: "warning")[
  Не используйте диаграммы Эйлера-Венна для объяснения JOIN, потому что они могут сформировать неправильное представление о работе соединений.
]

Есть несколько причин:
- Диаграммы показывают принадлежность элементов множествам, но не показывают условие сопоставления строк и количество получившихся сочетаний.

- Закрашенное пересечение кругов создаёт впечатление, что JOIN ищет одинаковые строки двух таблиц. На самом деле строки могут различаться и сопоставляться только по указанному условию.

- Некоторые соединения такая визуализация вообще не объясняет: например, CROSS JOIN формирует все возможные пары строк, а пересечение кругов этого не показывает.

=== Правильный выбор визуализации
Вместо этого лучше визуализировать JOIN'ы именно так, как выглядят их результаты.

Рассмотрим пример визуализации на LEFT JOIN:

#join-picture("left")

== Виды JOIN

=== CROSS JOIN -- перекрёстное соединение

Формирует все возможные пары строк двух таблиц. Условие соединения не задаётся.

Получим все сочетания групп и преподавателей:

```sql
SELECT g.group_id, t.teacher_id
  FROM groups AS g
       CROSS JOIN teachers AS t
 ORDER BY g.group_id, t.teacher_id;
```

Результат:

```text
 group_id | teacher_id
----------+------------
        1 |          1
        1 |          2
        1 |          3
        2 |          1
        2 |          2
        2 |          3
        3 |          1
        3 |          2
        3 |          3
```

=== INNER JOIN -- внутреннее соединение

Возвращает только пары строк, удовлетворяющие условию соединения.

Получим группы, у которых назначен староста:

```sql
SELECT g.group_id, g.code, s.student_id, s.name
  FROM groups AS g
       INNER JOIN students AS s
       ON g.admin_id = s.student_id
 ORDER BY g.group_id;
```

Результат:

```text
 group_id | code  | student_id | name
----------+-------+------------+-------
        1 | P3221 |          1 | Иван
        2 | P3222 |          4 | Дарья
```

#message(severity: "info")[
Слово `INNER` можно опустить, обычный `JOIN` означает `INNER JOIN`.
]

=== LEFT JOIN -- левое внешнее соединение

Возвращает подходящие пары и сохраняет строки левой таблицы без соответствий. Для них столбцы правой стороны заполняются `NULL`.

Получим все группы, включая группы без старост:

```sql
SELECT g.group_id, g.code, s.student_id, s.name
  FROM groups AS g
       LEFT JOIN students AS s
       ON g.admin_id = s.student_id
 ORDER BY g.group_id;
```

Результат:

```text
 group_id | code  | student_id | name
----------+-------+------------+-------
        1 | P3221 |          1 | Иван
        2 | P3222 |          4 | Дарья
        3 | P3223 |            |

```

=== RIGHT JOIN -- правое внешнее соединение

Возвращает подходящие пары и сохраняет строки правой таблицы без соответствий. Для них столбцы левой стороны заполняются `NULL`.

Получим всех студентов и сведения о группах, в которых они являются старостами:

```sql
SELECT g.group_id, g.code, s.student_id, s.name
  FROM groups AS g
       RIGHT JOIN students AS s
       ON g.admin_id = s.student_id
 ORDER BY g.group_id NULLS LAST, s.student_id;
```

Результат:

```text
 group_id | code  | student_id |  name
----------+-------+------------+---------
        1 | P3221 |          1 | Иван
        2 | P3222 |          4 | Дарья
          |       |          2 | Петр
          |       |          3 | Федор
          |       |          5 | Елена
          |       |          6 | Егор
          |       |          7 | Анна
          |       |          8 | Дмитрий
```

#messages(severity: "info")[
  Если задачу можно выразить и через `LEFT JOIN`, и через `RIGHT JOIN`, для читаемости удобно придерживаться `LEFT JOIN`: слева располагается таблица, все строки которой нужно сохранить, а справа -- дополнительные сведения. Такой порядок проще читать последовательно, слева направо.
]

=== FULL JOIN -- полное внешнее соединение

Возвращает подходящие пары и сохраняет строки без соответствий с обеих сторон. Столбцы отсутствующей стороны заполняются `NULL`.

```sql
SELECT g.group_id, g.code, s.student_id, s.name
  FROM groups AS g
       FULL JOIN students AS s
       ON g.admin_id = s.student_id
 ORDER BY g.group_id NULLS LAST, s.student_id;
```

Результат:

```text
 group_id | code  | student_id |  name
----------+-------+------------+---------
        1 | P3221 |          1 | Иван
        2 | P3222 |          4 | Дарья
        3 | P3223 |            |
          |       |          2 | Петр
          |       |          3 | Федор
          |       |          5 | Елена
          |       |          6 | Егор
          |       |          7 | Анна
          |       |          8 | Дмитрий
```

#messages(severity: "info")[
  `LEFT JOIN`, `RIGHT JOINT`, `FULL JOIN`, еще часто назвавают `OUTER` JOINS, потому что такое соединение сохраняет не только подходящие пары, но и строки без соответствий с одной или обеих сторон. Слово необязательно, поскольку `LEFT`, `RIGHT` и `FULL` уже обозначают внешнее соединение. Например, `LEFT JOIN` и `LEFT OUTER JOIN` равнозначны.
]

=== NATURAL JOIN -- естественное соединение

Автоматически задаёт условие равенства по всем одноимённым столбцам двух таблиц. Общие столбцы представлены в результате по одному разу.

```sql
SELECT group_id, code, student_id, name
  FROM groups
       NATURAL JOIN students
 ORDER BY group_id, student_id;
```

Результат:

```text
 group_id | code  | student_id |  name
----------+-------+------------+---------
        1 | P3221 |          1 | Иван
        1 | P3221 |          2 | Петр
        1 | P3221 |          3 | Федор
        1 | P3221 |          7 | Анна
        2 | P3222 |          4 | Дарья
        2 | P3222 |          5 | Елена
        2 | P3222 |          6 | Егор
        2 | P3222 |          8 | Дмитрий
```

#messages(severity: "info")[
Без уточнения `NATURAL JOIN` означает `NATURAL INNER JOIN`. Также допустимы `NATURAL LEFT JOIN`, `NATURAL RIGHT JOIN` и `NATURAL FULL JOIN`.
]
#messages(severity: "warning")[
  `NATURAL JOIN` учитывает все одноимённые столбцы, а не только ключи. Добавление нового одноимённого столбца может изменить условие соединения. Явные `ON` или `USING` позволяют избежать такой зависимости.
]

= NULL
`NULL` -- специальное значение-маркер, обозначающее отсутствие значения. Оно обрабатывается по особым правилам и может использоваться в столбцах разных типов.

Для проверки используют `IS NULL` и `IS NOT NULL`. Для примера, найдём группы без старосты:

```sql
SELECT group_id, code
  FROM groups
 WHERE admin_id IS NULL;
```

Результат:

```text
 group_id | code
----------+-------
        3 | P3223
```

== Трёхзначная логика

В PostgreSQL используется трёхзначная логика, поэтому работа с условиями немного отличается от привычной классической логики.
В классической логике у высказывания два значения: истина (`TRUE`) и ложь (`FALSE`). В SQL появляется третье -- неизвестно (`UNKNOWN`), которое представляется как `NULL` логического типа.

#message(severity: "info")[
  Если значение нам неизвестно, то мы не можем определить, истинно сравнение или ложно. Например, неизвестное число может быть равно 5, а может отличаться от него. Поэтому результат `NULL = 5` -- UNKNOWN ("неизвестно").

  Отрицание не устраняет неопределённость: если мы не знаем, равно ли число 5, то мы также не знаем, отличается ли оно от 5. Поэтому `NULL <> 5` тоже даёт UNKNOWN.
]

Для операций с NULL можно представить следующую таблицу истинности:
#table(
  columns: (auto, auto, 1fr),
  table.header(
    [*Выражение*], [*Результат*], [*Пояснение*],
  ),

  [`TRUE AND NULL`], [`NULL`],
  [Для истинности AND нужны два истинных операнда, а второй неизвестен.],

  [`FALSE AND NULL`], [`FALSE`],
  [Одного ложного операнда достаточно, чтобы AND был ложным.],

  [`NULL AND NULL`], [`NULL`],
  [Оба операнда неизвестны, поэтому результат так же неизвестен.],

  [`TRUE OR NULL`], [`TRUE`],
  [Одного истинного операнда достаточно, чтобы OR был истинным.],

  [`FALSE OR NULL`], [`NULL`],
  [Первый операнд ложный, поэтому результат зависит от неизвестного второго операнда.],

  [`NULL OR NULL`], [`NULL`],
  [Неизвестно, является ли истиной хотя бы одно из операндов.],

  [`NOT NULL`], [`NULL`],
  [Отрицание неизвестного операнда тоже неизвестно.],
)

#messages(severity: "warning")[
  Из-за описанных особенностей, не используйте `= NULL` и `<> NULL` для проверки отсутствующего значения.
  Обычное сравнение с NULL даёт неизвестный результат, даже при сравнении NULL с самим собой.
]

Если нужно сравнить два значения, среди которых могут быть `NULL`, используют `IS DISTINCT FROM` и `IS NOT DISTINCT FROM`, которые для обычных значений они работают как `<>` и `=`, но при сравнении двух `NULL` считают их неразличимыми:

```sql
SELECT NULL IS DISTINCT FROM NULL;     -- FALSE
SELECT NULL IS NOT DISTINCT FROM NULL; -- TRUE
SELECT 1 IS DISTINCT FROM NULL;        -- TRUE
```

=== Ловушка NOT IN

Попробуем найти студентов, которые не являются старостами:

```sql
SELECT student_id
  FROM students
 WHERE student_id NOT IN (
       SELECT admin_id FROM groups
 );
```

Запрос не вернёт строк. Подзапрос содержит `1`, `4` и `NULL`. Для старост условие ложно, а для остальных результат неизвестен, т.к. нельзя подтвердить отличие от неизвестного значения.

Для этой задачи можно использовать `NOT EXISTS`:

```sql
SELECT s.student_id
  FROM students AS s
 WHERE NOT EXISTS (
       SELECT 1
         FROM groups AS g
        WHERE g.admin_id = s.student_id
 )
 ORDER BY s.student_id;
```

Результат:
```text
 student_id
------------
          2
          3
          5
          6
          7
          8
```

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

+ PostgreSQL 18. Combining Queries (UNION, INTERSECT, EXCEPT). #underline(link("https://www.postgresql.org/docs/18/queries-union.html")[Официальная документация]).

+ PostgreSQL 18. Table Expressions. Виды соединений, условия ON и USING, NATURAL JOIN. #underline(link("https://www.postgresql.org/docs/18/queries-table-expressions.html")[Официальная документация]).

+ PostgreSQL 18. Functions and Operators. Разделы #underline(link("https://www.postgresql.org/docs/18/functions-logical.html")[Logical Operators]) и #underline(link("https://www.postgresql.org/docs/18/functions-comparison.html")[Comparison Functions and Operators]): трёхзначная логика и сравнения с NULL.