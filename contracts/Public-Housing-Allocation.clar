(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_EXISTS (err u102))
(define-constant ERR_INVALID_INPUT (err u103))
(define-constant ERR_UNIT_OCCUPIED (err u104))
(define-constant ERR_INSUFFICIENT_ELIGIBILITY (err u105))
(define-constant ERR_ALREADY_ALLOCATED (err u106))
(define-constant ERR_NOT_ELIGIBLE (err u107))
(define-constant ERR_APPEAL_COOLDOWN (err u108))
(define-constant ERR_ALREADY_APPEALED (err u109))
(define-constant ERR_CANNOT_APPEAL (err u110))

(define-data-var contract-owner principal tx-sender)
(define-map role-membership
    {
        role: (buff 32),
        account: principal,
    }
    { active: bool }
)
(define-map role-counts
    { role: (buff 32) }
    { count: uint }
)

(define-data-var next-unit-id uint u1)
(define-data-var next-application-id uint u1)
(define-data-var allocation-open bool true)

(define-map housing-units
    uint
    {
        address: (string-ascii 200),
        bedrooms: uint,
        monthly-rent: uint,
        is-occupied: bool,
        tenant: (optional principal),
        created-at: uint,
    }
)

(define-map applications
    uint
    {
        applicant: principal,
        household-size: uint,
        monthly-income: uint,
        priority-score: uint,
        status: (string-ascii 20),
        applied-at: uint,
        allocated-unit: (optional uint),
    }
)

(define-map applicant-to-application
    principal
    uint
)

(define-map waitlist-queue
    uint
    {
        application-id: uint,
        priority-score: uint,
        position: uint,
    }
)

(define-data-var waitlist-length uint u0)

(define-map application-appeals
    uint
    {
        appeal-reason: (string-ascii 500),
        appealed-at: uint,
        appeal-status: (string-ascii 20),
        reviewed-at: (optional uint),
    }
)

(define-data-var appeal-cooldown-blocks uint u144)

(define-map eligibility-criteria
    (string-ascii 50)
    uint
)

(define-read-only (get-contract-owner)
    CONTRACT_OWNER
)

(define-read-only (get-owner)
    (var-get contract-owner)
)

(define-read-only (get-role-count (role (buff 32)))
    (let (
            (entry (map-get? role-counts { role: role }))
            (value (default-to { count: u0 } entry))
            (count (get count value))
        )
        count
    )
)

(define-public (has-role
        (role (buff 32))
        (account principal)
    )
    (let (
            (entry (map-get? role-membership {
                role: role,
                account: account,
            }))
            (value (default-to { active: false } entry))
            (flag (get active value))
        )
        (ok flag)
    )
)

(define-public (transfer-ownership (new-owner principal))
    (if (is-eq tx-sender (var-get contract-owner))
        (begin
            (var-set contract-owner new-owner)
            (ok true)
        )
        (err u100)
    )
)

(define-public (grant-role
        (role (buff 32))
        (account principal)
    )
    (if (is-eq tx-sender (var-get contract-owner))
        (let (
                (current-opt (map-get? role-membership {
                    role: role,
                    account: account,
                }))
                (current (default-to { active: false } current-opt))
                (is-active (get active current))
                (count-opt (map-get? role-counts { role: role }))
                (count-tuple (default-to { count: u0 } count-opt))
                (count-val (get count count-tuple))
            )
            (if is-active
                (ok false)
                (begin
                    (map-set role-membership {
                        role: role,
                        account: account,
                    } { active: true }
                    )
                    (map-set role-counts { role: role } { count: (+ count-val u1) })
                    (ok true)
                )
            )
        )
        (err u100)
    )
)

