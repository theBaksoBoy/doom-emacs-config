;;; lisp/emacspeak-logic.el -*- lexical-binding: t; -*-

(defun my/load-emacspeak ()
  "Load emacspeak, settings, and disable auditory icons in org files"
  (interactive)

  (load-file "/usr/share/emacs/site-lisp/emacspeak/lisp/emacspeak-setup.el")

  ; it's unfortunate that auditory icons are disabled globally, but they cause a lot of issues with org files and in some other scenarios
  (setq-default emacspeak-use-auditory-icons nil)
  (setq emacspeak-use-auditory-icons nil)

  ; turn off character echo
  (emacspeak-toggle-character-echo)

  ; change speech speed
  (dtk-set-rate 300)
  )
