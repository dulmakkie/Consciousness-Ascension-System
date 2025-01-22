;; Consciousness Milestone Tracking Contract

(define-data-var milestone-counter uint u0)

(define-map consciousness-milestones uint {
    achiever: principal,
    level: uint,
    description: (string-utf8 500),
    timestamp: uint,
    verified: bool
})

(define-public (record-milestone (level uint) (description (string-utf8 500)))
    (let
        ((new-id (+ (var-get milestone-counter) u1)))
        (map-set consciousness-milestones new-id {
            achiever: tx-sender,
            level: level,
            description: description,
            timestamp: block-height,
            verified: false
        })
        (var-set milestone-counter new-id)
        (ok new-id)
    )
)

(define-public (verify-milestone (milestone-id uint))
    (let
        ((milestone (unwrap! (map-get? consciousness-milestones milestone-id) (err u404))))
        (asserts! (is-eq tx-sender (get achiever milestone)) (err u403))
        (ok (map-set consciousness-milestones milestone-id
            (merge milestone { verified: true })))
    )
)

(define-read-only (get-milestone (milestone-id uint))
    (map-get? consciousness-milestones milestone-id)
)

(define-read-only (get-milestone-count)
    (var-get milestone-counter)
)

