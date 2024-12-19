.PHONY: all img publish

all: img publish

img:
	make -C img

publish:
	cp -r pages pages-tmp
	find pages-tmp -type f -name '*.org' \
		-exec sh -c 'printf "#+HTML: <nav class=\"sidebar\">\n#+INCLUDE: \"%s/pages-tmp/sitemap.org\" :lines \"3-\"\n#+HTML: </nav>\n" $$1 >> $$2' _ $(CURDIR) {} \;
	emacs	--quick --batch \
		--load 'publish.el' \
		--file pages-tmp/index.org \
		--eval '(org-publish-current-project t)'
	rm -f ../public/sitemap.html
	rm -rf pages-tmp
	find ../public -type f -name '*.html' \
		-exec node colorize-source-code.js {} +

