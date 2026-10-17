#import "@preview/unofficial-sorbonne-presentation:0.3.1": *

#let code-ink = rgb("#334A52")
#let code-muted = rgb("#5F6F75")

#set raw(
  theme: "static/eo.tmTheme",
  tab-size: 2,
)

#show raw.where(block: true): set text(
  fill: code-ink,
  font: "DejaVu Sans Mono",
)

#show raw.where(block: false): set text(
  fill: code-muted,
  size: 0.9em,
  font: "DejaVu Sans Mono",
)

#show: template.with(
  title: [Как выбирать типы данных в PostgreSQL],
  short-title: [Типы данных PostgreSQL],
  subtitle: [Встроенные и пользовательские типы, паттерны использования],
  author: [Владимир Добрышкин],
  short-author: [Добрышкин В. А.],
  affiliation: [],
  faculty: "univ",
  date: "20.10.2026",
  show-outline: false,
  progress-bar: "bottom",
  logo-slide: image("./images/logo/itmo1.png"),
  logo-transition: image("./images/logo/itmo2.png"),
  dark-mode: false
)

#slide(title: [Мотивация])[
    \
    #align(center)[#text(size: 44pt)[*Улучшить навык моделирования предметной области, осознанно выбирая типы данных.*]]
]

#slide(title: text()[План доклада])[
  #grid(
    columns: (3fr, 3fr),
    gutter: 0.8cm,

    [
      + Модель данных PostgreSQL.

      + Пользовательские типы данных.

      + Паттерны использования различных типов данных.
    ],

    [
        #image("images/Postgresql_elephant.svg.webp", width: 70%)
    ],
  )
]

= Модель данных PostgreSQL

#slide(title: text()[Что такое модель данных?])[
  #grid(
    columns: (3fr, 2fr),
    gutter: 0.8cm,

    [
      Классическое определение было дано Эдгаром Коддом (_Edgar F. Codd_) в 1980 году в статье _#link("http://courses.washington.edu/geog482/resource/Codd_1981_Data_Model.pdf")[Data Models in Database Management]_.

      Комбинация трёх компонентов:
      + Набор типов структур данных.
      + Набор операций, которые можно применять к экземплярам этих типов данных.
      + Набор общих правил целостности.
    ],

    [
        #figure(
                image("images/Edgar-Kodd.jpg", width: 78%),
                caption: text(size: 0.6em)[Эдгар Кодд (1923-2003), автор реляционной модели данных],
                supplement: none
        )
    ],
  )
]

#slide(title: text()[Простыми словами])[
    #themed-block(title: [Определение], [
        Модель данных -- набор правил, которые описывают, как устроены данные, что с ними можно делать и какие правила они должны соблюдать (например, какие значения нельзя повторять и на какие записи можно ссылаться).
    ])
]

#slide(title: text()[Примеры моделей данных])[
    - *Реляционная модель* -- данные хранятся в виде таблиц, которые могут ссылаться друг на друга.

    - *Объектно-ориентированная модель* -- данные хранятся в виде объектов, которые могут наследовать свойства и методы друг от друга.

    - *Объектно-реляционная модель* -- реляционная модель, расширенная пользовательскими типами, операторами, процедурами и наследованием.

    - *Модель "ключ-значение"* -- данные хранятся в виде пар "ключ-значение", где ключи уникальны, а значения могут быть любыми.
]

#focus-slide([А какая модель данных в PostgreSQL?])

#slide(title: text()[Примеры моделей данных])[
    - #muted[*Реляционная модель* -- данные хранятся в виде таблиц, которые могут ссылаться друг на друга.]

    - #muted[*Объектно-ориентированная модель* -- данные хранятся в виде объектов, которые могут наследовать свойства и методы друг от друга.]

    - #alert[*Объектно-реляционная модель* -- реляционная модель, расширенная пользовательскими типами, операторами, процедурами и наследованием.]

    - #muted[*Модель "ключ-значение"* -- данные хранятся в виде пар "ключ-значение", где ключи уникальны, а значения могут быть любыми.]
]

