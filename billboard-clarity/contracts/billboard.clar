
;; billboard
;; Test contract for clarity practice
;; constants
;; error constants
(define-constant ERR_STX_TRANSFER u0)

;; data maps and vars
;; variable defined below
(define-data-var billboard-message (string-utf8 500) u"Hello Billboard")
(define-data-var price uint u100)


;; private functions
;;

;; public functions
;;
;; This will set the function on a public level
;;This updates the billboard message

(define-read-only (get-message)
    (var-get billboard-message)
)

(define-read-only (get-price)
  (var-get price)
)

(define-public (set-message (message (string-utf8 500)))
  (let ((cur-price (var-get price))
          (new-price (+ cur-price u10)))

      (unwrap! (stx-transfer? cur-price tx-sender (as-contract tx-sender)) (err ERR_STX_TRANSFER))

      ;; update the billboard's message
      (var-set billboard-message message)

      ;; update the practice
      (var-set price new-price)

      ;; return the updated practice
      (ok new-price)
    )
)
