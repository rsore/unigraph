(require 'cmake-mode)

(defun unigraph-keywords ()
  '("NAME" "TYPE" "SOURCES" "HEADERS" "DEPEND" "INCLUDE_DIRS"
    "TEST_SOURCES" "NOLINK_DEPEND" "PROPERTIES" "DEFINITIONS"
    "GENERATE_REPORT" "GENERATE_DEPENDENCY_GRAPH" "TEST_FRAMEWORK"
    "UNITS"))

(defun unigraph-functions ()
  '("unigraph_init" "unigraph_unit"))

(defun unigraph-font-lock-keywords ()
  (list
   ;; Highlight keywords like SOURCES, HEADERS, DEPEND
   `(,(regexp-opt (unigraph-keywords) 'symbols) . font-lock-keyword-face)

   ;; Highlight platform annotations like :windows, :darwin
   '(":\\([a-zA-Z0-9-_]+\\(?:\\(:[a-zA-Z0-9-_]+\\)*\\)\\)" . font-lock-preprocessor-face)

   ;; Highlight the user-facing unigraph functions
   `(,(regexp-opt (unigraph-functions) 'symbols) . font-lock-function-name-face)))

(define-derived-mode unigraph-mode cmake-mode "Unigraph"
  "Simple major mode for editing Unigraph unit files."
  :syntax-table nil ;; Inherit the syntax table of cmake-mode
  (setq-local font-lock-defaults '(unigraph-font-lock-keywords)))

(defun unigraph-mode-maybe ()
  "Activate `unigraph-mode` for unit.cmake files."
  (when (string= (file-name-nondirectory buffer-file-name) "unit.cmake")
    (unigraph-mode)))
(add-hook 'find-file-hook 'unigraph-mode-maybe)

(provide 'unigraph-mode)
