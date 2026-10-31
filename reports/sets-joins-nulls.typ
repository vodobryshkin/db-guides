#import "@preview/primeone:1.0.0": *
#import "@preview/fletcher:0.5.8" as cf

#show: article.with(
  title: "Множества, соединения таблиц и NULL в PostgreSQL",
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

= Обратная связь
#messages(severity: "error")[Нашли опечатку или ошибку?]

#messages(severity: "warning")[Есть идеи по улучшению материала?]

#messages(severity: "info")[Хотите предложить тему, которой можно будет дополнить доклад?]

#messages(severity: "success")[
Пишите в #underline(link("https://t.me/vodobryshkin")[личные сообщения]) или заведите issue в #underline(link("https://github.com/vodobryshkin/db-guides")[репозитории])!
]

= Источники
+ Материалы курса "Базы данных". _Лекция 4: Запросы и SQL_.