;; Title: BitForge Gaming Protocol
;; Summary: A decentralized gaming ecosystem on Stacks Layer 2 with Bitcoin rewards
;; Description: BitForge enables players to mint gaming NFTs, create avatars, compete
;;              in virtual worlds, and earn Bitcoin rewards through skill-based gameplay.
;;              Built for the Bitcoin economy with full Layer 2 scalability.

;; ERROR CONSTANTS

(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-GAME-ASSET (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-TRANSFER-FAILED (err u4))
(define-constant ERR-LEADERBOARD-FULL (err u5))
(define-constant ERR-ALREADY-REGISTERED (err u6))
(define-constant ERR-INVALID-REWARD (err u7))
(define-constant ERR-INVALID-INPUT (err u8))
(define-constant ERR-INVALID-SCORE (err u9))
(define-constant ERR-INVALID-FEE (err u10))
(define-constant ERR-INVALID-ENTRIES (err u11))
(define-constant ERR-PLAYER-NOT-FOUND (err u12))
(define-constant ERR-INVALID-AVATAR (err u13))
(define-constant ERR-WORLD-NOT-FOUND (err u14))
(define-constant ERR-INVALID-NAME (err u15))
(define-constant ERR-INVALID-DESCRIPTION (err u16))
(define-constant ERR-INVALID-RARITY (err u17))
(define-constant ERR-INVALID-POWER-LEVEL (err u18))
(define-constant ERR-INVALID-ATTRIBUTES (err u19))
(define-constant ERR-INVALID-WORLD-ACCESS (err u20))
(define-constant ERR-INVALID-OWNER (err u21))
(define-constant ERR-MAX-LEVEL-REACHED (err u22))
(define-constant ERR-MAX-EXPERIENCE-REACHED (err u23))
(define-constant ERR-INVALID-LEVEL-UP (err u24))

;; GAME MECHANICS CONSTANTS

(define-constant MAX-LEVEL u100)
(define-constant MAX-EXPERIENCE-PER-LEVEL u1000)
(define-constant BASE-EXPERIENCE-REQUIRED u100)

;; PROTOCOL CONFIGURATION VARIABLES

(define-data-var protocol-fee uint u10)
(define-data-var max-leaderboard-entries uint u50)
(define-data-var total-prize-pool uint u0)
(define-data-var total-assets uint u0)
(define-data-var total-avatars uint u0)
(define-data-var total-worlds uint u0)

;; ACCESS CONTROL MAPS

(define-map protocol-admin-whitelist
  principal
  bool
)

;; NFT DEFINITIONS

(define-non-fungible-token bitforge-asset uint)
(define-non-fungible-token bitforge-avatar uint)

;; DATA STORAGE MAPS

;; Gaming Asset Metadata Storage
(define-map bitforge-asset-metadata
  { token-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    rarity: (string-ascii 20),
    power-level: uint,
    world-id: uint,
    attributes: (list 10 (string-ascii 20)),
    experience: uint,
    level: uint,
  }
)

;; Avatar Progression Storage
(define-map avatar-metadata
  { avatar-id: uint }
  {
    name: (string-ascii 50),
    level: uint,
    experience: uint,
    achievements: (list 20 (string-ascii 50)),
    equipped-assets: (list 5 uint),
    world-access: (list 10 uint),
  }
)

;; Virtual Worlds Registry
(define-map game-worlds
  { world-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    entry-requirement: uint,
    active-players: uint,
    total-rewards: uint,
  }
)

;; Player Leaderboard & Statistics
(define-map leaderboard
  { player: principal }
  {
    score: uint,
    games-played: uint,
    total-rewards: uint,
    avatar-id: uint,
    rank: uint,
    achievements: (list 20 (string-ascii 50)),
  }
)

;; VALIDATION FUNCTIONS

;; Validate asset/avatar names
(define-private (is-valid-name (name (string-ascii 50)))
  (and
    (>= (len name) u1)
    (<= (len name) u50)
    (not (is-eq name ""))
  )
)

;; Validate descriptions for assets/worlds
(define-private (is-valid-description (description (string-ascii 200)))
  (and
    (>= (len description) u1)
    (<= (len description) u200)
    (not (is-eq description ""))
  )
)

;; Validate asset rarity levels
(define-private (is-valid-rarity (rarity (string-ascii 20)))
  (or
    (is-eq rarity "common")
    (is-eq rarity "uncommon")
    (is-eq rarity "rare")
    (is-eq rarity "epic")
    (is-eq rarity "legendary")
  )
)

;; Validate power level range
(define-private (is-valid-power-level (power uint))
  (and (>= power u1) (<= power u1000))
)

;; Validate asset attributes
(define-private (is-valid-attributes (attributes (list 10 (string-ascii 20))))
  (and
    (>= (len attributes) u1)
    (<= (len attributes) u10)
  )
)

;; Validate world access permissions
(define-private (is-valid-world-access (worlds (list 10 uint)))
  (and
    (>= (len worlds) u1)
    (<= (len worlds) u10)
    (fold check-world-exists worlds true)
  )
)

;; Helper function to verify world existence
(define-private (check-world-exists
    (world-id uint)
    (valid bool)
  )
  (and valid (is-some (get-world-details world-id)))
)

;; UTILITY FUNCTIONS

;; Check if caller is protocol administrator
(define-read-only (is-protocol-admin (sender principal))
  (default-to false (map-get? protocol-admin-whitelist sender))
)

;; Validate principal address
(define-read-only (is-valid-principal (input principal))
  (and
    (not (is-eq input tx-sender))
    (not (is-eq input (as-contract tx-sender)))
  )
)

;; Enhanced principal security validation
(define-read-only (is-safe-principal (input principal))
  (and
    (is-valid-principal input)
    (or
      (is-protocol-admin input)
      (is-some (map-get? leaderboard { player: input }))
    )
  )
)

;; Retrieve world information
(define-read-only (get-world-details (world-id uint))
  (map-get? game-worlds { world-id: world-id })
)

;; Retrieve avatar information
(define-read-only (get-avatar-details (avatar-id uint))
  (map-get? avatar-metadata { avatar-id: avatar-id })
)

;; Get top performing players (simplified implementation)
(define-read-only (get-top-players)
  (let ((max-entries (var-get max-leaderboard-entries)))
    (list tx-sender)
    ;; Placeholder - full implementation would query and sort leaderboard
  )
)

;; EXPERIENCE & PROGRESSION SYSTEM

;; Calculate experience required for next level
(define-read-only (get-next-level-requirement (avatar-id uint))
  (match (get-avatar-details avatar-id)
    metadata (ok (calculate-level-up-experience (get level metadata)))
    ERR-INVALID-AVATAR
  )
)

;; Check if avatar can receive additional experience
(define-read-only (can-receive-experience
    (avatar-id uint)
    (experience-amount uint)
  )
  (match (get-avatar-details avatar-id)
    metadata (ok (and
      (< (get level metadata) MAX-LEVEL)
      (validate-experience-gain (get experience metadata) experience-amount
        (get level metadata)
      )
    ))
    ERR-INVALID-AVATAR
  )
)

;; PROTOCOL MANAGEMENT FUNCTIONS

;; Initialize BitForge protocol with configuration
(define-public (initialize-protocol
    (entry-fee uint)
    (max-entries uint)
  )
  (begin
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= entry-fee u1) (<= entry-fee u1000)) ERR-INVALID-FEE)
    (asserts! (and (>= max-entries u1) (<= max-entries u500)) ERR-INVALID-ENTRIES)
    (var-set protocol-fee entry-fee)
    (var-set max-leaderboard-entries max-entries)
    (ok true)
  )
)

