;;; emacs-base-lsp.el --- Explicit local and remote LSP -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 Thomas Lesniak

;; Never download servers into either the local or remote user's home.
(setq lsp-enable-suggest-server-download nil
      lsp-keymap-prefix "C-c L")
(require 'lsp-mode)
(use-package lsp-ui :commands lsp-ui-mode :hook (lsp-mode . lsp-ui-mode))
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

;; Distinct remote clients prevent local store paths from reaching the SSH host.
;; Commands are resolved in the remote login environment, not on the Mac.
(dolist (spec '((emacs-base-remote-c (c-mode c++-mode c-ts-mode c++-ts-mode) "clangd")
                (emacs-base-remote-kotlin (kotlin-mode) "kotlin-language-server")
                (emacs-base-remote-typescript (typescript-mode typescript-ts-mode tsx-ts-mode)
                                             "typescript-language-server" "--stdio")))
  (lsp-register-client
   (make-lsp-client :server-id (nth 0 spec) :major-modes (nth 1 spec)
                    :new-connection (lsp-tramp-connection (nthcdr 2 spec))
                    :remote? t :priority 1)))

;; Start with M-x lsp. Consumers can add lsp-deferred to their chosen mode hooks.
;; Merely opening a file must not prompt for server installation or SSH access.
(provide 'emacs-base-lsp)
;;; emacs-base-lsp.el ends here
