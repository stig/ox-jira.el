#!/bin/sh -e

emacs -q \
      --batch \
      -l ox-jira.el \
      -l test/ox-jira-test.el \
      -f ert-run-tests-batch-and-exit
