.PHONY: all build-assets build

all: build-assets build

build-assets:
	make -C assets

build:
	emacs --quick --batch \
		--eval "(add-to-list 'load-path (expand-file-name \"..\"))" \
		--load publish.el \
		--eval '(org-publish-project "blog" t)'
