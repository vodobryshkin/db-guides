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

= Обратная связь
#messages(severity: "error")[Нашли опечатку или ошибку?]

#messages(severity: "warning")[Есть идеи по улучшению материала?]

#messages(severity: "info")[Хотите предложить тему, которой можно будет дополнить доклад?]

#messages(severity: "success")[
Пишите в #underline(link("https://t.me/vodobryshkin")[личные сообщения]) или заведите issue в #underline(link("https://github.com/vodobryshkin/db-guides")[репозитории])!
]

= Источники
+ Материалы курса "Базы данных". _Лекция 4: Запросы и SQL_.