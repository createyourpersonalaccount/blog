((org-mode
  . ((display-buffer-alist
      ("[*]compilation[*]" display-buffer-no-window))
     (eval
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
