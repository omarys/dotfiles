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
    org-journal-dir "~/Dev/Org/Journal/"
    ;; Breathtaking, clear todo states mapping perfectly to GTD
    org-todo-keywords
    '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "|" "DONE(d)" "KILL(k)"))
    ;; Gorgeous aesthetic styling matching the Dracula theme
    org-todo-keyword-faces
    '(("TODO" . (:foreground "#ff5555" :weight bold)
        ("STRT" . (:foreground "#f1fa8c" :weight bold))
        ("WAIT" . (:foreground "#ffb86c" :weight bold))
        ("DONE" . (:foreground "#50fa7b" :weight bold))
        ("KILL" . (:foreground "#6272a4" :weight bold :strike-through t))))
    ;; Quality of life logging & visuals
    org-log-done 'time
    org-log-into-drawer t
    org-fontify-done-headline t
    org-fontify-quote-and-verse-blocks t
    org-hide-emphasis-markers t
    org-pretty-entities t)

  ;; Dynamic directory-based agenda files (loads instantly and catches new captures in real-time)
  (setq org-agenda-files
    (list
      (concat org-directory "Agenda/inbox.org")
      (concat org-directory "Agenda/personal.org")
      (concat org-directory "Agenda/work.org")
      (concat org-directory "Agenda/school.org")
      (concat org-directory "Roam/Inbox/")
      (concat org-directory "Roam/Jira/")
      (concat org-directory "Roam/Tasks/")
      (concat org-directory "Roam/Projects/")
      (concat org-directory "Roam/Meetings/")))

  ;; Refresh the Agenda view automatically when any capture is finalized
  (add-hook 'org-capture-after-finalize-hook
    (lambda ()
      (when (get-buffer "*Org Agenda*")
        (with-current-buffer "*Org Agenda*"
          (org-agenda-redo t)))))

  ;; Premium Outlining & Refiling (move tasks between inbox, personal, and work files seamlessly)
  (setq org-refile-targets
    '((nil :maxlevel . 3
        ("personal.org" :maxlevel . 3)
        ("work.org" :maxlevel . 3)
        ("school.org" :maxlevel . 3)))
    org-refile-use-outline-path 'file
    org-outline-path-complete-in-steps nil)

  ;; Global quick capture templates for capturing reminders and quick tasks from anywhere in Emacs
  (setq org-capture-templates
    '(("t" "Personal Todo" entry
        (file+headline "~/Dev/Org/Agenda/inbox.org" "Personal Tasks")
        "* TODO %?\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n%a"
        :prepend t
        ("w" "Work Todo" entry
          (file+headline "~/Dev/Org/Agenda/inbox.org" "Work Tasks")
          "* TODO %?\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n%a"
          :prepend t)
        ("r" "Reminder" entry
          (file+headline "~/Dev/Org/Agenda/inbox.org" "Reminders")
          "* TODO %? :reminder:\nSCHEDULED: %^t\n:PROPERTIES:\n:Created: %U\n:END:\n%i"
          :prepend t))))

  ;; Premium Custom Unified Dashboard
  (setq org-agenda-custom-commands
    '(("d" "Unified Work & Life Dashboard"
        ((agenda "" ((org-agenda-span 'day
                       (org-agenda-start-on-weekday nil)
                       (org-agenda-overriding-header "⚡ Today's Schedule & Deadlines")))
           (todo "STRT"
             ((org-agenda-overriding-header "🔥 Active / In-Progress Tasks")))
           (tags-todo "inbox"
             ((org-agenda-overriding-header "📥 Inbox & Quick Reminders (Need Refiling)")))
           (tags-todo "jira"
             ((org-agenda-overriding-header "🎫 Jira Ticket Stubs")))
           (tags-todo "work|task"
             ((org-agenda-overriding-header "💼 Active Work Tasks")))
           (tags-todo "personal|family|school"
             ((org-agenda-overriding-header "🏡 Active Personal & Life Tasks")))
           (todo "WAIT"
             ((org-agenda-overriding-header "⏳ Blocked / Waiting on Others"))))))))

  ;; Directly launch the dashboard bypassing the dispatcher menu
  (defun my/org-agenda-dashboard ()
    "Directly launch the custom Org Agenda Unified Dashboard."
    (interactive)
    (org-agenda nil "d"))

  (map! :leader
    :desc "Unified Agenda Dashboard" "o d" #'my/org-agenda-dashboard))

(after! org-roam
  (setq org-roam-directory "~/Dev/Org/Roam/"
    org-roam-db-location "~/Dev/Org/Roam/org-roam.db")

  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))

  (org-roam-db-autosync-mode)

  ;; Org-roam leader hotkeys
  (map! :leader
    (:prefix-map ("n" . "notes")
      :desc "Find node"        "f" #'org-roam-node-find
      :desc "Insert node"      "i" #'org-roam-node-insert
      (:prefix-map ("c" . "capture")
        :desc "Roam capture menu" "c" #'org-roam-capture
        :desc "Jira ticket stub"  "j" (lambda () (interactive) (org-roam-capture nil "j"))
        :desc "Inbox roam note"   "i" (lambda () (interactive) (org-roam-capture nil "i"))
        :desc "Work task note"    "w" (lambda () (interactive) (org-roam-capture nil "w"))
        :desc "Meeting notes"     "m" (lambda () (interactive) (org-roam-capture nil "m"))
        :desc "Default note"      "d" (lambda () (interactive) (org-roam-capture nil "d")))
      :desc "Roam buffer"      "r" #'org-roam-buffer-toggle
      :desc "Graph"            "g" #'org-roam-graph
      :desc "Capture today"    "j" #'org-roam-dailies-capture-today
      :desc "Goto today"       "t" #'org-roam-dailies-goto-today
      :desc "Goto tomorrow"    "T" #'org-roam-dailies-goto-tomorrow
      :desc "Goto yesterday"   "y" #'org-roam-dailies-goto-yesterday
      :desc "Goto date"        "d" #'org-roam-dailies-goto-date
      :desc "Capture date"     "D" #'org-roam-dailies-capture-date))

  ;; Org-roam node capture templates (clean, flat, collision-proof structure)
  (setq org-roam-capture-templates
    '(("d" "Default Note" plain
        "%?"
        :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                  "#+title: ${title}\n#+created: %U\n")
        :unnarrowed t

        ("j" "Jira Ticket Stub" plain
          "* TODO ${title} :jira:\n:PROPERTIES:\n:Jira-Key: %^{Jira key, optional}\n:Created: %U\n:END:\n\n** Description\n%^{Description}\n\n** Definition of Done\n%(my/org-capture-jira-dod)\n\n** Notes\n%?"
          :target (file+head "Jira/%<%Y%m%d%H%M%S>-${slug}.org"
                    "#+title: ${title}\n#+filetags: :jira:ticket:\n#+created: %U\n")
          :unnarrowed t)

        ("i" "Inbox Roam Note" plain
          "* TODO ${title} :inbox:\n:PROPERTIES:\n:Created: %U\n:END:\n\n%?"
          :target (file+head "Inbox/%<%Y%m%d%H%M%S>-${slug}.org"
                    "#+title: ${title}\n#+filetags: :inbox:\n#+created: %U\n")
          :unnarrowed t)

        ("w" "Work Task Note" plain
          "* TODO ${title} :work:task:\n:PROPERTIES:\n:Created: %U\n:Context: %^{Context|OpenCTI|Kubernetes|Terraform|AWS|Docs|Other}\n:END:\n\n** Background / Why\n%?\n\n** Next Action Items\n- [ ] "
          :target (file+head "Tasks/%<%Y%m%d%H%M%S>-${slug}.org"
                    "#+title: ${title}\n#+filetags: :work:task:\n#+created: %U\n")
          :unnarrowed t)

        ("m" "Meeting Notes" plain
          "* ${title} :meeting:\n:PROPERTIES:\n:Created: %U\n:Attendees: %^{Attendees}\n:END:\n\n** Agenda / Purpose\n%?\n\n** Notes & Discussion\n\n** Decisions\n- \n\n** Action Items\n- [ ] "
          :target (file+head "Meetings/%<%Y%m%d%H%M%S>-${slug}.org"
                    "#+title: ${title}\n#+filetags: :meeting:work:\n#+created: %U\n")
          :unnarrowed t))))

  ;; Org-roam daily/journal capture templates
  (setq org-roam-dailies-directory "Daily/")

  (setq org-roam-dailies-capture-templates
    '(("J" "Journal" entry
        "* %U

%?"
        :target
        (file+head
          "%<%Y-%m-%d>.org"
          "#+title: %<%Y-%m-%d>
#+filetags: :journal:daily:
")))))

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
    '(:yaml (:schemas [(:kubernetes ["/*.yaml" "!kustomization.yaml" "!*.sops.yaml"]
                         "https://json.schemastore.org/kustomization.json" ["kustomization.yaml"])])
       :validate t
       :hover t
       :completion t))
  (setq eglot-stay-out-of '(mode-line)))


(after! vterm
  (add-to-list 'vterm-keymap-exceptions "C-SPC"))

(defun my-flycheck-parse-trivy-json (output checker buffer)
  "Parse Trivy JSON output into Flycheck errors."
  (let ((errors nil
          (json-data (condition-case nil
                       (json-parse-string output :object-type 'alist :array-type 'list)
                       (error nil)))))
    (when json-data
      (let ((results (alist-get 'Results json-data)))
        (dolist (result results)
          (let ((target (alist-get 'Target result)
                  (misconfigs (alist-get 'Misconfigurations result))))
            (dolist (m misconfigs)
              (let* ((line (or (alist-get 'StartLine (alist-get 'IacMetadata m)) 1)
                       (msg (format "[%s] %s" (alist-get 'ID m) (alist-get 'Title m)))
                       (severity-raw (alist-get 'Severity m))
                       (level (if (member severity-raw '("HIGH" "CRITICAL")) 'error 'warning))))
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
    ((info line-start (file-name) ":" line " " (id) " DL" (message) line-end
       (warning line-start (file-name) ":" line " " (id) " SC" (message) line-end)
       (error line-start (file-name) ":" line " " (id) " " (message) line-end)))
    :modes dockerfile-mode))

(add-to-list 'flycheck-checkers 'dockerfile-hadolint)
(add-to-list 'flycheck-checkers 'terraform-tfsec)
(add-to-list 'flycheck-checkers 'checkov)
(add-to-list 'flycheck-checkers 'k8s-trivy-json)

;; Fixed the truncated function names here
(flycheck-add-next-checker 'terraform-tfsec '(warning . k8s-trivy-json))
(flycheck-add-next-checker 'k8s-trivy-json '(warning . checkov))

(when (memq window-system '(mac ns x))
  (setq exec-path-from-shell-variables '("PATH" "MANPATH" "FNM_DIR" "FNM_MULTISHELL_PATH"))
  (exec-path-from-shell-initialize))

(after! auth-source
  (add-to-list 'auth-sources 'pass))

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

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(after! flycheck
  (setq flycheck-textlint-config "~/.config/textlint/textlintrc")
  (setq-default flycheck-disabled-checkers '(proselint markdown-markdownlint-cli markdown-mdl)))

(after! flycheck
  (add-to-list 'flycheck-textlint-plugin-alist '(org-mode . "org"))
  (add-to-list 'flycheck-textlint-plugin-alist '(latex-mode . "latex")))

(require 'subr-x)

(defun my/org-capture-jira-dod ()
  "Prompt for Definition of Done checklist items."
  (let ((items '()
          (item "")))
    (while (not (string-empty-p
                  (setq item (read-string "Done criterion, blank to finish: "))))
      (push item items))
    (mapconcat
      (lambda (x) (concat "- [ ] " x))
      (nreverse items)
      "\n")))

(after! org-journal
  (setq org-journal-file-format "%Y%m%d.org.gpg")
  (setq org-journal-enable-encryption t)
  (setq epa-file-encrypt-to nil))
