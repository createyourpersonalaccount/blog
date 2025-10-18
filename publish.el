;;; Initialize the package manager
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;; Load ox-blorg.

;; In the server, you should use BLORG_LOAD_PATH. Locally, my blog
;; resides in the same parent directory as the ox-blorg
;; repository. Your layout may be different; adjust the local
;; configuration accordingly.
(push (or
       ;; Server configuration.
       (getenv "BLORG_LOAD_PATH")
       ;; Local configuration.
       "../ox-blorg")
      load-path)

(use-package ox-blorg
  :ensure nil)

;;; Deal with citations.
(use-package citeproc
  :ensure t)

;;; Load htmlize to colorize source blocks.
(use-package htmlize
  :ensure t)
;;; Use external CSS to stylize the source blocks.
(setq org-html-htmlize-output-type 'css)
;;; Colorize haskell source code.
(use-package haskell-mode
  :ensure t)

;;; The publishing directory
;; 
;; Where the browsable content of the blog will be.
(setq-local ox-blorg-publishing-directory "public_html")

;;; Include every headline in the table of contents.
(setq org-export-headline-levels 99)
(setq org-export-with-toc 99)

;;; This is the ox-blorg root.
;;
;; It is different for local builds versus server (or CI) builds.
(setq-local ox-blorg-root
            (ox-blorg-ensure-suffix
             "/"
             (expand-file-name
              (if (getenv "BLORG_SERVE")
                  ;; The server/CI value
                  "/blog"
                ;; The local build value
                (concat
                 (ox-blorg-ensure-suffix "/" (or (locate-dominating-file "." "index.org") ""))
                 ox-blorg-publishing-directory)))))

;;; Bibliographic files.
(setq org-cite-global-bibliography `(,(expand-file-name "bibliography.bib")))
(setq org-cite-export-processors `((t . (csl ,(expand-file-name "elsevier-with-titles.csl")))))

;;; Show the checkboxes as unicode.
(setq org-html-checkbox-type 'unicode)

;;; Set blog configuration options for org-publish.
(add-to-list 'org-publish-project-alist
             '("blog"
               ;; The blog has two components:
               ;; 1) The Org pages that will be converted to HTML.
               ;; 2) Assets such as CSS, JavaScript, images, and other
               ;;    files.
               ;; Each component has a different configuration,
               ;; specified below.
               :components ("blog-pages" "blog-assets")))

;;; Prevent org-export from evaluating babel blocks.
(setq org-export-use-babel nil)

;;; Strip noweb references and do not evaluate source blocks on export.
(setq org-babel-default-header-args
      '((:session . "none") (:results . "replace")
        (:exports . "both") (:eval . "never-export")
        (:cache . "no") (:noweb . "strip-export")
        (:hlines . "no") (:tangle . "no")))

;;; The configuration of the portion consisting of the Org pages
(add-to-list 'org-publish-project-alist
             `("blog-pages"
               ;; Author name & email information.
               :with-author t
               :author "Nikolaos Chatzikonstantinou"
               :with-email t
               :email "nchatz314@gmail.com"
               ;; Show the #+DATE: of articles (when set).
               :with-date t
               ;; Articles to publish.
               :base-directory "."
               :base-extension "org"
               :publishing-directory ,ox-blorg-publishing-directory
               :recursive t
               ;; Backend function to convert to HTML.
               :publishing-function ox-blorg-html-publish-to-html
               ;; Sitemap.
               :auto-sitemap t
               :sitemap-filename "sitemap.org"
               :sitemap-title "My Blog"
               :sitemap-sort-files anti-chronologically
               :sitemap-function ox-blorg-sitemap-function
               ;; CSS and JavaScript.
               :html-head ,(concat
                            "<link rel=\"icon\" type=\"image/x-icon\" href=\"blorg:favicon.ico\">"
                            "<link rel=\"stylesheet\" href=\"blorg:css/style.css\">"
                            "\n"
                            "<link rel=\"stylesheet\" href=\"blorg:css/adwaita.css\">")
               ;; MathJax options.
               :html-mathjax-options ((path "blorg:mathjax/tex-chtml-full.js")
                                      (multlinewidth "85%")
                                      (tags "ams")
                                      (tagside "right")
                                      (tagindent ".8em")
                                      (scale 1)
                                      (align "center")
                                      (font "mathjax-modern")
                                      (overflow "overflow")
                                      (indent "0em"))
               ;; This is the root of the served directory in the
               ;; server. E.g. if the blog is served under
               ;; $domain/blog, then :blorg-root should be set to
               ;; "blog". The blorg: links will then be converted to
               ;; properly account for that directory when exported as
               ;; HTML links.
               ;;
               ;; Note that this variable is only specified if
               ;; BLORG_SERVE is defined in the environment, so that
               ;; users can discard it when they build their blog for
               ;; local viewing.
               :blorg-root ,ox-blorg-root
               ;; Inside the <header> element, under the
               ;; title. Typically you want to place a navigation bar
               ;; here.
               :blorg-header "<nav id=\"navbar\"><ul>
<li><a href=\"blorg:index.html\">Home</a></li>
<li><a href=\"blorg:sitemap.html\">Sitemap</a></li>
<li><a href=\"blorg:license.html\">License</a></li>
</ul>
<hr id=\"navbar-divider\">
</nav>"))

;;; The configuration of the portion of the copy of the assets into
;;; the publishing directory.
(add-to-list 'org-publish-project-alist
             `("blog-assets"
               ;; Copy the entire contents of this directory to the
               ;; ox-blorg-publishing-directory.
               :base-directory "assets"
               :base-extension ".*"
               :recursive t
               :publishing-function org-publish-attachment
               :publishing-directory ,ox-blorg-publishing-directory))
