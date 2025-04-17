;; Inventory Registration Contract
;; Records details of available furnishings

(define-data-var last-item-id uint u0)

;; Define furniture item map
(define-map furniture-items
  { item-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    condition: (string-ascii 50),
    available: bool,
    price-per-day: uint
  }
)

;; Add a new furniture item
(define-public (add-furniture-item (name (string-ascii 100))
                                  (description (string-ascii 500))
                                  (condition (string-ascii 50))
                                  (price-per-day uint))
  (let ((new-id (+ (var-get last-item-id) u1)))
    (begin
      (var-set last-item-id new-id)
      (map-set furniture-items
        { item-id: new-id }
        {
          name: name,
          description: description,
          condition: condition,
          available: true,
          price-per-day: price-per-day
        }
      )
      (ok new-id)
    )
  )
)

;; Update furniture item details
(define-public (update-furniture-item (item-id uint)
                                     (name (string-ascii 100))
                                     (description (string-ascii 500))
                                     (condition (string-ascii 50))
                                     (price-per-day uint))
  (let ((item (map-get? furniture-items { item-id: item-id })))
    (if (is-some item)
      (begin
        (map-set furniture-items
          { item-id: item-id }
          {
            name: name,
            description: description,
            condition: condition,
            available: (get available (unwrap-panic item)),
            price-per-day: price-per-day
          }
        )
        (ok true)
      )
      (err u1) ;; Item not found
    )
  )
)

;; Update furniture availability
(define-public (set-furniture-availability (item-id uint) (available bool))
  (let ((item (map-get? furniture-items { item-id: item-id })))
    (if (is-some item)
      (begin
        (map-set furniture-items
          { item-id: item-id }
          {
            name: (get name (unwrap-panic item)),
            description: (get description (unwrap-panic item)),
            condition: (get condition (unwrap-panic item)),
            available: available,
            price-per-day: (get price-per-day (unwrap-panic item))
          }
        )
        (ok true)
      )
      (err u1) ;; Item not found
    )
  )
)

;; Get furniture item details
(define-read-only (get-furniture-item (item-id uint))
  (map-get? furniture-items { item-id: item-id })
)

;; Check if furniture item is available
(define-read-only (is-furniture-available (item-id uint))
  (let ((item (map-get? furniture-items { item-id: item-id })))
    (if (is-some item)
      (get available (unwrap-panic item))
      false
    )
  )
)
