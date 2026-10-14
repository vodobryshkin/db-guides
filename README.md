# Материалы по базам данных

Памятки и презентации для практических занятий по Базам данных. Материалы написаны на [Typst](https://typst.app/).

## Сборка

Для сборки нужны Linux (x86_64 или aarch64), `make`, `curl`, `tar`.

```sh
make setup
make
```

Готовые PDF сохраняются в `dist/reports/` и `dist/slides/`.

Основные команды:

```sh
make reports # собрать все доклады
make slides  # собрать все презентации
```

Так же можно собрать одну презентацию/доклад с помощью команд:
```sh
make reports-<title> # собрать конкретный доклад с названием файла <title>.typ
make slides-<title>  # собрать конкретную презентацию с названием файла <title>.typ
```

Например:

```shell
make reports-chat-formatting-and-styleguide
make slides-data-types-and-patterns
```