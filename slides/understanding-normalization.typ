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
  title: [Предметная область и нормализация],
  short-title: [Нормализация],
  subtitle: [Как ограничения предметной области влияют на ключи, зависимости и нормальные формы],
  author: [Владимир Добрышкин],
  short-author: [Добрышкин В. А.],
  affiliation: [],
  faculty: "univ",
  date: "01.12.2026",
  show-outline: false,
  progress-bar: "bottom",
  logo-slide: image("./images/logo/itmo1.png"),
  logo-transition: image("./images/logo/itmo2.png"),
  dark-mode: false
)

#slide(title: [Мотивация])[
    \
    #align(center)[#text(size: 44pt)[*Научиться обосновывать решения при нормализации, опираясь на правила предметной области.*]]
]

#slide(title: text()[План доклада])[
  #grid(
    columns: (3fr, 3fr),
    gutter: 0.8cm,

    [
      + Выбор функциональных зависимостей.

      + 1НФ и атомарность.

      + Смысл требований 2НФ и 3НФ.

      + Проверка декомпозиции на отсутствие потерь.

      + Границы достаточности 3НФ и НФБК.
    ],

    [
        #image("images/normalization/1.png", width: 100%)
    ],
  )
]

= Выбор функциональных зависимостей
#slide(title: [Зачем нужны функциональные зависимости])[
  #grid(
    columns: (3fr, 2fr),
    gutter: 0.8cm,
    align: horizon,

    [

      #quote(
        block: true,
        quotes: true,
        attribution: text(size: 0.8em)[
          Ramez Elmasri and Shamkant B. Navathe\
            _Fundamentals of Database Systems_, 7th ed., § 14.2
        ],
      )[#text(size: 1.25em)[
        The single most important concept in relational schema design
        theory is that of a functional dependency.
      ]]
    ],

    [
      #figure(
        image("images/normalization/fundamentals.jpg", width: 70%),
        supplement: none,
      )
    ],
  )
]

#slide(title: [Функциональная зависимость])[
   #themed-block(title: [Определение], [
        Пусть $X$ и $Y$ -- множества атрибутов отношения.

        Функциональная зависимость $X -> Y$ выполняется, если в каждом допустимом состоянии отношения любые два кортежа, совпадающие по атрибутам $X$, совпадают и по атрибутам $Y$.
   ])
]

#equation-slide(
  $f: X -> Y$,
  title: [Функция в математике],
  definitions: [
    Функция $f$ сопоставляет каждому аргументу $x in X$
    ровно один элемент $f(x) in Y$.
  ],
)

#slide(title: [Функциональная зависимость])[
  #themed-block(title: [Аналогия], [
    У функциональной зависимости $X -> Y$ тот же смысл, что и у математической функции.

    Одинаковому $X$ соответствует одинаковое $Y$. При этом разным значениям $X$ может соответствовать одно и то же $Y$.
  ])
]

#slide(title: [Есть ли здесь такие функциональные зависимости?])[
  #grid(
    columns: (1.5fr, 1fr),
    gutter: 0.8cm,
    align: horizon,
    [
      + $"checkout_branch_id" -> "return_branch_id"$

      + $"return_branch_id" -> "checkout_branch_id"$
    ],

    [
      #figure(
        image("./images/normalization/2.png"),
        caption: text(size: 0.6em)[Таблица из схемы "Выдача книг"],
        supplement: none,
      )
    ],
  )
]

#focus-slide([Функциональные зависимости определяются правилами предметной области.])

#slide(title: [Книгу возвращают в тот же филиал])[
  #themed-block(title: [Доменное правило])[
    Книгу берут и возвращают в один и тот же филиал. По одному можно однозначно определить другой.
  ]

  Из правила следует:
  + $"checkout_branch_id" -> "return_branch_id"$

  + $"return_branch_id" -> "checkout_branch_id"$

]

#slide(title: [За каждым филиалом выдачи закреплён ровно один филиал возврата.])[
  #themed-block(title: [Доменное правило])[
    Книги из филиала А можно вернуть только в филиал Б.
  ]

  Из правила следует:
  + $"checkout_branch_id" -> "return_branch_id"$

  + $"return_branch_id" ↛ "checkout_branch_id"$

]

