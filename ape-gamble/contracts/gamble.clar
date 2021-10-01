
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

(define-map gamblers uint {player: principal, bet: uint})


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
;; amount to gamble
;; what seat to take 1-3
(define-public (play2 (amount uint) (gambler uint))
  (begin
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err ERR_TRANSFER))
    (map-set gamblers gambler {player: tx-sender, bet: amount})
    (ok (map-get? gamblers gambler))
  )
)

(define-read-only (get-gamblers)
  (print (map-get? gamblers u1))
)

;; below is trying to randomize the function

;; Get a SHA256 of number input from the users
(define-data-var test (hash160 10))

(define-private (get-digits (char (buff 1))) (get-digits char 0x1))

(define-private (winner)
  (print test)
)
