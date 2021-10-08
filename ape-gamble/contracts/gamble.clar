
;; gamble
;; This contract allows for three apes to gamble
;; Each send 1 STX to the contract, 1 of three will win all STX

;; constants
;;
(define-constant gamble-amount u10)
(define-constant ERR_INVALID_AMOUNT (err u99))
(define-constant ERR_TRANSFER (err u100))
(define-constant ERR_INVALID_PLAYER (err u101))

;; data maps and vars
;;
(define-data-var pot uint u0)
;; lucky num is a randomization input modified by the players
(define-data-var lucky_num uint u1)
(define-data-var player1 (optional principal) none)
(define-data-var player2 (optional principal) none)


;; This map is not used
;; unable to reference principal in contract calls, reference variables above
(define-map gamblers (string-ascii 34) {player: principal})

;; This was  a proof of concept funciton that
(define-public (play (amount uint))
  (begin
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err u101))
    (var-set pot (+ (var-get pot) amount))
    (ok (var-get pot))
  )
)
;; amount to gamble
;; what seat to take 1 or 2
(define-public (play2 (amount uint) (gambler uint) (num_fun uint))
  (begin
    (asserts! (is-eq amount gamble-amount) ERR_INVALID_AMOUNT)
    (asserts! (or (is-eq gambler u0) (is-eq gambler u1)) ERR_INVALID_PLAYER)
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err u101))
    (var-set pot (+ (var-get pot) amount))
    (if (is-eq gambler u0) (var-set player1  (some tx-sender)) (var-set player2  (some tx-sender)))
    (var-set lucky_num (+ (var-get lucky_num) num_fun))
    (ok (var-get player1))
  )
)

(define-read-only (get-gambler1)
    (print (var-get player1))
)

(define-read-only (get-gambler2)
  (print (var-get player2))
)

(define-read-only (get-lucky-num)
  (print (var-get lucky_num))
)



(define-read-only (get-pot)
  (var-get pot)
)


;; Below will take num_fun from both gamblers
;; add the numbers together, mixer function numfun*(22/7)
;; if odd player1 wins, if even player2 wins
;;(define-data-var test uint u0)

;; Verify winner function
;; implment from gamblers next step
;; This function needs to be private and called when determining the winner
(define-public (winner)
  (begin
    (var-set lucky_num (* (var-get lucky_num) u22))
    (var-set lucky_num (/ (var-get lucky_num) u7))
    (var-set lucky_num (mod (var-get lucky_num) u2))
    (ok (var-get lucky_num))
  )
)

(define-public (get-winner)
  (begin
    (print (var-get lucky_num))
    ;;(print (unwrap-panic (map-get?)))
    (if (is-eq (var-get lucky_num) u0)
      ;;(ok (var-get test))
      ;;(ok (var-get test))
      (as-contract (stx-transfer? (var-get pot) tx-sender (unwrap-panic (var-get player1))))
      (as-contract (stx-transfer? (var-get pot) tx-sender (unwrap-panic (var-get player2))))
    )
  )
)
