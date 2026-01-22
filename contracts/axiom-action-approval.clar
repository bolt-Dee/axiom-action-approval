;; title: axiom-action-approval
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;
;; ============================================================
;; Contract: axiom-action-approval.clar
;; Purpose : On-chain approval gate for AI agent actions
;; Network : Stacks
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------

(define-constant ERR-NOT-OWNER        (err u100))
(define-constant ERR-NOT-AGENT        (err u101))
(define-constant ERR-NOT-FOUND        (err u102))
(define-constant ERR-NOT-APPROVED     (err u103))
(define-constant ERR-ALREADY-USED     (err u104))

;; -------------------------
;; STATE
;; -------------------------

(define-data-var next-action-id uint u0)

;; -------------------------
;; STORAGE
;; -------------------------

(define-map actions
  { id: uint }
  {
    owner: principal,
    agent: principal,
    description: (string-ascii 128),
    approved: bool,
    executed: bool,
    created-at: uint
  }
)

;; -------------------------
;; REQUEST ACTION (AI AGENT)
;; -------------------------

(define-public (request-action
  (owner principal)
  (description (string-ascii 128))
)
  (begin
    (let ((id (+ (var-get next-action-id) u1)))
      (map-set actions
        { id: id }
        {
          owner: owner,
          agent: tx-sender,
          description: description,
          approved: false,
          executed: false,
          created-at: burn-block-height
        }
      )

      (var-set next-action-id id)
      (ok id)
    )
  )
)

;; -------------------------
;; APPROVE ACTION (OWNER)
;; -------------------------

(define-public (approve-action (id uint))
  (let ((action (map-get? actions { id: id })))
    (match action data
      (begin
        (asserts! (is-eq tx-sender (get owner data)) ERR-NOT-OWNER)
        (asserts! (not (get executed data)) ERR-ALREADY-USED)

        (map-set actions
          { id: id }
          (merge data { approved: true })
        )

        (ok true)
      )
      ERR-NOT-FOUND
    )
  )
)

;; -------------------------
;; REJECT ACTION (OWNER)
;; -------------------------

(define-public (reject-action (id uint))
  (let ((action (map-get? actions { id: id })))
    (match action data
      (begin
        (asserts! (is-eq tx-sender (get owner data)) ERR-NOT-OWNER)

        (map-set actions
          { id: id }
          (merge data { approved: false, executed: true })
        )

        (ok true)
      )
      ERR-NOT-FOUND
    )
  )
)

;; -------------------------
;; EXECUTE ACTION (AI AGENT)
;; -------------------------

(define-public (execute-action (id uint))
  (let ((action (map-get? actions { id: id })))
    (match action data
      (begin
        (asserts! (is-eq tx-sender (get agent data)) ERR-NOT-AGENT)
        (asserts! (get approved data) ERR-NOT-APPROVED)
        (asserts! (not (get executed data)) ERR-ALREADY-USED)

        ;; Mark action as executed
        (map-set actions
          { id: id }
          (merge data { executed: true })
        )

        ;; Actual execution happens off-chain
        (ok true)
      )
      ERR-NOT-FOUND
    )
  )
)

;; -------------------------
;; READ-ONLY
;; -------------------------

(define-read-only (get-action (id uint))
  (map-get? actions { id: id })
)

(define-read-only (action-count)
  (var-get next-action-id)
)

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

