#lang racket/base
(require racket/contract/base
         racket/serialize
         "private/provide-structs.rkt")

(provide-structs
 [typ-addition ([path (or/c path-string? (cons/c 'collects (listof bytes?)) bytes?)])]
 [typst-defaults ([prefix (or/c bytes? path-string? (cons/c 'collects (listof bytes?)))]
                  [style (or/c bytes? path-string? (cons/c 'collects (listof bytes?)))]
                  [extra-files (listof (or/c path-string? (cons/c 'collects (listof bytes?))))])])
