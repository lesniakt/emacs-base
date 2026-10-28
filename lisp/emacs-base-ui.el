;;; emacs-base-ui.el --- Display and editing conventions -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: MIT
;; Copyright (c) 2026 Thomas Lesniak

(defcustom emacs-base-font-height 120 "Default font height in tenths of a point."
  :type 'integer :group 'faces)

(defun emacs-base-setup-frame (&optional frame)
  "Apply graphical settings to FRAME without affecting terminals."
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (set-frame-parameter frame 'vertical-scroll-bars nil)
      (set-frame-parameter frame 'tool-bar-lines 0)
      (set-frame-parameter frame 'left-fringe 10)
      (set-frame-parameter frame 'right-fringe 10)
      (dolist (face '(default fixed-pitch))
        (set-face-attribute face frame :family "Fira Code" :height emacs-base-font-height))
      (set-face-attribute 'variable-pitch frame :family "Cantarell"
                          :height emacs-base-font-height))))
(add-hook 'after-make-frame-functions #'emacs-base-setup-frame)
(emacs-base-setup-frame)

(use-package doom-themes :config (load-theme 'doom-dracula t))
(use-package doom-modeline :config (doom-modeline-mode 1))
(use-package which-key :config (which-key-mode 1))
(use-package evil
  :init (setq evil-want-keybinding nil evil-want-C-u-scroll t
              evil-want-C-i-jump nil evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") #'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") #'evil-delete-backward-char-and-join)
  (evil-global-set-key 'motion "j" #'evil-next-visual-line)
  (evil-global-set-key 'motion "k" #'evil-previous-visual-line))
(use-package general
  :config
  (general-create-definer emacs-base-leader
    :states '(normal visual insert emacs) :prefix "SPC" :global-prefix "C-SPC")
  (emacs-base-leader "t" '(:ignore t :which-key "toggles")
                     "tt" #'counsel-load-theme))
(use-package ivy
  :bind (("C-s" . swiper))
  :config
  (ivy-mode 1)
  (define-key ivy-minibuffer-map (kbd "C-j") #'ivy-next-line)
  (define-key ivy-minibuffer-map (kbd "C-k") #'ivy-previous-line)
  (define-key ivy-minibuffer-map (kbd "TAB") #'ivy-alt-done))
(use-package ivy-rich :config (ivy-rich-mode 1))
(use-package counsel
  :bind (("C-M-j" . counsel-switch-buffer))
  :config (counsel-mode 1))
(use-package helpful
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-command] . helpful-command)
         ([remap describe-key] . helpful-key)))
(use-package hydra
  :config
  (defhydra emacs-base-text-size (:timeout 4)
    "Text size" ("j" text-scale-increase) ("k" text-scale-decrease) ("f" nil :exit t))
  (emacs-base-leader "ts" #'emacs-base-text-size/body))
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(provide 'emacs-base-ui)
;;; emacs-base-ui.el ends here
