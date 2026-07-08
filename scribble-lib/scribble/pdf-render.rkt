#lang racket/base

(require (prefix-in latex: "latex-render.rkt")
         (prefix-in typst: "typst-render.rkt")
         "private/indirect-renderer.rkt"
         "private/run-pdflatex.rkt"
         "private/run-typst.rkt")

(provide render-mixin
         dvi-render-mixin
         xelatex-render-mixin
         lualatex-render-mixin
         typst-render-mixin)

(define render-mixin
  (make-indirect-renderer-mixin
   (λ (%) (latex:render-mixin % #:image-mode 'pdf)) #".tex" #".pdf"
   run-pdflatex))

(define dvi-render-mixin
  (make-indirect-renderer-mixin
   (λ (%) (latex:render-mixin % #:image-mode 'ps)) #".tex" #".pdf"
   run-dvipdf-latex))

(define xelatex-render-mixin
  (make-indirect-renderer-mixin
   (λ (%) (latex:render-mixin % #:image-mode 'pdf)) #".tex" #".pdf"
   run-xelatex))

(define lualatex-render-mixin
  (make-indirect-renderer-mixin
   (λ (%) (latex:render-mixin % #:image-mode 'pdf)) #".tex" #".pdf"
   run-lualatex))

(define typst-render-mixin
  (make-indirect-renderer-mixin
   typst:render-mixin #".typ" #".pdf"
   run-typst))
