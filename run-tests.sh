#!/bin/sh -e

emacs --version
emacs -q \
      --batch \
      -l ox-jira.el \
      -l test/ox-jira-test.el \
      -f ert-run-tests-batch-and-exit
