;;; .emacs --- Configuração pessoal do Emacs

;; ------------------------------------------------------------------
;; Configurações Básicas
;; ------------------------------------------------------------------

;; Desativa mensagem inicial
(setq inhibit-startup-message t)

;; Comportamento de rolagem
(setq scroll-preserve-screen-position t)

;; Configurações de arquivos
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; Aparência
(setq-default cursor-type 'bar)

;; Configuração híbrida (relativa + absoluta na linha atual)
(add-hook 'prog-mode-hook 
          (lambda ()
            (display-line-numbers-mode 1)
            (setq display-line-numbers-type 'relative)
            (setq display-line-numbers-current-absolute t)))

;; OPÇÃO 1: Números globais à esquerda, relativos à direita
(defvar-local my/global-line-overlays nil
  "Lista de overlays para números globais.")

(defun my/clear-global-line-numbers ()
  "Remove todos os overlays de números globais."
  (dolist (overlay my/global-line-overlays)
    (delete-overlay overlay))
  (setq my/global-line-overlays nil))

(defun my/create-global-line-numbers ()
  "Cria overlays com números globais à esquerda da numeração relativa."
  (my/clear-global-line-numbers)
  (save-excursion
    (goto-char (point-min))
    (let ((line-num 1))
      (while (not (eobp))
        (let ((overlay (make-overlay (line-beginning-position) 
                                     (line-beginning-position))))
          (overlay-put overlay 'before-string 
                       (propertize (format "│%5d " line-num)
                                   'face 'line-number
                                   'display '((margin left-margin))))
          (push overlay my/global-line-overlays))
        (setq line-num (1+ line-num))
        (forward-line 1)))))

(defun my/setup-dual-line-numbers ()
  "Configura numeração dupla: global (extrema esquerda) + híbrida (direita)."
  ;; Primeiro desabilita a numeração padrão
  (display-line-numbers-mode -1)
  ;; Configura margem para números globais
  (my/create-global-line-numbers)
  ;; Reabilita com configuração híbrida
  (display-line-numbers-mode 1)
  (setq display-line-numbers-type 'relative)
  (setq display-line-numbers-current-absolute t))

;; Adiciona o hook apenas para modos de programação
(add-hook 'prog-mode-hook #'my/setup-dual-line-numbers)

;; Atualiza quando o buffer muda
(add-hook 'after-change-functions 
          (lambda (&rest _) 
            (when (and (derived-mode-p 'prog-mode) my/global-line-overlays)
              (run-with-idle-timer 0.1 nil #'my/create-global-line-numbers))))

;; Limpa overlays ao sair do modo
(add-hook 'prog-mode-hook
          (lambda ()
            (add-hook 'kill-buffer-hook #'my/clear-global-line-numbers nil t)))


(tab-bar-mode 1)
(scroll-bar-mode -1)
(electric-pair-mode 1)
(tool-bar-mode 0)
(set-face-attribute 'default nil
                    :font (font-spec :name "JetBrains Mono"
                                     :weight 'normal
                                     :slant 'normal
                                     :size 14))

;; Configuração de TAB
(setq-default indent-tabs-mode t)
(setq-default tab-width 4)

;; ------------------------------------------------------------------
;; Gerenciamento de Pacotes
;; ------------------------------------------------------------------

;; Configuração do package.el
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(package-initialize)

;; Instala use-package se necessário
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; ------------------------------------------------------------------
;; Pacotes Essenciais
;; ------------------------------------------------------------------

;; Evil Mode
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (setq evil-normal-state-cursor '(box "white"))
  (setq evil-insert-state-cursor '(bar "white"))
  ;; Navegar entre tabs
  (evil-global-set-key 'normal "g9" 'tab-previous)
  (evil-global-set-key 'normal "g0" 'tab-next)
  ;; Criar nova tab
  (evil-global-set-key 'normal "gt" 'tab-new)
  ;; Fechar tab
  (evil-global-set-key 'normal "gw" 'tab-close)
  ;; Alternar entre janelas
  (evil-define-key 'normal evil-normal-state-map (kbd "C-<tab>") 'other-window))

;; Outros pacotes
(use-package quelpa
  :ensure t)

(use-package quelpa-use-package
  :ensure t
  :config
  (quelpa-use-package-activate-advice))

(use-package try :ensure t)

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package gruvbox-theme
  :ensure t
  :config
  (load-theme 'gruvbox-dark-hard t))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(marginalia-mode 1)

;; ------------------------------------------------------------------
;; IDE Features
;; ------------------------------------------------------------------

;; Neotree
(use-package neotree
  :ensure t
  :bind (("C-/" . neotree-toggle)
         ("C-c C-/" . neotree-dir))
  :config
  (setq neo-smart-open t)
  (setq neo-window-fixed-size nil)
  (setq neo-window-width 35)
  (setq neo-theme 'arrow)
  (setq neo-theme 'icons))

;; Code folding
(use-package hs-minor-mode
  :hook (prog-mode . hs-minor-mode)
  :bind (("C-c k" . hs-hide-block)
         ("C-c j" . hs-show-block)))

;; Ferramentas de desenvolvimento
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))

(use-package swiper
  :ensure t
  :bind (("C-s" . swiper-isearch)))

(use-package ace-window
  :ensure t
  :bind (("M-o" . ace-window)))

(use-package eat
  :ensure t
  :bind (("C-c t" . (lambda () (interactive) (split-window-below) (other-window 1) (eat)))))

;; Autocompletamento
(use-package company
  :ensure t
  :config
  (global-company-mode 1))

(use-package company-ansible :ensure t)
(use-package company-shell :ensure t)
(use-package company-terraform :ensure t)

;; Lua
(use-package company-lua
  :quelpa (company-lua :fetcher github :repo "ptrv/company-lua"))

;; GO
(use-package company-go
  :quelpa (company-go :fetcher github :repo "emacsattic/company-go"))

;; ------------------------------------------------------------------
;; Configuração Python
;; ------------------------------------------------------------------

;; Define o nível de indentação no Python para 4 espaços
(setq python-indent-offset 4)

;; Define o interpretador padrão como "python3"
(setq python-shell-interpreter "python3")


;; ===================
;; LSP (Language Server)
;; ===================

(use-package lsp-mode
  :ensure t
  :init
  ;; Prefixo para os atalhos do LSP
  (setq lsp-keymap-prefix "C-c l")
  :hook ((python-mode . lsp-deferred)
         (sh-mode . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))
  :config
  ;; Desabilita log detalhado
  (setq lsp-log-io nil)
  ;; Usa flycheck ao invés de flymake
  (setq lsp-prefer-flymake nil)
  ;; Tempo ocioso antes de acionar o LSP (em segundos)
  (setq lsp-idle-delay 0.3)
  ;; Opção extra para destacar erros de parsing no Bash
  (setq lsp-bash-highlight-parsing-errors t))


;; =======
;; Pyright
;; =======

(use-package lsp-pyright
  :ensure t
  :after lsp-mode
  :custom
  ;; Caminho para o executável do Python
  (lsp-pyright-python-executable-cmd "python3")
  ;; Nível de checagem de tipos (pode ser: off, basic, strict)
  (setq lsp-pyright-typechecking-mode "basic")
  ;; Caminho para ambientes virtuais
  (setq lsp-pyright-venv-path "~/.virtualenvs"))


;; ===================
;; Interface gráfica para LSP
;; ===================

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :commands lsp-ui-mode
  :config
  ;; Ativa documentação flutuante
  (setq lsp-ui-doc-enable t)
  ;; Posição da doc: pode ser top, bottom, left, right
  (setq lsp-ui-doc-position 'bottom)
  ;; Mostra ações de código no sideline
  (setq lsp-ui-sideline-show-code-actions t))

;; ======================================
;; Ações ao abrir arquivos Python
;; --------------------------------------

(add-hook 'python-mode-hook
          (lambda ()
            ;; Atalhos LSP
            (local-set-key (kbd "C-c r") 'lsp-rename)
            (local-set-key (kbd "C-c d") 'lsp-ui-doc-show)))


;; ------------------------------------------------------------------
;; Outras Linguagens
;; ------------------------------------------------------------------

;; Rust
(use-package rust-mode :ensure t)
(use-package rustic :ensure t)
(use-package cargo :ensure t)

;; Modo Web
(use-package web-mode :ensure t)
(use-package emmet-mode :ensure t)

;; Jenkinsfile e Groovy
(use-package groovy-mode :ensure t :after cc-mode)

;; Docker
(use-package dockerfile-mode :ensure t)
(use-package docker :ensure t :bind ("C-c d" . docker))

;; YAML
(use-package yaml-mode :ensure t)
(use-package docker-compose-mode :ensure t)

;; Lua
(use-package lua-mode :ensure t)

;; Go
(use-package go-mode :ensure t)

;; ------------------------------------------------------------------
;; Interface
;; ------------------------------------------------------------------

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-items '((recents . 10))))

(use-package page-break-lines
  :ensure t
  :config
  (global-page-break-lines-mode))

(setq initial-buffer-choice (lambda () (get-buffer-create "dashboard")))

;; ------------------------------------------------------------------
;; Atalhos Globais
;; ------------------------------------------------------------------

;; Swiper
(global-set-key (kbd "C-s") 'swiper-isearch)

;; Ação para fechar buffer e janela
(global-set-key (kbd "C-x C-q")
                (lambda ()
                  (interactive)
                  (kill-this-buffer)
                  (when (not (one-window-p))
                    (delete-window))))

;; ------------------------------------------------------------------
;; Configurações de Tema
;; ------------------------------------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(gruvbox-dark-hard))
 '(custom-safe-themes
   '("8363207a952efb78e917230f5a4d3326b2916c63237c1f61d7e5fe07def8d378"
	 "01f347a923dd21661412d4c5a7c7655bf17fb311b57ddbdbd6fce87bd7e58de6"
	 "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8"
	 "8d3ef5ff6273f2a552152c7febc40eabca26bae05bd12bc85062e2dc224cde9a"
	 "921f165deb8030167d44eaa82e85fcef0254b212439b550a9b6c924f281b5695"
	 "d97ac0baa0b67be4f7523795621ea5096939a47e8b46378f79e78846e0e4ad3d"
	 "0c83e0b50946e39e237769ad368a08f2cd1c854ccbcd1a01d39fdce4d6f86478"
	 "4b88b7ca61eb48bb22e2a4b589be66ba31ba805860db9ed51b4c484f3ef612a7"
	 "b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19"
	 "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69"
	 "7771c8496c10162220af0ca7b7e61459cb42d18c35ce272a63461c0fc1336015"
	 "e4a702e262c3e3501dfe25091621fe12cd63c7845221687e36a79e17cf3a67e0"
	 "e8bd9bbf6506afca133125b0be48b1f033b1c8647c628652ab7a2fe065c10ef0"
	 "3061706fa92759264751c64950df09b285e3a2d3a9db771e99bcbb2f9b470037"
	 "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d"
	 "fffef514346b2a43900e1c7ea2bc7d84cbdd4aa66c1b51946aade4b8d343b55a"
	 "22a0d47fe2e6159e2f15449fcb90bbf2fe1940b185ff143995cc604ead1ea171"
	 "9b9d7a851a8e26f294e778e02c8df25c8a3b15170e6f9fd6965ac5f2544ef2a9"
	 "7de64ff2bb2f94d7679a7e9019e23c3bf1a6a04ba54341c36e7cf2d2e56e2bcc"
	 default))
 '(package-selected-packages
   '(ace-window all-the-icons cargo company-ansible company-go
				company-lua company-shell company-terraform dashboard
				docker docker-compose-mode dockerfile-mode eat
				emmet-mode evil groovy-mode gruvbox-theme
				linum-relative lsp-pyright lsp-ui marginalia neotree
				page-break-lines pyvenv quelpa-use-package rustic
				swiper try web-mode)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

