((org-mode
  . ((eval
      . (keymap-set
         org-mode-map
         "C-c m"
         (lambda ()
           (interactive)
           (let ((project-root
                  (locate-dominating-file default-directory ".git")))
             (compile
              (format "make -C %s/content"
                      project-root)))))))))
