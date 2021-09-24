
;; create-nft
;; this is using SIP009 creating an nft
;; <add a description here>
;; Ned to implement the associated Contract
(impl-trait .sip009-nft-trait.sip009-nft-trait)

;; Cant be used in clarinet - reference for mainnet
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)


;; constants
;; define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

(define-non-fungible-token test-token uint)

;; This increments
(define-data-var last-token-id uint u0)

;; Use variable to track last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok none)
)

;; If this is related to a domain, need to convert
;;(concat "https://domain.tld/metadata/" (to-ascii token-id))

;; get-owner function
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? test-token token-id))
)

;; transfer
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (nft-transfer? test-token token-id sender recipient)
  )
)

;; minting said token
(define-public (mint (recipient principal))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? test-token token-id recipient))
    (var-set last-token-id token-id)
    (ok token-id)
  )
)
