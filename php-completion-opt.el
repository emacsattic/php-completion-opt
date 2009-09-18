;;; php-completion-opt.el --- php-completion optional utilities

;; Copyright (C) 2009  kitokitoki

;; Author: kitokitoki <morihenotegami@gmail.com>
;; Keywords: convenience
;; Prefix: phpcmpopt-

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Change Log
;; 1.0.1: cleanup で persistent-action で用いたバッファを削除する処理を追加。
;; 1.0.0: 新規作成

;; TODO documentation

;;; Code:

(require 'php-completion)

(defvar phpcmp-persistent-document-buffer "*phpcmp persistent doc*")
(defvar phpcmpopt-manual-window-height 75)

(defun phpcmpopt-popup-document-persistent-action (candidate)
  ;(interactive)
    (let ((docstring (phpcmp-get-document-string candidate))
           (b (get-buffer-create phpcmp-persistent-document-buffer)))
      (with-current-buffer b
        (erase-buffer)
        (insert docstring)
        (goto-char (point-min)))
      (pop-to-buffer b)))

(defun phpcmpopt-make-completion-sources ()
  (labels ((make-source (&key name candidates)
            `((name . ,name)
              (init . (lambda ()
                        (with-current-buffer (anything-candidate-buffer 'global)
                          (insert (mapconcat 'identity
                                             (if (functionp ',candidates)
                                                 (funcall ',candidates)
                                               ',candidates)
                                             "\n")))))
              (candidates-in-buffer)
              (action . (("Insert" . (lambda (candidate)
                                       (delete-backward-char (length phpcmp-initial-input))
                                       (insert candidate)))
              ("Search". (lambda (candidate)
                           (phpcmp-search-manual candidate)))))
              (persistent-action . phpcmpopt-popup-document-persistent-action)
              (cleanup . phpcmpopt-delete-persistent-action-buffer))))
    (loop for (name candidates) in (phpcmp-completions-table)
          collect (make-source
                   :name name
                   :candidates candidates))))

(defun phpcmpopt-delete-persistent-action-buffer ()
   (and (get-buffer phpcmp-persistent-document-buffer)
        (kill-buffer (get-buffer phpcmp-persistent-document-buffer)))
  )

(defun phpcmpopt-complete ()
  (interactive)
  (anything (phpcmpopt-make-completion-sources)
            (phpcmp-get-initial-input)))

;; below is an arrange of shell-pop.el.
;; shell-pop.el is written by Kazuo YAGI
;; http://www.emacswiki.org/emacs/shell-pop.el

(defun phpcmpopt-manual-pop ()
  (interactive)
  (if (equal (buffer-name) phpcmp-popup-document-buffer)
      (phpcmpopt-manual-pop-out)
    (phpcmpopt-manual-pop-up)))

(defun phpcmpopt-manual-pop-up ()
  (setq phpcmpopt-manual-last-buffer (buffer-name))
  (setq phpcmpopt-manual-last-window (selected-window))
  (split-window (selected-window)
                (round (* (window-height)
                          (/ (- 100 phpcmpopt-manual-window-height) 100.0))))
  (phpcmp-popup-document-at-point))

(defun phpcmpopt-manual-pop-out ()
  (delete-window)
  (select-window phpcmpopt-manual-last-window)
  (switch-to-buffer phpcmpopt-manual-last-buffer))


(provide 'php-completion-opt)

;;; php-completion-opt.el ends here
