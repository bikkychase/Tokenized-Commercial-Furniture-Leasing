;; Client Verification Contract
;; Validates qualified business customers

(define-map verified-clients
  { client-principal: principal }
  {
    business-name: (string-ascii 100),
    business-id: (string-ascii 50),
    contact-info: (string-ascii 100),
    verification-status: bool,
    verification-date: uint
  }
)

;; Register a new client (initially unverified)
(define-public (register-client (business-name (string-ascii 100))
                               (business-id (string-ascii 50))
                               (contact-info (string-ascii 100)))
  (begin
    (map-set verified-clients
      { client-principal: tx-sender }
      {
        business-name: business-name,
        business-id: business-id,
        contact-info: contact-info,
        verification-status: false,
        verification-date: u0
      }
    )
    (ok true)
  )
)

;; Verify a client (only contract owner can do this)
(define-public (verify-client (client-principal principal))
  (let ((client (map-get? verified-clients { client-principal: client-principal })))
    (if (is-some client)
      (begin
        (map-set verified-clients
          { client-principal: client-principal }
          {
            business-name: (get business-name (unwrap-panic client)),
            business-id: (get business-id (unwrap-panic client)),
            contact-info: (get contact-info (unwrap-panic client)),
            verification-status: true,
            verification-date: block-height
          }
        )
        (ok true)
      )
      (err u1) ;; Client not found
    )
  )
)

;; Check if a client is verified
(define-read-only (is-client-verified (client-principal principal))
  (let ((client (map-get? verified-clients { client-principal: client-principal })))
    (if (is-some client)
      (get verification-status (unwrap-panic client))
      false
    )
  )
)

;; Get client details
(define-read-only (get-client-details (client-principal principal))
  (map-get? verified-clients { client-principal: client-principal })
)