(define-public (revoke-role
        (role (buff 32))
        (account principal)
    )
    (if (is-eq tx-sender (var-get contract-owner))
        (let (
                (current-opt (map-get? role-membership {
                    role: role,
                    account: account,
                }))
                (current (default-to { active: false } current-opt))
                (is-active (get active current))
                (count-opt (map-get? role-counts { role: role }))
                (count-tuple (default-to { count: u0 } count-opt))
                (count-val (get count count-tuple))
                (new-count (if (> count-val u0)
                    (- count-val u1)
                    u0
                ))
            )
            (if is-active
                (begin
                    (map-set role-membership {
                        role: role,
                        account: account,
                    } { active: false }
                    )
                    (map-set role-counts { role: role } { count: new-count })
                    (ok true)
                )
                (ok false)
            )
        )
        (err u100)
    )
)

(define-public (renounce-role (role (buff 32)))
    (let (
            (account tx-sender)
            (current-opt (map-get? role-membership {
                role: role,
                account: account,
            }))
            (current (default-to { active: false } current-opt))
            (is-active (get active current))
            (count-opt (map-get? role-counts { role: role }))
            (count-tuple (default-to { count: u0 } count-opt))
            (count-val (get count count-tuple))
            (new-count (if (> count-val u0)
                (- count-val u1)
                u0
            ))
        )
        (if is-active
            (begin
                (map-set role-membership {
                    role: role,
                    account: account,
                } { active: false }
                )
                (map-set role-counts { role: role } { count: new-count })
                (ok true)
            )
            (ok false)
        )
    )
)

(define-read-only (is-allocation-open)
    (var-get allocation-open)
)

(define-read-only (get-housing-unit (unit-id uint))
    (map-get? housing-units unit-id)
)

(define-read-only (get-application (app-id uint))
    (map-get? applications app-id)
)

(define-read-only (get-applicant-application (applicant principal))
    (match (map-get? applicant-to-application applicant)
        app-id (map-get? applications app-id)
        none
    )
)

(define-read-only (get-waitlist-position (app-id uint))
    (map-get? waitlist-queue app-id)
)

(define-read-only (get-eligibility-criteria (criteria-name (string-ascii 50)))
    (map-get? eligibility-criteria criteria-name)
)

(define-read-only (get-appeal (app-id uint))
    (map-get? application-appeals app-id)
)

(define-read-only (can-appeal (app-id uint))
    (match (map-get? applications app-id)
        app-data (let (
                (is-rejected (is-eq (get status app-data) "rejected"))
                (appeal-exists (is-some (map-get? application-appeals app-id)))
                (cooldown (var-get appeal-cooldown-blocks))
                (current-height stacks-block-height)
                (applied-height (get applied-at app-data))
                (blocks-passed (- current-height applied-height))
            )
            (and
                is-rejected
                (not appeal-exists)
                (>= blocks-passed cooldown)
            )
        )
        false
    )
)

(define-read-only (calculate-priority-score
        (household-size uint)
        (monthly-income uint)
    )
    (let (
            (base-score u100)
            (income-multiplier (if (<= monthly-income u30000)
                u50
                (if (<= monthly-income u50000)
                    u30
                    u10
                )
            ))
            (family-bonus (if (> household-size u1)
                (* (- household-size u1) u20)
                u0
            ))
        )
        (+ base-score income-multiplier family-bonus)
    )
)

(define-read-only (check-eligibility
        (household-size uint)
        (monthly-income uint)
    )
    (let (
            (max-income (default-to u60000 (map-get? eligibility-criteria "max-income")))
            (min-household (default-to u1 (map-get? eligibility-criteria "min-household")))
        )
        (and
            (<= monthly-income max-income)
            (>= household-size min-household)
        )
    )
)

(define-public (set-allocation-status (open bool))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (var-set allocation-open open)
        (ok true)
    )
)

(define-public (add-housing-unit
        (address (string-ascii 200))
        (bedrooms uint)
        (monthly-rent uint)
    )
    (let ((unit-id (var-get next-unit-id)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> bedrooms u0) ERR_INVALID_INPUT)
        (asserts! (> monthly-rent u0) ERR_INVALID_INPUT)

        (map-set housing-units unit-id {
            address: address,
            bedrooms: bedrooms,
            monthly-rent: monthly-rent,
            is-occupied: false,
            tenant: none,
            created-at: stacks-block-height,
        })
        (var-set next-unit-id (+ unit-id u1))
        (ok unit-id)
    )
)

