;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Scott O'Mary"
      user-full-address "omaryscott@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
(add-to-list 'default-frame-alist '(font . "CaskaydiaCove Nerd Font Mono-14"))
(setq doom-font "CaskaydiaCove Nerd Font Mono:pixelsize=18")
(unless (doom-font-exists-p doom-font)
  (setq doom-font nil))
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'dracula)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t
      evil-want-fine-undo t)


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
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

(after! evil-snipe
  (evil-snipe-mode -1))

(map! :map general-override-mode-map :nv "s" #'evil-substitute)
(map! :map general-override-mode-map :nv "S" #'evil-change-whole-line)


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


(setq mu4e-maildir "~/.mail"
      mu4e-attachment-dir "~/Downloads")

(setq user-mail-address "scottomary@proton.me"
      user-full-name  "Scott O'Mary")

;; Get mail
(setq mu4e-get-mail-command "mbsync protonmail"
      mu4e-change-filenames-when-moving t   ; needed for mbsync
      mu4e-update-interval 120)             ; update every 2 minutes

;; Send mail
(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-auth-credentials "~/.authinfo.gpg"
      smtpmail-smtp-server "127.0.0.1"
      smtpmail-stream-type 'starttls
      smtpmail-smtp-service 1025)

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

;; Silence compiler warnings as they can be pretty disruptive
(setq comp-async-report-warnings-errors nil)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
