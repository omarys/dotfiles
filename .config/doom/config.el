;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Scott O'Mary"
      user-full-address "omaryscott@gmail.com")

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(font . "CaskaydiaCove Nerd Font Mono-14"))
(setq doom-font "CaskaydiaCove Nerd Font Mono:pixelsize=18")
(unless (doom-font-exists-p doom-font)
  (setq doom-font nil))

(remove-hook 'after-init-hook #'savehist-mode)

(setq doom-theme 'dracula)

(setq display-line-numbers-type t
      evil-want-fine-undo t)

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

;; (after! org
;;   (setq org-time-stamp-formats '("<%Y-%m-%d %a %H:%M>" . "<%Y-%m-%d %a %H:%M>")))

(after! org-roam
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n\n")
           :unnarrowed t)
          ("p" "project" plain "* Overview\n\n%?\n\n* Tasks\n** TODO Define initial tasks\n"
           :target (file+head "projects/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+category: ${title}\n#+filetags: :Project:\n")
           :unnarrowed t)
          ("t" "tech/dev" plain "%?"
           :target (file+head "tech/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :Tech:\n\n* Reference/Links\n\n* Notes\n")
           :unnarrowed t)))

  ;; Ensure the backlinks buffer shows up on the right side and is readable
  (setq org-roam-mode-sections
        (list #'org-roam-backlinks-section
              #'org-roam-reflinks-section
              #'org-roam-unlinked-references-section)))

(org-roam-db-autosync-mode)

(plist-put! +ligatures-extra-symbols
            :and           nil
            :or            nil
            :for           nil
            :not           nil
            :true          nil
            :false         nil
            :int           nil
            :float         nil
            :str           nil
            :bool          nil
            :list          nil)

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

(setq browse-url-browser-function 'eww-browse-url)

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

(after! spell-fu
  (setq spell-fu-idle-delay 1))

(map! :leader
      (:prefix-map ("m l" . "LLM")
       :desc "Launch Gptel" "g" #'gptel
       :desc "Gptel Menu" "m" #'gptel-menu
       :desc "Abort Gptel" "a" #'gptel-abort
       :desc "Add snippet to gptel" "c" #'gptel-add
       :desc "Add file to gptel" "f" #'gptel-add-file
       :desc "Send to Gptel" "RET" #'gptel-send))

(beacon-mode 1)

(map! :leader
      (:prefix-map ("m f" . "Firefox")
       :desc  "Launch in Firefox" "f" #'browse-url-firefox))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :config
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  (add-to-list 'copilot-indentation-alist '(org-mode 2))
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(closure-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))

  ;; 1. Standard Copilot keybindings (when Company is NOT active)
  (map! :map copilot-completion-map
        "<tab>"   #'copilot-accept-completion
        "TAB"     #'copilot-accept-completion
        "C-TAB"   #'copilot-accept-completion-by-word
        "C-<tab>" #'copilot-accept-completion-by-word
        "C-n"     #'copilot-next-completion
        "C-p"     #'copilot-previous-completion))

;; 2. The Traffic Cop (Resolves conflicts when Company IS active)
(after! (company copilot)
  (defun my/copilot-accept-if-visible ()
    "Accept Copilot if visible, otherwise accept Company."
    (interactive)
    (if (copilot--overlay-visible)
        (copilot-accept-completion)
      (company-complete-selection)))

  ;; 3. Tell Company to use our new function for TAB
  (map! :map company-active-map
        "<tab>" #'my/copilot-accept-if-visible
        "TAB"   #'my/copilot-accept-if-visible))

(after! eglot
  (setq-default eglot-workspace-configuration
                '(:yaml (:schemas (:kubernetes ["/*.yaml" "!kustomization.yaml" "!kustomization.yml"]
                                   :https://json.schemastore.org/kustomization.json ["kustomization.yaml" "kustomization.yml"])
                                  :validate t
                                  :hover t
                                  :schemaStore (:enable t))
                  :copilot (:editorConfiguration (:enableAutoCompletions t)
                            :pluginConfiguration (:inlineSuggest (:enable t))))))

(use-package! eglot-booster
  :after eglot
  :config (eglot-booster-mode))

;; 1. The custom parser function goes at the top level
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

;; 2. Your consolidated Flycheck block
(after! flycheck
  (add-to-list 'flycheck-checkers 'textlint)
  (setq flycheck-textlint-config "~/.config/textlint/.textlintrc")

  ;; Terraform tfsec
  (flycheck-define-checker terraform-tfsec
    "A Terraform security scanner."
    :command ("tfsec" "--format" "csv" source)
    :error-patterns
    ((warning line-start (file-name) "," line "," (message) line-end))
    :modes terraform-mode)

  ;; Checkov
  (flycheck-define-checker checkov
    "A static code analysis tool for infrastructure-as-code."
    :command ("checkov" "-f" source "--output" "cli" "--quiet")
    :error-patterns
    ((error line-start "Check: " (id) ":" (message) " failed in file " (file-name) ":" line line-end))
    :modes (yaml-mode terraform-mode))

  ;; Our new custom Trivy JSON checker
  (flycheck-define-checker k8s-trivy-json
    "A Kubernetes/IaC scanner using Trivy with a custom JSON parser."
    :command ("trivy" "config" "--format" "json" source)
    :error-parser my-flycheck-parse-trivy-json
    :modes (yaml-mode terraform-mode))

  ;; Register the checkers
  (add-to-list 'flycheck-checkers 'terraform-tfsec)
  (add-to-list 'flycheck-checkers 'checkov)
  (add-to-list 'flycheck-checkers 'k8s-trivy-json)

  (flycheck-add-next-checker 'terraform-tfsec '(warning . k8s-trivy-json))
  (flycheck-add-next-checker 'k8s-trivy-json '(warning . checkov)))

(use-package! gptel
  :config
  (setq! gptel-model 'gemini-2.5-pro)
  (setq! gptel-backend
         (gptel-make-gemini "Gemini"
           :key (lambda ()
                  (let ((secret (plist-get (car (auth-source-search
                                                 :host "api.generative.googleapis.com"
                                                 :user "apikey"))
                                           :secret)))
                    (if (functionp secret) (funcall secret) secret)))
           :stream t)))

(after! vterm
  (add-to-list 'vterm-keymap-exceptions "C-SPC"))

(when (memq window-system '(mac ns x))
  (setq exec-path-from-shell-variables '("PATH" "MANPATH" "FNM_DIR" "FNM_MULTISHELL_PATH"))
  (exec-path-from-shell-initialize))

(when (boundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1)
  (setq pixel-scroll-precision-interpolate-page t
        pixel-scroll-precision-interpolate-mice t
        pixel-scroll-precision-use-momentum t))
