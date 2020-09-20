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

(defun to-jira (string)
  (org-export-string-as string 'jira nil '(:src-collapse-threshold 3)))

;; This is my first foray into testing in Emacs. Please be kind.

;; Let's write the simplest possible test that actually invokes anything org
;; export related.
;;
(ert-deftest ox-jira-test/hello-world ()
  (should (equal "hello world\n" (to-jira "hello world"))))

;; Let's do some standalone tests of very simple markup for inline text
;; effects.
;;
(ert-deftest ox-jira-test/text-effects ()
  (should (equal "this is *strong* text\n" (to-jira "this is *strong* text")))
  (should (equal "this is _emphasised_ text\n" (to-jira "this is /emphasised/ text")))
  (should (equal "this is +underlined+ text\n" (to-jira "this is _underlined_ text")))
  (should (equal "this is -deleted- text\n" (to-jira "this is +deleted+ text")))
  (should (equal "this is {{inline code}}\n" (to-jira "this is ~inline code~")))
  (should (equal "this is {{verbatim}} text\n" (to-jira "this is =verbatim= text"))))

;; Test that super^script and sub_script have empty anchor immediately
;; preceeding, so they can be tacked at the end of words without whitespace
;; immediately before it.
;;
(ert-deftest ox-jira-test/embeddable-text-effects ()
  (should (equal "this is super{anchor}^scripted^ text\n" (to-jira "this is super^scripted text")))
  (should (equal "this is sub{anchor}~scripted~ text\n" (to-jira "this is sub_scripted text"))))

