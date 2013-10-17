;;; network-status.el -- Display network status in mode line.

;; Copyright (C) 2013 by Sachin Patil

;; Author: Sachin Patil <isachin@iitb.ac.in>
;; URL: http://github.com/psachin/network-status
;; Keywords: tools, network, convenience
;; Version: 0.9

;; This file is NOT a part of GNU Emacs.

;; network-status is free software distributed under the terms of the
;; GNU General Public License, version 3. For details, see the file
;; COPYING.

;;; Commentary:
;; Display network status in mode line.
;; URL: http://github.com/psachin/network-status

;; Install
;;
;; Unless installed from a package, add the directory containing
;; this file to `load-path', and then:
;; (require 'network-status)
;;
;; Customize
;; M-x customize-group RET network-status RET

;;; Code:

(require 'timer)

(defgroup network-status nil
  "Display network status in mode line."
  :group 'extensions
  :link '(url-link :tag "Github" "https://github.com/psachin/network-status"))

(defcustom network-status-up-string " ↑ "
  "String to be displayed in mode line.
When internet in UP."
  :type '(string)
  :group 'network-status)

(defcustom network-status-down-string " ↓ "
  "String to be displayed in mode line.
When internet in DOWN."
  :type '(string)
  :group 'network-status)

(defcustom network-status-process-name "network-status-process"
  "Name of the process."
  :type '(string)
  :group 'network-status)

(defcustom network-status-host-name "google.com"
  "Host name to ping.

It can be any live server on the internet.
For example: www.google.com, www.gnu.org etc."
  :type '(string)
  :group 'network-status)

(defcustom network-status-host-port 80
  "Host port number.

Port number of host."
  :type 'integer
  :group 'network-status)

(defcustom network-status-update-interval 1
  "Set update interval for `network-status'.

In seconds."
  :type 'integer
  :group 'network-status)

(defvar network-status-timer nil
  "Network status interval timer object.")

(defvar network-status-mode-line-string ""
  "Default network status mode line string.")

(defun network-status-kill-process ()
  "Kill network process if active."
  (interactive)
  (if (process-status network-status-process-name)
      (progn
	(delete-process network-status-process-name))))

(defun network-status-up ()
  "Update mode line if network is up."
  (network-status-kill-process)
  (if (member network-status-mode-line-string global-mode-string)
	(delq network-status-mode-line-string global-mode-string))
  (add-to-list 'global-mode-string (setq network-status-mode-line-string
					 network-status-up-string) t)
  (force-mode-line-update))

(defun network-status-down ()
  "Update mode line if network is down."
  (network-status-kill-process)
  (if (member network-status-mode-line-string global-mode-string)
      (delq network-status-mode-line-string global-mode-string))
  (add-to-list 'global-mode-string (setq network-status-mode-line-string
					     network-status-down-string) t)
  (force-mode-line-update))

(defun network-status-updater ()
  "Check internet connection by pinging host.

And update the status on mode line."
  (if (ignore-errors (make-network-process
       :name network-status-process-name
       :host network-status-host-name
       :service network-status-host-port
       :nowait t))
      (progn
	(network-status-up))
    (progn
      (network-status-down))))

;;;###autoload
(defun network-status ()
  "Call `network-status-updater'.

Every `network-status-update-interval' seconds."
  (interactive)
  (setq network-status-timer (run-at-time nil network-status-update-interval
	       'network-status-updater)))

;;;###autoload
(define-minor-mode network-status-mode
  "Display network status in mode line."
  :lighter " nS"
  :global t
  (setq network-status-mode-line-string "")
  (or global-mode-string (setq global-mode-string '("")))
  (and network-status-timer (cancel-timer network-status-timer))
  (if (not network-status-mode)
      (progn
  	(network-status-kill-process)
	(cancel-timer network-status-timer)
	(if (member network-status-up-string global-mode-string)
	    (delq network-status-up-string global-mode-string)
	  (delq network-status-down-string global-mode-string))
	(delq network-status-mode-line-string global-mode-string))
    (network-status)))

(provide 'network-status)
;;; network-status.el ends here

