;;; emacs-base-development.el --- Projects and language tools -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 Thomas Lesniak

(use-package magit
  :demand t
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))
(use-package projectile
  :bind-keymap ("C-c p" . projectile-command-map)
  :config (projectile-mode 1))
(use-package counsel-projectile :config (counsel-projectile-mode 1))
(use-package company :hook (prog-mode . company-mode)
  :custom (company-idle-delay 0.0) (company-minimum-prefix-length 1))
(use-package company-box
  :hook (company-mode . (lambda () (when (display-graphic-p) (company-box-mode 1)))))
(use-package kotlin-mode :mode "\\.kts?\\'")
(use-package typescript-mode :mode "\\.tsx?\\'")
(use-package evil-nerd-commenter :bind ("M-;" . evilnc-comment-or-uncomment-lines))
(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))

(use-package forge :after magit)

(require 'emacs-base-lsp)
(provide 'emacs-base-development)
;;; emacs-base-development.el ends here
