#lang racket/base

(provide make-colon-keyword-readtable)

;; from:
;; https://groups.google.com/d/msg/racket-dev/HUXsCRI5ab0/2jdn9FTVCwAJ

(define read-colon-keyword
  (case-lambda
    [(ch port)
     (symbol->keyword (read/recursive port))]
    [(ch port src line col pos)
     (define stx (read-syntax/recursive src port))
     (datum->syntax #f (symbol->keyword (syntax-e stx))
                    (list src line col pos (add1 (syntax-span stx)))
                    stx)]))

(define (symbol->keyword sym)
  (string->keyword (symbol->string sym)))

(define (make-colon-keyword-readtable)
  (make-readtable (current-readtable)
                  #\:
                  'non-terminating-macro
                  read-colon-keyword))

(module+ test
  (require rackunit)
  (define (reads in out)
    (check-equal? (read (open-input-string in)) out))
  (parameterize ([current-readtable (make-colon-keyword-readtable)])
    (reads "a:b" 'a:b)
    (reads ":a" '#:a)
    (reads "#:a" '#:a)))