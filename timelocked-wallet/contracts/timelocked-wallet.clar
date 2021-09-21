
;; timelocked-wallet
;; <add a description here>

;; constants
;;

;; data maps and vars
;;

;; private functions
;;

;; public functions
;;
;; defining a lock function to initiate
;; only can be locked by the Owner
(define-public (lock (new-beneficiary principal) (unlock-at uint) (amount uint))
  (begin
    ;; What do the asserts do?
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-none (var-get beneficiary)) err-already-locked)
    (asserts! (> unlock-at block-height) err-unlock-in-past)
    (asserts! (> amount u0) err-no-value)
    ;; what does the try do?
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set beneficiary (some new-beneficiary))
    (var-set unlock-height unlock-at)
    (ok true)
  )
)

;; bestow checks if sender is beneficiary
;; the principal is optional and needs to be wrapped in some
(define-public (bestow (new-beneficiary principal))
  (begin
    (asserts! (is-eq (some tx-sender) (var-get beneficiary)) err-beneficiary-only)
    (var-set beneficiary (some new-beneficiary))
    (ok true)
  )
)

;; now implement claim
(define-public (claim)
  (begin
    (asserts! (is-eq (some tx-sender) (var-get beneficiary)) err-beneficiary-only)
    (asserts! (>= block-height (var-get unlock-height)) err-unlock-height-not-reached)
    (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender (unwrap-panic (var-get beneficiary))))
  )
)

;; Owner
(define-constant contract-owner tx-sender)

;; Errors
;; error codes are meant for front end of application
(define-constant err-owner-only (err u100))
(define-constant err-already-locked (err u101))
(define-constant err-unlock-in-past (err u102))
(define-constant err-no-value (err u103))
(define-constant err-beneficiary-only (err u104))
(define-constant err-unlock-height-not-reached (err u105))

;; data
(define-data-var beneficiary (optional principal) none)
;; block at which to release funds
(define-data-var unlock-height uint u0)
