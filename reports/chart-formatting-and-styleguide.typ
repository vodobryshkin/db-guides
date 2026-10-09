#import "@preview/primeone:1.0.0": *
#import "@preview/fletcher:0.5.8" as cf

#show: article.with(
  title: "Как оформлять модели базы данных и SQL-код",
  subtitle: underline(link("https://github.com/vodobryshkin/db-guides")[Репозиторий c докладами]),
  authors: (
    (name: "Владимир Добрышкин", email: link("https://t.me/vodobryshkin")[t.me/vodobryshkin]),
  ),
  date: "Версия 0.1.0",
  abstract: [Данный документ представляет из себя практическую памятку по:
   - Нотациям Чена и Crow’s Foot.
   - Оформлению концептуальной, логической и физической моделей.
   - Правилам именования и стилю SQL-кода.],
  abstract-title: "Аннотация",
  titlepage: true,
  toc: true,
  toc-title: "Содержание",
  toc-depth: 2,
  theme: theme-lara-green
)

= Нотации
#message(severity: "warning")[
Перед тем, как говорить об оформлении моделей, нужно познакомиться с нотациями, в которых эти модели описывают.]
- Для оформления концептуальной модели могут быть использованы нотация Питера Чена или Crow's foot.

- Для оформления логической модели используется Crow's foot.

- Для оформления физической модели используется Crow's foot.

== Нотация Питера Чена
#messages(severity: "info")[
Система графических обозначений для ER-моделей. Она позволяет показать сущности предметной области, их свойства и связи. Питер Чен представил ER-модель и способ её изображения в 1976 году в статье _The Entity-Relationship Model—Toward a Unified View of Data_. Русский перевод можно найти #underline(link("https://citforum.ru/database/classics/chen/")[здесь]).
]

=== Основные компоненты нотации
#let chen-symbol(
  shape,
  label,
  double: false,
  key: false,
  derived: false,
  size: 8pt,
) = {
  let w = 36mm
  let h = if shape == "diamond" { 24mm } else { 18mm }

  let pen = (
    paint: black,
    thickness: 0.7pt,
    dash: if derived { "dashed" } else { "solid" },
  )

  let outline(width, height) = {
    if shape == "rect" {
      rect(
        width: width,
        height: height,
        stroke: pen,
        fill: none,
      )
    } else if shape == "diamond" {
      polygon(
        stroke: pen,
        fill: none,
        (width / 2, 0pt),
        (width, height / 2),
        (width / 2, height),
        (0pt, height / 2),
      )
    } else {
      ellipse(
        width: width,
        height: height,
        stroke: pen,
        fill: none,
      )
    }
  }

  let inner-w = w - 3mm
  let inner-h = if shape == "diamond" {
    h * (inner-w / w)
  } else {
    h - 3mm
  }

  box(width: w, height: h)[
    #place(center + horizon, outline(w, h))

    #if double {
      place(center + horizon, outline(inner-w, inner-h))
    }

    #place(center + horizon)[
      #set text(size: size, hyphenate: false)
      #set par(leading: 1.5pt, first-line-indent: 0pt)

      #align(center)[
        #if key { underline(label) } else { label }
      ]
    ]
  ]
}

#table(
  columns: (1.2fr, 1.3fr, 2fr),
  inset: 8pt,
  align: (
    left + horizon,
    center + horizon,
    left + horizon,
  ),

  table.header(
    [*Компонент*],
    [*Обозначение*],
    [*Описание*],
  ),

  [Сущность],
  chen-symbol("rect", [Сущность]),
  [Тип объектов предметной области, о которых нужно хранить данные.],

  [Связь],
  chen-symbol("diamond", [Связь]),
  [Ассоциация между сущностями. Может соединять две сущности.],

  [Атрибут],
  chen-symbol("ellipse", [Атрибут]),
  [Свойство сущности или связи.]
)