;; GAMING ASSET MANAGEMENT

;; Mint new gaming asset NFT
(define-public (mint-bitforge-asset
    (name (string-ascii 50))
    (description (string-ascii 200))
    (rarity (string-ascii 20))
    (power-level uint)
    (world-id uint)
    (attributes (list 10 (string-ascii 20)))
  )
  (let ((token-id (+ (var-get total-assets) u1)))
    ;; Validation checks
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-description description) ERR-INVALID-DESCRIPTION)
    (asserts! (is-valid-rarity rarity) ERR-INVALID-RARITY)
    (asserts! (is-valid-power-level power-level) ERR-INVALID-POWER-LEVEL)
    (asserts! (is-some (get-world-details world-id)) ERR-WORLD-NOT-FOUND)
    (asserts! (is-valid-attributes attributes) ERR-INVALID-ATTRIBUTES)
    ;; Mint NFT and set metadata
    (try! (nft-mint? bitforge-asset token-id tx-sender))
    (map-set bitforge-asset-metadata { token-id: token-id } {
      name: name,
      description: description,
      rarity: rarity,
      power-level: power-level,
      world-id: world-id,
      attributes: attributes,
      experience: u0,
      level: u1,
    })
    (var-set total-assets token-id)
    (ok token-id)
  )
)

