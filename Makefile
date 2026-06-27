.PHONY: all build-assets build-pages build clean-assets

all: build-assets build clean-assets

build-assets:
	make -C assets

build:
	emacs --quick --batch \
		--eval "(setq enable-dir-local-variables nil)" \
		--load publish.el \
		--eval '(org-publish-project "blog" t)'

build-pages:
	emacs --quick --batch \
		--eval "(setq enable-dir-local-variables nil)" \
		--load publish.el \
		--eval '(org-publish-project "blog-pages" t)'

clean-assets:
	make -C assets clean
