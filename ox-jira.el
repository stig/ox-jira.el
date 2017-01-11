;;; ox-jira.el --- JIRA Backend for Org Export Engine

;; Copyright (C) 2016 Stig Brautaset

;; Author: Stig Brautaset <stig@brautaset.org>
;; Version: 0.1-SNAPSHOT
;; Keywords: outlines, hypermedia, wp
;; Homepage: https://github.com/stig/ox-jira.el
;; Package-Requires: ((org "8.3"))

;; This file is NOT part of GNU Emacs.

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

;;; Commentary:

;; This module plugs into the regular Org Export Engine and transforms Org
;; files to JIRA markup for pasting into JIRA tickets & comments.

;; In an Org buffer, hit `C-c C-e j j' to bring up *Org Export Dispatcher*
;; and export it as a JIRA buffer. I usually use `C-x h' to mark the whole
;; buffer, then `M-w' to save it to the kill ring (and global pasteboard) for
;; pasting into JIRA issues.

;;; Code:

;; This is Cargo-culted from `ox-latex.el'`
(eval-when-compile (require 'cl))
(require 'ox)
(require 'ox-publish)

(org-export-define-backend 'jira
  '((babel-call . (lambda (&rest args) (ox-jira--not-implemented 'babel-call)))
    (body . (lambda (&rest args) (ox-jira--not-implemented 'body)))
    (bold . ox-jira-bold)
    (center-block . (lambda (&rest args) (ox-jira--not-implemented 'center-block)))
    (clock . (lambda (&rest args) (ox-jira--not-implemented 'clock)))
    (code . ox-jira-code)
    (diary-sexpexample-block . (lambda (&rest args) (ox-jira--not-implemented 'diary-sexpexample-block)))
    (drawer . (lambda (&rest args) (ox-jira--not-implemented 'drawer)))
    (dynamic-block . (lambda (&rest args) (ox-jira--not-implemented 'dynamic-block)))
    (entity . (lambda (&rest args) (ox-jira--not-implemented 'entity)))
    (example-block . ox-jira-example-block)
    (export-block . (lambda (&rest args) (ox-jira--not-implemented 'export-block)))
    (export-snippet . (lambda (&rest args) (ox-jira--not-implemented 'export-snippet)))
    (final-output . (lambda (&rest args) (ox-jira--not-implemented 'final-output)))
    (fixed-width . ox-jira-fixed-width)
    (footnote-definition . ox-jira-footnote-definition)
    (footnote-reference . ox-jira-footnote-reference)
    (headline . ox-jira-headline)
    (horizontal-rule . ox-jira-horizontal-rule)
    (inline-babel-call . (lambda (&rest args) (ox-jira--not-implemented 'inline-babel-call)))
    (inline-src-block . (lambda (&rest args) (ox-jira--not-implemented 'inline-src-block)))
    (inlinetask . (lambda (&rest args) (ox-jira--not-implemented 'inlinetask)))
    (italic . ox-jira-italic)
    (item . ox-jira-item)
    (keyword . (lambda (&rest args) ""))
    (latex-environment . (lambda (&rest args) (ox-jira--not-implemented 'latex-environment)))
    (latex-fragment . (lambda (&rest args) (ox-jira--not-implemented 'latex-fragment)))
    (line-break . (lambda (&rest args) (ox-jira--not-implemented 'line-break)))
    (link . ox-jira-link)
    (node-property . (lambda (&rest args) (ox-jira--not-implemented 'node-property)))
    (options . (lambda (&rest args) (ox-jira--not-implemented 'options)))
    (paragraph . ox-jira-paragraph)
    (parse-tree . (lambda (&rest args) (ox-jira--not-implemented 'parse-tree)))
    (plain-list . ox-jira-plain-list)
    (plain-text . ox-jira-plain-text)
    (planning . (lambda (&rest args) (ox-jira--not-implemented 'planning)))
    (property-drawer . (lambda (&rest args) (ox-jira--not-implemented 'property-drawer)))
    (quote-block . ox-jira-quote-block)
    (radio-target . (lambda (&rest args) (ox-jira--not-implemented 'radio-target)))
    (section . ox-jira-section)
    (special-block . (lambda (&rest args) (ox-jira--not-implemented 'special-block)))
    (src-block . ox-jira-src-block)
    (statistics-cookie . ox-jira-statistics-cookie)
    (strike-through . ox-jira-strike-through)
    (subscript . ox-jira-subscript)
    (superscript . ox-jira-superscript)
    (table . ox-jira-table)
    (table-cell . ox-jira-table-cell)
    (table-row . ox-jira-table-row)
    (target . (lambda (&rest args) (ox-jira--not-implemented 'target)))
    (timestamp . ox-jira-timestamp)
    (underline . ox-jira-underline)
    (verbatim . ox-jira-verbatim)
    (verse-block . (lambda (&rest args) (ox-jira--not-implemented 'verse-block))))
  :filters-alist '((:filter-parse-tree . ox-jira-fix-multi-paragraph-items))
  :menu-entry
  '(?j "Export to JIRA"
       ((?j "As JIRA buffer" ox-jira-export-as-jira))))

;;; Internal Helpers

;; Because I'm adding support for things as I find I need it rather than all
;; in one go, let's put a big fat red marker in for things we have not
;; implemented yet, to avoid missing it.
;;
(defun ox-jira--not-implemented (element-type)
  "Replace anything we don't handle yet wiht a big red marker."
  (format "{color:red}Element of type '%s' not implemented!{color}" element-type))

;; Super^script and sub_script I often want at the end of words, with no
;; whitespace immediately before it. Unfortunately JIRA doesn't support
;; that,so we have to fake it. This function makes simple text transforms
;; "embeddable" by preceding them with an empty anchor. This is admittedly a
;; bit of a hack, but I haven't found anything better.
;;
(defun ox-jira--text-transform-embeddable (transform-char contents)
  (concat "{anchor}" transform-char contents transform-char))

;;; Filters

;; Org support a single blank line between items in a list, but if we export
;; like that to JIRA format it will be interpreted as multiple consecutive
;; lists, which is never what I want. We can attempt to fix this by removing
;; the "post-blank" after a items (and paragraphs inside items) using a
;; filter.
;; 
(defun ox-jira-fix-multi-paragraph-items (tree backend info)
  "Remove extra blank line between paragraphs in plain-list items.

TREE is the parse tree being exported.  BACKEND is the export
back-end used.  INFO is a plist used as a communication channel.

Assume BACKEND is `jira'."
  (org-element-map tree '(item paragraph src-block)
    (lambda (e)
      (org-element-put-property
       e :post-blank
       (if (or (eq (org-element-type e) 'item)
               (eq (org-element-type (org-element-property :parent e)) 'item))
           0 1))))
  ;; Return updated tree.
  tree)

;;; Transcode functions

;; These functions do the actual translation to JIRA format. For this section
;; I've used Atlassian's Text Formatting Notation Help page as a reference:
;; https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa?section=all

(defun ox-jira-bold (bold contents info)
  "Transcode BOLD from Org to JIRA.
CONTENTS is the text with bold markup. INFO is a plist holding
contextual information."
  (format "*%s*" contents))

(defun ox-jira-code (code _contents info)
  "Transcode a CODE object from Org to JIRA.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (format "{{%s}}" (org-element-property :value code)))

(defun ox-jira-example-block (example-block contents info)
  "Transcode an EXAMPLE-BLOCK element from Org to Jira.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (when (org-string-nw-p (org-element-property :value example-block))
    (format "{noformat}\n%s{noformat}"
            (org-export-format-code-default example-block info))))

(defun ox-jira-fixed-width (fixed-width contents info)
  "Transcode an FIXED-WIDTH element from Org to Jira.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (format "{noformat}\n%s{noformat}"
          (org-remove-indentation
           (org-element-property :value fixed-width))))

;; Footnotes have two parts: the reference, and the definition.
;;
(defun ox-jira--footnote-anchor (element)
  (let ((label (org-element-property :label element)))
    (replace-regexp-in-string ":" "" label)))

(defun ox-jira--footnote-ref (anchor)
  (replace-regexp-in-string "fn" "" anchor))

(defun ox-jira-footnote-reference (footnote-reference contents info)
  "Transcode an FOOTNOTE-REFERENCE element from Org to Jira.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (let* ((anchor (ox-jira--footnote-anchor footnote-reference))
        (ref (ox-jira--footnote-ref anchor)))
    (format "{anchor:back%s}[^%s^|#%s]"
            anchor ref anchor)))

(defun ox-jira-footnote-definition (footnote-definition contents info)
  "Transcode an FOOTNOTE-DEFINITION element from Org to Jira.
CONTENTS is nil.  INFO is a plist holding contextual
information."
  (let* ((anchor (ox-jira--footnote-anchor footnote-definition))
         (ref (ox-jira--footnote-ref anchor)))
    (format "{anchor:%s}[^%s^|#back%s] %s"
            anchor ref anchor contents)))

;; Headlines are a little bit more complex. I'm not even attempting to support
;; TODO labels and meta-information, just the straight-up text. It would be
;; nice to support the six standard levels of headlines JIRA offers though.
;;
;; Since the headline level is _relative_ rather than absolute, if the
;; exporter sees a '** second level' heading before it's seen a '* first
;; level' then the '** second level' will think it's a top-level heading.
;; That's a bit weird, but there you go.
;; 
(defun ox-jira-headline (headline contents info)
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

(defun ox-jira-horizontal-rule (horizontal-rule contents info)
  "Transcode a HORIZONTAL-RULE element from Org to JIRA."
  "----\n")

(defun ox-jira-italic (italic contents info)
  "Transcode ITALIC from Org to JIRA.
CONTENTS is the text with italic markup. INFO is a plist holding
contextual information."
  (format "_%s_" contents))

;; A list item. The JIRA format for nested lists follows. (You can also mix
;; ordered and unordered lists.)
;;
;; * item
;; ** sub-item
;; ** sub-item 2
;; * item 2
;;
;; The item element itself does not know what type it is: that is an attribute
;; of its parent, a plain-list element. We need to walk the path of
;; alternating plain-list and item nodes until there are no more, and extract
;; their type. The type list is used to create a bullet string.
;;
;; JIRA doesn't really have support for definition lists, so we fake it with a
;; bullet list and some bold text for the term.
;;
(defun ox-jira--list-type-path (item)
  (when (and item (eq 'item (org-element-type item)))
    (let* ((list (org-element-property :parent item))
           (list-type (org-element-property :type list)))
      (cons list-type (ox-jira--list-type-path
                       (org-element-property :parent list))))))

(defun ox-jira--bullet-string (list-type-path)
  (apply 'string
         (mapcar (lambda (x) (if (eq x 'ordered) ?# ?*))
                 list-type-path)))

(defun ox-jira-item (item contents info)
  "Transcode ITEM from Org to JIRA.
CONTENTS is the text with item markup. INFO is a plist holding
contextual information."
  (let* ((list-type-path (ox-jira--list-type-path item))
         (bullet-string (ox-jira--bullet-string (reverse list-type-path)))
         (tag (let ((tag (org-element-property :tag item)))
                (when tag
                  (org-export-data tag info))))
         (checkbox (case (org-element-property :checkbox item)
                     (on "(/)")
                     (off "(x)")
                     (trans "(i)"))))
    (concat
     bullet-string
     " "
     (when checkbox
       (concat checkbox " "))
     (when tag
       (format "*%s*: " tag))
     contents)))

;; JIRA supports many types of links. I don't expect we support them all, but
;; we must make a token effort. A lot of this code is cribbed from
;; `ox-latex.el'.
;;
(defun ox-jira-link (link desc info)
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

(defun ox-jira-underline (underline contents info)
  "Transcode UNDERLINE from Org to JIRA.
CONTENTS is the text with underline markup. INFO is a plist holding
contextual information."
  (format "+%s+" contents))

(defun ox-jira-verbatim (verbatim _contents info)
  "Transcode a VERBATIM object from Org to Jira.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (format "{{%s}}" (org-element-property :value verbatim)))

;; One of the most annoying things about JIRA markup is the way it doesn't
;; reflow text properly, so any linebreaks becomes hard linebreaks in the
;; rendered output. Let's fix that!
;;
;; What we need to do is replace any *internal* newlines (i.e. any not at the
;; end of the string) with a space. Regexes to the rescue! I used the
;; following reference to help me with this function:
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Regexp-Backslash.html#Regexp-Backslash


(defun ox-jira-paragraph (paragraph contents info)
  "Transcode a PARAGRAPH element from Org to JIRA.
CONTENTS is the contents of the paragraph, as a string.  INFO is
the plist used as a communication channel."
  (replace-regexp-in-string "\n\\([^\']\\)" " \\1" contents))

;; I make a lot of lists. Let's make sure we handle them! This is very simple,
;; as in the JIRA format all the logic is actually _for each item_ in the
;; list.
;;
(defun ox-jira-plain-list (plain-list contents info)
  "Transcode PLAIN-LIST from Org to JIRA.
CONTENTS is the text with plain-list markup. INFO is a plist holding
contextual information."
  contents)

;; This is text with no markup, but we have to escape certain characters to
;; avoid tripping up JIRA. In particular:
;; 
;; - ={= :: Introduces macros
;; - =[= :: Introduces links
;;
(defun ox-jira-plain-text (text info)
  "Transcode TEXT from Org to JIRA.
TEXT is the string to transcode. INFO is a plist holding
contextual information."
  (replace-regexp-in-string "\\([[{]\\)"
                            '(lambda (p) (format "\\\\%s" p))
                            text))

;; Paragraphs are grouped into sections. I've not found any mention in the Org
;; documentation, but it appears to be essential for any export to happen.
;; I've essentially cribbed this from `ox-latex.el`.
;;

(defun ox-jira-section (section contents info)
  "Transcode a SECTION element from Org to JIRA.
CONTENTS is the contents of the section, as a string.  INFO is
the plist used as a communication channel."
  contents)

;; JIRA supports formatting for these languages: actionscript, html,
;; java,javascript, sql, xhtml, xml. If none of them fits, we can use 'none',
;; or leave out the language altogether, which I imagine will be a bit like
;; ={noformat}=.
;;
(defun ox-jira-src-block (src-block contents info)
  "Transcode a SRC-BLOCK element from Org to Jira.
CONTENTS holds the contents of the src-block.  INFO is a plist holding
contextual information."
  (when (org-string-nw-p (org-element-property :value src-block))
    (let* ((lang (org-element-property :language src-block))
           (lang (if (member lang '("actionscript" "html" "java" "javascript" "sql" "xhtml" "xml")) lang))
           (code (org-export-format-code-default src-block info)))
      (concat
       (if lang
           (format "{code:%s}" lang)
         "{code}")
       code
       "{code}"))))

(defun ox-jira-subscript (subscript contents info)
  "Transcode SUBSCRIPT from Org to JIRA.
CONTENTS is the text with subscript markup. INFO is a plist holding
contextual information."
  (ox-jira--text-transform-embeddable "~" contents))

(defun ox-jira-superscript (superscript contents info)
  "Transcode SUPERSCRIPT from Org to JIRA.
CONTENTS is the text with superscript markup. INFO is a plist holding
contextual information."
  (ox-jira--text-transform-embeddable "^" contents))


;; Org's table editor is one of the many reasons to use Org. It is excellent.
;; Org and JIRA's tables are quite similar. Where Org marks tables up like
;; this:
;; 
;; | Name   | Score |
;; |--------+-------|
;; | Ashley |     2 |
;; | Alex   |     3 |
;; 
;; Jira uses the following format:
;; 
;; || Name  || Score ||
;; | Ashley | 2 |
;; | Alex   | 3 |
;;
;; Tables are complex beasts. I only hope to support very simple ones. Looks
;; like most of the logic will live in the row and cell transcoding functions.
;;
(defun ox-jira-table (table contents info)
  "Transcode a TABLE element from Org to JIRA.
CONTENTS holds the contents of the table.  INFO is a plist holding
contextual information."
  contents)

;; We only want to output =standard= rows, not horizontal lines. I'm not sure
;; if detection of header rows belong here or in the cells.
;;
(defun ox-jira-table-row (table-row contents info)
  "Transcode a TABLE-ROW element from Org to JIRA.
CONTENTS holds the contents of the table-row.  INFO is a plist holding
contextual information."
  (when (eq 'standard (org-element-property :type table-row))
    (format "%s\n" contents)))

;; The cell itself does not know if it is a header cell or not, so we have to
;; ask its containing row if it is the first row, and the table if it has a
;; header row at all. If those things are true, make the cell a header cell.
;;
(defun ox-jira-table-cell (table-cell contents info)
  "Transcode a TABLE-CELL element from Org to JIRA.
CONTENTS holds the contents of the table-cell.  INFO is a plist holding
contextual information."
  (let* ((row (org-element-property :parent table-cell))
         (table (org-element-property :parent row))
         (has-header (org-export-table-has-header-p table info))
         (group (org-export-table-row-group row info))
         (is-header (and has-header (eq 1 group)))
         (sep (if is-header "||" "|")))
    (format "%s %s %s" sep contents
            (if (org-export-last-sibling-p table-cell info) sep ""))))

;; This is updated to show progress of subsequent list of check boxes.
;;
(defun ox-jira-statistics-cookie (statistics-cookie _contents _info)
  "Transcode a STATISTICS-COOKIE object from Org to JIRA.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (format "\\%s" (org-element-property :value statistics-cookie)))

(defun ox-jira-strike-through (strike-through contents info)
  "Transcode STRIKE-THROUGH from Org to JIRA.
CONTENTS is the text with strike-through markup. INFO is a plist holding
contextual information."
  (format "-%s-" contents))

(defun ox-jira-quote-block (quote-block contents info)
  "Transcode a QUOTE-BLOCK element from Org to Jira.
CONTENTS holds the contents of the block.  INFO is a plist
holding contextual information."
  (format "{quote}\n%s{quote}" contents))


(defun ox-jira-timestamp (timestamp _contents info)
  "Transcode a TIMESTAMP object from Org to JIRA.
CONTENTS is nil. INFO is a plist holding contextual information."
  (let ((value (org-timestamp-translate timestamp))
        (fmt (cl-case (org-element-property :type timestamp)
               ((active active-range) "_%s_")
               ((inactive inactive-range) "_\\%s_")
               (otherwise "_%s_"))))
    (format fmt value)))

(defun ox-jira-export-as-jira
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
