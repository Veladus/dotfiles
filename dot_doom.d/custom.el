(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(magit-todos-insert-after '(bottom) nil nil "Changed by setter of obsolete option `magit-todos-insert-at'")
 '(org-format-latex-options
   '(:foreground default :background default :scale 2.3 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers
     ("begin" "$1" "$" "$$" "\\(" "\\[")))
 '(safe-local-variable-values
   '((eval when dominating-folder
      (setq-local ma-base-directory
       (expand-file-name dominating-folder))
      (when
          (file-newer-than-file-p
           (expand-file-name "ma-init.el" ma-base-directory)
           (expand-file-name "ma-init.elc" ma-base-directory))
        (byte-compile-file
         (expand-file-name "ma-init.el" ma-base-directory)))
      (load
       (expand-file-name "ma-init" ma-base-directory)
       nil t))
     (eval when dominating-folder
      (setq-local ma-base-directory
                  (expand-file-name dominating-folder))
      (when
          (file-newer-than-file-p
           (expand-file-name "ma-init.el" ma-base-directory)
           (expand-file-name "ma-init.elc" ma-base-directory))
        (byte-compile-file
         (expand-file-name "ma-init.el" ma-base-directory)))
      (load
       (expand-file-name "ma-init" ma-base-directory)))
     (eval when dominating-folder
      (setq-local ma-base-directory
                  (expand-file-name dominating-folder))
      (load-file
       (expand-file-name "ma-init.el" ma-base-directory)))
     (eval setq-local dominating-folder
      (locate-dominating-file default-directory ".dir-locals.el"))
     (eval load-file
      (expand-file-name "ma-init.el" ma-base-directory))
     (eval setq-local ma-base-directory
      (expand-file-name
       (locate-dominating-file default-directory ".dir-locals.el"))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
