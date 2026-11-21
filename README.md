# Материалы по базам данных

Памятки и презентации для практических занятий по базам данных. Материалы написаны на [Typst](https://typst.app/).

## Сборка

Для сборки нужны `make`, `curl`, `tar` и поддержка распаковки XZ. Поддерживаются Linux и macOS на x86_64 и ARM64, а также Windows через MSYS2.

На macOS `make` можно установить вместе с Command Line Tools:

```sh
xcode-select --install
```

На Windows установите [MSYS2](https://www.msys2.org/) и выполните в его терминале:

```sh
pacman -S --needed make curl tar unzip xz
```

Все команды сборки на Windows выполняйте в терминале MSYS2.

Для сборки перейдите в корень репозитория и выполните:

```sh
make setup
make
```

Typst, шрифты и пакеты скачиваются автоматически. Готовые PDF сохраняются в `dist/reports/` и `dist/slides/`.

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