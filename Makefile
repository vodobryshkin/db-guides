.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SECONDARY:

TYPST_VERSION := 0.15.1
TYPST := .tools/typst-$(TYPST_VERSION)/typst
ARCH := $(shell uname -m)
ifeq ($(ARCH),x86_64)
TYPST_TARGET := x86_64-unknown-linux-musl
else ifeq ($(ARCH),aarch64)
TYPST_TARGET := aarch64-unknown-linux-musl
else
$(error For now only x86_64 and aarch64 are supported; detected $(ARCH))
endif

CURL := curl --fail --location --silent --show-error --retry 3 --connect-timeout 15
GOOGLE_FONTS := https://raw.githubusercontent.com/google/fonts/2eb0b48d5f760f62e286216f0859a8c540dbc1bd/ofl
EXPO_FONTS := https://raw.githubusercontent.com/expo/google-fonts/bb2d936bfd81d1497d12661c439d753b15b777fc/font-packages/material-symbols-rounded
TYPST_FLAGS := --root . --font-path .tools/fonts --ignore-system-fonts --package-path .tools/packages --package-cache-path .tools/packages

REPORTS := $(patsubst reports/%.typ,dist/reports/%.pdf,$(wildcard reports/*.typ))
SLIDES := $(patsubst slides/%.typ,dist/slides/%.pdf,$(wildcard slides/*.typ))

.PHONY: all setup fonts reports slides watch clean help FORCE intro-report intro-slides
all: reports slides
reports: $(REPORTS)
slides: $(SLIDES)
fonts: .tools/fonts/.ready

setup: $(TYPST) fonts
	mkdir -p reports slides assets dist .tools/packages
	printf '%s\n' \
		'#import "@preview/primeone:1.0.0" as primeone' \
		'#import "@preview/unofficial-sorbonne-presentation:0.5.0" as sorbonne' \
		> .tools/dependencies.typ
	$(TYPST) compile $(TYPST_FLAGS) .tools/dependencies.typ .tools/dependencies.pdf

$(TYPST):
	mkdir -p "$(@D)"
	$(CURL) -o "$(@D)/typst.tar.xz" https://github.com/typst/typst/releases/download/v$(TYPST_VERSION)/typst-$(TYPST_TARGET).tar.xz
	tar --no-same-owner -xJf "$(@D)/typst.tar.xz" --strip-components=1 -C "$(@D)"
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
dist/reports/%.pdf: reports/%.typ FORCE | $(TYPST) fonts
	mkdir -p "$(@D)"
	$(TYPST) compile $(TYPST_FLAGS) "$<" "$@"

dist/slides/%.pdf: slides/%.typ FORCE | $(TYPST) fonts
	mkdir -p "$(@D)"
	$(TYPST) compile $(TYPST_FLAGS) "$<" "$@"

report-%: dist/reports/%.pdf
	@:
slides-%: dist/slides/%.pdf
	@:

intro-report: dist/reports/intro.pdf
intro-slides: dist/slides/intro.pdf

watch: $(TYPST) fonts
	@test -n "$(FILE)" && test -f "$(FILE)" || { echo 'Укажи существующий файл: make watch FILE=slides/intro.typ'; exit 1; }
	@test "$(suffix $(FILE))" = .typ || { echo 'Нужен файл .typ'; exit 1; }
	mkdir -p "dist/$(dir $(FILE))"
	$(TYPST) watch $(TYPST_FLAGS) "$(FILE)" "dist/$(patsubst %.typ,%.pdf,$(FILE))"

clean:
	rm -rf dist

help:
	@printf '%s\n' 'make setup             — скачать Typst, шрифты и пакеты' 'make                   — собрать всё' 'make reports / slides  — собрать доклады / презентации' 'make report-ИМЯ        — собрать reports/ИМЯ.typ' 'make slides-ИМЯ        — собрать slides/ИМЯ.typ' 'make watch FILE=...    — пересобирать при изменениях' 'make clean             — удалить только dist/'