(setq package-load-list
      '((htmlize nil) all))
(package-initialize)
(use-package package
  :config
  (add-to-list 'package-archives
	       '("melpa" . "https://melpa.org/packages/") t))
(use-package use-package-ensure
  :config
  (setq use-package-always-ensure t))
(use-package citeproc)
(defvar blog-prefix (or (getenv "BLOG_PREFIX") ""))
(defvar js-files
  (list "sidebar.js"))
(defvar css-files
  (list "style.css"
        "atom-one-light.min.css"))
(defun html-src-js (blog-prefix files)
  "Create HTML link tags linking to the JS files."
  (mapconcat
   (lambda (file)
     (format "<script src=\"%s/js/%s\"></script>"
             blog-prefix
             file))
   files
   "\n"))
(defun html-link-css (blog-prefix files)
  "Create HTML link tags linking to the CSS files."
  (mapconcat
   (lambda (file)
     (format "<link rel=\"stylesheet\" href=\"%s/css/%s\">"
             blog-prefix
             file))
   files
   "\n"))
(defun html-head (blog-prefix)
  "Create HTML head that includes JS and CSS."
  (concat (html-src-js blog-prefix js-files)
          "\n"
          (html-link-css blog-prefix css-files)))
(defun inline-html-for-sitemap (html)
  "Produce a string that can be used inside sitemap.org.

Sitemap for some reason strips a normal backend string like
@@html:<b>@@. We use this \"bug\" against itself to force the
appearance of this string in the final sitemap.org."
  (format "@@html@@a:@@:%s@@" html))
(defun format-blog-entry-date-nav-sidebar (entry project)
  "This formats the YYYY-MM-DD part of a blog entry"
  (let* ((date (org-publish-find-date entry project))
         (has-date
          (zerop
           (call-process "awk" nil nil nil
                         "NR<=10 && /^#\\+DATE:/ {f=1} END {exit !f}"
                         entry))))
    (when has-date
      (format-time-string "%Y-%m-%d" date))))
(defun format-dir-nav-sidebar (entry)
  "Format a directory for the navigation sidebar"
  (capitalize (replace-regexp-in-string "-" " " entry)))
(defun format-blog-entry-nav-sidebar (entry project)
  "Format a blog entry for the navigation sidebar"
  (let ((title (org-publish-find-title entry project))
        (date (format-blog-entry-date-nav-sidebar entry project)))
    (format "[[./%s][%s]]%s"
            entry
            title
            (if date
                (format ", %s%s%s"
                        (inline-html-for-sitemap "<span class=\"blog-entry-date\">")
                        date
                        (inline-html-for-sitemap "</span>"))
              ""))))
(setq enable-local-variables :all)
;; Show the checkboxes as unicode.
(setq org-html-checkbox-type 'unicode)
;; Show tables centered and with border lines.
(setq org-html-table-default-attributes
      '(:align "center"
        :border "2"
        :cellpadding "6"
        :cellspacing "0"
        :frame "border"
        :rules "all"))
;; Always include babel src-block output in HTML export, if it exists.
(let ((pair (assoc :exports org-babel-default-header-args)))
  (if pair
      (setcdr pair "both")
    (add-to-list 'org-babel-default-header-args
                 '(:exports . "both"))))
(setq org-publish-project-alist
      `(("blog"
         :components ("blog-pages" "blog-assets"))
        ("blog-pages"
         :author "Nikolaos Chatzikonstantinou"
         :with-email t
         :email "nchatz314@gmail.com"
         :time-stamp-file nil
         :html-metadata-timestamp-format "%Y-%m-%d %a"
         :html-head ,(html-head blog-prefix)
         :html-mathjax-options ((path ,(format "%s/mathjax/tex-chtml.js" blog-prefix))
                                (tags "ams")
                                (tagside "right")
                                (tagindent ".8em")
                                (scale 1.0)
                                (align "center")
                                (font "mathjax-modern")
                                (overflow "overflow")
                                (indent "0em"))
         :html-validation-link ""
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :html-divs ((preamble "header" "preamble")
                     (content "main" "content")
                     (postamble "footer" "postamble"))
         :base-directory "."
         :base-extension "org"
         :recursive t
         :auto-sitemap t
         :sitemap-sort-files anti-chronologically
         :sitemap-format-entry
         (lambda (entry sitemap-style project)
           (if (file-directory-p entry)
               (format-dir-nav-sidebar entry)
             (format-blog-entry-nav-sidebar entry project)))
         :publishing-function org-html-publish-to-html
         :publishing-directory "../../public")
        ("blog-assets"
         :base-directory "../assets"
         :base-extension ".*"
         :recursive t
         :publishing-function org-publish-attachment
         :publishing-directory "../../public")))
