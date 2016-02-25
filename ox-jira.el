;;; ox-jira.el --- an Org mode export backend for JIRA format

;;; Copyright (C) 2016 Stig Brautaset

;; Permission is hereby granted, free of charge, to any person obtaining a
;; copy of this software and associated documentation files (the "Software"),
;; to deal in the Software without restriction, including without limitation
;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;; and/or sell copies of the Software, and to permit persons to whom the
;; Software is furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;; DEALINGS IN THE SOFTWARE.

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
    (item . (lambda (&rest args) (org-jira--not-implemented 'item)))
    (keyword . (lambda (&rest args) (org-jira--not-implemented 'keyword)))
    (latex-environment . (lambda (&rest args) (org-jira--not-implemented 'latex-environment)))
    (latex-fragment . (lambda (&rest args) (org-jira--not-implemented 'latex-fragment)))
    (line-break . (lambda (&rest args) (org-jira--not-implemented 'line-break)))
    (link . (lambda (&rest args) (org-jira--not-implemented 'link)))
    (node-property . (lambda (&rest args) (org-jira--not-implemented 'node-property)))
    (options . (lambda (&rest args) (org-jira--not-implemented 'options)))
    (paragraph . org-jira-paragraph)
    (parse-tree . (lambda (&rest args) (org-jira--not-implemented 'parse-tree)))
    (plain-list . (lambda (&rest args) (org-jira--not-implemented 'plain-list)))
    (plain-text . (lambda (plain-text info) plain-text))
    (planning . (lambda (&rest args) (org-jira--not-implemented 'planning)))
    (property-drawer . (lambda (&rest args) (org-jira--not-implemented 'property-drawer)))
    (quote-block . org-jira-quote-block)
    (radio-target . (lambda (&rest args) (org-jira--not-implemented 'radio-target)))
    (section . org-jira-section)
    (special-block . (lambda (&rest args) (org-jira--not-implemented 'special-block)))
    (src-block . (lambda (&rest args) (org-jira--not-implemented 'src-block)))
    (statistics-cookie . (lambda (&rest args) (org-jira--not-implemented 'statistics-cookie)))
    (strike-through . (lambda (&rest args) (org-jira--not-implemented 'strike-through)))
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
  (format "{color:red}\nElement of type '%s' not implemented!\n{color}" element-type))

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
  (replace-regexp-in-string "\n[^\']" " " contents))

(defun org-jira-section (section contents info)
  "Transcode a SECTION element from Org to JIRA.
CONTENTS is the contents of the section, as a string.  INFO is
the plist used as a communication channel."
  contents)

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
