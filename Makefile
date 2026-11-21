.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SECONDARY:

TYPST_VERSION := 0.15.1

SYSTEM := $(shell uname -s)
ARCH := $(shell uname -m)

ifneq ($(filter x86_64 amd64 AMD64,$(ARCH)),)
TYPST_ARCH := x86_64
else ifneq ($(filter aarch64 arm64 ARM64,$(ARCH)),)
TYPST_ARCH := aarch64
else
$(error Unsupported architecture: $(ARCH))
endif

ifeq ($(SYSTEM),Linux)
TYPST_PLATFORM := unknown-linux-musl
else ifeq ($(SYSTEM),Darwin)
TYPST_PLATFORM := apple-darwin
else ifneq ($(filter MINGW% MSYS% CYGWIN%,$(SYSTEM)),)
TYPST_PLATFORM := pc-windows-msvc
else
$(error Unsupported system: $(SYSTEM). On Windows, run make in MSYS2)
endif

TYPST_TARGET := $(TYPST_ARCH)-$(TYPST_PLATFORM)

ifeq ($(TYPST_PLATFORM),pc-windows-msvc)
TYPST_EXT := .exe
TYPST_ARCHIVE_EXT := zip
else
TYPST_EXT :=
TYPST_ARCHIVE_EXT := tar.xz
endif

TYPST := .tools/typst-$(TYPST_VERSION)-$(TYPST_TARGET)/typst$(TYPST_EXT)

CURL := curl --fail --location --silent --show-error --retry 3 --connect-timeout 15
GOOGLE_FONTS := https://raw.githubusercontent.com/google/fonts/2eb0b48d5f760f62e286216f0859a8c540dbc1bd/ofl
EXPO_FONTS := https://raw.githubusercontent.com/expo/google-fonts/bb2d936bfd81d1497d12661c439d753b15b777fc/font-packages/material-symbols-rounded
TYPST_FLAGS := --root . --font-path .tools/fonts --ignore-system-fonts --package-path .tools/packages --package-cache-path .tools/packages

REPORTS := $(patsubst reports/%.typ,dist/reports/%.pdf,$(wildcard reports/*.typ))
SLIDES := $(patsubst slides/%.typ,dist/slides/%.pdf,$(wildcard slides/*.typ))

.PHONY: all setup fonts packages reports slides watch clean help FORCE
all: reports slides
reports: $(REPORTS)
slides: $(SLIDES)
fonts: .tools/fonts/.ready

setup: packages
	mkdir -p reports slides assets dist

packages: $(TYPST) fonts
	mkdir -p .tools/packages
	printf '%s\n' \
		'#import "@preview/primeone:1.0.0" as primeone' \
		'#import "@preview/unofficial-sorbonne-presentation:0.5.0" as sorbonne' \
		'#import "@preview/fletcher:0.5.8" as fletcher' \
		'#import "@preview/cetz:0.5.2" as cetz' \
		'#import "@preview/cetz-venn:0.2.0" as cetz-venn' \
		> .tools/dependencies.typ
	$(TYPST) compile $(TYPST_FLAGS) .tools/dependencies.typ .tools/dependencies.pdf

$(TYPST):
	mkdir -p "$(@D)"
	$(CURL) -o "$(@D)/typst.$(TYPST_ARCHIVE_EXT)" https://github.com/typst/typst/releases/download/v$(TYPST_VERSION)/typst-$(TYPST_TARGET).$(TYPST_ARCHIVE_EXT)
ifeq ($(TYPST_ARCHIVE_EXT),zip)
	unzip -o "$(@D)/typst.zip" -d "$(@D)"
	mv "$(@D)/typst-$(TYPST_TARGET)/typst.exe" "$@"
else
	tar --no-same-owner -xJf "$(@D)/typst.tar.xz" --strip-components=1 -C "$(@D)"
endif
	"$@" --version

.tools/fonts/.ready:
	mkdir -p .tools/fonts/liberation
	$(CURL) -o .tools/fonts/Inter.ttf "$(GOOGLE_FONTS)/inter/Inter%5Bopsz%2Cwght%5D.ttf"
	$(CURL) -o .tools/fonts/Inter-Italic.ttf "$(GOOGLE_FONTS)/inter/Inter-Italic%5Bopsz%2Cwght%5D.ttf"
	set -e; for style in Regular Italic Bold BoldItalic; do \
		$(CURL) -o ".tools/fonts/FiraSans-$$style.ttf" "$(GOOGLE_FONTS)/firasans/FiraSans-$$style.ttf"; \
	done
	$(CURL) -o .tools/fonts/FiraMath-Regular.otf https://github.com/firamath/firamath/releases/download/v0.3.4/FiraMath-Regular.otf
	set -e; for style in 400Regular 700Bold; do \
		$(CURL) -o ".tools/fonts/MaterialSymbolsRounded_$$style.ttf" "$(EXPO_FONTS)/$${style}_Filled/MaterialSymbolsRounded_$${style}_Filled.ttf"; \
	done
	$(CURL) -o .tools/fonts/liberation.tar.gz https://github.com/liberationfonts/liberation-fonts/files/7261482/liberation-fonts-ttf-2.1.5.tar.gz
	tar --no-same-owner -xzf .tools/fonts/liberation.tar.gz --strip-components=1 -C .tools/fonts/liberation
	$(CURL) -o .tools/fonts/Inter-OFL.txt "$(GOOGLE_FONTS)/inter/OFL.txt"
	$(CURL) -o .tools/fonts/FiraSans-OFL.txt "$(GOOGLE_FONTS)/firasans/OFL.txt"
	$(CURL) -o .tools/fonts/FiraMath-OFL.txt https://raw.githubusercontent.com/firamath/firamath/v0.3.4/LICENSE
	$(CURL) -o .tools/fonts/MaterialSymbols-LICENSE.txt "$(EXPO_FONTS)/LICENSE_FONT"
	touch "$@"

FORCE:

dist/reports/%.pdf: reports/%.typ FORCE | packages
	mkdir -p "$(@D)"
	$(TYPST) compile $(TYPST_FLAGS) "$<" "$@"

dist/slides/%.pdf: slides/%.typ FORCE | packages
	mkdir -p "$(@D)"
	$(TYPST) compile $(TYPST_FLAGS) "$<" "$@"

report-%: dist/reports/%.pdf
	@:

slides-%: dist/slides/%.pdf
	@:

watch: packages
	@test -n "$(FILE)" && test -f "$(FILE)" || { echo 'Укажи существующий файл: make watch FILE=slides/intro.typ'; exit 1; }
	@test "$(suffix $(FILE))" = .typ || { echo 'Нужен файл .typ'; exit 1; }
	mkdir -p "dist/$(dir $(FILE))"
	$(TYPST) watch $(TYPST_FLAGS) "$(FILE)" "dist/$(patsubst %.typ,%.pdf,$(FILE))"

clean:
	rm -rf dist

help:
	@printf '%s\n' \
		'make setup             — скачать Typst, шрифты и пакеты' \
		'make packages          — подкачать пакеты Typst' \
		'make                   — собрать всё' \
		'make reports / slides  — собрать доклады / презентации' \
		'make report-ИМЯ        — собрать reports/ИМЯ.typ' \
		'make slides-ИМЯ        — собрать slides/ИМЯ.typ' \
		'make watch FILE=...    — пересобирать при изменениях' \
		'make clean             — удалить только dist/'