;; Quotations are a bit more elaborate, so let's test those separately. They
;; can have other text effects inside them too.
;;
(ert-deftest ox-jira-test/quotations ()
  (should (equal "{quote}
This is a quote.

It can have multiple paragraphs.
{quote}
" (to-jira "
#+BEGIN_QUOTE
This is a quote.

It can have multiple paragraphs.
#+END_QUOTE")))

  (should (equal "{quote}
This is a quote with _emphasis_.
{quote}
" (to-jira "
#+begin_quote
This is a quote with /emphasis/.
#+end_quote"))))

;; Headline numbering in org is *relative*, so we cannot test that they work
;; one-by-one.
;;
(ert-deftest ox-jira-test/headlines ()
  (should (equal "h1. top level
h2. second level
h3. third level
" (to-jira "* top level
** second level
*** third level"))))

;; Override headline offset
;;
(ert-deftest ox-jira-test/headlines-with-customized-levels ()
  (let ((ox-jira-override-headline-offset 2))
    (should (equal "h3. top level
h4. second level
h5. third level
" (to-jira "* top level
** second level
*** third level")))))


(ert-deftest ox-jira-test/todo-headlines ()
  (should
   (equal "h1. {color:lightgreen}{{DONE}}{color} This is a headline
h1. {color:red}{{TODO}}{color} This is another headline
" (to-jira "* DONE This is a headline
* TODO This is another headline"))))

(ert-deftest ox-jira-test/tag-headlines ()
  (should (equal "h1. This is a headline {color:blue}{{:TAG:XXX:}}{color}
h1. This is another headline {color:blue}{{:FOO:BAR:}}{color}
" (to-jira "* This is a headline :TAG:XXX:
* This is another headline :FOO:BAR:"))))


(ert-deftest ox-jira-test/full-headlines ()
  (should (equal "h1. {color:lightgreen}{{DONE}}{color} This is a headline {color:blue}{{:TAG:XXX:}}{color}
h1. {color:red}{{TODO}}{color} This is another headline {color:blue}{{:FOO:BAR:}}{color}
" (to-jira "* DONE This is a headline :TAG:XXX:
* TODO This is another headline :FOO:BAR:"))))

;; As far as I understand these are not useful in JIRA output, so let's just
;; filter them out.
;;
(ert-deftest ox-jira-test/keywords()
  (should (equal "" (to-jira "#+TITLE: MyTitle
#+DATE: 2016-02-26
#+OPTIONS: f:t"))))

(ert-deftest ox-jira-test/links ()
  (should (equal "fi [http://jira.atlassian.com] fo\n"
                 (to-jira "fi [[http://jira.atlassian.com]] fo")))
  (should (equal "fi [Jira|http://jira.atlassian.com] fo\n"
                 (to-jira "fi [[http://jira.atlassian.com][Jira]] fo")))
  (should (equal "see [#Heading Name] for details\n"
                 (to-jira "see [[*Heading Name]] for details")))
  (should (equal "see [This Thing|#Heading Name] for details\n"
                 (to-jira "see [[*Heading Name][This Thing]] for details")))
  (should (equal "see [#Heading Name] for details\n"
                 (to-jira "see [[#Heading Name]] for details")))
  (should (equal "see [This Thing|#This Thing] for details\n"
                 (to-jira "see [[#Heading Name][This Thing]] for details"))))

;; Check that text in paragraphs does not have hard newlines.
;;
(ert-deftest ox-jira-test/paragraphs ()
  (should (equal "fi fo fa fum\n" (to-jira "fi
fo
fa
fum"))))

(ert-deftest ox-jira-test/unordered-lists()
  (should (equal "* fi
* fo
* fa
* fum
" (to-jira "- fi
- fo
- fa
- fum"))))

(ert-deftest ox-jira-test/ordered-lists()
  (should (equal "# fi
# fo
# fa
# fum
" (to-jira "1. fi
2. fo
3. fa
3. fum"))))

(ert-deftest ox-jira-test/nested-lists()
  (should (equal "* fi
** fo
*** fa
**** fum
" (to-jira "- fi
  - fo
    - fa
      - fum")))
  (should (equal "* fi
*# fo
*#* fa
*#*# fum
" (to-jira "- fi
  1. fo
    - fa
      1. fum"))))

(ert-deftest ox-jira-test/unordered-list-with-checkboxes()
  (should (equal "* (x) fi
* (/) fo
" (to-jira "- [ ] fi
- [X] fo"))))

(ert-deftest ox-jira-test/checkboxes-and-statistics()
  (should (equal "* (i) Progress \\[50%]
** (x) fi
** (/) fo
" (to-jira "- [-] Progress [50%]
  - [ ] fi
  - [X] fo"))))

(ert-deftest ox-jira-test/definition-lists()
  (should (equal "* *fi*: fo
* *fa*: fum
" (to-jira "- fi :: fo
- fa :: fum"))))

;; This is not really supported by JIRA, so we have to fake it.
;;
(ert-deftest ox-jira-test/multi-para-list-items()
  (should (equal "# fi
fo
# fa
" (to-jira "1. fi

   fo
2. fa")))

  (should (equal "# fi
#* fifi
#* fofo
# fa
# fum
" (to-jira "1. fi

  * fifi

  * fofo

2. fa

3. fum")))

  (should (equal "# fi
#* {code:title=|language=sql|collapse=false}SELECT 1;
{code}
{code:title=|language=sql|collapse=false}SELECT 2;
{code}
#* fofo
# fa
" (to-jira "1. fi

  *
    #+begin_src sql
    SELECT 1;
    #+end_src

    #+begin_src sql
    SELECT 2;
    #+end_src

  * fofo

2. fa
")))
  )

(ert-deftest ox-jira-test/plain-text ()
  (should (equal "fi fo \\[fa] fum
" (to-jira "fi fo [fa] fum"))))

(ert-deftest ox-jira-test/src-blocks ()
  (should (equal "{code:title=|language=none|collapse=false}echo hello
# echo world
{code}
" (to-jira "#+begin_src sh
     echo hello
     # echo world
     #+end_src
")))
  (should (equal "{code:title=|language=sql|collapse=false}BEGIN;
SELECT NOW();
END;
{code}
" (to-jira "#+begin_src sql
     BEGIN;
     SELECT NOW();
     END;
     #+end_src
")))
  (should (equal "{code:title=Hello|language=sql|collapse=false}BEGIN;
SELECT NOW();
END;
{code}
" (to-jira "#+CAPTION: Hello
     #+begin_src sql
     BEGIN;
     SELECT NOW();
     END;
     #+end_src
")))

  (should (equal "{code:title=Hello World|language=sql|collapse=true}BEGIN;
SELECT NOW();
SELECT NOW();
END;
{code}
" (to-jira "#+CAPTION: Hello World
     #+begin_src sql
     BEGIN;
     SELECT NOW();
     SELECT NOW();
     END;
     #+end_src
")))
  )

;; The Holy Grail. Do me proud, Org mode!
;;
(ert-deftest ox-jira-test/tables ()
  (should (equal "| a | b |
| c | d |
" (to-jira "
| a | b |
| c | d |
")))

  (should (equal "|  | b |
| c |  |
" (to-jira "
|  | b |
| c |  |
")))

  ;; This should really be
  ;; : || a || b ||
  ;; : | c | d |
  ;;
  ;; but I haven't figured out how to identify the header row yet. This test
  ;; checks that we at least ignore the horizontal lines.
  (should (equal "|| a || b ||
| c | d |
" (to-jira "
| a | b |
|---+---|
| c | d |
"))))

(ert-deftest ox-jira-test/example-blocks ()
  (should (equal "{noformat}
stuff that should
 not be
formatted
{noformat}
" (to-jira "#+begin_example
stuff that should
 not be
formatted
#+end_example
"))))

(ert-deftest ox-jira-test/fixed-width-blocks ()
  (should (equal "{noformat}
stuff that should
 not be
formatted
{noformat}
" (to-jira ": stuff that should
:  not be
: formatted
"))))

(ert-deftest ox-jira-test/horizontal-rule ()
  (should
   (equal "----\n" (to-jira "-----\n")))
  (should
   (equal "----\n" (to-jira "-------\n"))))

(ert-deftest ox-jira-test/footnotes ()
  (should (equal "fi fo{anchor:fnr1}[^1^|#fn1]. Another one{anchor:fnr2}[^2^|#fn2].

h1. Footnotes
{anchor:fn1}[^1^|#fnr1] fa fum.

{anchor:fn2}[^2^|#fnr2] fut fut.
" (to-jira "fi fo[fn:1]. Another one[fn:2].

* Footnotes

[fn:1] fa fum.

[fn:2] fut fut.
"))))

(ert-deftest ox-jira-test/timestamps ()
  (should (equal "An inactive datestamp: _\\[2017-01-11 Wed]_\n"
                 (to-jira "An inactive datestamp: [2017-01-11 Wed]")))
  (should (equal "An inactive timestamp: _\\[2017-01-11 Wed 12:34]_\n"
                 (to-jira "An inactive timestamp: [2017-01-11 Wed 12:34]")))
  (should (equal "An active datestamp: _<2017-01-11 Wed>_\n"
                 (to-jira "An active datestamp: <2017-01-11 Wed>")))
  (should (equal "An active timestamp: _<2017-01-11 Wed 02:12>_\n"
                 (to-jira "An active timestamp: <2017-01-11 Wed 02:12>"))))

(provide 'ox-jira-test)

;;; ox-jira.el-test.el ends here
