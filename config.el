;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

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
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;; do `visual' to make folded text not count as a billion lines. Does make
;; wrapped around lines count as multiple lines though.
(setq display-line-numbers-type 'visual)

;; Enable visual line navigation
;; shit aint working
;; (setq line-move-visual t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


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

(defun qleguennec/set-frame-transparency (&optional frame)
  (interactive)
  (let ((frame (or frame (selected-frame))))
    (set-frame-parameter frame 'alpha-background 90)))

(dolist (frame (visible-frame-list))
  (qleguennec/set-frame-transparency frame))

(add-to-list 'after-make-frame-functions
             #'qleguennec/set-frame-transparency)

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

;; Set the font size for headers in org mode
(custom-set-faces
 '(org-level-1 ((t (:height 1.5 :weight bold))))
 '(org-level-2 ((t (:height 1.3 :weight bold))))
 '(org-level-3 ((t (:height 1.2))))
 '(org-level-4 ((t (:height 1.1)))))

;; Determine what should automatically be added to the top of created org files
(defun my/org-default-headers ()
  (when (and (string= (file-name-extension (or buffer-file-name "")) "org")
             (= (buffer-size) 0)) ;; Only add if file is empty
    (let* ((title (replace-regexp-in-string "_" " " (file-name-base buffer-file-name)))
           (capitalized-title (concat (upcase (substring title 0 1)) (substring title 1))))
      (unless (save-excursion (goto-char (point-min)) (re-search-forward "^#\\+title:" nil t))
        (insert "#+title: " capitalized-title "\n"))
      (unless (save-excursion (goto-char (point-min)) (re-search-forward "^#\\+startup:" nil t))
        (insert "#+startup: content\n"))
      (unless (save-excursion (goto-char (point-min)) (re-search-forward "^#\\+SETUPFILE:" nil t))
        (insert "#+SETUPFILE: ~/.config/doom/jake-latex-standard.setup\n\n")))))
(add-hook 'org-mode-hook #'my/org-default-headers)

;; keybindings
(map! :leader
      :desc "Open main notes file"
      "o n" #'(lambda () (interactive) (find-file "~/notes/main.org")))

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

;; get tabs of buffers
(use-package! centaur-tabs
  :hook (doom-first-buffer . centaur-tabs-mode)
  :config
  (setq centaur-tabs-style "bar"
        centaur-tabs-set-bar 'over
        centaur-tabs-set-icons t
        centaur-tabs-set-close-button nil
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "•"
        centaur-tabs-cycle-scope 'tabs)) ; Only cycle through visible tabs (buffers)

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
