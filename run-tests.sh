#!/bin/sh -e

# first regenerate *.el files from *.org  sources
cask eval '(load-file "tangle-org-files.el")'

# Now run tests
cask exec ert-runner -L . -L test "$@"