#slide(title: [Книгу возвращают в любой филиал сети])[
  #themed-block(title: [Доменное правило])[
    Книги из филиала А можно вернуть в разные филиалы. В филиал Б можно вернуть книги из разных филиалов.
  ]

  Из правила следует:
  + $"checkout_branch_id" ↛ "return_branch_id"$

  + $"return_branch_id" ↛ "checkout_branch_id"$
]

= 1НФ и атомарность

#slide(title: [Первая нормальная форма])[
  #themed-block(title: [Определение])[
    Схема отношения находится в первой нормальной форме (1НФ) тогда
    и только тогда, когда домен каждого атрибута содержит только атомарные
    значения, а в каждом кортеже атрибут принимает одно значение
    из своего домена.
  ]
]

#slide(title: [Атомарен ли адрес?])[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.8cm,
    align: horizon,

    [
      В таблице нужно хранить адрес. Была выбрана следующая модель:
      - address VARCHAR(255) NOT NULL
      
      - Формат записи:\
        \<страна>, \<город>, \<улица>, \<дом>\

        Например:\
        Россия, г. Санкт-Петербург, пр-кт Кронверкский, 49
      
    ],

    [
      #figure(
        image("images/normalization/atom.jpg"),
        supplement: none,
      )
    ],
  )
]

#focus-slide([
  Атомарность зависит от того, какие части значения нужны модели как самостоятельные данные.
])


#slide(title: [Адрес площадки в афише])[
  #grid(
    columns: (1.5fr, 1fr),
    gutter: 0.8cm,
    align: horizon,

    [
      Требования:
      + Организатор вводит адрес площадки.

      + Система выводит его целиком в карточке мероприятия и в билете.

      Для этой задачи адрес можно считать атомарным значением. Достаточно одного атрибута address.
    ],

    [
      #figure(
        image("./images/normalization/3.png", width: 100%),
        supplement: none,
      )
    ],
  )
]

#slide(title: [Адрес в службе доставки])[
  #grid(
    columns: (1.5fr, 1fr),
    gutter: 0.8cm,
    align: horizon,

    [
      Требования:
      + По стране проверяют, доступна ли доставка.

      + По городу выбирают склад.

      + По улице и номеру дома определяют точку доставки.

      Части адреса нужны для разных операций, поэтому в модели их представляют отдельными атрибутами.
    ],

    [
      #figure(
        image("./images/normalization/4.png", width: 100%),
        supplement: none,
      )
    ],
  )
]

= Смысл требований 2НФ и 3НФ

#slide(title: [Билеты в кино])[
  #grid(
    columns: (1.5fr, 1fr),
    gutter: 0.8cm,
    align: horizon,

    [
      Одна строка -- один проданный билет.

      + На одно место на одном сеансе продаётся максимум один билет.

      + Каждый сеанс проходит в одном зале. В одном зале может быть
        несколько сеансов.

      + У каждого зала одна вместимость.
    ],

    [
      #figure(
        image("./images/normalization/5.png", width: 100%),
        supplement: none,
      )
    ],
  )
]

#slide(title: [Вторая нормальная форма])[
  #themed-block(title: [Определение])[
    Схема находится в 2НФ, если она находится в 1НФ и каждый атрибут,
    который не входит ни в один потенциальный ключ, полностью зависит
    от каждого потенциального ключа.
  ]

  + $("screening_id", "seat_number") -> "paid_amount"$ \
    Сумма оплаты относится к конкретному билету. Нужны обе части ключа.

  + $"screening_id" -> "hall_id"$ \
    Сеанс определяет зал. Номер места здесь ничего не добавляет.
]

#slide(title: [Почему частичная зависимость создаёт избыточность?])[
  #grid(
    columns: (1.5fr, 1fr),
    gutter: 0.8cm,
    align: horizon,

    [
      *Зал относится к сеансу.* Если на сеанс продали 50 билетов,
      его зал записан в 50 строках.

      + *Обновление.* Если исправить зал в одном билете, у одного
        сеанса окажутся разные залы.

      + *Вставка.* Чтобы записать зал нового сеанса, нужен хотя бы один билет.

      + *Удаление.* Вместе с последним билетом пропадёт запись о зале сеанса.
    ],

    [
      #themed-block(title: [Частичная зависимость])[
        $ "screening_id" -> "hall_id" $
      ]
    ],
  )
]

