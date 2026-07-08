#lang racket/base
(require "core.rkt"
         "base-render.rkt"
         "private/render-utils.rkt"
         racket/class
         racket/port
         racket/list
         racket/string
         racket/runtime-path
         setup/collects
         file/convertible)

(provide render-mixin)

(define current-indent (make-parameter 0))
(define (make-indent amt)
  (+ amt (current-indent)))
(define (indent)
  (define i (current-indent))
  (unless (zero? i) (display (make-string i #\space))))
(define (indented-newline)
  (newline)
  (indent))

(define in-code? (make-parameter #f))
(define in-link? (make-parameter #f))
(define preserving-spaces? (make-parameter #f))
;; When rendering in code mode, a box to accumulate labels for
;; target elements that appear in the code, so that anchors can be
;; emitted after the code block:
(define code-target-labels (make-parameter #f))

(define typst-part-tag 'typst-section)

(define-runtime-path scribble-prefix-typ "scribble-prefix.typ")
(define-runtime-path scribble-style-typ "scribble-style.typ")

;; Escape a string for use in Typst markup mode. The escaped set
;; covers all characters that are (or can be) markup-significant;
;; parentheses are included because an open parenthesis immediately
;; after an embedded code expression would be parsed as a call.
(define (typst-escape s)
  (regexp-replace* #rx"[][()\\{}#$*`@<>/~'\"=+_-]" s "\\\\&"))

;; Escape a string for use inside a Typst string literal:
(define (typst-string-escape s)
  (let* ([s (regexp-replace* #rx"\\\\" s "\\\\\\\\")]
         [s (regexp-replace* #rx"\"" s "\\\\\"")]
         [s (regexp-replace* #rx"\n" s "\\\\n")]
         [s (regexp-replace* #rx"\t" s "\\\\t")]
         [s (regexp-replace* #rx"\r" s "")])
    s))

;; Encode a tag as a Typst label name; produces only alphanumeric
;; ASCII characters plus `_`, which are all allowed in label names:
(define (t-encode s)
  (string-append*
   (map (lambda (c)
          (cond
            [(and (or (char-alphabetic? c) (char-numeric? c))
                  ((char->integer c) . < . 128))
             (string c)]
            [(char=? c #\space) "_"]
            [else (format "x~x" (char->integer c))]))
        (string->list (format "~s" s)))))

;; Color names that Typst predefines, for `color-property` values
;; that arrive as strings:
(define typst-color-names
  '("black" "gray" "silver" "white" "navy" "blue" "aqua" "teal" "eastern"
    "purple" "fuchsia" "maroon" "red" "orange" "yellow" "olive" "green" "lime"))

(define (typst-color c)
  (cond
    [(string? c) (if (member c typst-color-names) c "black")]
    [else (format "rgb(~a, ~a, ~a)" (car c) (cadr c) (caddr c))]))

(define-struct (toc-paragraph paragraph) ())

(define (render-mixin %)
  (class %
    (super-new)

    (inherit-field prefix-file style-file style-extra-files image-preferences)

    (define/override (current-render-mode)
      '(typst))

    (define/override (get-suffix) #".typ")

    (define/override (get-substitutions)
      '((#rx"---" "\U2014")
        (#rx"--" "\U2013")
        (#rx"``" "\U201C")
        (#rx"''" "\U201D")
        (#rx"'" "\U2019")))

    (inherit render-block
             render-part
             install-file
             format-number
             number-depth
             sort-image-requests
             extract-version
             extract-date
             extract-authors
             extract-pretitle-content)

    (define image-reqs
      (sort-image-requests '(svg-bytes png@2x-bytes png-bytes pdf-bytes)
                           image-preferences))

    ;; Typst reports an error for a reference to a label that is not
    ;; defined or that is defined multiple times, so keep track of
    ;; emitted and referenced labels; extra anchors are added at the
    ;; end of the document for referenced labels that were never
    ;; emitted (e.g., a target that appears only inside a code block)
    (define emitted-labels (make-hash))
    (define linked-labels (make-hash))

    ;; Emits a `#metadata' anchor for `lbl' (unless one was already
    ;; emitted for it), which is invisible but linkable:
    (define/private (emit-anchor lbl)
      (unless (hash-ref emitted-labels lbl #f)
        (hash-set! emitted-labels lbl #t)
        (printf "#metadata(none) <~a>" lbl)))

    (define/private (display-raw s #:block? [block? #f] #:lang [lang #f])
      (printf "#raw(~a~a\"~a\")"
              (if block? "block: true, " "")
              (if lang (format "lang: \"~a\", " lang) "")
              (typst-string-escape s)))

    ;; ----------------------------------------
    ;; collect

    (define/override (collect-part-tags d ci number)
      (for ([t (part-tags d)])
        (let ([t (generate-tag t ci)])
          (collect-put! ci
                        t
                        (vector (or (part-title-content d) '("???"))
                                (add-current-tag-prefix t)
                                number
                                typst-part-tag)))))

    ;; ----------------------------------------
    ;; render

    (define/override (render-one d ri fn)
      (define (copy-file-to-output file)
        (if (bytes? file)
            (display file)
            (with-input-from-file file
              (lambda ()
                (copy-port (current-input-port) (current-output-port))))))
      (copy-file-to-output (or prefix-file scribble-prefix-typ))
      (copy-file-to-output (or style-file scribble-style-typ))
      (for ([style-file (in-list style-extra-files)])
        (copy-file-to-output style-file))
      (define title-content (part-title-content d))
      (define title-str (and title-content (content->string title-content this d ri)))
      (when (and title-str (not (equal? title-str "")))
        (printf "#set document(title: \"~a\")\n" (typst-string-escape title-str)))
      (newline)
      (when (and title-content
                 (not (and (part-style? d 'hidden)
                           (equal? "" title-str))))
        (let ([vers (extract-version d)]
              [date (extract-date d)]
              [auths (extract-authors d)]
              [pres (extract-pretitle-content d)])
          (for ([pre (in-list pres)])
            (newline)
            (cond
              [(paragraph? pre) (do-render-paragraph pre d ri #t)]
              [(nested-flow? pre) (do-render-nested-flow pre d ri #f #t)]))
          (printf "#align(center)[#text(1.8em, weight: \"bold\")[")
          (render-content title-content d ri)
          (printf "]]\n")
          (unless (equal? vers "")
            (printf "#align(center)[#text(1.1em)[Version ~a]]\n" (typst-escape vers)))
          (for ([auth (in-list auths)])
            (printf "#align(center)[")
            (do-render-paragraph auth d ri #t)
            (printf "]\n"))
          (when date
            (printf "#align(center)[~a]\n" (typst-escape date)))
          (newline)))
      (render-part d ri)
      ;; Add anchors for any referenced-but-never-emitted labels, so
      ;; that no `#link' in the document can fail to resolve:
      (let ([missing (sort (for/list ([lbl (in-hash-keys linked-labels)]
                                      #:unless (hash-ref emitted-labels lbl #f))
                             lbl)
                           string<?)])
        (unless (null? missing)
          (newline)
          (for ([lbl (in-list missing)])
            (printf "#metadata(none) <~a>\n" lbl)))))

    (define/override (render-part-content d ri)
      (define number (collected-info-number (part-collected-info d ri)))
      (define depth (number-depth number))
      (define hidden? (or (part-style? d 'hidden) (zero? depth)))
      (cond
        [hidden?
         ;; No heading, but emit anchors so that links to this part work:
         (for ([t (part-tags d)])
           (emit-anchor (t-encode (add-current-tag-prefix (tag-key t ri))))
           (newline))]
        [else
         (printf "~a " (make-string depth #\=))
         (let ([s (format-number number '() #t)])
           (unless (null? s)
             (printf "~a~a" (car s) (if (part-title-content d) " " ""))))
         (when (part-title-content d)
           (render-content (part-title-content d) d ri))
         ;; Only one label can attach to the heading; emit any others
         ;; as invisible anchors:
         (for ([t (part-tags d)]
               [i (in-naturals)])
           (let ([lbl (t-encode (add-current-tag-prefix (tag-key t ri)))])
             (cond
               [(and (zero? i) (not (hash-ref emitted-labels lbl #f)))
                (hash-set! emitted-labels lbl #t)
                (printf " <~a>" lbl)]
               [else
                (newline)
                (emit-anchor lbl)])))
         (newline)
         (newline)])
      (render-flow (part-blocks d) d ri #f)
      (for ([sec (part-parts d)])
        (newline)
        (render-part sec ri))
      null)

    (define/override (render-flow f part ri starting-item?)
      (if (null? f)
          null
          (append*
           (render-block (car f) part ri starting-item?)
           (for/list ([p (in-list (cdr f))])
             (indented-newline)
             (render-block p part ri #f)))))

    (define/override (render-intrapara-block p part ri first? last? starting-item?)
      (unless first? (indented-newline))
      (super render-intrapara-block p part ri first? last? starting-item?))

    ;; ----------------------------------------
    ;; paragraphs

    (define/override (render-paragraph p part ri)
      (do-render-paragraph p part ri #f))

    (define/private (do-render-paragraph p part ri show-pre?)
      (define sn (style-name (paragraph-style p)))
      (cond
        [(and (not show-pre?)
              (or (eq? sn 'author) (eq? sn 'pretitle)))
         null]
        [(toc-paragraph? p)
         (printf "#outline()")
         (newline)
         null]
        [else
         (super render-paragraph p part ri)
         (unless show-pre? (newline))
         null]))

    (define/override (table-of-contents part ri)
      (make-toc-paragraph plain null))

    (define/override (local-table-of-contents part ri style)
      (make-paragraph plain null))

    ;; ----------------------------------------
    ;; content

    (define/private (content-style e)
      (cond
        [(element? e) (element-style e)]
        [(multiarg-element? e) (multiarg-element-style e)]
        [else #f]))

    (define/private (content-style-name e)
      (define s (content-style e))
      (if (style? s) (style-name s) s))

    (define (code? i)
      (define sn (content-style-name i))
      (or (eq? sn 'tt)
          (eq? sn 'url)
          (and (string? sn)
               (regexp-match? #rx"^Rkt[A-Z]" sn))))

    (define (preserve-spaces? i)
      (eq? 'hspace (content-style-name i)))

    (define (find-target-url i)
      (define s (content-style i))
      (and (style? s)
           (for/or ([v (in-list (style-properties s))])
             (and (target-url? v) v))))

    (define/override (render-content e part ri)
      (cond
        [(in-code?)
         ;; Plain rendering, accumulating the labels of any target
         ;; elements so that anchors can be emitted after the code:
         (when (and (target-element? e) (code-target-labels))
           (let ([b (code-target-labels)])
             (set-box! b (cons (t-encode (add-current-tag-prefix
                                          (tag-key (target-element-tag e) ri)))
                               (unbox b)))))
         (if (eq? 'newline (content-style-name e))
             (begin (display "\n") null)
             (super render-content e part ri))]
        [else
         (when (target-element? e)
           (emit-anchor (t-encode (add-current-tag-prefix
                                   (tag-key (target-element-tag e) ri)))))
         (define link-target
           (and (not (in-link?))
                (or (let ([u (find-target-url e)])
                      (and u (target-url-addr u)))
                    (and (link-element? e)
                         (let-values ([(dest ext?)
                                       (resolve-get/ext? part ri (link-element-tag e))])
                           (and dest
                                (not ext?)
                                (let ([lbl (t-encode (vector-ref dest 1))])
                                  (hash-set! linked-labels lbl #t)
                                  (list 'label lbl))))))))
         (cond
           [link-target
            (if (pair? link-target)
                (printf "#link(label(\"~a\"))[" (cadr link-target))
                (printf "#link(\"~a\")[" (typst-string-escape
                                          (let ([p link-target])
                                            (if (path? p) (path->string p) p)))))
            (begin0
              (parameterize ([in-link? #t])
                (render-styled e part ri))
              (display "]"))]
           [else (render-styled e part ri)])]))

    (define/private (render-styled e part ri)
      (define es (content-style e))
      (define props (if (style? es) (style-properties es) null))
      (define color (findf color-property? props))
      (define bg (findf background-color-property? props))
      (when color
        (printf "#text(fill: ~a)[" (typst-color (color-property-color color))))
      (when bg
        (printf "#highlight(fill: ~a)[" (typst-color (background-color-property-color bg))))
      (begin0
        (render-plain-styled e part ri)
        (when bg (display "]"))
        (when color (display "]"))))

    (define/private (render-plain-styled e part ri)
      (define sn (content-style-name e))
      (define (wrap pre post)
        (display pre)
        (begin0
          (super render-content e part ri)
          (display post)))
      (cond
        [(and (image-element? e))
         (let ([fn (install-file
                    (select-suffix
                     (collects-relative->path (image-element-path e))
                     (image-element-suffixes e)
                     '(".svg" ".png" ".pdf")))])
           (render-image fn (image-element-scale e) #f)
           null)]
        [(and (convertible? e)
              (render-convertible e))
         null]
        [(code? e)
         (render-code e part ri)]
        [(and (preserve-spaces? e) (not (preserving-spaces?)))
         (parameterize ([preserving-spaces? #t])
           (render-content e part ri))]
        [(eq? sn 'bold) (wrap "#strong[" "]")]
        [(or (eq? sn 'italic) (eq? sn 'emph)) (wrap "#emph[" "]")]
        [(eq? sn 'subscript) (wrap "#sub[" "]")]
        [(eq? sn 'superscript) (wrap "#super[" "]")]
        [(eq? sn 'smaller) (wrap "#text(size: 0.83em)[" "]")]
        [(eq? sn 'larger) (wrap "#text(size: 1.2em)[" "]")]
        [(eq? sn 'no-break) (wrap "#box[" "]")]
        [(eq? sn 'newline)
         (display "#linebreak()")
         null]
        [else (super render-content e part ri)]))

    ;; Render code content to a string with escapes disabled, and
    ;; emit it as a `#raw' form:
    (define/private (render-code e part ri)
      (define o (open-output-string))
      (define targets (box null))
      (parameterize ([current-output-port o]
                     [in-code? #t]
                     [code-target-labels targets])
        (super render-content e part ri))
      (display-raw (get-output-string o))
      (for ([lbl (in-list (reverse (unbox targets)))])
        (emit-anchor lbl))
      null)

    ;; ----------------------------------------
    ;; images

    ;; Wrapping `image' in `box' makes it suitable for inline
    ;; contexts, and it stays a single unit in block contexts:
    (define/private (render-image fn scale width)
      (define img
        (format "image(\"~a\"~a)"
                (typst-string-escape (if (path? fn) (path->string fn) fn))
                (if width (format ", width: ~apt" width) "")))
      (printf "#box(~a)"
              (if (and scale (not (= scale 1)))
                  (format "scale(x: ~a%, y: ~a%, reflow: true, ~a)"
                          (exact->inexact (* 100 scale))
                          (exact->inexact (* 100 scale))
                          img)
                  img)))

    (define/private (render-convertible e)
      (for/or ([req (in-list image-reqs)])
        (case req
          [(svg-bytes)
           (let ([v (convert e 'svg-bytes)])
             (and v
                  (begin
                    (render-image (install-file "pict.svg" v) #f #f)
                    #t)))]
          [(png@2x-bytes)
           (let ([v (convert e 'png@2x-bytes+bounds8)])
             (and v
                  (begin
                    (render-image (install-file "pict.png" (car v)) #f (cadr v))
                    #t)))]
          [(png-bytes)
           (let ([v (convert e 'png-bytes+bounds8)]
                 [plain-v (lambda () (convert e 'png-bytes))])
             (cond
               [v (render-image (install-file "pict.png" (car v)) #f (cadr v)) #t]
               [(plain-v)
                => (lambda (v)
                     (render-image (install-file "pict.png" v) #f #f)
                     #t)]
               [else #f]))]
          [(pdf-bytes)
           (let ([v (convert e 'pdf-bytes)])
             (and v
                  (begin
                    (render-image (install-file "pict.pdf" v) #f #f)
                    #t)))]
          [else #f])))

    ;; ----------------------------------------
    ;; itemizations

    (define/override (render-itemization i part ri)
      (define flows (itemization-blockss i))
      (define marker
        (if (eq? 'ordered (style-name (itemization-style i)))
            "+ "
            "- "))
      (if (null? flows)
          null
          (append*
           (begin
             (display marker)
             (parameterize ([current-indent (make-indent 2)])
               (render-flow (car flows) part ri #t)))
           (for/list ([d (in-list (cdr flows))])
             (indented-newline)
             (display marker)
             (parameterize ([current-indent (make-indent 2)])
               (render-flow d part ri #f))))))

    ;; ----------------------------------------
    ;; nested flows

    (define/override (render-nested-flow i part ri starting-item?)
      (do-render-nested-flow i part ri starting-item? #f))

    (define/private (do-render-nested-flow i part ri starting-item? show-pre?)
      (define s (nested-flow-style i))
      (define props (style-properties s))
      (cond
        [(and (not show-pre?) (memq 'pretitle props))
         null]
        [(and (not (in-code?))
              (or (memq (style-name s) '(inset code-inset vertical-inset))
                  (member (style-name s) '("refcontent" "refpara" "refparaleft"))))
         (printf "#block(inset: (left: 1em))[\n")
         (begin0
           (super render-nested-flow i part ri starting-item?)
           (printf "\n]")
           (newline))]
        [else
         (super render-nested-flow i part ri starting-item?)]))

    ;; ----------------------------------------
    ;; tables

    (define/override (render-table i part ri starting-item?)
      (define flowss (table-blockss i))
      (define tick? (member (style-name (table-style i))
                            (list 'boxed "defmodule" "RktBlk")))
      (cond
        [(or (null? flowss) (null? (car flowss))) null]
        [(and tick? (not (in-code?)))
         ;; A code-flavored table: render it as plain text in a
         ;; `raw' block
         (define o (open-output-string))
         (define targets (box null))
         (parameterize ([current-output-port o]
                        [current-indent 0]
                        [in-code? #t]
                        [code-target-labels targets])
           (render-table i part ri starting-item?))
         (display-raw (regexp-replace #rx"\n+$" (get-output-string o) "")
                      #:block? #t
                      #:lang "racket")
         (newline)
         (for ([lbl (in-list (reverse (unbox targets)))])
           (emit-anchor lbl))
         null]
        [(in-code?)
         ;; Plain-text rendering of a table, with columns aligned by
         ;; padding with spaces (as in the markdown renderer):
         (define strs (map (lambda (flows)
                             (map (lambda (d)
                                    (cond
                                      [(eq? d 'cont) d]
                                      [else
                                       (define o (open-output-string))
                                       (parameterize ([current-indent 0]
                                                      [current-output-port o])
                                         (render-block d part ri #f))
                                       (regexp-split
                                        #rx"\n"
                                        (regexp-replace #rx"\n$" (get-output-string o) ""))]))
                                  flows))
                           flowss))
         (define widths (map (lambda (col)
                               (for/fold ([d 0]) ([i (in-list col)])
                                 (if (eq? i 'cont)
                                     0
                                     (apply max d (map string-length i)))))
                             (apply map list strs)))
         (define (x-length col)
           (if (eq? col 'cont) 0 (length col)))
         (for/fold ([indent? #f]) ([row (in-list strs)])
           (let ([h (apply max 0 (map x-length row))])
             (define row*
               (for/list ([i (in-range h)])
                 (for/list ([col (in-list row)])
                   (if (i . < . (x-length col)) (list-ref col i) ""))))
             (for/fold ([indent? indent?]) ([sub-row (in-list row*)])
               (when indent?
                 (indent))
               (for/fold ([space? #f])
                         ([col (in-list sub-row)]
                          [w (in-list widths)])
                 (let ([col (if (eq? col 'cont) "" col)])
                   (display (regexp-replace* #rx"\uA0" col " "))
                   (display (make-string (max 0 (- w (string-length col))) #\space)))
                 #t)
               (newline)
               #t))
           #t)
         null]
        [else
         ;; A real table:
         (define cell-styless (extract-table-cell-styles i))
         (printf "#table(\n")
         (indent)
         (printf "  columns: ~a,\n" (length (car flowss)))
         (indent)
         (printf "  stroke: none,\n")
         (for ([row (in-list flowss)]
               [styles (in-list cell-styless)])
           (indent)
           (printf "  ")
           (let loop ([row row] [styles styles])
             (unless (null? row)
               (define d (car row))
               (cond
                 [(eq? d 'cont)
                  ;; A 'cont in the first column; render as an empty cell
                  (printf "[], ")
                  (loop (cdr row) (cdr styles))]
                 [else
                  (define cnt (let inner ([row (cdr row)] [n 1])
                                (cond
                                  [(null? row) n]
                                  [(eq? (car row) 'cont) (inner (cdr row) (add1 n))]
                                  [else n])))
                  (define props (style-properties (car styles)))
                  (define opts
                    (append
                     (if (cnt . > . 1) (list (format "colspan: ~a" cnt)) null)
                     (let ([horiz (cond
                                    [(memq 'right props) "right"]
                                    [(memq 'center props) "center"]
                                    [else #f])]
                           [vert (cond
                                   [(memq 'top props) "top"]
                                   [(memq 'bottom props) "bottom"]
                                   [else #f])])
                       (if (or horiz vert)
                           (list (format "align: ~a"
                                         (string-join (filter values (list horiz vert)) " + ")))
                           null))
                     (cond
                       [(memq 'border props) (list "stroke: 0.6pt")]
                       [else
                        (define sides
                          (filter values
                                  (list (and (memq 'left-border props) "left: 0.6pt")
                                        (and (memq 'right-border props) "right: 0.6pt")
                                        (and (memq 'top-border props) "top: 0.6pt")
                                        (and (memq 'bottom-border props) "bottom: 0.6pt"))))
                        (if (null? sides)
                            null
                            (list (format "stroke: (~a)" (string-join sides ", "))))])))
                  (if (null? opts)
                      (printf "[")
                      (printf "table.cell(~a)[" (string-join opts ", ")))
                  (parameterize ([current-indent 0])
                    (render-block d part ri #f))
                  (printf "], ")
                  (loop (list-tail row cnt) (list-tail styles cnt))])))
           (newline))
         (indent)
         (printf ")")
         (newline)
         null]))

    ;; ----------------------------------------
    ;; strings and other atoms

    (define/override (render-other i part ri)
      (cond
        [(symbol? i)
         (display (case i
                    [(mdash) "—"]
                    [(ndash) "–"]
                    [(ldquo) "“"]
                    [(rdquo) "”"]
                    [(lsquo) "‘"]
                    [(rsquo) "’"]
                    [(prime) "′"]
                    [(rarr) "→"]
                    [(larr) "←"]
                    [(alpha) "α"]
                    [(infin) "∞"]
                    [(lang) "⟨"]
                    [(rang) "⟩"]
                    [(nbsp) "\uA0"]
                    [else (error 'typst-render "unknown element symbol: ~e" i)]))]
        [(string? i)
         (cond
           [(in-code?) (display i)]
           [else
            (let* ([s (regexp-replace** i '((#rx"---" . "—")
                                            (#rx"--" . "–")
                                            (#rx"``" . "“")
                                            (#rx"''" . "”")
                                            (#rx"'" . "’")))]
                   [s (typst-escape s)]
                   [s (if (preserving-spaces?)
                          (regexp-replace* #rx" " s "\uA0")
                          s)])
              (display s))])]
        [else (render-other (format "~s" i) part ri)])
      null)))

(define (regexp-replace** str ptns&reps)
  (for/fold ([str str])
            ([ptn (in-list (map car ptns&reps))]
             [rep (in-list (map cdr ptns&reps))])
    (regexp-replace* ptn str rep)))
