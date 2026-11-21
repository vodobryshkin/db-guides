# Материалы по базам данных

Памятки и презентации для практических занятий по базам данных. Материалы написаны на [Typst](https://typst.app/).

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

Также можно собрать одну презентацию/доклад с помощью команд:

```sh
make report-<title>  # собрать конкретный доклад с названием файла <title>.typ
make slides-<title>  # собрать конкретную презентацию с названием файла <title>.typ
```

Например:

```sh
make report-chart-formatting-and-styleguide
make slides-data-types-and-patterns
```