=== Дополнительные компоненты нотации
#table(
  columns: (1.2fr, 1.3fr, 2fr),
  inset: 8pt,
  align: (
    left + horizon,
    center + horizon,
    left + horizon,
  ),

  table.header(
    [*Компонент*],
    [*Обозначение*],
    [*Описание*],
  ),

  [Слабая сущность],
  chen-symbol(
    "rect",
    [Слабая \ сущность],
    double: true,
  ),
  [Для идентификации её экземпляра собственных атрибутов недостаточно: требуется также ключ сущности-владельца.],

  [Идентифицирующая связь],
  chen-symbol(
    "diamond",
    [Идентифицирующая \ связь],
    double: true,
    size: 7pt,
  ),
  [Связь слабой сущности с сущностью-владельцем, участвующая в её идентификации.],

  [Ключевой атрибут],
  chen-symbol(
    "ellipse",
    [Ключевой \ атрибут],
    key: true,
  ),
  [Атрибут, входящий в ключ, который однозначно определяет экземпляр сущности.],

  [Многозначный атрибут],
  chen-symbol(
    "ellipse",
    [Многозначный \ атрибут],
    double: true,
  ),
  [Для одного экземпляра сущности может иметь несколько значений.],

  [Производный атрибут],
  chen-symbol(
    "ellipse",
    [Производный \ атрибут],
    derived: true,
  ),
  [Атрибут, значение которого вычисляется на основе других данных.],
)

#let chen-relation(left-max, right-max, total-a: false, total-b: false) = {
  let pen = 0.7pt + black
  let segment(width) = curve(
    stroke: pen, fill: none,
    curve.move((0pt, 0pt)),
    curve.line((width, 0pt)),
  )
  let node(label) = rect(
    width: 9mm, height: 9mm, inset: 0pt,
    stroke: pen, fill: none,
  )[#align(center + horizon)[#label]]

  box(width: 56mm, height: 17mm)[
    #set text(size: 8pt, hyphenate: false)
    #set par(first-line-indent: 0pt)

    #place(top + left, dx: 0mm, dy: 4mm, node([А]))
    #place(top + left, dx: 47mm, dy: 4mm, node([Б]))

    #place(top + left, dx: 21mm, dy: 2.5mm)[
      #polygon(
        stroke: pen, fill: none,
        (7mm, 0mm), (14mm, 6mm),
        (7mm, 12mm), (0mm, 6mm),
      )
    ]
    #place(top + left, dx: 21mm, dy: 2.5mm)[
      #box(width: 14mm, height: 12mm)[
        #align(center + horizon)[Связь]
      ]
    ]

    #for offset in (if total-a { (-0.6mm, 0.6mm) } else { (0mm,) }) {
      place(top + left, dx: 9mm, dy: 8.5mm + offset,
        segment(if total-a { 12.7mm } else { 12mm }))
    }
    #for offset in (if total-b { (-0.6mm, 0.6mm) } else { (0mm,) }) {
      place(top + left,
        dx: if total-b { 34.3mm } else { 35mm },
        dy: 8.5mm + offset,
        segment(if total-b { 12.7mm } else { 12mm }))
    }

    #place(top + left, dx: 9mm, dy: 2.5mm)[
      #box(width: 12mm, height: 3mm)[#align(center + horizon)[#left-max]]
    ]
    #place(top + left, dx: 35mm, dy: 2.5mm)[
      #box(width: 12mm, height: 3mm)[#align(center + horizon)[#right-max]]
    ]
  ]
}

=== Связи в нотации Чена

Перед рассмотрением обозначений связей определим, что такое
кратность связи и обязательность участия в ней.

#messages(severity: "info", title: "Кратность связи")[
  Параметр, который задаёт допустимое количество экземпляров одного типа сущности, которые могут быть связаны с одним экземпляром другого типа. Она определяется для каждого направления связи.

  Кратность может задаваться минимальным и максимальным значениями: например, 0..1 означает "ноль или один", а 1..M -- "один или несколько". Минимальное значение показывает, обязательно ли участие в связи, а максимальное -- сколько связанных экземпляров допускается.
]

