;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(load! "lisp/process_org_agenda_item")
(load! "lisp/emacspeak_logic")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "DejaVu Sans Mono" :size 14)
      doom-variable-pitch-font (font-spec :family "DejaVu Sans Mono" :size 14))

;; load theme and set custom faces
(setq doom-theme 'doom-lantern)
(custom-set-faces!
  '(hl-line :background "#32221d") ; background color of the line that the cursor is on
  '(org-level-1 :foreground "#eda553" :height 1.5 :weight bold)
  '(org-level-2 :height 1.3 :weight bold)
  '(org-level-3 :height 1.2 :weight bold)
  '(org-level-4 :height 1.1 :weight bold)
  '(org-scheduled-today :foreground "#eda553")
  '(org-scheduled :foreground "#aa6a1f")
  '(org-code :foreground "#f97400")
  '(org-verbatim :foreground "#91d80d")
  '(org-link :foreground "#65a1a2")
  )

(setq display-line-numbers-type 'visual)

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

(use-package lsp-pyright
  :ensure t
  :custom (lsp-pyright-langserver-command "pyright") ;; or basedpyright
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp))))  ; or lsp-deferred

;; Set time it takes until auto-complete popup appears
(after! company
  (setq company-idle-delay 0.15))
;; Set time it takes until auto-complete popup appears... again. idfk the difference
(after! corfu
  (setq corfu-auto-delay 0.15))



;; Determine what should automatically be added to the top of created org files
;; this is not run when making an org file using org-roam
(defun my/org-default-headers ()
  (when (and buffer-file-name
             (not (org-roam-file-p))
             (string= (file-name-extension buffer-file-name) "org")
             (= (buffer-size) 0))
    (let* ((title (replace-regexp-in-string "_" " " (file-name-base buffer-file-name)))
           (capitalized-title
            (concat (upcase (substring title 0 1))
                    (substring title 1))))
      
      (unless (save-excursion
                (goto-char (point-min))
                (re-search-forward "^#\\+title:" nil t))
        (insert "#+title: " capitalized-title "\n"))

      (unless (save-excursion
                (goto-char (point-min))
                (re-search-forward "^#\\+startup:" nil t))
        (insert "#+startup: content\n"))

      (unless (save-excursion
                (goto-char (point-min))
                (re-search-forward "^#\\+SETUPFILE:" nil t))
        (insert "#+SETUPFILE: ~/.config/doom/latex-template.setup\n\n")))))
(add-hook 'org-mode-hook #'my/org-default-headers)



;; keybindings
(map! :leader
      :desc "Open main notes file"
      "o n" #'(lambda () (interactive) (find-file "~/notes/main.org")))
(map! :leader
      :desc "Open agenda (shortcut)"
      "o o" #'(lambda () (interactive) (find-file  "~/notes/tasks/tasks.org") (org-agenda nil "u")))
(after! org-agenda
  (define-key org-agenda-keymap
    (kbd "ä")
    #'my/org-agenda-process-item))
(map! :leader
      :desc "Start emacspeak with predefined settings"
      "e s" #'my/load-emacspeak)
(map! :leader
      :desc "open org-roam-ui graph"
      "n r g" #'(lambda () (interactive) (org-roam-ui-mode)))
(map! :after org ; make the org agenda possible to close down with "z x" like you can with other buffers
      :map org-agenda-mode-map
      (:prefix ("z")
       "x" #'doom/kill-this-buffer))

;; make visual lines (wrapped around lines) able to be navigated through more intuitively
(map!
 :nvm "<up>"   #'evil-previous-visual-line
 :nvm "k"   #'evil-previous-visual-line
 :o   "<up>"   #'evil-previous-line
 :o   "k"   #'evil-previous-line
 :nvm "<down>" #'evil-next-visual-line
 :nvm "j" #'evil-next-visual-line
 :o   "<down>" #'evil-next-line
 :o   "j" #'evil-next-line
 :nvm "<home>" #'evil-beginning-of-visual-line
 :nvm "<end>"  #'evil-end-of-visual-line)

;; make all image links show up as images instead of text by default when opening an org file
(after! org
  (setq org-startup-with-inline-images t)
  (add-hook 'org-mode-hook #'org-display-inline-images))

;; enable beacon package
(use-package! beacon
  :diminish
  :config
  (setq beacon-color "#666666"
        beacon-blink-when-window-scrolls t) ; Customize the beacon color
  (beacon-mode 1))                          ; Enable beacon mode globally

;; setting up a plain LaTeX class or some shit
(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("org-plain-latex"
                 "\\documentclass{article}
           [NO-DEFAULT-PACKAGES]
           [PACKAGES]
           [EXTRA]"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;; Disable company-mode (autocomplete thingimabob) in org-mode
(setq company-global-modes '(not text-mode org-mode))


;; shit for making is so that the line number type is visual by default, but relative when in an operator pending state like when about to delete or yank stuff
;; ----------
(defvar my/line-numbers-before-operator nil
  "Stores the line number display style before operator pending state.")

(defun my/enable-relative-line-numbers ()
  (setq my/line-numbers-before-operator display-line-numbers-type)
  (setq display-line-numbers-type 'relative)
  (display-line-numbers-mode 1))

(defun my/restore-line-numbers ()
  (when my/line-numbers-before-operator
    (setq display-line-numbers-type my/line-numbers-before-operator)
    (setq my/line-numbers-before-operator nil)
    (display-line-numbers-mode 1)))

(add-hook 'evil-operator-state-entry-hook #'my/enable-relative-line-numbers)
(add-hook 'evil-operator-state-exit-hook #'my/restore-line-numbers)
;; ----------

;; make lua indent with 4 spaces instead of 2
(after! lua-mode
  (setq lua-indent-level 4))

;; make c++ indent with 4 spaces instead of 2
(after! cc-mode
  (setq c-basic-offest 4))

(after! lsp-mode
  (setq lsp-rust-analyzer-server-command '("~/.local/bin/rust-analyzer")))

(after! org
  (add-to-list 'org-agenda-files "~/notes/tasks/tasks.org"))

(after! org
  (setq org-agenda-custom-commands
        '(("u" "Agenda + Unscheduled TODOs"
           ((agenda "")
            (alltodo ""
                     ((org-agenda-skip-function
                       '(org-agenda-skip-entry-if 'scheduled 'deadline))
                      (org-agenda-overriding-header "Unscheduled TODOs"))))))))


;; override surround pairs to remove spaces for brackets
(after! evil-surround
  (dolist (p '((?\[ . ("[" . "]"))
               (?\( . ("(" . ")"))
               (?\{ . ("{" . "}"))
               (?\< . ("<" . ">"))))
    (let ((existing (assoc (car p) evil-surround-pairs-alist)))
      (if existing
          (setcdr existing (cdr p))
        (push p evil-surround-pairs-alist)))))

(use-package! odin-mode
  :mode "\\.odin\\'")

(setq scroll-margin 10
      scroll-conservatively 101)



;; set up org-roam and org-roam-ui stuff
(setq org-roam-directory (file-truename "~/notes/org-roam/"))
; make the filename of created files not be dogshit
(setq org-roam-capture-templates
      '(("d" "default" plain "%?"
         :target (file+head "${slug}.org"
                            "#+title: ${title}\n#+startup: content\n\n")
         :unnarrowed t)))
; org-roam-ui stuff
(use-package! org-roam-ui
  :after org-roam
  :hook (org-roam-mode . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-startup t))
