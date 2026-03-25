;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Scott O'Mary"
      user-full-address "omaryscott@gmail.com")
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(font . "CaskaydiaCove Nerd Font Mono-14"))
(setq doom-font "CaskaydiaCove Nerd Font Mono:pixelsize=18")
(unless (doom-font-exists-p doom-font)
  (setq doom-font nil))
(setq doom-theme 'dracula)
(setq display-line-numbers-type t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(run-with-idle-timer 2 nil (lambda () (require 'gptel)))
(require 'transient)
(setq gptel-model 'gemini-2.5-flash)

(after! spell-fu
  (add-hook 'prog-mode-hook (lambda () (spell-fu-mode -1)))
  (dolist (hook '(yaml-mode-hook
                  yaml-ts-mode-hook
                  conf-mode-hook
                  json-mode-hook))
    (add-hook hook (lambda () (spell-fu-mode -1)))))

(after! org
  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-k" #'org-metaup)
  (setq org-directory "~/Dev/Org/"
        org-roam-directory "~/Dev/Org/Roam/"
        org-roam-db-location "~/Dev/Org/Roam/org-roam.db"
        org-journal-dir "~/Dev/Org/Journal/"
        org-agenda-files (list
                          (concat org-directory "Agenda/personal.org")
                          (concat org-directory "Agenda/work.org")
                          (concat org-directory "Agenda/school.org"))
        org-todo-keywords '((sequence "TODO(t)" "INPROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELED(c)"))
        org-todo-keywords-for-agenda '((sequence "TODO" "INPROGRESS" "WAITING" "|" "DONE" "CANCELED"))))

(after! org-roam
  (setq org-roam-directory "~/Dev/Org/Roam/"
        org-roam-db-location "~/Dev/Org/Roam/org-roam.db")
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  (org-roam-db-autosync-mode))

(plist-put! +ligatures-extra-symbols
            :and nil :or nil :for nil :not nil :true nil :false nil :int nil
            :float nil :str nil :bool nil :list nil)

(setq rmh-elfeed-org-files (list "~/Dev/Org/Elfeed/elfeed.org")
      elfeed-db-directory "~/.elfeed"
      elfeed-use-curl t)

(after! elfeed
  (require 'elfeed-org)
  (elfeed-org)
  (defun my/elfeed-load-and-update ()
    (interactive)
    (elfeed)
    (elfeed-update))
  (map! :leader
        :desc "Open & update Elfeed" "o n" #'my/elfeed-load-and-update))

(defun window-split-toggle ()
  "Toggle between horizontal and vertical split with two windows."
  (interactive)
  (if (> (length (window-list)) 2)
      (error "Can't toggle with more than 2 windows!")
    (let ((func (if (window-full-height-p)
                    #'split-window-vertically
                  #'split-window-horizontally)))
      (delete-other-windows)
      (funcall func)
      (save-selected-window
        (other-window 1)
        (switch-to-buffer (other-buffer))))))

(map! :leader
      (:prefix-map ("t" . "toggle")
                   (:desc "Invert-Split" "i" #'window-split-toggle)))

(use-package! beacon
  :hook (doom-first-input . beacon-mode) ; Starts beacon as soon as you start typing
  :config
  (setq beacon-color "#666666" ; You can customize the flash color here
        beacon-size 40))       ; and the size of the "blink"

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :config
  (setq copilot-indent-offset-alist '((t . nil)))

  (map! :map copilot-completion-map
        "<tab>" #'copilot-accept-completion
        "TAB"    #'copilot-accept-completion
        "C-TAB"  #'copilot-accept-completion-by-word))

(after! eglot
  (setq-default eglot-workspace-configuration
                '(:yaml (:schemas [(:kubernetes ["/*.yaml" "!kustomization.yaml" "!*.sops.yaml"])
                                   "https://json.schemastore.org/kustomization.json" ["kustomization.yaml"]])
                  :validate t
                  :hover t
                  :completion t))
  (setq eglot-stay-out-of '(mode-line)))


(after! vterm
  (add-to-list 'vterm-keymap-exceptions "C-SPC"))

(defun my-flycheck-parse-trivy-json (output checker buffer)
  "Parse Trivy JSON output into Flycheck errors."
  (let ((errors nil)
        (json-data (condition-case nil
                       (json-parse-string output :object-type 'alist :array-type 'list)
                     (error nil))))
    (when json-data
      (let ((results (alist-get 'Results json-data)))
        (dolist (result results)
          (let ((target (alist-get 'Target result))
                (misconfigs (alist-get 'Misconfigurations result)))
            (dolist (m misconfigs)
              (let* ((line (or (alist-get 'StartLine (alist-get 'IacMetadata m)) 1))
                     (msg (format "[%s] %s" (alist-get 'ID m) (alist-get 'Title m)))
                     (severity-raw (alist-get 'Severity m))
                     (level (if (member severity-raw '("HIGH" "CRITICAL")) 'error 'warning)))
                (push (flycheck-error-new-at
                       line nil level msg
                       :checker checker
                       :buffer buffer
                       :filename target)
                      errors)))))))
    (nreverse errors)))

(after! flycheck
  (flycheck-define-checker terraform-tfsec
    "A Terraform security scanner."
    :command ("tfsec" "--format" "csv" source)
    :error-patterns
    ((warning line-start (file-name) "," line "," (message) line-end))
    :modes terraform-mode)

  (flycheck-define-checker checkov
    "A static code analysis tool for infrastructure-as-code."
    :command ("checkov" "-f" source "--output" "cli" "--quiet")
    :error-patterns
    ((error line-start "Check: " (id) ":" (message) " failed in file " (file-name) ":" line line-end))
    :modes (yaml-mode terraform-mode))

  (flycheck-define-checker k8s-trivy-json
    "A Kubernetes/IaC scanner using Trivy with a custom JSON parser."
    :command ("trivy" "config" "--format" "json" source)
    :error-parser my-flycheck-parse-trivy-json
    :modes (yaml-mode terraform-mode))

  (flycheck-define-checker dockerfile-hadolint
    "A Dockerfile linter using Hadolint."
    :command ("hadolint" "--format" "tty" source)
    :error-patterns
    ((info line-start (file-name) ":" line " " (id) " DL" (message) line-end)
     (warning line-start (file-name) ":" line " " (id) " SC" (message) line-end)
     (error line-start (file-name) ":" line " " (id) " " (message) line-end))
    :modes dockerfile-mode)

  (add-to-list 'flycheck-checkers 'dockerfile-hadolint)
  (add-to-list 'flycheck-checkers 'terraform-tfsec)
  (add-to-list 'flycheck-checkers 'checkov)
  (add-to-list 'flycheck-checkers 'k8s-trivy-json)

  (flycheck-add-next-checker 'terraform-tfsec '(warning . k8s-trivy-json))
  (flycheck-add-next-checker 'k8s-trivy-json '(warning . checkov)))

(when (memq window-system '(mac ns x))
  (setq exec-path-from-shell-variables '("PATH" "MANPATH" "FNM_DIR" "FNM_MULTISHELL_PATH"))
  (exec-path-from-shell-initialize))

(after! auth-source
  (add-to-list 'auth-sources 'pass))

(after! gptel
  (setopt gptel-backend
          (gptel-make-gemini "Gemini"
            :key (lambda () (auth-source-pass-get 'secret "gemini_api_key"))
            :stream t))

  (setq gptel-model 'gemini-2.5-flash
        gptel-models '(gemini-3.1-pro-preview
                       gemini-3-flash-preview
                       gemini-3-deep-think-preview
                       gemini-2.5-pro
                       gemini-2.5-flash))

  (map! :leader
        (:prefix-map ("o" . "open")
         :desc "Gemini Model Switcher" "m" #'my-gptel-model-switcher)))

(defun my-gptel-model-indicator ()
  "Display the current gptel model name in a condensed format."
  (when (bound-and-true-p gptel-model)
    (let ((model-name (symbol-name gptel-model)))
      (cond
       ((string-match "3.1-pro" model-name)  " [G:Pro]")
       ((string-match "3-flash" model-name) " [G:Flash]")
       ((string-match "deep-think" model-name) " [G:Deep]")
       ((string-match "2.5-pro" model-name)  " [G:2.5P]")
       ((string-match "2.5-flash" model-name)  " [G:2.5F]")
       (t (concat " [G:" model-name "]"))))))

;; Add the indicator to the global mode line
(add-to-list 'global-mode-string '(:eval (my-gptel-model-indicator)))


(transient-define-prefix my-gptel-model-switcher ()
  ["Gemini Models (March 2026)"
   ("p" "3.1 Pro (Reasoning)" (lambda () (interactive)
                                (setq gptel-model 'gemini-3.1-pro-preview)
                                (force-mode-line-update)
                                (message "Switched to Gemini 3.1 Pro")))
   ("f" "3 Flash (Speed)"     (lambda () (interactive)
                                (setq gptel-model 'gemini-3-flash-preview)
                                (force-mode-line-update)
                                (message "Switched to Gemini 3 Flash")))
   ("d" "Deep Think (Expert)" (lambda () (interactive)
                                (setq gptel-model 'gemini-3-deep-think-preview)
                                (force-mode-line-update)
                                (message "Switched to Deep Think")))
   ("s" "2.5 Pro (Stable)"    (lambda () (interactive)
                                (setq gptel-model 'gemini-2.5-pro)
                                (force-mode-line-update)
                                (message "Switched to Gemini 2.5 Pro")))
   ("a" "2.5 Flash (Stable)"  (lambda () (interactive)
                                (setq gptel-model 'gemini-2.5-flash)
                                (force-mode-line-update)
                                (message "Switched to Gemini 2.5 Flash")))])

(defun my-copilot-modeline-indicator ()
  "Display a Copilot icon/status in the modeline."
  (when (bound-and-true-p copilot-mode)
    (propertize " 🤖 " 'face 'warning)))

(add-to-list 'global-mode-string '(:eval (my-copilot-modeline-indicator)))

(defun my-eglot-modeline-indicator ()
  "Display an LSP indicator if Eglot is active in the current buffer."
  (when (bound-and-true-p eglot--managed-mode)
    (propertize " [LSP]" 'face 'success))) ;; 'success' usually makes it green in Doom

(add-to-list 'global-mode-string '(:eval (my-eglot-modeline-indicator)))

(after! treemacs
  (setq treemacs-follow-mode t))