#slide(title: [Схема после перехода к 2НФ])[
  #align(center)[
    #image("./images/normalization/6.png", width: 70%)
  ]
]

#slide(title: [Почему транзитивная зависимость создаёт избыточность?])[
  #grid(
    columns: (1.5fr, 1fr),
    gutter: 0.8cm,
    align: horizon,

    [
      *Вместимость относится к залу.* Каждый новый сеанс в том же зале
      добавляет ещё одну копию его вместимости.

      + *Обновление.* Если исправить вместимость в одном сеансе,
        у одного зала окажутся разные значения.

      + *Вставка.* Чтобы записать вместимость нового зала,
        нужен хотя бы один сеанс.

      + *Удаление.* Вместе с последним сеансом пропадёт запись
        о вместимости зала.
    ],

    [
      #themed-block(title: [Транзитивная зависимость])[
        $ "screening_id" -> "hall_id" $
        $ "hall_id" -> "hall_capacity" $
      ]
    ],
  )
]

#slide(title: [Схема после перехода к 3НФ])[
  #align(center)[
    #image("./images/normalization/7.png", width: 70%)
  ]
]

= Проверка декомпозиции на отсутствие потерь

#slide(title: [Зачем проверять декомпозицию?])[
  #text(size: 1.25em)[
    - После разбиения все полученные таблицы могут быть в 3НФ.

    - Если при обратном соединении появляются лишние строки,
      часть исходных связей потеряна.
  ]
]

#slide(title: [Закупки розничной сети])[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.8cm,
    align: horizon,

    [
      #set text(size: 0.85em)

      *Товары магазинов -- store_products*

      #table(
        columns: 3,
        inset: (x: 0.45em, y: 0.2em),
        table.header([*`store_id`*], [*`product_id`*], [*`stock_qty`*]),
        [`1`], [`10`], [`18`],
        [`2`], [`10`], [`32`],
      )

      *Товары поставщиков -- supplier_products*

      #table(
        columns: 3,
        inset: (x: 0.45em, y: 0.2em),
        table.header([*`supplier_id`*], [*`product_id`*], [*`unit_price`*]),
        [`101`], [`10`], [`100`],
        [`102`], [`10`], [`120`],
      )
    ],

    [
      #figure(
        image("./images/normalization/9.png", width: 100%),
        supplement: none,
      )
    ],
  )
]

#slide(title: [Проверяем обратным соединением])[
  #grid(
    columns: (1fr, 1.35fr),
    gutter: 0.8cm,
    align: horizon,

    [
      ```sql
      SELECT sp.store_id, sp.product_id,
             sup.supplier_id,
             sp.stock_qty, sup.unit_price
      FROM store_products AS sp
      JOIN supplier_products AS sup
        USING (product_id)
      ORDER BY sp.store_id, sup.supplier_id;
      ```
    ],

    [
      #set text(size: 0.85em)

      #table(
        columns: 5,
        inset: (x: 0.35em, y: 0.25em),
        fill: (x, y) => if y == 2 or y == 3 { rgb("#FFF0CC") },
        table.header(
          [*`store_id`*], [*`product_id`*], [*`supplier_id`*],
          [*`stock_qty`*], [*`unit_price`*],
        ),
        [`1`], [`10`], [`101`], [`18`], [`100`],
        [`1`], [`10`], [`102`], [`18`], [`120`],
        [`2`], [`10`], [`101`], [`32`], [`100`],
        [`2`], [`10`], [`102`], [`32`], [`120`],
      )
    ],
  )
]

#focus-slide([
  Декомпозиция без потерь гарантирует,
  что соединение вернёт ровно исходные строки.
])

#slide(title: [Исправленная схема закупок])[
  #grid(
    columns: (1fr, 1.2fr),
    gutter: 0.8cm,
    align: horizon,

    [
      *Поставки -- store_supplies*

      #table(
        columns: 3,
        inset: (x: 0.45em, y: 0.25em),
        table.header([*`store_id`*], [*`product_id`*], [*`supplier_id`*]),
        [`1`], [`10`], [`101`],
        [`2`], [`10`], [`102`],
      )
    ],

    [
      #figure(
        image("./images/normalization/8.png", width: 75%),
        supplement: none,
      )
    ],
  )
]

