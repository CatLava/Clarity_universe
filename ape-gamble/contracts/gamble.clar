
;; gambling contract
;; This contract allows for two players to gamble
;; Each send 10 STX to the contract, one will win all STX and associated nft


;; constants
(define-constant ERR_INVALID_AMOUNT (err u99))
(define-constant ERR_TRANSFER (err u100))
(define-constant ERR_INVALID_PLAYER (err u101))
(define-constant ERR_NOT_WINNER (err u102))
(define-constant ERR_PLAYER_ACTIVE (err u103))
(define-constant ERR_NO_GAME_LEFT (err u104))
(define-constant ERR_SET_PLAYER1 (err u105))
(define-constant ERR_POT_INCOMPLETE (err u106))
(define-constant ERR_GAME_NOT_PLAYED (err u107))
(define-constant ERR_WINNER_NOT_PAID (err u108))

;; playing variables
;; amount to play with
(define-data-var gamble-amount uint u10)
;; pot variable for payout
(define-data-var pot uint u0)
;; lucky num is a randomization input modified by the players
(define-data-var lucky_num uint u1)

(define-data-var player1 (optional principal) none)
;; control variable for active game
(define-data-var player1-active uint u0)

;; player2 principal and control logic
(define-data-var player2 (optional principal) none)
;; control variable for active game
(define-data-var player2-active uint u0)

;; principal to send nft to
(define-data-var winner-mint (optional principal) none)
;; number of games to play
(define-data-var game-count uint u100)

;; control logic for claiming nft
(define-data-var claim-nft uint u0)


(define-public (gambler1 (amount uint) (num_fun uint))
  (begin
    (asserts! (is-eq amount (var-get gamble-amount)) ERR_INVALID_AMOUNT) ;; checks amount sent to contract
    (asserts! (is-eq (var-get player1-active) u0) ERR_PLAYER_ACTIVE) ;; prevents double play while player active
    (asserts! (> (var-get game-count) u0) ERR_NO_GAME_LEFT) ;; stops at game threshold
    (var-set player1-active u1)
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err u101)) ;; sending stx to contract
    (var-set pot (+ (var-get pot) amount))
    (var-set lucky_num (+ (var-get lucky_num) num_fun))
    (var-set player1 (some tx-sender))
    (ok (var-get player1))
  )
)

;; similar logic to player1
(define-public (gambler2 (amount uint) (num_fun uint))
  (begin
    (asserts! (is-eq amount (var-get gamble-amount))  ERR_INVALID_AMOUNT)
    (asserts! (is-eq (var-get player1-active) u1) ERR_SET_PLAYER1) ;; ensures player1 is set first before allowing player2
    (asserts! (is-eq (var-get player2-active) u0) ERR_PLAYER_ACTIVE)
    (var-set player2-active u1)
    (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err u101))
    (var-set pot (+ (var-get pot) amount))
    (var-set lucky_num (+ (var-get lucky_num) num_fun))
    (var-set player2 (some tx-sender))
    (ok (var-get player2))
  )
)

;; read only to check game status

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

(define-read-only (get-game-count)
  (var-get game-count)
)


;; This function adds a layer of randomization to the gambler1
;; some math functions, where at the end even or odd determines the winner
;; player1 wins if even, if odd player2 wins
(define-private (winner)
  (begin
    (var-set lucky_num (* (var-get lucky_num) u22))
    (var-set lucky_num (/ (var-get lucky_num) u7))
    (var-set lucky_num (mod (var-get lucky_num) u2))
    (is-eq (var-get lucky_num) u0)
  )
)

(define-public (get-winner)
  (begin
    ;; ensures pot is filled prior to allowing payout
    (asserts! (>= (var-get pot) (* (var-get gamble-amount) u2)) (err ERR_POT_INCOMPLETE))
    ;; allows winner to claim nft after winning
    (var-set claim-nft u1)
    (print (var-get lucky_num))
    ;; boolean of winner determines pot payout of winner
    (if (winner)
      (ok (as-contract (stx-transfer? (var-get pot) tx-sender (unwrap-panic (var-get player1)))))
      (ok (as-contract (stx-transfer? (var-get pot) tx-sender (unwrap-panic (var-get player2)))))
    )
  )
)

;; function to set minting principal
(define-private (set-mint-winner)
  ;; setting winner principal to receive nft
  (if (is-eq (var-get lucky_num) u0)
    (var-set winner-mint (var-get player1))
    (var-set winner-mint (var-get player2))
  )
)

;; This is calling an outside contract to mint the nft
;; Must also be set in the config.toml component
(define-public (winner-receive)
  (begin
    (set-mint-winner)
    (print (var-get winner-mint))
    ;; checks if winner is making the call
    (asserts! (is-eq (unwrap-panic (var-get winner-mint)) tx-sender) (err ERR_NOT_WINNER))
    ;; various logic checks if game is played properly
    (asserts! (> (var-get game-count) u1) (err ERR_NO_GAME_LEFT ))
    (asserts! (is-eq (var-get player1-active) u1) (err ERR_GAME_NOT_PLAYED))
    (asserts! (is-eq (var-get player2-active) u1) (err ERR_GAME_NOT_PLAYED))
    (asserts! (is-eq (var-get claim-nft) u1) (err ERR_WINNER_NOT_PAID))
    ;; reset values to play again
    (var-set player1-active u0)
    (var-set player2-active u0)
    (var-set lucky_num u1)
    (var-set claim-nft u0)
    (var-set pot u0)
    ;; count down of finite games to play
    (var-set game-count (- (var-get game-count) u1))
    ;; mint nft for the winner
    (ok (as-contract (contract-call? .winner-nft claim (unwrap-panic (var-get winner-mint)))))
  )
)
