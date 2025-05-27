# BitForge Gaming Protocol

**BitForge** is a decentralized gaming protocol built on the **Stacks Layer 2**, enabling players to mint gaming NFTs, create avatars, explore virtual worlds, and earn **Bitcoin rewards** through competitive, skill-based gameplay.

## 🛠 Built For

* **Stacks Blockchain (Layer 2 for Bitcoin)**
* NFT-based gaming assets and avatars
* Competitive leaderboards with real Bitcoin rewards
* Scalable and secure game state management

---

## 🚀 Key Features

* 🎮 **NFT Minting**: Create unique gaming assets and avatars.
* 🌍 **Virtual Worlds**: Customizable game worlds with entry requirements and rewards.
* 📈 **Experience System**: Progression via experience points and levels.
* 🏆 **Leaderboards**: Track scores, achievements, and reward distribution.
* 🪙 **Bitcoin Rewards**: Distribute real Bitcoin based on leaderboard ranking.
* 🔐 **Access Control**: Protocol-admin gated functions for secure upgrades and management.

---

## 📐 Architecture Overview

Here's a conceptual breakdown of the protocol’s structure:

```
                    +-----------------------------+
                    |     Players / Game Clients  |
                    +-----------------------------+
                            |
                            v
              +-----------------------------+
              |      BitForge Smart Contract |
              +-----------------------------+
                            |
     +----------+-----------+-------------+-------------------+
     |          |           |             |                   |
     v          v           v             v                   v
[Asset NFT] [Avatar NFT] [World Registry] [Leaderboard Map] [Reward System]
     |          |           |             |                   |
     | Metadata |  Progress | Entry Rules | Stats & Scores    |
     +--------------------------------------------------------+
                            |
                    +---------------------+
                    |   Admin Whitelist   |
                    +---------------------+
```

### Core Components

| Module              | Description                                                       |
| ------------------- | ----------------------------------------------------------------- |
| **bitforge-asset**  | NFT representing game items with rarity, power, and attributes.   |
| **bitforge-avatar** | NFT representing players' avatars, trackable progress and access. |
| **game-worlds**     | Registry of virtual game worlds with reward and entry metadata.   |
| **leaderboard**     | Stores player statistics including scores and achievements.       |
| **reward system**   | Logic for distributing Bitcoin rewards based on ranking.          |
| **access control**  | Admin-only features for protocol configuration and asset minting. |

---

## 🧪 Smart Contract Highlights

* **Language**: Clarity (Stacks smart contract language)
* **Constants**: Error codes, experience thresholds, power levels, etc.
* **Validation**: Robust checks for names, rarity levels, attributes, and ownership.
* **Upgradeable Protocol**: Admin whitelist and initialization support.

---

## 📦 Deployment & Initialization

### Prerequisites

* [Stacks CLI](https://docs.stacks.co/docs/cli)
* Stacks testnet wallet or deployer address
* Clarity tools

### Deploy Contract

```bash
clarinet deploy
```

### Initialize Protocol

```clarity
(initialize-protocol u10 u50)
;; u10 = protocol entry fee
;; u50 = max leaderboard entries
```

### Grant Admin Rights

On deployment, the deployer is automatically added as a protocol admin:

```clarity
(map-set protocol-admin-whitelist tx-sender true)
```

---

## 📄 Sample Usage

### Minting a Game Asset

```clarity
(mint-bitforge-asset "Sword of Fire" "Epic sword" "epic" u250 u1 (list "fire" "sharp"))
```

### Creating an Avatar

```clarity
(create-avatar "PlayerOne" (list u1 u2))
```

### Updating Experience

```clarity
(update-avatar-experience u1 u150)
```

### Distributing Rewards

```clarity
(distribute-bitcoin-rewards)
```

---

## ⚠️ Error Codes

| Code  | Meaning                   |
| ----- | ------------------------- |
| `u1`  | Not authorized            |
| `u3`  | Insufficient funds        |
| `u5`  | Leaderboard full          |
| `u7`  | Invalid reward            |
| `u13` | Invalid avatar            |
| `u22` | Max level reached         |
| ...   | See full contract for all |

---

## Contributions

* **Contributions**: PRs and feature requests welcome!