#slide(title: [Объектно-реляционная модель])[
  #grid(
    columns: (3fr, 2fr),
    gutter: 0.8cm,
    align: horizon,

    [
      #set text(lang: "en")

      #quote(
        block: true,
        quotes: true,
        attribution: text(size: 0.8em)[
          Michael Stonebraker\
          #link("https://dsf.berkeley.edu/papers/Informix/www.informix.com/informix/corpinfo/zines/whitpprs/illuswp/wave.htm")[
            _Object-Relational DBMS -- The Next Wave_
          ]
        ],
      )[#text(size: 1.25em)[
        In essence they are a marriage of the SQL
        from the relational world and the
        modeling primitives from the object world.
      ]]
    ],

    [
      #figure(
        image("images/Michael-Stonebraker.jpg", width: 78%),
        caption: text(size: 0.6em)[
          Майкл Стоунбрейкер (род. 1943), создатель проекта POSTGRES
        ],
        supplement: none,
      )
    ],
  )
]

#slide(title: [Признаки объектно-реляционности у PostgreSQL])[
    #set text(size: 1.2em)
    - #alert[Пользовательские типы данных (```sql ENUM```, ```sql DOMAIN``` и т.д.).]

    - #muted[Собственные функции и операторы для пользовательских типов.]

    - #muted[Механизм перегрузки функций.]

    - #muted[Механизм наследования с помощью оператора ```sql INHERITS```.]
]

= Пользовательские типы данных
#slide(title: text()[Встроенные типы данных])[
    - Целочисленные типы данных: ```sql SMALLINT```, ```sql INTEGER```, ```sql BIGINT```.

    - Логический тип данных: ```sql BOOLEAN```.

    - Числа с плавающей запятой: ```sql REAL```, ```sql DOUBLE PRECISION```.

    - Символьные строки: ```sql CHAR```, ```sql VARCHAR```, ```sql TEXT```.

    - Дата и время: ```sql DATE```, ```sql TIME```, ```sql TIMESTAMP```, ```sql TIMESTAMP WITH TIME ZONE```.

    - Куча других типов данных, включая массивы, JSON, XML, UUID и т.д.
]

#focus-slide([Зачем тогда нужны пользовательские типы данных?])

#slide(title: text()[Предметная область: таск-трекер])[
  #align(center)[
    #block(width: 75%)[
      #algorithm-box(title:[Таблица задач], [
        #text()[
          ```sql
CREATE TABLE tasks (
    task_id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    priority TEXT NOT NULL -- низкий, средний, высокий
);

INSERT INTO tasks (title, priority) VALUES
    ('Выучить теорию на лабу', 'low'),
    ('Сдать первую лабу', 'medium'),
    ('Подготовиться к экзамену', 'high');
          ```
        ]
      ])
    ]
  ]
]

#slide(title: text()[Аномалия вставки])[
  #align(center)[
    #block(width: 75%)[
      #algorithm-box(title:[Вставка "левых" значений], [
        #text()[
          ```sql
INSERT INTO tasks (title, priority) VALUES
    ('Начать делать вторую лабу', 'meedium'),
    ('Выучить теорию на вторую лабу', 'extra-high'),
    ('Сходить на английский', 'LOW')
          ```
        ]
      ])
    ]
  ]
]

#slide(title: text()[Одно из возможных решений])[
  #align(center)[
    #block(width: 75%)[
      #algorithm-box(title:[Использование CHECK], [
        #text()[
          ```sql
CREATE TABLE tasks (
    task_id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    priority TEXT NOT NULL (СHECK priority IN ('low', 'medium', 'high'))
);
          ```
        ]
      ])
    ]
  ]
]

#slide(title: [Проблема 1: одна проверка в трёх таблицах])[
  #set text(size: 0.82em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.3cm,

    [
      #algorithm-box(title: [Задачи], [
        ```sql
CREATE TABLE tasks (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  priority TEXT NOT NULL
    CHECK (priority IN (
      'low', 'medium',
      'high'
    ))
);
        ```
      ])
    ],

    [
      #algorithm-box(title: [Цели], [
        ```sql
CREATE TABLE goals (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  target_date DATE,
  priority TEXT NOT NULL
    CHECK (priority IN (
      'low', 'medium',
      'high'
    ))
);
        ```
      ])
    ],

    [
      #algorithm-box(title: [События], [
        ```sql
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  starts_at TIMESTAMPTZ,
  location TEXT,
  priority TEXT NOT NULL
    CHECK (priority IN (
      'low', 'medium',
      'high'
    ))
);
        ```
      ])
    ],
  )
]

