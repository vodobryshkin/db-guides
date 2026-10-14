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
  subtitle: [Встроенные и пользовательские типы, паттерны и антипаттерны],
  author: [Владимир Добрышкин],
  short-author: [Добрышкин В. А.],
  affiliation: [Студент 3-го курса НИУ ИТМО],
  faculty: "univ",
  date: "20.10.2026",
  show-outline: false,
  progress-bar: "bottom",
  logo-slide: image("./images/logo/itmo1.png"),
  logo-transition: image("./images/logo/itmo2.png"),
  dark-mode: false
)