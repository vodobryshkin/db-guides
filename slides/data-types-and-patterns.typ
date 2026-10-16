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

      + Пользовательские типы данных ENUM, DOMAIN, COMPOSITE.

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
      Классическое определение было дано Эдгаром Коддом (_Edgar F. Codd_) в 1980 году в статье "Data Models in Database Management".

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
            _Object-Relational DBMS — The Next Wave_
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