#table(
  columns: (1.2fr, 2.2fr, 2.2fr),
  inset: 8pt,
  align: (left + horizon, center + horizon, left + horizon),

  table.header([*Тип связи*], [*Обозначение*], [*Как читать*]),

  [Один к одному (1:1)],
  chen-relation([1], [1]),
  [Каждому А соответствует не более одного Б, и наоборот. Участие обеих сторон необязательно.],

  [Один ко многим (1:M)],
  chen-relation([1], [M]),
  [Одному А может соответствовать несколько Б. Каждому Б -- не более одного А. Участие обеих сторон необязательно.],

  [Многие ко многим (M:N)],
  chen-relation([M], [N]),
  [Одному А может соответствовать несколько Б, а одному Б -- несколько А. Участие обеих сторон необязательно.],

  [1:M. Обязательное участие А и Б],
  chen-relation([1], [M], total-a: true, total-b: true),
  [Каждому А соответствует не менее одного Б. Каждый Б связан ровно с одним А.],

  [1:M. Обязательно только А],
  chen-relation([1], [M], total-a: true),
  [Каждому А соответствует хотя бы один Б. Каждый Б может быть связан с одним А или не участвовать в связи.],

  [1:M. Обязательно только Б],
  chen-relation([1], [M], total-b: true),
  [Каждый А может быть связан с несколькими Б или не участвовать в связи. Каждый Б связан ровно с одним А.],
)

#messages(severity: "warning")[
  Часто на ER-диаграммах можно встретить использование только первых трёх видов связи. Чтобы схема точнее передавала правила предметной области, рекомендую указывать не только тип связи -- 1:1, 1:M или M:N, -- но и обязательность участия каждой стороны.
]

#let cf-entity(title, attributes: (), width: 36mm) = {
  let cells = ()

  for (key, attribute) in attributes {
    cells.push(text(size: 6.5pt, weight: "bold", key))
    cells.push(attribute)
  }

  let body = if attributes.len() == 0 {
    align(center + horizon)[#title]
  } else {
    block(width: width)[
      #grid(
        columns: (9mm, 1fr),
        inset: 3pt,
        align: left + horizon,
        stroke: none,

        grid.cell(
          colspan: 2,
          stroke: (bottom: 0.7pt + black),
        )[#align(center)[#strong(title)]],

        ..cells,
      )
    ]
  }

  [
    #set text(size: 8pt, fill: black, hyphenate: false)
    #set par(first-line-indent: 0pt, leading: 1pt, spacing: 0pt)

    #cf.diagram(
      node-stroke: 0.7pt + black,
      node-fill: none,

      cf.node(
        (0, 0), body,
        width: width,
        height: if attributes.len() == 0 { 18mm } else { auto },
        inset: 0pt,
        corner-radius: 0pt,
      ),
    )
  ]
}

#let cf-relation(left-end, right-end, compact: false) = {
  let node-size = if compact { 7mm } else { 9mm }

  [
    #set text(size: 8pt, fill: black, hyphenate: false)
    #set par(first-line-indent: 0pt, leading: 1pt, spacing: 0pt)

    #box(
      width: if compact { 36mm } else { 56mm },
      height: 15mm,
    )[
      #align(center + horizon)[
        #cf.diagram(
          spacing: if compact { 16mm } else { 28mm },
          node-stroke: 0.7pt + black,
          edge-stroke: 0.7pt + black,
          node-fill: none,

          cf.node(
            (0, 0), [А],
            name: <cf-a>,
            width: node-size,
            height: node-size,
            inset: 0pt,
            corner-radius: 0pt,
          ),

          cf.node(
            (1, 0), [Б],
            name: <cf-b>,
            width: node-size,
            height: node-size,
            inset: 0pt,
            corner-radius: 0pt,
          ),

          cf.edge(
            <cf-a>, <cf-b>,
            marks: (left-end, right-end),
            label: [Связь],
          ),
        )
      ]
    ]
  ]
}

