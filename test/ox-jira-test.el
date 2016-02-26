
;;; ox-jira-test.el --- tests for ox-jira.el

;;; Author: Stig Brautaset <stig@brautaset.org>

;; This file is NOT part of GNU Emacs.

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

;;; Code:

(require 'ert)
(require 'ox)
(require 'ox-jira)

(ert-deftest ox-jira-test/hello-world ()
  (should (equal "hello world\n" (org-export-string-as "hello world" 'jira))))

(ert-deftest ox-jira-test/text-effects ()
  (should (equal "this is *strong* text\n" (org-export-string-as "this is *strong* text" 'jira)))
  (should (equal "this is _emphasised_ text\n" (org-export-string-as "this is /emphasised/ text" 'jira)))
  (should (equal "this is +underlined+ text\n" (org-export-string-as "this is _underlined_ text" 'jira)))
  (should (equal "this is -deleted- text\n" (org-export-string-as "this is +deleted+ text" 'jira)))
  (should (equal "this is {{inline code}}\n" (org-export-string-as "this is ~inline code~" 'jira)))
  (should (equal "this is {{verbatim}} text\n" (org-export-string-as "this is =verbatim= text" 'jira))))

(ert-deftest ox-jira-test/quotations ()
  (should (equal "{quote}
This is a quote.

It can have multiple paragraphs.
{quote}
" (org-export-string-as "
#+BEGIN_QUOTE
This is a quote.

It can have multiple paragraphs.
#+END_QUOTE" 'jira)))

  (should (equal "{quote}
This is a quote with _emphasis_.
{quote}
" (org-export-string-as "
#+begin_quote
This is a quote with /emphasis/.
#+end_quote" 'jira))))

(ert-deftest ox-jira-test/headlines ()
  (should (equal "h1. top level
h2. second level
h3. third level
" (org-export-string-as "* top level
** second level
*** third level" 'jira))))

(ert-deftest ox-jira-test/keywords()
  (should (equal "" (org-export-string-as "#+TITLE: MyTitle
#+DATE: 2016-02-26
#+OPTIONS: f:t" 'jira))))

(ert-deftest ox-jira-test/links ()
  (should (equal "fi [http://jira.atlassian.com] fo\n"
                 (org-export-string-as "fi [[http://jira.atlassian.com]] fo" 'jira)))
  (should (equal "fi [Jira|http://jira.atlassian.com] fo\n"
                 (org-export-string-as "fi [[http://jira.atlassian.com][Jira]] fo" 'jira))))

(ert-deftest ox-jira-test/paragraphs ()
  (should (equal "fi fo fa fum\n" (org-export-string-as "fi
fo
fa
fum" 'jira))))

(ert-deftest ox-jira-test/unordered-lists()
  (should (equal "* fi
* fo
* fa
* fum
" (org-export-string-as "- fi
- fo
- fa
- fum" 'jira))))

(ert-deftest ox-jira-test/ordered-lists()
  (should (equal "# fi
# fo
# fa
# fum
" (org-export-string-as "1. fi
2. fo
3. fa
3. fum" 'jira))))

(ert-deftest ox-jira-test/unordered-list-with-checkboxes()
  (should (equal "* {{[ ]}} fi
* {{[X]}} fo
" (org-export-string-as "- [ ] fi
- [X] fo" 'jira))))

(ert-deftest ox-jira-test/src-blocks ()
  (should (equal "{code:none}
echo hello
# echo world
{code}
" (org-export-string-as "#+begin_src sh
     echo hello
     # echo world
     #+end_src
" 'jira)))
  (should (equal "{code:sql}
BEGIN;
SELECT NOW();
END;
{code}
" (org-export-string-as "#+begin_src sql
     BEGIN;
     SELECT NOW();
     END;
     #+end_src
" 'jira))))

(ert-deftest ox-jira-test/example-blocks ()
  (should (equal "{noformat}
stuff that should
 not be
formatted
{noformat}
" (org-export-string-as "#+begin_example
stuff that should
 not be
formatted
#+end_example
" 'jira))))

(provide 'ox-jira-test)

;;; ox-jira.el-test.el ends here