#slide(title: [Проверяем исправленную схему])[
  #grid(
    columns: (1fr, 1.35fr),
    gutter: 0.8cm,
    align: horizon,

    [
      #set text(size: 0.85em)

      ```sql
      SELECT ss.store_id, ss.product_id,
             ss.supplier_id,
             sp.stock_qty, sup.unit_price
      FROM store_supplies AS ss
      JOIN store_products AS sp
        USING (store_id, product_id)
      JOIN supplier_products AS sup
        USING (supplier_id, product_id)
      ORDER BY ss.store_id, ss.supplier_id;
      ```
    ],

    [
      #set text(size: 0.85em)

      #table(
        columns: 5,
        inset: (x: 0.35em, y: 0.25em),
        table.header(
          [*`store_id`*], [*`product_id`*], [*`supplier_id`*],
          [*`stock_qty`*], [*`unit_price`*],
        ),
        [`1`], [`10`], [`101`], [`18`], [`100`],
        [`2`], [`10`], [`102`], [`32`], [`120`],
      )
    ],
  )
]

= Границы достаточности 3НФ и НФБК

#focus-slide([
  Зачем нормализовать дальше, \
  если схема уже в 3НФ?
])

#slide(title: [3НФ и НФБК])[
  + *3НФ* допускает нетривиальную зависимость $X -> A$,
    где $X$ не суперключ, если атрибут $A$ входит
    хотя бы в один потенциальный ключ.

  + *НФБК* требует, чтобы слева в каждой нетривиальной
    функциональной зависимости стоял суперключ.

]

#focus-slide([
  Зачем существуют высшие НФ?
])

#slide(title: [Что проверяют высшие нормальные формы?])[
  #grid(
      columns: (1fr, 1fr),
      gutter: 0.8cm,
      align: horizon,

      [
        + 4НФ разделяет независимые списки значений, чтобы не хранить все их сочетания.

        + 5НФ учитывает зависимости соединения, в том числе разбиения на три и более части, которые вместе позволяют восстановить исходные данные

        + 6НФ доводит разбиение до таблиц, которые уже нельзя разложить на меньшие без потери информации.
      ],

      [
        #figure(
          image("./images/normalization/tom.jpg", width: 80%),
          supplement: none,
        )
      ],
    )
]

#slide(title: [Суровая реальность])[
  В рабочей системе важна скорость запросов. Если замеры показывают,
  что соединения замедляют чтение, данные можно денормализовать.

  + Дублировать нужные атрибуты.

  + Хранить заранее рассчитанные итоги.

  + Использовать специальные типы данных.
]

#ending-slide(
    title: [Спасибо за внимание!],
    subtitle: [Вопросы?],
    contact: (link("https://t.me/vodobryshkin")[t.me/vodobryshkin], link("https://github.com/vodobryshkin")[github.com/vodobryshkin],),
)

#slide(title: [Источники])[
  #set text(size: 1em)

  - Ramez Elmasri, Shamkant B. Navathe.
    #link("https://eecs.csuohio.edu/~sschung/cis430/Fundamentals-of-Database-Systems-Pearson-2015-Ramez-Elmasri-Shamkant-B.-Navathe.pdf")[Fundamentals of Database Systems].

  - C. J. Date.
    #link("https://www.oreilly.com/library/view/sql-and-relational/9781449319724/ch02s03.html")[SQL and Relational Theory: Data Value Atomicity].

  - William Kent.
    #link("https://www.bkent.net/Doc/simple5.htm")[A Simple Guide to Five Normal Forms in Relational Database Theory].

  - Hugh Darwen. Database Design Issues.
    #link("https://www.dcs.warwick.ac.uk/~hugh/CS252/CS252-HACD-Notes8.pdf")[Часть I] ·
    #link("https://www.dcs.warwick.ac.uk/~hugh/CS252/CS252-HACD-Notes9.pdf")[Часть II].
]