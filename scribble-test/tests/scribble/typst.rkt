#lang racket/base

;; Use Typst renderer to check some Scribble functionality

(require scribble/base-render (prefix-in typst: scribble/typst-render)
         racket/file racket/class racket/runtime-path tests/eli-tester)

(define-runtime-path source-dir "typst-docs")
(define work-dir (build-path (find-system-path 'temp-dir)
                             "scribble-docs-tests"))

(define (build-typst-doc src-file dest-file)
  (define renderer (new (typst:render-mixin render%) [dest-dir work-dir]))
  (define docs (list (dynamic-require src-file 'doc)))
  (define fns (list (build-path work-dir dest-file)))
  (define fp (send renderer traverse docs fns))
  (define info (send renderer collect docs fns fp))
  (define r-info (send renderer resolve docs fns info))
  (send renderer render docs fns r-info)
  (send renderer get-undefined r-info))

(provide typst-tests)
(module+ main (typst-tests))
(define (typst-tests)
  (when (or (file-exists? work-dir) (directory-exists? work-dir))
    (delete-directory/files work-dir))
  (dynamic-wind
    (λ() (make-directory work-dir))
    (λ()
      (define files (map path-element->string (directory-list source-dir)))
      (test do
        (for ([scrbl (in-list files)]
              #:when (regexp-match? #rx"\\.scrbl$" scrbl)
              [typ   (in-value (regexp-replace #rx"\\.scrbl$" scrbl ".typ"))]
              #:when (member typ files))
          ;; (printf "Testing ~s -> ~s\n" scrbl typ)
          (define src-file (build-path source-dir scrbl))
          (define expect-file (build-path source-dir typ))
          (define generated-file (build-path work-dir "gen.typ"))
          (define (contents file)
            (regexp-replace #rx"\n+$" (file->string file) ""))
          (build-typst-doc src-file "gen.typ")
          (test #:failure-message
                (format
                 "mismatch for: \"~a\", expected text in: \"~a\", got:\n~a"
                 scrbl typ (contents generated-file))
                (string=? (contents expect-file) (contents generated-file))))))
    (λ() (delete-directory/files work-dir))))