#let cf-ending(mark) = [
  #set text(size: 8pt, fill: black, hyphenate: false)
  #set par(first-line-indent: 0pt, leading: 1pt, spacing: 0pt)

  #box(width: 36mm, height: 12mm)[
    #align(center + horizon)[
      #cf.diagram(
        spacing: 18mm,
        node-stroke: 0.7pt + black,
        edge-stroke: 0.7pt + black,
        node-fill: none,

        cf.node(
          (1, 0), [Б],
          name: <cf-target>,
          width: 9mm,
          height: 9mm,
          inset: 0pt,
          corner-radius: 0pt,
        ),

        cf.edge(
          (0, 0), <cf-target>,
          marks: (none, mark),
        ),
      )
    ]
  ]
]

== Нотация Crow’s Foot

#messages(severity: "info")[
  Система графических обозначений для ER-моделей. Существуют разные соглашения Crow’s Foot. Здесь используется
  вариант, описанный Терри Халпином в статье #underline(link("https://orm.net/pdf/JCM13.pdf")[
    _Entity Relationship Modeling from an ORM Perspective: Part 3_]).
]

=== Компоненты нотации

#table(
  columns: (1.2fr, 1.3fr, 2fr),
  inset: 8pt,
  align: (
    left + horizon,
    center + horizon,
    left + horizon,
  ),

  table.header(
    [*Компонент*],
    [*Обозначение*],
    [*Описание*],
  ),

  [Сущность],
  cf-entity([Сущность]),
  [Тип объектов предметной области, о которых нужно хранить данные.],

  [Атрибут],
  cf-entity(
    [Сущность],
    attributes: (("", [Атрибут1]), ("", [Атрибут2]), ("", [Атрибут3]), ("", [Атрибут4])),
  ),
  [Свойство сущности, которое записывается внутри её прямоугольника.],

  [Связь],
  cf-relation("1?", "n?", compact: true),
  [Ассоциация между сущностями, изображается именованной линией.],
)

=== Обозначение ключей
#table(
  columns: (1.2fr, 1.3fr, 2fr),
  inset: 8pt,
  align: (
    left + horizon,
    center + horizon,
    left + horizon,
  ),

  table.header(
    [*Компонент*],
    [*Обозначение*],
    [*Описание*],
  ),

  [Первичный ключ (PK)],
  cf-entity(
    [Сущность],
    attributes: (("PK", [Первичный ключ]),),
  ),
  [Атрибут или набор атрибутов, выбранный для однозначной идентификации экземпляра сущности.],

  [Внешний ключ (FK)],
  cf-entity(
    [Сущность],
    attributes: (("FK", [Внешний ключ]),),
  ),
  [Атрибут или набор атрибутов, ссылающийся на ключ другой или этой же сущности.],
)

#message(severity: "info")[
Если ключ составной, метку PK/FK ставят у каждого входящего в него атрибута. Для атрибута, одновременно входящего в первичный и внешний ключи, можно указать "PK, FK".]

=== Окончания связей в Crow's Foot

В каждом окончании два символа задают минимум и максимум. Символ ближе к сущности задаёт максимум, второй -- минимум.

#table(
  columns: (1.2fr, 1.3fr, 2fr),
  inset: 8pt,
  align: (
    left + horizon,
    center + horizon,
    left + horizon,
  ),

  table.header(
    [*Кратность*],
    [*Обозначение*],
    [*Как читать*],
  ),

  [Ноль или один (0..1)],
  cf-ending("1?"),
  [Кружок и черта: ноль или один Б.],

  [Ровно один (1..1)],
  cf-ending("1!"),
  [Две черты: ровно один Б.],

  [Ноль, один или несколько (0..M)],
  cf-ending("n?"),
  [Кружок и лапка: ноль, один или несколько Б.],

  [Один или несколько (1..M)],
  cf-ending("n!"),
  [Черта и лапка: один или несколько Б.],
)

#messages(severity: "warning")[
  Аналогично связям в нотации Чена, чтобы схема правильнее передавала суть предметной области, рекомендуется указывать обязательность участия каждой стороны.
]

#pagebreak()

