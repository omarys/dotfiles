;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! dracula-theme)
(package! beacon)
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))
(package! exec-path-from-shell)
