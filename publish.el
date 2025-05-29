;;; Initialize the package manager
(require 'package)
(package-initialize)

;;; Load blorg.
(use-package blorg
  ;; Don't attempt to install if package is missing.
  :ensure nil)

;;; Load htmlize to colorize source blocks.
(use-package htmlize)
;;; Use external CSS to stylize the source blocks.
(setq org-html-htmlize-output-type 'css)

;;; The publishing directory
;; 
;; Where the browsable content of the blog will be.
(setq-local blorg-publishing-directory "public_html")

;;; Include every headline in the table of contents.
(setq org-export-headline-levels 99)
(setq org-export-with-toc 99)

;;; This is the blorg root.
;;
;; It is different for local builds versus server (or CI) builds.
(setq-local blorg-root
            (ensure-suffix "/"
                           (expand-file-name
                            (if (getenv "BLORG_SERVE")
                                ;; The server/CI value
                                "/blog"
                              ;; The local build value
                              (concat
                               (ensure-suffix "/" (or (locate-dominating-file "." "index.org") ""))
                               blorg-publishing-directory)))))

;;; Bibliographic files.
(setq org-cite-global-bibliography `(,(expand-file-name "bibliography.bib")))
(setq org-cite-export-processors `((t . (csl ,(expand-file-name "elsevier-with-titles.csl")))))

;;; Show the checkboxes as unicode.
(setq org-html-checkbox-type 'unicode)

;;; Always include babel src-block output in HTML export, if it exists.
(let ((pair (assoc :exports org-babel-default-header-args)))
  (if pair
      (setcdr pair "both")
    (add-to-list 'org-babel-default-header-args
                 '(:exports . "both"))))

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
               :publishing-directory ,blorg-publishing-directory
               :recursive t
               ;; Backend function to convert to HTML.
               :publishing-function blorg-html-publish-to-html
               ;; Sitemap.
               :auto-sitemap t
               :sitemap-filename "sitemap.org"
               :sitemap-title "My Blog"
               :sitemap-sort-files anti-chronologically
               :sitemap-function blorg-sitemap-function
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
               :blorg-root ,blorg-root
               ;; Inside the <header> element, under the
               ;; title. Typically you want to place a navigation bar
               ;; here.
               :blorg-header "<nav id=\"navbar\"><ul>
<li><a href=\"blorg:index.html\">Home</a></li>
<li><a href=\"blorg:sitemap.html\">Sitemap</a></li>
<li><a href=\"blorg:about.html\">About</a></li>
<li><a href=\"blorg:license.html\">License</a></li>
</ul>
<hr id=\"navbar-divider\">
</nav>"))

;;; The configuration of the portion of the copy of the assets into
;;; the publishing directory.
(add-to-list 'org-publish-project-alist
             `("blog-assets"
               ;; Copy the entire contents of this directory to the
               ;; blorg-publishing-directory.
               :base-directory "assets"
               :base-extension ".*"
               :recursive t
               :publishing-function org-publish-attachment
               :publishing-directory ,blorg-publishing-directory))