;; Transfer gaming asset to another player
(define-public (transfer-game-asset
    (token-id uint)
    (recipient principal)
  )
  (begin
    ;; Verify ownership and authorization
    (asserts!
      (is-eq tx-sender
        (unwrap! (nft-get-owner? bitforge-asset token-id) ERR-INVALID-GAME-ASSET)
      )
      ERR-NOT-AUTHORIZED
    )
    (asserts! (is-valid-principal recipient) ERR-INVALID-INPUT)
    ;; Execute transfer
    (nft-transfer? bitforge-asset token-id tx-sender recipient)
  )
)

;; AVATAR SYSTEM FUNCTIONS

;; Create new player avatar
(define-public (create-avatar
    (name (string-ascii 50))
    (world-access (list 10 uint))
  )
  (let ((avatar-id (+ (var-get total-avatars) u1)))
    ;; Validation checks
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-world-access world-access) ERR-INVALID-WORLD-ACCESS)
    (asserts! (is-none (map-get? leaderboard { player: tx-sender }))
      ERR-ALREADY-REGISTERED
    )
    ;; Create avatar NFT
    (try! (nft-mint? bitforge-avatar avatar-id tx-sender))
    ;; Initialize avatar metadata
    (map-set avatar-metadata { avatar-id: avatar-id } {
      name: name,
      level: u1,
      experience: u0,
      achievements: (list),
      equipped-assets: (list),
      world-access: world-access,
    })
    ;; Register player in leaderboard
    (map-set leaderboard { player: tx-sender } {
      score: u0,
      games-played: u0,
      total-rewards: u0,
      avatar-id: avatar-id,
      rank: u0,
      achievements: (list),
    })
    (var-set total-avatars avatar-id)
    (ok avatar-id)
  )
)

;; Update avatar experience and handle level progression
(define-public (update-avatar-experience
    (avatar-id uint)
    (experience-gained uint)
  )
  (let (
      (current-metadata (unwrap! (get-avatar-details avatar-id) ERR-INVALID-AVATAR))
      (avatar-owner (unwrap! (nft-get-owner? bitforge-avatar avatar-id) ERR-INVALID-AVATAR))
      (current-level (get level current-metadata))
      (current-experience (get experience current-metadata))
    )
    ;; Authorization and validation
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (<= avatar-id (var-get total-avatars)) ERR-INVALID-AVATAR)
    (asserts! (> experience-gained u0) ERR-INVALID-INPUT)
    (asserts! (< current-level MAX-LEVEL) ERR-MAX-LEVEL-REACHED)
    (asserts!
      (validate-experience-gain current-experience experience-gained
        current-level
      )
      ERR-MAX-EXPERIENCE-REACHED
    )
    ;; Calculate new experience and level
    (let (
        (new-experience (+ current-experience experience-gained))
        (should-level-up (can-level-up current-experience experience-gained current-level))
        (new-level (if should-level-up
          (+ current-level u1)
          current-level
        ))
      )
      (asserts! (or (not should-level-up) (<= new-level MAX-LEVEL))
        ERR-MAX-LEVEL-REACHED
      )
      ;; Update avatar metadata
      (map-set avatar-metadata { avatar-id: avatar-id }
        (merge current-metadata {
          experience: new-experience,
          level: new-level,
        })
      )
      (ok should-level-up)
    )
  )
)

