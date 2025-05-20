;; Entity Verification Contract
;; Validates reporting organizations

(define-data-var admin principal tx-sender)

;; Map of verified entities
(define-map verified-entities principal bool)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-ALREADY-VERIFIED u101)
(define-constant ERR-NOT-VERIFIED u102)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Verify an entity
(define-public (verify-entity (entity principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? verified-entities entity)) (err ERR-ALREADY-VERIFIED))
    (ok (map-set verified-entities entity true))))

;; Revoke verification
(define-public (revoke-verification (entity principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (map-get? verified-entities entity)) (err ERR-NOT-VERIFIED))
    (ok (map-delete verified-entities entity))))

;; Check if an entity is verified
(define-read-only (is-verified (entity principal))
  (default-to false (map-get? verified-entities entity)))

;; Transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (var-set admin new-admin))))
