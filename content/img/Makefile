.PHONY: all clean move

GV_FILES := $(wildcard *.gv)
TEX_FILES := $(wildcard *.tex)

all: $(TEX_FILES:.tex=.svg) $(GV_FILES:.gv=.svg) move clean

%.dvi: %.tex
	latex $<

%.svg: %.dvi
	dvisvgm $<

%.svg: %.gv
	dot -Tsvg $< > $@

move:
	mkdir -p ../../public/img
	find . -type f -name '*.svg' -exec mv {} ../../public/img \;

clean:
	rm -f *.aux *.log *.dvi