;; VIRTUAL WORLD MANAGEMENT

;; Create new gaming world
(define-public (create-game-world
    (name (string-ascii 50))
    (description (string-ascii 200))
    (entry-requirement uint)
  )
  (let ((world-id (+ (var-get total-worlds) u1)))
    ;; Authorization and validation
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-description description) ERR-INVALID-DESCRIPTION)
    (asserts! (>= entry-requirement u0) ERR-INVALID-INPUT)
    ;; Create world entry
    (map-set game-worlds { world-id: world-id } {
      name: name,
      description: description,
      entry-requirement: entry-requirement,
      active-players: u0,
      total-rewards: u0,
    })
    (var-set total-worlds world-id)
    (ok world-id)
  )
)

;; LEADERBOARD & SCORING SYSTEM

;; Update player's game score
(define-public (update-player-score
    (player principal)
    (new-score uint)
  )
  (let ((current-stats (unwrap! (map-get? leaderboard { player: player }) ERR-PLAYER-NOT-FOUND)))
    ;; Authorization and validation
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-principal player) ERR-INVALID-INPUT)
    (asserts! (and (>= new-score u0) (<= new-score u10000)) ERR-INVALID-SCORE)
    ;; Update leaderboard entry
    (map-set leaderboard { player: player }
      (merge current-stats {
        score: new-score,
        games-played: (+ (get games-played current-stats) u1),
      })
    )
    (ok true)
  )
)

;; BITCOIN REWARD DISTRIBUTION SYSTEM

;; Distribute Bitcoin rewards to top players
(define-public (distribute-bitcoin-rewards)
  (let ((top-players (get-top-players)))
    (asserts! (is-protocol-admin tx-sender) ERR-NOT-AUTHORIZED)
    ;; Process reward distribution
    (try! (fold distribute-reward (filter is-valid-reward-candidate top-players)
      (ok true)
    ))
    (ok true)
  )
)

;; Validate if player qualifies for rewards
(define-private (is-valid-reward-candidate (player principal))
  (match (map-get? leaderboard { player: player })
    stats (and
      (> (get score stats) u0)
      (is-valid-principal player)
    )
    false
  )
)

;; Process individual reward distribution
(define-private (distribute-reward
    (player principal)
    (previous-result (response bool uint))
  )
  (match (map-get? leaderboard { player: player })
    player-stats (let ((reward-amount (calculate-reward (get score player-stats))))
      (if (and (is-ok previous-result) (> reward-amount u0))
        (begin
          (map-set leaderboard { player: player }
            (merge player-stats { total-rewards: (+ (get total-rewards player-stats) reward-amount) })
          )
          (ok true)
        )
        previous-result
      )
    )
    previous-result
  )
)

;; HELPER & CALCULATION FUNCTIONS

;; Calculate reward amount based on player score
(define-private (calculate-reward (score uint))
  (if (and (> score u100) (<= score u10000))
    (* score u10)
    u0
  )
)

;; Calculate experience required for level advancement
(define-private (calculate-level-up-experience (current-level uint))
  (* BASE-EXPERIENCE-REQUIRED current-level)
)

;; Validate experience gain within limits
(define-private (validate-experience-gain
    (current-experience uint)
    (gained-experience uint)
    (current-level uint)
  )
  (let (
      (max-allowed-gain (calculate-level-up-experience current-level))
      (new-total-experience (+ current-experience gained-experience))
    )
    (and
      (<= gained-experience max-allowed-gain)
      (<= new-total-experience (* MAX-EXPERIENCE-PER-LEVEL current-level))
    )
  )
)

;; Check if avatar can level up with gained experience
(define-private (can-level-up
    (current-experience uint)
    (gained-experience uint)
    (current-level uint)
  )
  (let (
      (new-total-experience (+ current-experience gained-experience))
      (required-experience (calculate-level-up-experience current-level))
    )
    (>= new-total-experience required-experience)
  )
)

;; PROTOCOL INITIALIZATION

;; Initialize deployer as protocol administrator
(map-set protocol-admin-whitelist tx-sender true)
