;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(load! "private.el")

(defun set-ssh-auth-to-gpg-socket ()
  "This function sets the environment variables to use"
  (interactive)
  (setenv
   "SSH_AUTH_SOCK"
   (string-chop-newline
     (shell-command-to-string "gpgconf --list-dirs | grep \"agent-ssh-socket\" | cut -d: -f2"))))


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Niko Hastrich"
      user-mail-address "niko.hastrich@t-online.de")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Adapt path variable
(let ((nix-profile-bin (concat (getenv "HOME") "/.nix-profile/bin")))
  (unless
      (string-match-p
       (concat "\\(^\\|:\\)" (regexp-quote nix-profile-bin) "\\($\\|:\\)")
       (getenv "PATH"))
    (setenv "PATH" (concat nix-profile-bin ":" (getenv "PATH")))
    (setq exec-path (cons nix-profile-bin exec-path))))

;; Global packages
(use-package! evil
  :config
  (map! :i "C-S-V" #'clipboard-yank)
  (map! :v "C-S-C" #'clipboard-kill-ring-save))

;; Org packages
(use-package! org
  :init
  (setq org-directory "~/org/")
  :config
  (setq!
   org-format-latex-options (plist-put org-format-latex-options :scale 2.5)
   org-startup-with-latex-preview t)
  (add-to-list 'org-latex-packages-alist
            '("" "mathtools" t))

  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-k" #'org-metaup)
  (setq org-return-follows-link t))

(use-package! org-roam
  :init
  (setq org-roam-directory (expand-file-name "roam" org-directory))
  (setq org-roam-db-location (expand-file-name "org-roam.db" org-roam-directory))
  :config
  (org-roam-db-autosync-mode)
  (org-roam-update-org-id-locations)
  (setq org-roam-capture-templates
        '(("d" "/d/efault" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)
          ("p" "/p/arameter" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+FILETAGS: parameter")
           :unnarrowed t)
          ("r" "p/r/oblem" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+FILETAGS: problem")
           :unnarrowed t)
          ("P" "/P/aper" plain "%?"
           :target (file+head
                    "%(if (boundp 'citar-org-notes-path-hack) citar-org-notes-path-hack (expand-file-name (or citar-org-roam-subdir \"\") org-roam-directory))/${citar-citekey}.org"
                    "#+title: ${citar-citekey} (${citar-date}). ${note-title}.\n#+FILETAGS: paper\n\n")
           :unnarrowed t))))
          

(use-package! org-caldav
  :after org
  :init
  ;; Actual calendar configuration
  (private-calendar-server-config)
  (setq
   org-caldav-calendar-id "org"
   org-caldav-my-base-dir (expand-file-name "cal" org-directory)
   org-caldav-inbox (expand-file-name "inbox.org" org-caldav-my-base-dir)
   org-caldav-files (directory-files-recursively org-caldav-my-base-dir ".*\.org"))

  (setq
   org-icalendar-timezone "Europe/Berlin"
   org-icalendar-include-todo 'all
   org-icalendar-use-scheduled '(todo-start event-if-not-todo)
   org-caldav-sync-todo t)

  :config
  (map!
   :map org-mode-map
   :localleader
   :n "S" #'org-caldav-sync))
;; enable <localleader> S to sync also in org-agenda mode
(after! (:and org-caldav org-agenda)
  (map!
   :map org-agenda-mode-map
   :localleader
   :n "S" #'org-caldav-sync))

;; org-noter
(use-package! org-noter
  :after org
  :config
  (setq org-noter-auto-save-last-location t))

;; Bibliography management
(use-package! citar
  :no-require
  :custom
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography)
  :config
  (map! :leader :desc "insert citation" :n "B i" #'citar-insert-citation)
  (map! :leader :desc "insert key" :n "B k" #'citar-insert-key)
  (map! :leader :desc "open" :n "B o" #'citar-open)
  (map! :leader :desc "open" :n "B n" #'citar-open-notes)
  (map! :leader :desc "open at point" :n "B p" #'citar-dwim)
  (map! :leader :desc "open in library" :n "B l" #'citar-open-files)
  (map! :leader :desc "open entry" :n "B e" #'citar-open-entry)
  (map! :leader :desc "add file to library" :n "B a" #'citar-add-file-to-library))

(use-package citar-org-roam
  :after (citar org-roam)
  :config
  (citar-org-roam-mode)
  :custom
  (citar-org-roam-capture-template-key "P"))
org-format-latex-options

;; yas-snippet stuff
(defun disable-require-final-newline ()
  (setq require-final-newline nil))
(use-package! yasnippet
 :config
  ;; Remove default TAB keybindings
  ;; (define-key yas-minor-mode-map (kbd "<tab>") nil)
  ;; (define-key yas-minor-mode-map (kbd "TAB") nil)

  ;; Define new keybinding
  (map!
   :map yas-minor-mode-map
   :i "M-w" #'yas-expand))

;; latex
(use-package! latex
  :config
  (map!
   :map latex-mode-map
   :leader
   :n "t P" #'latex-preview-pane-mode))

;; Magit
(use-package! magit
  :config
  (set-ssh-auth-to-gpg-socket))
