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

(setq org-directory "~/org/")

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

(org-roam-db-autosync-mode)

;; (plist-put! +ligatures-extra-symbols
;;             :and           nil
;;             :or            nil
;;             :for           nil
;;             :not           nil
;;             :true          nil
;;             :false         nil
;;             :int           nil
;;             :float         nil
;;             :str           nil
;;             :bool          nil
;;             :list          nil)

(let ((ligatures-to-disable '(:true :false :int :float :str :bool :list :and :or :for :not)))
  (dolist (sym ligatures-to-disable)
    (plist-put! +ligatures-extra-symbols sym nil)))

(require 'elfeed-org)
(elfeed-org)
(setq rmh-elfeed-org-files (list "~/Dev/Org/Elfeed/elfeed.org"))
(setq elfeed-db-directory "~/.elfeed")
(setq elfeed-use-curl t)

(map! :leader
      (:prefix-map ("o" . "open")
                   (:desc "elfeed" "l" #'elfeed)))

(map! :leader
      (:prefix-map ("e" . "easy")
                   (:prefix ("e" . "elfeed")
                    :desc "Filter feeds" "f" #'elfeed-search-set-filter
                    :desc "Clear filter" "c" #'elfeed-search-clear-filter
                    :desc "Update feeds" "u" #'elfeed-update)))

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
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word))
  :config
  ;; This bit is crucial: It tells Copilot to take priority over
  ;; Corfu/Company when a suggestion is visible.
  (defun my-copilot-tab-or-default ()
    (interactive)
    (if (copilot--overlay-visible-p)
        (copilot-accept-completion)
      (execute-kbd-macro (kbd "TAB")))))

;; Optional: If you find TAB conflicts too annoying, use the "Fish" style
;; where Right Arrow accepts the suggestion.
;; (define-key copilot-completion-map (kbd "<right>") 'copilot-accept-completion)


;; Eglot Booster usually works out of the box with Corfu,
;; but this ensures they stay snappy.
(after! eglot
  (setq completion-category-defaults nil))

(after! eglot
  (setq-default eglot-workspace-configuration
                '(:yaml (:schemas (:kubernetes ["/*.yaml" "!kustomization.yaml" "!kustomization.yml"]
                                   :https://json.schemastore.org/kustomization.json ["kustomization.yaml" "kustomization.yml"])
                                  :validate t
                                  :hover t
                                  :schemaStore (:enable t))
                  :copilot (:editorConfiguration (:enableAutoCompletions t)
                            :pluginConfiguration (:inlineSuggest (:enable t))))))

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

(use-package! gptel
  :config
  (setq! gptel-model 'gemini-1.5-pro)
  (setq! gptel-backend
         (gptel-make-gemini "Gemini"
           :key (lambda ()
                  ;; This looks specifically in your password-store
                  (auth-source-pass-get 'secret "gemini_api_key"))
           :stream t)))