(define-public (submit-application
        (household-size uint)
        (monthly-income uint)
    )
    (let (
            (app-id (var-get next-application-id))
            (priority (calculate-priority-score household-size monthly-income))
        )
        (asserts! (var-get allocation-open) ERR_NOT_ELIGIBLE)
        (asserts! (is-none (map-get? applicant-to-application tx-sender))
            ERR_ALREADY_EXISTS
        )
        (asserts! (check-eligibility household-size monthly-income)
            ERR_NOT_ELIGIBLE
        )
        (asserts! (> household-size u0) ERR_INVALID_INPUT)

        (map-set applications app-id {
            applicant: tx-sender,
            household-size: household-size,
            monthly-income: monthly-income,
            priority-score: priority,
            status: "pending",
            applied-at: stacks-block-height,
            allocated-unit: none,
        })

        (map-set applicant-to-application tx-sender app-id)
        (add-to-waitlist app-id priority)
        (var-set next-application-id (+ app-id u1))
        (ok app-id)
    )
)

(define-private (add-to-waitlist
        (app-id uint)
        (priority uint)
    )
    (let ((current-length (var-get waitlist-length)))
        (map-set waitlist-queue app-id {
            application-id: app-id,
            priority-score: priority,
            position: (+ current-length u1),
        })
        (var-set waitlist-length (+ current-length u1))
    )
)

(define-public (allocate-unit
        (unit-id uint)
        (app-id uint)
    )
    (let (
            (unit-data (unwrap! (map-get? housing-units unit-id) ERR_NOT_FOUND))
            (app-data (unwrap! (map-get? applications app-id) ERR_NOT_FOUND))
        )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (get is-occupied unit-data)) ERR_UNIT_OCCUPIED)
        (asserts! (is-eq (get status app-data) "pending") ERR_ALREADY_ALLOCATED)

        (map-set housing-units unit-id
            (merge unit-data {
                is-occupied: true,
                tenant: (some (get applicant app-data)),
            })
        )

        (map-set applications app-id
            (merge app-data {
                status: "allocated",
                allocated-unit: (some unit-id),
            })
        )

        (remove-from-waitlist app-id)
        (ok true)
    )
)

(define-private (remove-from-waitlist (app-id uint))
    (match (map-get? waitlist-queue app-id)
        waitlist-entry (begin
            (map-delete waitlist-queue app-id)
            (var-set waitlist-length (- (var-get waitlist-length) u1))
        )
        false
    )
)

(define-public (reject-application
        (app-id uint)
        (reason (string-ascii 100))
    )
    (let ((app-data (unwrap! (map-get? applications app-id) ERR_NOT_FOUND)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status app-data) "pending") ERR_INVALID_INPUT)

        (map-set applications app-id (merge app-data { status: "rejected" }))

        (remove-from-waitlist app-id)
        (ok true)
    )
)

(define-public (vacate-unit (unit-id uint))
    (let (
            (unit-data (unwrap! (map-get? housing-units unit-id) ERR_NOT_FOUND))
            (tenant (unwrap! (get tenant unit-data) ERR_NOT_FOUND))
        )
        (asserts!
            (or
                (is-eq tx-sender CONTRACT_OWNER)
                (is-eq tx-sender tenant)
            )
            ERR_UNAUTHORIZED
        )
        (asserts! (get is-occupied unit-data) ERR_INVALID_INPUT)

        (map-set housing-units unit-id
            (merge unit-data {
                is-occupied: false,
                tenant: none,
            })
        )

        (match (map-get? applicant-to-application tenant)
            app-id (match (map-get? applications app-id)
                app-data (map-set applications app-id
                    (merge app-data {
                        status: "completed",
                        allocated-unit: none,
                    })
                )
                false
            )
            false
        )

        (ok true)
    )
)