#slide(title: [Проблема 2: добавление значения в трёх местах])[
  #set text(size: 0.82em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.3cm,

    [
      #algorithm-box(title: [Задачи], [
        ```sql
ALTER TABLE tasks
  DROP CONSTRAINT
    tasks_priority_check,
  ADD CHECK (
    priority IN (
      'low', 'medium',
      'high', 'urgent'
    )
  );
        ```
      ])
    ],

    [
      #algorithm-box(title: [Цели], [
        ```sql
ALTER TABLE goals
  DROP CONSTRAINT
    goals_priority_check,
  ADD CHECK (
    priority IN (
      'low', 'medium',
      'high', 'urgent'
    )
  );
        ```
      ])
    ],

    [
      #algorithm-box(title: [События], [
        ```sql
ALTER TABLE events
  DROP CONSTRAINT
    events_priority_check,
  ADD CHECK (
    priority IN (
      'low', 'medium',
      'high', 'urgent'
    )
  );
        ```
      ])
    ],
  )
]

#slide(title: [Проблема 3: CHECK не задаёт порядок приоритетов])[
  #set text(size: 0.82em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.3cm,

    [
      #algorithm-box(title: [Сортировка по правилам строк], [
        ```sql
SELECT title, priority
FROM tasks
ORDER BY priority DESC;

-- Названия приоритетов
-- сравниваются как строки.
        ```
      ])
    ],

    [
      #algorithm-box(title: [Порядок важности задаём вручную], [
        ```sql
SELECT title, priority
FROM tasks
ORDER BY CASE priority
  WHEN 'urgent' THEN 4
  WHEN 'high'   THEN 3
  WHEN 'medium' THEN 2
  WHEN 'low'    THEN 1
END DESC;
        ```
      ])
    ],
  )
]

#focus-slide([Решение: пользовательский тип данных c помощью ENUM])

#slide(title: [ENUM])[
  *ENUM* -- тип данных с заранее заданным набором допустимых значений.

  Поддержка enum есть в большинстве языков программирования:

  #v(0.4cm)

  #set text(size: 0.82em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.3cm,

    [
      #algorithm-box(title: [Python], [
        ```python
from enum import Enum

class Priority(Enum):
  LOW = "low"
  MEDIUM = "medium"
  HIGH = "high"
        ```
      ])
    ],

    [
      #algorithm-box(title: [Java], [
        ```java
enum Priority {
  LOW,
  MEDIUM,
  HIGH
}
        ```
      ])
    ],

    [
      #algorithm-box(title: [C++], [
        ```cpp
enum class Priority {
  LOW,
  MEDIUM,
  HIGH
};
        ```
      ])
    ],
  )
]

#slide(title: text()[Пример использования ENUM])[
  #align(center)[
    #block(width: 75%)[
      #algorithm-box(title:[Сущность tasks], [
        #text()[
          ```sql
CREATE TYPE PRIORITY AS ENUM (
    'low',
    'medium',
    'high'
);

CREATE TABLE tasks (
    task_id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    task_priority PRIORITY NOT NULL
);
          ```
        ]
      ])
    ]
  ]
]

#slide(title: [Добавляем значение в одном месте])[
  #set text(size: 0.82em)

  #grid(
    columns: (1fr, 1.5fr),
    gutter: 0.3cm,

    [
      #algorithm-box(title: [Изменяем общий тип], [
        ```sql
ALTER TYPE PRIORITY
  ADD VALUE 'urgent'
  AFTER 'high';
        ```
      ])
    ],

    [
      #algorithm-box(title: [Значение доступно во всех таблицах], [
        ```sql
INSERT INTO tasks(title, task_priority) VALUES
    ('Задача', 'urgent');

INSERT INTO goals(title, goal_priority) VALUES
    ('Цель', 'urgent');

INSERT INTO events(title, event_priority) VALUES
    ('Событие', 'urgent');
        ```
      ])
    ],
  )
]

#slide(title: [Cортировка по порядку значений ENUM])[
  #set text(size: 0.82em)

  #grid(
    columns: (2fr, 1.8fr, 1.5fr),
    gutter: 0.3cm,

    [
      #algorithm-box(title: [Порядок значений типа], [
        ```sql
CREATE TYPE PRIORITY AS ENUM (
  'low',
  'medium',
  'high',
  'urgent'
);
        ```
      ])
    ],

    [
      #algorithm-box(title: [Запрос], [
        ```sql
SELECT task_priority
FROM tasks
ORDER BY
  task_priority DESC;
        ```
      ])
    ],

    [
      #algorithm-box(title: [Результат], [
        ```text
task_priority
-------------
urgent
high
medium
low
        ```
      ])
    ],
  )
]

