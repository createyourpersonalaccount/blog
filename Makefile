.PHONY: all build-assets build clean-assets

all: build-assets build clean-assets

build-assets:
	make -C assets

build:
	emacs --quick --batch \
		--load publish.el \
		--eval '(org-publish-project "blog" t)'

clean-assets:
	make -C assets clean
