;;; ox-jira-test.el --- tests for ox-jira.el

;; Copyright (C) 2016 Stig Brautaset

;; Author: Stig Brautaset <stig@brautaset.org>

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

;;; Code:

(require 'ert)
(require 'ox)
(require 'ox-jira)

;; This is my first foray into testing in Emacs. Please be kind.

;; Let's write the simplest possible test that actually invokes anything org
;; export related.
;;
(ert-deftest ox-jira-test/hello-world ()
  (should (equal "hello world\n" (org-export-string-as "hello world" 'jira))))

;; Let's do some standalone tests of very simple markup for inline text
;; effects.
;;
(ert-deftest ox-jira-test/text-effects ()
  (should (equal "this is *strong* text\n" (org-export-string-as "this is *strong* text" 'jira)))
  (should (equal "this is _emphasised_ text\n" (org-export-string-as "this is /emphasised/ text" 'jira)))
  (should (equal "this is +underlined+ text\n" (org-export-string-as "this is _underlined_ text" 'jira)))
  (should (equal "this is -deleted- text\n" (org-export-string-as "this is +deleted+ text" 'jira)))
  (should (equal "this is {{inline code}}\n" (org-export-string-as "this is ~inline code~" 'jira)))
  (should (equal "this is {{verbatim}} text\n" (org-export-string-as "this is =verbatim= text" 'jira))))

;; Test that super^script and sub_script have empty anchor immediately
;; preceeding, so they can be tacked at the end of words without whitespace
;; immediately before it.
;;
(ert-deftest ox-jira-test/embeddable-text-effects ()
  (should (equal "this is super{anchor}^scripted^ text\n" (org-export-string-as "this is super^scripted text" 'jira)))
  (should (equal "this is sub{anchor}~scripted~ text\n" (org-export-string-as "this is sub_scripted text" 'jira))))

;; Quotations are a bit more elaborate, so let's test those separately. They
;; can have other text effects inside them too.
;;
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

;; Headline numbering in org is *relative*, so we cannot test that they work
;; one-by-one.
;;
(ert-deftest ox-jira-test/headlines ()
  (should (equal "h1. top level
h2. second level
h3. third level
" (org-export-string-as "* top level
** second level
*** third level" 'jira))))

;; As far as I understand these are not useful in JIRA output, so let's just
;; filter them out.
;;
(ert-deftest ox-jira-test/keywords()
  (should (equal "" (org-export-string-as "#+TITLE: MyTitle
#+DATE: 2016-02-26
#+OPTIONS: f:t" 'jira))))

(ert-deftest ox-jira-test/links ()
  (should (equal "fi [http://jira.atlassian.com] fo\n"
                 (org-export-string-as "fi [[http://jira.atlassian.com]] fo" 'jira)))
  (should (equal "fi [Jira|http://jira.atlassian.com] fo\n"
                 (org-export-string-as "fi [[http://jira.atlassian.com][Jira]] fo" 'jira))))

;; Check that text in paragraphs does not have hard newlines.
;;
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

(ert-deftest ox-jira-test/nested-lists()
  (should (equal "* fi
** fo
*** fa
**** fum
" (org-export-string-as "- fi
  - fo
    - fa
      - fum" 'jira)))
  (should (equal "* fi
*# fo
*#* fa
*#*# fum
" (org-export-string-as "- fi
  1. fo
    - fa
      1. fum" 'jira))))

(ert-deftest ox-jira-test/unordered-list-with-checkboxes()
  (should (equal "* (x) fi
* (/) fo
" (org-export-string-as "- [ ] fi
- [X] fo" 'jira))))

(ert-deftest ox-jira-test/checkboxes-and-statistics()
  (should (equal "* (i) Progress \\[50%]
** (x) fi
** (/) fo
" (org-export-string-as "- [-] Progress [50%]
  - [ ] fi
  - [X] fo" 'jira))))

(ert-deftest ox-jira-test/definition-lists()
  (should (equal "* *fi*: fo
* *fa*: fum
" (org-export-string-as "- fi :: fo
- fa :: fum" 'jira))))

;; This is not really supported by JIRA, so we have to fake it.
;;
(ert-deftest ox-jira-test/multi-para-list-items()
  (should (equal "# fi
fo
# fa
" (org-export-string-as "1. fi

   fo
2. fa" 'jira)))

  (should (equal "# fi
#* fifi
#* fofo
# fa
# fum
" (org-export-string-as "1. fi

  * fifi

  * fofo

2. fa

3. fum" 'jira)))

  (should (equal "# fi
#* {code:sql}SELECT 1;
{code}
{code:sql}SELECT 2;
{code}
#* fofo
# fa
" (org-export-string-as "1. fi

  *
    #+begin_src sql
    SELECT 1;
    #+end_src

    #+begin_src sql
    SELECT 2;
    #+end_src

  * fofo

2. fa
" 'jira)))
  )

(ert-deftest ox-jira-test/plain-text ()
  (should (equal "fi fo \\[fa] fum
" (org-export-string-as "fi fo [fa] fum" 'jira))))

(ert-deftest ox-jira-test/src-blocks ()
  (should (equal "{code}echo hello
# echo world
{code}
" (org-export-string-as "#+begin_src sh
     echo hello
     # echo world
     #+end_src
" 'jira)))
  (should (equal "{code:sql}BEGIN;
SELECT NOW();
END;
{code}
" (org-export-string-as "#+begin_src sql
     BEGIN;
     SELECT NOW();
     END;
     #+end_src
" 'jira))))

;; The Holy Grail. Do me proud, Org mode!
;;
(ert-deftest ox-jira-test/tables ()
  (should (equal "| a | b |
| c | d |
" (org-export-string-as "
| a | b |
| c | d |
" 'jira)))

  ;; This should really be
  ;; : || a || b ||
  ;; : | c | d |
  ;;
  ;; but I haven't figured out how to identify the header row yet. This test
  ;; checks that we at least ignore the horizontal lines.
  (should (equal "|| a || b ||
| c | d |
" (org-export-string-as "
| a | b |
|---+---|
| c | d |
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

(ert-deftest ox-jira-test/fixed-width-blocks ()
  (should (equal "{noformat}
stuff that should
 not be
formatted
{noformat}
" (org-export-string-as ": stuff that should
:  not be
: formatted
" 'jira))))

(ert-deftest ox-jira-test/horizontal-rule ()
  (should
   (equal "----\n" (org-export-string-as "-----\n" 'jira)))
  (should
   (equal "----\n" (org-export-string-as "-------\n" 'jira))))

(ert-deftest ox-jira-test/footnotes ()
  (should (equal "fi fo{anchor:backfn1}[^1^|#fn1]. Another one{anchor:backfn2}[^2^|#fn2].

h1. Footnotes
{anchor:fn1}[^1^|#backfn1] fa fum.
{anchor:fn2}[^2^|#backfn2] fut fut.
" (org-export-string-as "fi fo[fn:1]. Another one[fn:2].

* Footnotes

[fn:1] fa fum.

[fn:2] fut fut.
" 'jira))))

(provide 'ox-jira-test)

;;; ox-jira.el-test.el ends here
