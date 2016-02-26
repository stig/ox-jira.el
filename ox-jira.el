
;;; ox-jira.el --- JIRA Backend for Org Export Engine -*- lexical-binding: j; -*-

;;; Copyright (C) 2016 Stig Brautaset

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Author: Stig Brautaset <stig@brautaset.org>

;; Keywords: outlines, hypermedia, wp

;; This file is NOT part of GNU Emacs.

;;; Version: 0.1-SNAPSHOT

;; Homepage: https://github.com/stig/ox-jira.el

;; Package-Requires: ((org "8.0"))

;;; Code:

(eval-when-compile (require 'cl))
(require 'ox)
(require 'ox-publish)

(org-export-define-backend 'jira
  '((babel-call . (lambda (&rest args) (org-jira--not-implemented 'babel-call)))
    (body . (lambda (&rest args) (org-jira--not-implemented 'body)))
    (bold . org-jira-bold)
    (center-block . (lambda (&rest args) (org-jira--not-implemented 'center-block)))
    (clock . (lambda (&rest args) (org-jira--not-implemented 'clock)))
    (code . org-jira-code)
    (diary-sexpexample-block . (lambda (&rest args) (org-jira--not-implemented 'diary-sexpexample-block)))
    (drawer . (lambda (&rest args) (org-jira--not-implemented 'drawer)))
    (dynamic-block . (lambda (&rest args) (org-jira--not-implemented 'dynamic-block)))
    (entity . (lambda (&rest args) (org-jira--not-implemented 'entity)))
    (example-block . org-jira-example-block)
    (export-block . (lambda (&rest args) (org-jira--not-implemented 'export-block)))
    (export-snippet . (lambda (&rest args) (org-jira--not-implemented 'export-snippet)))
    (final-output . (lambda (&rest args) (org-jira--not-implemented 'final-output)))
    (fixed-width . (lambda (&rest args) (org-jira--not-implemented 'fixed-width)))
    (footnote-definition . (lambda (&rest args) (org-jira--not-implemented 'footnote-definition)))
    (footnote-reference . (lambda (&rest args) (org-jira--not-implemented 'footnote-reference)))
    (headline . org-jira-headline)
    (horizontal-rule . (lambda (&rest args) (org-jira--not-implemented 'horizontal-rule)))
    (inline-babel-call . (lambda (&rest args) (org-jira--not-implemented 'inline-babel-call)))
    (inline-src-block . (lambda (&rest args) (org-jira--not-implemented 'inline-src-block)))
    (inlinetask . (lambda (&rest args) (org-jira--not-implemented 'inlinetask)))
    (italic . org-jira-italic)
    (item . org-jira-item)
    (keyword . (lambda (&rest args) ""))
    (latex-environment . (lambda (&rest args) (org-jira--not-implemented 'latex-environment)))
    (latex-fragment . (lambda (&rest args) (org-jira--not-implemented 'latex-fragment)))
    (line-break . (lambda (&rest args) (org-jira--not-implemented 'line-break)))
    (link . org-jira-link)
    (node-property . (lambda (&rest args) (org-jira--not-implemented 'node-property)))
    (options . (lambda (&rest args) (org-jira--not-implemented 'options)))
    (paragraph . org-jira-paragraph)
    (parse-tree . (lambda (&rest args) (org-jira--not-implemented 'parse-tree)))
    (plain-list . org-jira-plain-list)
    (plain-text . (lambda (plain-text info) plain-text))
    (planning . (lambda (&rest args) (org-jira--not-implemented 'planning)))
    (property-drawer . (lambda (&rest args) (org-jira--not-implemented 'property-drawer)))
    (quote-block . org-jira-quote-block)
    (radio-target . (lambda (&rest args) (org-jira--not-implemented 'radio-target)))
    (section . org-jira-section)
    (special-block . (lambda (&rest args) (org-jira--not-implemented 'special-block)))
    (src-block . org-jira-src-block)
    (statistics-cookie . org-jira-statistics-cookie)
    (strike-through . org-jira-strike-through)
    (subscript . (lambda (&rest args) (org-jira--not-implemented 'subscript)))
    (superscript . (lambda (&rest args) (org-jira--not-implemented 'superscript)))
    (table . (lambda (&rest args) (org-jira--not-implemented 'table)))
    (table-cell . (lambda (&rest args) (org-jira--not-implemented 'table-cell)))
    (table-row . (lambda (&rest args) (org-jira--not-implemented 'table-row)))
    (target . (lambda (&rest args) (org-jira--not-implemented 'target)))
    (timestamp . (lambda (&rest args) (org-jira--not-implemented 'timestamp)))
    (underline . org-jira-underline)
    (verbatim . org-jira-verbatim)
    (verse-block . (lambda (&rest args) (org-jira--not-implemented 'verse-block))))
  :menu-entry
  '(?j "Export to JIRA"
       ((?j "As JIRA buffer" org-jira-export-as-jira))))

(defun org-jira--not-implemented (element-type)
  "Replace anything we don't handle yet wiht a big red marker."
  (format "{color:red}Element of type '%s' not implemented!{color}" element-type))

;;; Transcode functions

(defun org-jira-bold (bold contents info)
  "Transcode BOLD from Org to JIRA.
CONTENTS is the text with bold markup. INFO is a plist holding
contextual information."
  (format "*%s*" contents))

(defun org-jira-code (code _contents info)
  "Transcode a CODE object from Org to JIRA.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (format "{{%s}}" (org-element-property :value code)))

(defun org-jira-example-block (example-block contents info)
  "Transcode an EXAMPLE-BLOCK element from Org to Jira.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (when (org-string-nw-p (org-element-property :value example-block))
    (format "{noformat}\n%s{noformat}"
            (org-export-format-code-default example-block info))))

(defun org-jira-headline (headline contents info)
  "Transcode a HEADLINE element from Org to JIRA.
CONTENTS is the contents of the headline, as a string.  INFO is
the plist used as a communication channel."
  (let* ((level (org-export-get-relative-level headline info))
         (title (org-export-data-with-backend
                 (org-element-property :title headline)
                 'jira info)))
    (concat
     (format "h%d. %s\n" level title)
     contents)))

(defun org-jira-italic (italic contents info)
  "Transcode ITALIC from Org to JIRA.
CONTENTS is the text with italic markup. INFO is a plist holding
contextual information."
  (format "_%s_" contents))

(defun org-jira-item (item contents info)
  "Transcode ITEM from Org to JIRA.
CONTENTS is the text with item markup. INFO is a plist holding
contextual information."
  (let* ((parent (org-element-property :parent item))
         (list-type (org-element-property :type parent))
         (checkbox (case (org-element-property :checkbox item)
                     (on "(/) ")
                     (off "(x) ")
                     (trans "(i) "))))
    (concat
     (if (eq list-type 'ordered) "#" "*")
     " "
     checkbox
     contents)))

(defun org-jira-link (link desc info)
  "Transcode a LINK object from Org to JIRA.

DESC is the description part of the link, or the empty string.
INFO is a plist holding contextual information.  See
`org-export-data'."
  (let* ((type (org-element-property :type link))
         (raw-path (org-element-property :path link))
         (desc (and (not (string= desc "")) desc))
         (path (cond
                ((member type '("http" "https" "ftp" "mailto" "doi"))
                 (concat type ":" raw-path))
                ((string= type "file")
                 (org-export-file-uri raw-path))
                (t raw-path))))
    (cond
     ;; Link with description
     ((and path desc) (format "[%s|%s]" desc path))
     ;; Link without description
     (path (format "[%s]" path))
     ;; Link with only description?!
     (t desc))))

(defun org-jira-underline (underline contents info)
  "Transcode UNDERLINE from Org to JIRA.
CONTENTS is the text with underline markup. INFO is a plist holding
contextual information."
  (format "+%s+" contents))

(defun org-jira-verbatim (verbatim _contents info)
  "Transcode a VERBATIM object from Org to Jira.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (format "{{%s}}" (org-element-property :value verbatim)))

(defun org-jira-paragraph (paragraph contents info)
  "Transcode a PARAGRAPH element from Org to JIRA.
CONTENTS is the contents of the paragraph, as a string.  INFO is
the plist used as a communication channel."
  (replace-regexp-in-string "\n\\([^\']\\)" " \\1" contents))

(defun org-jira-plain-list (plain-list contents info)
  "Transcode PLAIN-LIST from Org to JIRA.
      CONTENTS is the text with plain-list markup. INFO is a plist holding
      contextual information."
  contents)

(defun org-jira-section (section contents info)
  "Transcode a SECTION element from Org to JIRA.
CONTENTS is the contents of the section, as a string.  INFO is
the plist used as a communication channel."
  contents)

(defun org-jira-src-block (src-block contents info)
  "Transcode a SRC-BLOCK element from Org to Jira.
CONTENTS holds the contents of the item.  INFO is a plist holding
contextual information."
  (when (org-string-nw-p (org-element-property :value src-block))
    (let* ((lang (org-element-property :language src-block))
           (lang (if (member lang '("actionscript" "html" "java" "javascript" "sql" "xhtml" "xml"))
                     lang "none"))
           (code (org-export-format-code-default src-block info)))
      (format "{code:%s}\n%s{code}"
              lang
              code))))

(defun org-jira-statistics-cookie (statistics-cookie _contents _info)
  "Transcode a STATISTICS-COOKIE object from Org to JIRA.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (format "\\%s" (org-element-property :value statistics-cookie)))

(defun org-jira-strike-through (strike-through contents info)
  "Transcode STRIKE-THROUGH from Org to JIRA.
CONTENTS is the text with strike-through markup. INFO is a plist holding
contextual information."
  (format "-%s-" contents))

(defun org-jira-quote-block (quote-block contents info)
  "Transcode a QUOTE-BLOCK element from Org to Jira.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  (format "{quote}\n%s{quote}" contents))

(defun org-jira-export-as-jira
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer as a Jira buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, omit header
stuff. (e.g. AUTHOR and TITLE.)

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Export is done in a buffer named \"*Org JIRA Export*\", which
will be displayed when `org-export-show-temporary-export-buffer'
is non-nil."
  (interactive)
  (org-export-to-buffer 'jira "*Org JIRA Export*"
    async subtreep visible-only body-only ext-plist))

(provide 'ox-jira)

;;; ox-jira.el ends here
