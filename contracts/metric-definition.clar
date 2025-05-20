;; Metric Definition Contract
;; Standardizes sustainability measures

(define-data-var admin principal tx-sender)

;; Metric structure
(define-map metrics
  { metric-id: uint }
  {
    name: (string-ascii 64),
    description: (string-ascii 256),
    unit: (string-ascii 32),
    category: (string-ascii 64),
    created-by: principal,
    active: bool
  }
)

;; Track the next available metric ID
(define-data-var next-metric-id uint u1)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-METRIC-NOT-FOUND u101)
(define-constant ERR-METRIC-INACTIVE u102)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Create a new metric definition
(define-public (create-metric
    (name (string-ascii 64))
    (description (string-ascii 256))
    (unit (string-ascii 32))
    (category (string-ascii 64)))
  (let ((metric-id (var-get next-metric-id)))
    (begin
      (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
      (map-set metrics
        { metric-id: metric-id }
        {
          name: name,
          description: description,
          unit: unit,
          category: category,
          created-by: tx-sender,
          active: true
        }
      )
      (var-set next-metric-id (+ metric-id u1))
      (ok metric-id))))

;; Deactivate a metric
(define-public (deactivate-metric (metric-id uint))
  (let ((metric (map-get? metrics { metric-id: metric-id })))
    (begin
      (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-some metric) (err ERR-METRIC-NOT-FOUND))
      (map-set metrics
        { metric-id: metric-id }
        (merge (unwrap-panic metric) { active: false })
      )
      (ok true))))

;; Get metric details
(define-read-only (get-metric (metric-id uint))
  (map-get? metrics { metric-id: metric-id }))

;; Check if a metric is active
(define-read-only (is-metric-active (metric-id uint))
  (let ((metric (map-get? metrics { metric-id: metric-id })))
    (if (is-some metric)
      (get active (unwrap-panic metric))
      false)))

;; Transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (var-set admin new-admin))))
