
;; gamble
;; This contract allows for three apes to gamble
;; Each send 1 STX to the contract, 1 of three will win all STX

;; constants
;;
(define-constant gamble-amount u1)
(define-constant ERR_TRANSFER u10)

;; data maps and vars
;;
(define-data-var pot uint u0)
(define-data-var fee uint u10)

;; private functions
;;

;; public functions
;;
(define-read-only (get-fee)
  (var-get fee)
)

(define-read-only (get-pot)
  (var-get pot)
)

(define-public (play (amount uint))
  (begin
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err ERR_TRANSFER))
    (var-set pot (+ (var-get pot) amount))
    (ok (var-get pot))
  )
)
;; tx-sender sends to contract
