;;; emacs-base.el --- Portable editor configuration -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 Thomas Lesniak

(defvar emacs-base-settings nil "Settings supplied by the Home Manager module.")
(make-directory user-emacs-directory t)
(require 'use-package)
(setq use-package-always-ensure nil
      inhibit-startup-message t
      visible-bell t)
(global-auto-revert-mode 1)
(column-number-mode 1)
(menu-bar-mode -1)
(global-set-key (kbd "<escape>") #'keyboard-escape-quit)

(require 'emacs-base-ui)
(require 'emacs-base-org)
(require 'emacs-base-development)
;; Forge adds Magit transient entries before Evil Collection remaps them.
(use-package evil-collection :config (evil-collection-init))
(provide 'emacs-base)
;;; emacs-base.el ends here
