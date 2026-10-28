;;; emacs-base-org.el --- General Org workflow -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 Thomas Lesniak

(require 'org)
(require 'org-id)
(require 'org-clock)
(require 'org-capture)
(require 'org-agenda)

;; Joining strings here avoids resolving a remote home directory during startup.
(setq org-directory (or (alist-get 'orgDirectory emacs-base-settings) "~/org"))
(defun emacs-base-org-file (name)
  "Return NAME under `org-directory', without accessing the filesystem."
  (concat (file-name-as-directory org-directory) name))
(defun emacs-base-org-target (name)
  "Prepare an Org capture target named NAME, only when it is requested."
  (let ((target (emacs-base-org-file name)))
    (make-directory (file-name-directory target) t)
    target))
(defun emacs-base-open-inbox ()
  "Open the task inbox."
  (interactive)
  (find-file (emacs-base-org-target "TaskInbox.org")))
(defun emacs-base-journal ()
  "Capture a journal entry."
  (interactive)
  (org-capture nil "jj"))

(setq org-agenda-files
      (mapcar #'emacs-base-org-file
              (or (alist-get 'agendaFiles emacs-base-settings) '("TaskInbox.org")))
      org-log-done 'time
      org-log-into-drawer t
      org-agenda-start-with-log-mode t
      org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)"))
      org-refile-targets '((org-agenda-files :maxlevel . 3))
      org-capture-templates
      '(("t" "Tasks")
        ("tt" "Task" entry (file (lambda () (emacs-base-org-target "TaskInbox.org")))
         "* TODO %?%i\n%U\n%a\n" :empty-lines 1)
        ("n" "Note" entry (file (lambda () (emacs-base-org-target "Notes.org")))
         "* %?%i\n%U\n%a\n" :empty-lines 1)
        ("j" "Journal")
        ("jj" "Journal" entry
         (file+olp+datetree (lambda () (emacs-base-org-target "Journal.org")))
         "* %<%H:%M> %?%i\n" :empty-lines 1)
        ("jm" "Meeting" entry
         (file+olp+datetree (lambda () (emacs-base-org-target "Journal.org")))
         "* %<%H:%M> Meeting: %? :meeting:\n%a\n" :empty-lines 1)))
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c j") #'emacs-base-journal)
(global-set-key (kbd "C-c l") #'org-store-link)
(emacs-base-leader "o" '(:ignore t :which-key "org")
                   "oi" #'emacs-base-open-inbox "oa" #'org-agenda "oc" #'org-capture)

(defun emacs-base-org-display ()
  "Apply the document layout to an Org buffer."
  (org-indent-mode 1)
  (visual-line-mode 1)
  (when (display-graphic-p) (variable-pitch-mode 1))
  (setq-local visual-fill-column-width 100 visual-fill-column-center-text t)
  (visual-fill-column-mode 1))
(use-package org-bullets :hook (org-mode . org-bullets-mode))
(use-package visual-fill-column :commands visual-fill-column-mode)
(add-hook 'org-mode-hook #'emacs-base-org-display)
(dolist (face '(org-block org-table org-code org-verbatim))
  (set-face-attribute face nil :inherit 'fixed-pitch))
(require 'org-tempo)
(dolist (template '(("sh" . "src shell") ("el" . "src emacs-lisp") ("py" . "src python")))
  (add-to-list 'org-structure-template-alist template))
(provide 'emacs-base-org)
;;; emacs-base-org.el ends here
