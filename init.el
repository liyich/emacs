(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
;;------------------------update package---------------------------------
(require 'cl)
;; Add Packages
(defvar my/packages '(
		      ;; --- Auto-completion ---
		      company
		      company-web
		      company-php
		      ;; --- check ---
		      flycheck
		      ;; --- tree ---
		      neotree
		      ;; --- Better Editor ---
		      yasnippet
		      auctex
		      ace-jump-mode
		      ;; --- vim ---
		      evil
		      evil-leader
		      evil-nerd-commenter
		      ;;hungry-delete
		      ;;swiper
		      ;;counsel
		      ;;smartparens
		      ;; --- Major Mode ---
		      web-mode
		      ;;php-mode
		      ;;js2-mode
		      ;; --- Minor Mode ---
		      ;;nodejs-repl
		      ;;exec-path-from-shell
		      ;; --- Themes ---
		      ;;monokai-theme
		      solarized-theme
		      ) "Default packages")

(setq package-selected-packages my/packages)
(defun my/packages-installed-p ()
  (loop for pkg in my/packages
	when (not (package-installed-p pkg)) do (return nil)
	finally (return t)))
(unless (my/packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg my/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))
;; Find Executable Path on OS X
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;;-----------------------------------------------init emacs ------------------------------------------------------
(setq inhibit-splash-screen 1)
(set-face-attribute 'default nil :height 170)
(global-hl-line-mode 1)
;;(load-theme 'monokai t)
(load-theme 'solarized-dark t)
(electric-pair-mode t)
(show-paren-mode t)
(global-linum-mode)
;;(set-frame-parameter (selected-frame) 'alpha (list 85 50))
;;(add-to-list 'default-frame-alist (cons 'alpha (list 85 50)))
(tool-bar-mode -1)
(defun open-init-file()
  (interactive)
  (find-file "~/.emacs.d/init.el"))



;;------------------------------------------ -------------------------------------------------------------
(require 'company-web-html)                          ; load company mode html backend
(require 'company-web-jade)                          ; load company mode jade backend
(require 'company-web-slim) 
(require 'company-php)
;;-----------------------------------------neotree -------------------------------------------------
(require 'neotree)
(global-set-key [f2] 'neotree-toggle)
  (add-hook 'neotree-mode-hook
            (lambda ()
              (define-key evil-normal-state-local-map (kbd "s") 'neotree-enter-vertical-split)
              (define-key evil-normal-state-local-map (kbd "H") 'neotree-hidden-file-toggle)
              (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
              (define-key evil-normal-state-local-map (kbd "o") 'neotree-enter)))
 (setq neo-smart-open t)
;;----------------------------------------set web mode------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

;;--------------------------------------key map --------------------------------------------------
;;auto complete key 
(global-set-key (kbd "M-/") 'company-complete)
(global-set-key (kbd "<backtab>") 'company-ispell)
(global-set-key (kbd "<f3>") 'open-init-file)
(global-set-key (kbd "<f4>") 'load-file)

;;------------------------------------------ company mode --------------------------------------
(add-hook 'after-init-hook 'global-company-mode)
(setq company-minimum-prefix-length 1);
(setq company-idle-delay .0)     

(add-hook 'web-mode-hook (lambda ()
			   (set (make-local-variable 'company-backends) '((company-web-html ) ))
			   (company-mode t)))
(add-hook 'php-mode-hook  (lambda()
				(set
				 (make-local-variable 'company-backends) '((company-ac-php-backend company-dabbrev-code))
				 )
				
				)
	  )
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
;;------------------------------------------------ vim --------------------------------------------------
(evil-mode 1)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "w" 'web-mode
  "c" 'c++-mode
  "p" 'php-mode
  "s" 'split-window-horizontally
  "l" 'windmove-right
  "j" 'windmove-down
  "k" 'windmove-up
  "h" 'windmove-left
  "[" 'shrink-window-horizontally
  "]" 'enlarge-window-horizontally
  "f" 'ace-jump-mode
  )
(evilnc-default-hotkeys)
(define-key evil-normal-state-map (kbd "//") 'evilnc-comment-or-uncomment-lines)
(define-key evil-visual-state-map (kbd "//") 'evilnc-comment-or-uncomment-lines)
;;-----------------------------------------------------flycheck -------------------------------------------
(add-hook 'after-init-hook #'global-flycheck-mode)

;;-----------------------------------------------------latex -------------------------------------------
;;---------------------------------------------------- yasnippet -------------------------------------------
   (require 'yasnippet)
;;; use popup menu for yas-choose-value
   (yas-global-mode 1)
;; Add yasnippet support for all company backends
;;https://github.com/syl20bnr/spacemacs/pull/179
(defvar company-mode/enable-yas t "Enable yasnippet for all backends.")
(defun company-mode/backend-with-yas (backend)
 (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
      backend
    (append (if (consp backend) backend (list backend))
           '(:with company-yasnippet))))

(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
;;---------------------------------------------------------- tab --------------------------------------------
(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
    (backward-char 1)
    (if (looking-at "->") t nil)))))

(defun do-yas-expand ()
  (let ((yas/fallback-behavior 'return-nil))
    (yas/expand)))

(defun tab-indent-or-complete ()
  (interactive)
  (cond
   ((minibufferp)
    (minibuffer-complete))
   (t
    (indent-for-tab-command)
    (if (or (not yas/minor-mode)
        (null (do-yas-expand)))
    (if (check-expansion)
        (progn
          (company-manual-begin)
          (if (null company-candidates)
          (progn
            (company-abort)
            (indent-for-tab-command)))))))))

(defun tab-complete-or-next-field ()
  (interactive)
  (if (or (not yas/minor-mode)
      (null (do-yas-expand)))
      (if company-candidates
      (company-complete-selection)
    (if (check-expansion)
      (progn
        (company-manual-begin)
        (if (null company-candidates)
        (progn
          (company-abort)
          (yas-next-field))))
      (yas-next-field)))))

(defun expand-snippet-or-complete-selection ()
  (interactive)
  (if (or (not yas/minor-mode)
      (null (do-yas-expand))
      (company-abort))
      (company-complete-selection)))

(defun abort-company-or-yas ()
  (interactive)
  (if (null company-candidates)
      (yas-abort-snippet)
    (company-abort)))

(global-set-key [tab] 'tab-indent-or-complete)
(global-set-key (kbd "TAB") 'tab-indent-or-complete)
(global-set-key [(control return)] 'company-complete-common)

(define-key company-active-map [tab] 'expand-snippet-or-complete-selection)
(define-key company-active-map (kbd "TAB") 'expand-snippet-or-complete-selection)

(define-key yas-minor-mode-map [tab] nil)
(define-key yas-minor-mode-map (kbd "TAB") nil)

(define-key yas-keymap [tab] 'tab-complete-or-next-field)
(define-key yas-keymap (kbd "TAB") 'tab-complete-or-next-field)
(define-key yas-keymap [(control tab)] 'yas-next-field)
(define-key yas-keymap (kbd "C-g") 'abort-company-or-yas)