= Оформление моделей
После того, как мы разобрались с нотациями, можно наконец описать все три вида моделей. Предлагаю сделать это на примере чуть-чуть видоизменённой предметной области про сдачу экзамена из #underline(link("https://se.ifmo.ru/documents/10180/733702/isbd-2021-2.6.pdf/e47a2e01-d445-e017-070f-a300ecdb71a8")[второй лекции]).

=== Описание предметной области
#messages(severity: "warning")[Описанная предметная область не претендует на полноту по атрибутам. Главная цель -- показать, как визуализировать модели.]

Студент (сущность) имеет имя, фамилию и дату рождения (атрибуты) и состоит ровно в одной учебной группе.
Группа (сущность) имеет код, название (атрибуты) и может объединять несколько студентов. Группа может иметь старосту.
Преподаватель (сущность) имеет имя и фамилию (атрибуты), 
экзамен (сущность) -- название и длительность (атрибуты).
Попытка сдачи (сущность) имеет дату и оценку (атрибуты) и связывает одного студента, один экзамен и одного преподавателя.
Студент может повторно сдавать тот же экзамен тому же преподавателю, каждая сдача сохраняется как отдельная попытка.

=== Инструмент для рисования моделей
#messages(severity: "info")[
Одним из лучших инструментов для рисования моделей является платформа #underline(link("https://www.drawio.com/")[drawio]). Она предоставляет графический редактор для различного вида диаграмм с огромными возможностями. Помимо веб-версии, доступна #underline(link("https://github.com/jgraph/drawio-desktop/releases/")[десктопная версия]), а так же #underline(link("https://plugins.jetbrains.com/plugin/15635-diagrams-net-integration")[плагин на IDE от JetBrains]) (Intellij IDEA, Pycharm, etc.).
]

#pagebreak()

== Концептуальная модель
#messages(severity: "info")[Концептуальная модель нужна для описания предметной области: важных для задачи сущностей, их свойств, связей между ними. Эта модель не зависит от деталей реализации. При концептуальном проектировании мы не задумываемся о будущей модели данных, СУБД, прикладных программах, аппаратной платформе и т.д.]

#figure(
    image("images/conceptual_chen.png"),
    supplement: [Изображение],
    caption: [Концептуальная модель в нотации Питера Чена],
)

#figure(
    image("images/conceptual_crow.png"),
    supplement: [Изображение],
    caption: [Концептуальная модель в нотации Crow's foot]
)

#pagebreak()

== Логическая модель
#messages(severity: "info")[Логическая модель предназначена для подготовки структуры данных в выбранной модели (например, реляционной), которую затем можно реализовать в конкретной СУБД. Говоря о реляционном логическом проектировании, мы выделям состав данных, атрибуты, ключи, связи и ограничения, но не делаем это в терминах конкретной СУБД.]

#figure(
    image("images/logical.png"),
    supplement: [Изображение],
    caption: [Логическая модель]
)

#pagebreak()

== Физическая модель
#messages(severity: "info")[Физическая модель описывает, как структура данных будет реализована в конкретной СУБД. При физическом проектировании мы уточняем таблицы и их столбцы, выбираем конкретные типы данных, задаём первичные и внешние ключи, пользовательские ограничения. Цель данного этапа -- подготовить проект базы данных, который можно реализовать средствами выбранной СУБД.]

#figure(
    image("images/physical.png"),
    supplement: [Изображение],
    caption: [Физическая модель]
)

#pagebreak()

= Оформление SQL
#messages(severity: "error")[Не существует единого стандарта по оформлению кода на SQL. Правила оформления кода часто отличаются от коллектива к коллективу.]

#messages(severity: "success")[Но есть много хороших SQL Style Guide'ов. Эмпрически, большая часть правил из этих туториалов совпадают с кастомными правилами оформления.]

Рассмотрим 10 наиболее полезных (IMHO) правил оформления из одного из самых популярных гайдов -- #underline(link("https://www.sqlstyle.guide/ru/")[_Руководство по стилю SQL от Саймона Холливелла_]).

