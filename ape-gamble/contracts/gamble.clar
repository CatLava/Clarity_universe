
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
(define-data-var lucky_num uint u1)
(define-data-var player1 (optional principal) none)
(define-data-var player2 (optional principal) none)

(define-map gamblers (string-ascii 34) {player: principal})



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
;; what seat to take 1 or 2
(define-public (play2 (amount uint) (gambler uint) (num_fun uint))
  (begin
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err ERR_TRANSFER))
    (var-set pot (+ (var-get pot) amount))
    (var-set player1  (some tx-sender))
    (var-set lucky_num (+ (var-get lucky_num) amount))
    (ok (var-get player1))
  )
)

(define-read-only (get-gambler1)
    (print (var-get player1))
)

(define-read-only (get-gambler2)
  (print (var-get player2))
)



;; Below will take num_fun from both gamblers
;; add the numbers together, mixer function numfun*(22/7)
;; if odd player1 wins, if even player2 wins
(define-data-var test uint u0)

;; Verify winner function
;; implment from gamblers next step
(define-public (winner)
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
    ;;(print (unwrap-panic (map-get?)))
    (if (is-eq (var-get test) u0)
      ;;(ok (var-get test))
      ;;(ok (var-get test))
      (as-contract (stx-transfer? (var-get pot) tx-sender (unwrap-panic (var-get player1))))
      (as-contract (stx-transfer? (var-get pot) tx-sender (unwrap-panic (var-get player1))))
    )
  )
)
