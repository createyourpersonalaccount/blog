.PHONY: all img publish

all: img publish

img:
	make -C img

publish:
	rm -rf pages-tmp
	cp -r pages pages-tmp
	find pages-tmp -type f -name '*.org' \
		-exec sh -c 'printf "#+HTML: <div id=\"sidebar\" onclick=\"toggleNav()\"><h2>Blog Posts</h2><nav class=\"sidebar\">\n#+INCLUDE: \"%s/pages-tmp/sitemap.org\" :lines \"3-\"\n#+HTML: </h2></nav></div>\n" $$1 >> $$2' _ $(CURDIR) {} \;
	find pages-tmp -type f -name '*.org' \
		-exec ./prepend-latex-template.bash {} +
	emacs	--quick --batch \
		--load 'publish.el' \
		--file pages-tmp/index.org \
		--eval '(org-publish-current-project t)'
	rm -f ../public/sitemap.html
	find ../public -type f -name '*.html' \
		-exec node colorize-source-code.js {} +