#messages(severity: "warning")[Примеры этого раздела иллюстрируют стиль SQL и используют самостоятельные условные схемы.]

#let sql-examples(bad, good, stacked: false) = [
  #show raw.where(block: true): set text(size: 8pt)

  #grid(
    columns: if stacked { (1fr,) } else { (1fr, 1fr) },
    column-gutter: 0.6em,
    row-gutter: 0.8em,

    messages(severity: "error", title: "Плохой пример")[
      #bad
    ],
    messages(severity: "success", title: "Хороший пример")[
      #good
    ],
  )
]

== Используйте осмысленные названия

По имени объекта должно быть понятно его содержание. Так вам и вашим коллегам не придётся постоянно сверяться со схемой и догадываться, что означают сокращения.

#sql-examples[
  ```sql
  -- Непонятно, что хранят t, n и d.
  SELECT n, d
    FROM t;
  ```
][
  ```sql
  -- Названия раскрывают содержание:
  -- ФИО и даты рождения студентов.
  SELECT full_name, birth_date
    FROM students;
  ```
]

== Используйте snake_case вместо camelCase

Подчёркивания явно разделяют слова и сохраняют эти границы при написании имени строчными буквами. Помимо этого, в PostgreSQL есть дополнительная практическая причина: имена без кавычек приводятся к нижнему регистру. Поэтому при желании сохранить camelCase-названия, вам придется обращаться к ним с двойными кавычками, что неудобно и ухудшает читаемость.

#sql-examples[
  ```sql
  -- Смешанный регистр сохранён.
  -- Кавычки нужны при обращении
  -- к этим столбцам.
  SELECT "fullName", "birthDate"
    FROM students;
  ```
][
  ```sql
  -- Границы слов видны,
  -- кавычки не требуются.
  SELECT full_name, birth_date
    FROM students;
  ```
]

== Не используйте венгерскую нотацию
Префиксы вроде tbl_ и str_ дублируют информацию, видимую из запроса и определений столбцов.

#sql-examples[
  ```sql
  -- Зачем повторять то, что написано типами?
  SELECT str_name, int_group_id
    FROM tbl_students;
  ```
][
  ```sql
  -- Названия отражают смысл.
  SELECT name, group_id
    FROM students;
  ```
]

== Выделяйте ключевые слова регистром
Прописные ключевые слова помогают отличать структуру запроса от названий объектов.

#sql-examples[
  ```sql
  -- Ключевые слова визуально
  -- не выделяются среди имён.
  select full_name
    from students
   where group_id = 10;
  ```
][
  ```sql
  -- Сразу видны выборка,
  -- источник данных и фильтр.
  SELECT full_name
    FROM students
   WHERE group_id = 10;
  ```
]

== Разделяйте запрос на логические части
Переносы строк помогают отдельно увидеть выборку, соединения и фильтры. Условия с `AND` или `OR` на отдельных строках проще проверять и изменять.

#sql-examples[
  ```sql
  -- Части запроса записаны вместе.
  -- Отдельное условие труднее найти.
  SELECT name FROM students
  WHERE group_id = 10 AND active;
  ```
][
  ```sql
  -- Источник данных и каждое
  -- условие находятся отдельно.
  SELECT name
    FROM students
   WHERE group_id = 10
     AND active;
  ```
]

== Используйте пробелы и отступы
Пробелы отделяют имена и выражения друг от друга. Последовательные отступы показывают группировку кода: например, соединение таблиц и относящиеся к нему условия.

#sql-examples[
  ```sql
  -- Запятая и = прижаты к именам.
  -- Соединение не выделено отступом.
  SELECT s.name,g.name
  FROM students AS s
  JOIN groups AS g
  ON s.group_id=g.group_id;
  ```
][
  ```sql
  -- Пробелы разделяют выражения.
  -- JOIN и его условие сгруппированы.
  SELECT s.name, g.name
    FROM students AS s
         JOIN groups AS g
         ON s.group_id = g.group_id;
  ```
]

