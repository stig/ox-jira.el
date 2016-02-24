
;;; ox-jira-test.el --- tests for ox-jira.el

;;; Author: Stig Brautaset <stig@brautaset.org>

;; This file is NOT part of GNU Emacs.

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

;;; Code:

(require 'ert)
(require 'ox-jira)

(ert-deftest test-bootstrap-success ()
  (should (equal 1 1))
  (should (equal "foo" "foo")))

(ert-deftest test-bootstrap-fail ()
  (should (equal "foo" "bar")))


(ert-deftest test-bootstrap-success-2 ()
  (should (equal 4 4)))

(provide 'ox-jira-test)

;;; ox-jira.el-test.el ends here
