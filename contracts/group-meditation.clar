;; Group Meditation Event Coordination Contract

(define-data-var event-counter uint u0)

(define-map meditation-events uint {
    name: (string-ascii 100),
    description: (string-utf8 500),
    organizer: principal,
    participants: (list 1000 principal),
    start-time: uint,
    duration: uint,
    status: (string-ascii 20)
})

(define-public (create-meditation-event (name (string-ascii 100)) (description (string-utf8 500)) (start-time uint) (duration uint))
    (let
        ((new-id (+ (var-get event-counter) u1)))
        (map-set meditation-events new-id {
            name: name,
            description: description,
            organizer: tx-sender,
            participants: (list tx-sender),
            start-time: start-time,
            duration: duration,
            status: "scheduled"
        })
        (var-set event-counter new-id)
        (ok new-id)
    )
)

(define-public (join-meditation-event (event-id uint))
    (let
        ((event (unwrap! (map-get? meditation-events event-id) (err u404))))
        (asserts! (< (len (get participants event)) u1000) (err u400))
        (ok (map-set meditation-events event-id
            (merge event {
                participants: (unwrap! (as-max-len? (append (get participants event) tx-sender) u1000) (err u401))
            })))
    )
)

(define-public (update-event-status (event-id uint) (new-status (string-ascii 20)))
    (let
        ((event (unwrap! (map-get? meditation-events event-id) (err u404))))
        (asserts! (is-eq tx-sender (get organizer event)) (err u403))
        (ok (map-set meditation-events event-id
            (merge event { status: new-status })))
    )
)

(define-read-only (get-meditation-event (event-id uint))
    (map-get? meditation-events event-id)
)

(define-read-only (get-event-count)
    (var-get event-counter)
)