\
\
\

== Используйте понятные псевдонимы и `AS`
Псевдонимы сокращают длинные обращения, но должны оставаться понятными. Слово `AS` явно обозначает переименование и явно показывает, что оно есть.

#sql-examples(stacked: true)[
  ```sql
  -- q не связано с именем таблицы.
  -- x не объясняет, что вычислено.
  SELECT AVG(q.mark) x
    FROM exam_results q;
  ```
][
  ```sql
  -- er сокращает exam_results.
  -- Результат назван средней оценкой.
  SELECT AVG(er.mark) AS average_mark
    FROM exam_results AS er;
  ```
]

== Оформляйте определения таблиц последовательно

Отдельные строки позволяют быстро сопоставить столбцы,
типы и ограничения. Объявляйте каждый столбец отдельно;
внутри `CREATE TABLE` используйте отступ в четыре пробела.

#sql-examples(stacked: true)[
  ```sql
  -- Два столбца слились в строке.
  -- Нет отступа внутри определения.
  CREATE TABLE students (
  student_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL, birth_date DATE
  );
  ```
][
  ```sql
  -- Каждый столбец легко найти
  -- вместе с его типом и ограничениями.
  CREATE TABLE students (
      student_id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      birth_date DATE
  );
  ```
]

== Записывайте даты в однозначном формате
Используйте формат YYYY-MM-DD: по нему понятно, где год, месяц и день. В PostgreSQL такая запись даты не зависит от порядка компонентов, заданного настройкой DateStyle.

#sql-examples[
  ```sql
  -- MDY: 4 марта.
  -- DMY: 3 апреля.
  -- Настройка меняет смысл записи.
  SELECT DATE '03/04/2005';
  ```
][
  ```sql
  -- Однозначно: 3 апреля 2005 года.
  SELECT DATE '2005-04-03';
  ```
]

== Добавляйте содержательные комментарии
Комментарий полезен, когда объясняет цель запроса или причину неочевидного условия. В это время, пересказ очевидных действий увеличивает объём кода, не помогая понять его назначение.

#sql-examples[
  ```sql
  -- Комментарий пересказывает SELECT,
  -- но не объясняет цель запроса.
  -- Выбираем student_id.
  SELECT student_id
    FROM exam_results
   WHERE mark < 3;
  ```
][
  ```sql
  -- Комментарий объясняет цель:
  -- список студентов на пересдачу.
  SELECT student_id
    FROM exam_results
   WHERE mark < 3;
  ```
]

= Обратная связь
#messages(severity: "error")[Нашли опечатку или ошибку?]

#messages(severity: "warning")[Есть идеи по улучшению материала?]

#messages(severity: "info")[Хотите предложить тему, которой можно будет дополнить доклад?]

#messages(severity: "success")[
Пишите в #underline(link("https://t.me/vodobryshkin")[личные сообщения]) или заведите issue в #underline(link("https://github.com/vodobryshkin/db-guides")[репозитории])!
]

= Источники

+ Чен, П. П.-Ш. _Модель "сущность-связь" — шаг к единому представлению о данных_.
  Перевод М. Р. Когаловского; новая редакция С. Кузнецова, 2009.
  #link("https://citforum.ru/database/classics/chen/")[Русский перевод на CITForum].

+ Halpin, T. _Entity Relationship Modeling from an ORM Perspective: Part 3_.
  #link("https://orm.net/pdf/JCM13.pdf")[Статья].

+ IBM. _What Is Data Modeling?_
  #link("https://www.ibm.com/think/topics/data-modeling")[Статья].

+ Microsoft. _Create a Diagram with Crow's Foot Database Notation_.
  #link("https://support.microsoft.com/en-us/visio/create-a-diagram-with-crow-s-foot-database-notation")[Официальная документация].

+ Holywell, S. _Руководство по стилю SQL_.
  #link("https://www.sqlstyle.guide/ru/")[Русская версия SQL Style Guide].

+ Материалы курса "Базы данных".
  _Лекция 2: создание Базы Данных_.