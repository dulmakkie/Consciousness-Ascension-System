;; Ascension Trials Management Contract

(define-data-var trial-counter uint u0)

(define-map ascension-trials uint {
    name: (string-ascii 100),
    description: (string-utf8 500),
    difficulty: uint,
    participants: (list 100 principal),
    status: (string-ascii 20),
    start-time: uint,
    end-time: uint
})

(define-public (create-trial (name (string-ascii 100)) (description (string-utf8 500)) (difficulty uint) (start-time uint) (end-time uint))
    (let
        ((new-id (+ (var-get trial-counter) u1)))
        (map-set ascension-trials new-id {
            name: name,
            description: description,
            difficulty: difficulty,
            participants: (list),
            status: "upcoming",
            start-time: start-time,
            end-time: end-time
        })
        (var-set trial-counter new-id)
        (ok new-id)
    )
)

(define-public (join-trial (trial-id uint))
    (let
        ((trial (unwrap! (map-get? ascension-trials trial-id) (err u404))))
        (asserts! (< (len (get participants trial)) u100) (err u400))
        (ok (map-set ascension-trials trial-id
            (merge trial {
                participants: (unwrap! (as-max-len? (append (get participants trial) tx-sender) u100) (err u401))
            })))
    )
)

(define-public (update-trial-status (trial-id uint) (new-status (string-ascii 20)))
    (let
        ((trial (unwrap! (map-get? ascension-trials trial-id) (err u404))))
        (ok (map-set ascension-trials trial-id
            (merge trial { status: new-status })))
    )
)

(define-read-only (get-trial (trial-id uint))
    (map-get? ascension-trials trial-id)
)

(define-read-only (get-trial-count)
    (var-get trial-counter)
)

