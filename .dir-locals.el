((org-mode . ((eval . (setq-local
                       org-cite-global-bibliography
                       `(,(concat (locate-dominating-file default-directory "publish.el") "bibliography.bib"))
                       org-cite-export-processors
                       `((t . (csl
                               ,(concat
                                 (locate-dominating-file default-directory "publish.el")
                                 "elsevier-with-titles.csl"))))
                       org-babel-default-header-args
                       '((:session . "none") (:results . "replace")
                         (:exports . "both") (:eval . "never-export")
                         (:cache . "no") (:noweb . "strip-export")
                         (:hlines . "no") (:tangle . "no")))))))
