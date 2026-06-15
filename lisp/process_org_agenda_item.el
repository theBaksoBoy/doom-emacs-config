;;; lisp/process_org_agenda_item.el -*- lexical-binding: t; -*-

(defun my/open-agenda-shortcut ()
  (interactive)
  (find-file "~/notes/tasks/tasks.org")
  (org-agenda nil "u"))

(defun my/org-agenda-process-item ()
  (interactive)

  (let ((my-saved-point (point)))

    (org-agenda-switch-to)

    (org-back-to-heading t)
    (beginning-of-line)
    (forward-char 2)

    (let ((first-char (char-after)))

      (cond
       ((eq first-char ?!)
        (message "Protected item"))

       ((eq first-char ?+)
        (let ((repeat-token
               (buffer-substring-no-properties
                (point)
                (save-excursion
                  (skip-chars-forward "^ ")
                  (point)))))

          (org-schedule nil repeat-token)
          (save-buffer)
          (my/open-agenda-shortcut)
          (goto-char my-saved-point)))

       (t
        (org-cut-subtree)
        (save-buffer)
        (my/open-agenda-shortcut)
        (goto-char my-saved-point))))))
