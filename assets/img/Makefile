.PHONY: all clean

GV_FILES := $(wildcard *.gv)
TEX_FILES := $(wildcard *.tex)

all: $(TEX_FILES:.tex=.svg) $(GV_FILES:.gv=.svg)

%.dvi: %.tex
	latex $<

%.svg: %.dvi
	dvisvgm $<

%.svg: %.gv
	dot -Tsvg $< > $@

clean:
	rm -f $(TEX_FILES:.tex=.aux) $(TEX_FILES:.tex=.log) $(TEX_FILES:.tex=.svg) $(GV_FILES:.gv=.svg)
