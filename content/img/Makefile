.PHONY: all clean move

TEX_FILES := $(wildcard *.tex)

all: $(TEX_FILES:.tex=.svg) move

%.dvi: %.tex
	latex $<

%.svg: %.dvi
	dvisvgm $<

move:
	mkdir -p ../../public/img
	mv *.svg ../../public/img

clean:
	rm -f *.aux *.log *.dvi
