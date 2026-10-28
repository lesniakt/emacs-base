;;; no-network.el --- Catch unexpected startup traffic -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: MIT
(defvar emacs-base-test-warnings nil)
(advice-add 'display-warning :before
            (lambda (_type message &optional level _buffer)
              (when (memq level '(:warning :error))
                (push message emacs-base-test-warnings))))
(defun emacs-base-test-deny-network (&rest _)
  (error "Unexpected network access during initialization"))
(advice-add 'make-network-process :override #'emacs-base-test-deny-network)
(advice-add 'open-network-stream :override #'emacs-base-test-deny-network)
(advice-add 'package-refresh-contents :override #'emacs-base-test-deny-network)
(advice-add 'package-install :override #'emacs-base-test-deny-network)
