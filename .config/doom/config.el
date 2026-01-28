;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Scott O'Mary"
      user-full-address "omaryscott@gmail.com")

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(font . "CaskaydiaCove Nerd Font Mono-14"))
(setq doom-font "CaskaydiaCove Nerd Font Mono:pixelsize=18")
(unless (doom-font-exists-p doom-font)
  (setq doom-font nil))

(remove-hook 'after-init-hook #'savehist-mode)

(let ((file-path "~/.passwords/Keys/gemini_api.key"))
  (if (file-exists-p file-path)
      (let ((file-contents
             (with-temp-buffer
               (insert-file-contents file-path)
               (buffer-string))))
        (setq
         gptel-model 'gemini-2.5-pro-exp-03-25
         gptel-backend (gptel-make-gemini "Gemini" :key file-contents :stream t)))
    (message "File not found: %s" file-path)))

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

(after! org
  (setq org-time-stamp-formats '("<%Y-%m-%d %a %H:%M>" . "<%Y-%m-%d %a %H:%M>")))

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

(use-package! gptel)
:config
(gptel-make-ollama "Ollama"             ; Name for the backend
  :host "localhost:11434"               ;  Ollama host
  :header t
  :stream t                             ; Enable streaming responses
  :models '("devstral:latest"
            "deepseek-coder-v2:latest"
            "deepseek-r1:latest"
            "gemma3:latest"
            "qwen2.5-coder:latest")) ; List of available models
(setq gptel-mode 'org)

(map! :leader
      (:prefix-map ("m l" . "LLM")
       :desc "Launch Gptel" "g" #'gptel
       :desc "Gptel Menu" "m" #'gptel-menu
       :desc "Abort Gptel" "a" #'gptel-abort
       :desc "Send to Gptel" "RET" #'gptel-send))

(beacon-mode 1)

(map! :leader
      (:prefix-map ("m f" . "Firefox")
       :desc  "Launch in Firefox" "f" #'browse-url-firefox))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)
              ("C-n" . 'copilot-next-completion)
              ("C-p" . 'copilot-previous-completion))

  :config
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  (add-to-list 'copilot-indentation-alist '(org-mode 2))
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(closure-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2)))

(after! flycheck
  (add-to-list 'flycheck-checkers 'textlint)
  (setq flycheck-textlint-config "~/.config/textlint/.textlintrc")) ;; Optional: specify a custom config file
