;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File name: ` ~/.emacs '
;;; ---------------------
;;;
;;; If you need your own personal ~/.emacs
;;; please make a copy of this file
;;; an placein your changes and/or extension.
;;;
;;; Copyright (c) 1997-2002 SuSE Gmbh Nuernberg, Germany.
;;;
;;; Author: Werner Fink, <feedback@suse.de> 1997,98,99,2002
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Test of Emacs derivates
;;; -----------------------
(if (string-match "XEmacs\\|Lucid" emacs-version)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; XEmacs
  ;;; ------
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (progn
     (if (file-readable-p "~/.xemacs/init.el")
        (load "~/.xemacs/init.el" nil t))
  )
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; GNU-Emacs
  ;;; ---------
  ;;; load ~/.gnu-emacs or, if not exists /etc/skel/.gnu-emacs
  ;;; For a description and the settings see /etc/skel/.gnu-emacs
  ;;;   ... for your private ~/.gnu-emacs your are on your one.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (if (file-readable-p "~/.gnu-emacs")
      (load "~/.gnu-emacs" nil t)
    (if (file-readable-p "/etc/skel/.gnu-emacs")
	(load "/etc/skel/.gnu-emacs" nil t)))

  ;; Custom Settings
  ;; ===============
  ;; To avoid any trouble with the customization system of GNU emacs
  ;; we set the default file ~/.gnu-emacs-custom
  (setq custom-file "~/.gnu-emacs-custom")
  (load "~/.gnu-emacs-custom" t t)
;;;
)
;;;

;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)

;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil))

;; Enable Evil
(require 'evil)
(evil-mode 1)

