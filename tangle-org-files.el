(require 'org)

;; Find our current directory.
(setq dir (file-name-directory (or (buffer-file-name) load-file-name)))

;; Generate *.el files from *.org files in `.' and the `test/' directories.
;; No doubt this could be done in one statement, but my elisp-fu is not very strong yet.
(mapc #'org-babel-load-file (directory-files dir t "ox-.*\\.org$"))
(mapc #'org-babel-load-file (directory-files (expand-file-name "test" dir) t "ox-.*\\.org$"))
