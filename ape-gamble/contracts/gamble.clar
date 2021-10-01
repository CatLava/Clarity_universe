
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

(define-map gamblers uint {player: principal, bet: uint, number: uint})


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
(define-public (play2 (amount uint) (gambler uint) (num_fun uint))
  (begin
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err ERR_TRANSFER))
    (map-set gamblers gambler {player: tx-sender, bet: amount, number: num_fun})
    (ok (map-get? gamblers gambler))
  )
)

(define-read-only (get-gamblers)
  (begin
    (print (map-get? gamblers u1))
    (print (map-get? gamblers u2))
  )
)

;; Below will take num_fun from both gamblers
;; add the numbers together, mixer function numfun*(22/7)
;; if odd player1 wins, if even player2 wins
(define-data-var test uint u101)

(define-private (winner)
  (begin
    (var-set test (* (var-get test) u22))
    (var-set test (/ (var-get test) u7))
    (var-set test (mod (var-get test) u2))
    (ok (var-get test))
  )
)

(define-public (get-winner)
  (begin
    (print (var-get test))
    (if (is-eq (var-get test) u0)
      (var-get test)
      (var-get test)
      ;;(stx-transfer? (var-get pot) (as-contract tx-sender) (as-contract tx-sender))
      ;;(stx-transfer? (var-get pot) (as-contract tx-sender) (as-contract tx-sender))
    )
  )
)
