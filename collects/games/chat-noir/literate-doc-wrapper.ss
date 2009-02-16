#lang scheme/base

;; Use this module to create literate doc wrappers -- files that require the
;; literate code in a way that makes it a scribble file.

(provide include chunk chunkref
         (all-from-out scribble/manual))

(require scribble/manual scribble/decode scribble/struct scheme/include
         (for-syntax scheme/base syntax/boundmap))

(begin-for-syntax
  ;; maps chunk identifiers to a counter, so we can distinguish multiple uses
  ;; of the same name
  (define chunk-numbers (make-free-identifier-mapping))
  (define (get-chunk-number id)
    (let ([n (add1 (free-identifier-mapping-get chunk-numbers id
                                                (lambda () 0)))])
      (free-identifier-mapping-put! chunk-numbers id n)
      n)))

;; This is the doc-view implementation of `chunk', see "literate-lang.ss" for
;; the cide-view implementation.  Defines `chunk' as a macro that typesets the
;; contained code.
(define-syntax (chunk stx)
  (syntax-case stx ()
    [(_ name expr ...)
     ;; no need for more error checking, using chunk for the code will do that
     (identifier? #'name)
     (let ([n (get-chunk-number #'name)]
           [str (symbol->string (syntax-e #'name))])
       (with-syntax ([tag (if (n . > . 1) (format "~a:~a" str n) str)]
                     [(more ...) (if (n . > . 1)
                                     #`((subscript #,(format "~a" n)))
                                     #`())]
                     [str str])
         #`(make-splice
            (list (make-toc-element
                   #f
                   (list (elemtag '(chunk tag) (italic (scheme name) " ::=")))
                   (list (make-element
                          "smaller"
                          (list (elemref '(chunk tag) str more ...)))))
                  (schemeblock expr ...)))))]))

(define-syntax (chunkref stx)
  (syntax-case stx ()
    [(_ id)
     (identifier? #'id)
     (with-syntax ([str (format "~a" (syntax-e #'id))])
       #'(elemref '(chunk str) str))]))

;; HACK: provide a fake `module', which makes it possible to include a module
;; and get only its code in.
(provide module)
(define-syntax-rule (module name base body ...)
  (begin body ...))