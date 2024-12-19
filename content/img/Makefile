.PHONY: all clean move

TEX_FILES := $(wildcard *.tex)

all: $(TEX_FILES:.tex=.svg) move

%.dvi: %.tex
	latex $<

%.svg: %.dvi
	dvisvgm $<

move:
	mkdir -p ../../public/img
	find . -type f -name '*.svg' -exec mv {} ../../public/img \;

clean:
	rm -f *.aux *.log *.dvi
