(require 'org)

;; Find our current directory.
(let* ((dir (file-name-directory (or (buffer-file-name) load-file-name)))
       (test-dir (expand-file-name "test" dir)))

  ;; Tangle source files
  (mapc #'org-babel-load-file
        (directory-files dir t "ox-.*\\.org$"))

  ;; Tangle test files
  (mapc #'org-babel-load-file
        (directory-files test-dir t "ox-.*\\.org$")))