(define-public (update-eligibility-criteria
        (criteria-name (string-ascii 50))
        (value uint)
    )
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (map-set eligibility-criteria criteria-name value)
        (ok true)
    )
)

(define-public (update-unit-rent
        (unit-id uint)
        (new-rent uint)
    )
    (let ((unit-data (unwrap! (map-get? housing-units unit-id) ERR_NOT_FOUND)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-rent u0) ERR_INVALID_INPUT)

        (map-set housing-units unit-id
            (merge unit-data { monthly-rent: new-rent })
        )
        (ok true)
    )
)

(define-read-only (get-unit-count)
    (- (var-get next-unit-id) u1)
)

(define-read-only (get-application-count)
    (- (var-get next-application-id) u1)
)

(define-read-only (is-unit-available (unit-id uint))
    (match (map-get? housing-units unit-id)
        unit-data (not (get is-occupied unit-data))
        false
    )
)

(define-read-only (is-application-pending (app-id uint))
    (match (map-get? applications app-id)
        app-data (is-eq (get status app-data) "pending")
        false
    )
)

(define-public (withdraw-application)
    (match (map-get? applicant-to-application tx-sender)
        app-id (match (map-get? applications app-id)
            app-data (if (is-eq (get status app-data) "pending")
                (begin
                    (map-set applications app-id
                        (merge app-data { status: "withdrawn" })
                    )
                    (remove-from-waitlist app-id)
                    (map-delete applicant-to-application tx-sender)
                    (ok true)
                )
                ERR_INVALID_INPUT
            )
            ERR_NOT_FOUND
        )
        ERR_NOT_FOUND
    )
)

(define-public (submit-appeal
        (app-id uint)
        (appeal-reason (string-ascii 500))
    )
    (let (
            (app-data (unwrap! (map-get? applications app-id) ERR_NOT_FOUND))
            (applicant (get applicant app-data))
            (status (get status app-data))
            (applied-at (get applied-at app-data))
            (cooldown (var-get appeal-cooldown-blocks))
            (current-height stacks-block-height)
            (blocks-passed (- current-height applied-at))
        )
        (asserts! (is-eq tx-sender applicant) ERR_UNAUTHORIZED)
        (asserts! (is-eq status "rejected") ERR_CANNOT_APPEAL)
        (asserts! (>= blocks-passed cooldown) ERR_APPEAL_COOLDOWN)
        (asserts! (is-none (map-get? application-appeals app-id))
            ERR_ALREADY_APPEALED
        )
        (asserts! (> (len appeal-reason) u0) ERR_INVALID_INPUT)

        (map-set application-appeals app-id {
            appeal-reason: appeal-reason,
            appealed-at: current-height,
            appeal-status: "pending",
            reviewed-at: none,
        })
        (ok true)
    )
)

(define-public (review-appeal
        (app-id uint)
        (approved bool)
    )
    (let (
            (app-data (unwrap! (map-get? applications app-id) ERR_NOT_FOUND))
            (appeal-data (unwrap! (map-get? application-appeals app-id) ERR_NOT_FOUND))
            (current-height stacks-block-height)
        )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get appeal-status appeal-data) "pending")
            ERR_INVALID_INPUT
        )

        (if approved
            (begin
                (map-set applications app-id
                    (merge app-data { status: "pending" })
                )
                (add-to-waitlist app-id (get priority-score app-data))
                (map-set application-appeals app-id
                    (merge appeal-data {
                        appeal-status: "approved",
                        reviewed-at: (some current-height),
                    })
                )
                (ok true)
            )
            (begin
                (map-set application-appeals app-id
                    (merge appeal-data {
                        appeal-status: "denied",
                        reviewed-at: (some current-height),
                    })
                )
                (ok true)
            )
        )
    )
)

(define-public (update-appeal-cooldown (blocks uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> blocks u0) ERR_INVALID_INPUT)
        (var-set appeal-cooldown-blocks blocks)
        (ok true)
    )
)

(map-set eligibility-criteria "max-income" u60000)
(map-set eligibility-criteria "min-household" u1)