/*
#slide(title: [Плюсы и минусы ENUM])[
  #set text(size: 0.9em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.4cm,

    [
      #themed-block(title: [Плюсы], [
        - СУБД не даст записать значение, которого нет в списке.

        - Можно переиспользовать один тип в нескольких таблицах.

        - Легко добавлять новые значения.

        - Значения сортируются в заданном нами порядке.
      ])
    ],

    [
      #themed-block(title: [Минусы], [
        - Чтобы удалить значение или поменять порядок существующих, придётся пересоздать тип.

        - Есть проблемы с поддержкой ENUM в некоторых ORM (например в Hibernate).
      ])
    ],
  )
]
*/

#slide(title: [Почтовый индекс через CHECK])[
  #align(center)[
    #block(width: 80%)[
      #algorithm-box(title: [Таблица адресов], [
        ```sql
CREATE TABLE addresses (
  id BIGSERIAL PRIMARY KEY,
  city TEXT NOT NULL,
  postal_code TEXT NOT NULL CHECK (postal_code ~ '^[0-9]{6}$')
);
        ```
      ])
    ]
  ]
]

#slide(title: [DOMAIN])[
  *DOMAIN* -- пользовательский тип на основе существующего типа, которому можно задать ограничения на допустимые значения.

  #v(0.4cm)

  #set text(size: 0.82em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.3cm,

    [
      #algorithm-box(title: [Создаём тип для почтового индекса], [
        ```sql
CREATE DOMAIN POSTAL_CODE AS TEXT
CHECK (VALUE ~ '^[0-9]{6}$');
        ```
      ])
    ],

    [
      #algorithm-box(title: [Используем в таблице адресов], [
        ```sql
CREATE TABLE addresses (
  id BIGSERIAL PRIMARY KEY,
  city TEXT NOT NULL,
  postal_code POSTAL_CODE NOT NULL
);
        ```
      ])
    ],
  )
]

#slide(title: [Что решает DOMAIN])[
  - Даём понятию отдельное имя, соответствующее предметной области.

  - Проверку формата описываем в типе, а не в каждом столбце отдельно.

  - Можно переиспользовать один тип в нескольких таблицах.

  - Сохраняем обычные операции исходного типа ```sql TEXT```.
]

#slide(title: [COMPOSITE])[
  #set text(size: 0.82em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.3cm,

    [
      *COMPOSITE* -- составной тип, который объединяет несколько именованных полей в одно значение.

      - У каждого поля есть свой тип.

      - Можно использовать уже созданные
        пользовательские типы.

      - Можно обращаться к отдельным полям
        составного значения.
    ],

    [
      #algorithm-box(title: [Пример: адрес], [
        ```sql
CREATE TYPE ADDRESS AS (
    city TEXT,
    street TEXT,
    postal_code POSTAL_CODE
);

-- Санкт-Петербург
SELECT (ROW('Санкт-Петербург', 'Кроверкский пр-т', '197198')::ADDRESS).city;
        ```
      ])
    ],
  )
]

#slide(title: [Диапазоны значений])[
  #set text(size: 0.82em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 0.3cm,

    [
      - *RANGE* — один диапазон значений. Например, время работы без перерыва.

      - *MULTIRANGE* — несколько непересекающихся диапазонов. Например, время работы с перерывом.
    ],

    [
      #algorithm-box(title: [Пример: время работы], [
        ```sql
CREATE TYPE TIME_RANGE AS RANGE (
  SUBTYPE = TIME
);

SELECT '[09:00,18:00)'::TIME_RANGE;

SELECT '{[09:00,13:00),[14:00,18:00)}'::TIME_MULTIRANGE;
        ```
      ])
    ],
  )
]

#slide(title: [Какие пользовательские типы использовать?])[
  #set text(size: 1.5em)
  \
  #quote(
    block: true,
    quotes: true,
    attribution: text(size: 0.7em)[
      Grant Fritchey,
      #link("https://www.red-gate.com/simple-talk/databases/postgresql/learning-postgresql-with-grant-user-defined-types/")[
        Simple Talk, 2026
      ]
    ],
  )[
    It’s all about figuring out what’s going to work best in a given situation.
  ]
]