# AtlasLend — Decentralized Lending Protocol

AtlasLend is a **production-grade DeFi lending protocol** built with security, risk management, and governance at its core. It enables users to deposit assets as collateral, borrow against them, repay loans with interest, and liquidate undercollateralized positions.

This repository demonstrates **end‑to‑end DeFi engineering**: smart contract architecture, security hardening, full unit test coverage, deployment automation, and multi‑network configuration.

---

## ✨ Key Features

* **Overcollateralized Lending & Borrowing**
* **Interest Rate Model** with utilization-based curves
* **Health Factor–based Risk Engine**
* **Liquidation Engine** for unsafe positions
* **Protocol Admin Role** (risk parameters & upgrades)
* **Emergency Pause Mechanism**
* **Strict CEI & Reentrancy Protection**
* **Full Unit Tests + Solidity Coverage Reporting**
* **Network-aware Deployment Scripts**

---

## 🧱 High-Level Architecture

```
┌──────────────┐
│   Frontend   │ (future)
└──────┬───────┘
       │
┌──────▼────────┐
│  LendingPool  │  ← Core protocol logic
├───────────────┤
│ • Deposits    │
│ • Withdrawals │
│ • Borrowing   │
│ • Repayment   │
│ • Liquidation │
└──────┬────────┘
       │
┌──────▼───────────────────────┐
│ Supporting Components        │
│ • InterestRateModel          │
│ • HealthFactor Library       │
│ • Protocol Admin (RBAC)      │
│ • Pausable (Emergency Guard) │
└──────────────────────────────┘
```

---

## 📂 Repository Structure

```
contracts/
├─ core/
│  └─ LendingPool.sol
├─ libraries/
│  └─ HealthFactor.sol
├─ mocks/
│  └─ MockAUSD.sol
├─ interfaces/
│  └─ IInterestRateModel.sol

config/
├─ networks.ts
├─ accounts.ts
└─ protocol.ts

scripts/
├─ deploy.ts
└─ deploy/
   ├─ 00-deploy-rate-model.ts
   ├─ 01-deploy-token.ts
   └─ 02-deploy-lending-pool.ts

test/
├─ lending.depositWithdraw.test.ts
├─ lending.borrowRepay.test.ts
├─ lending.liquidation.test.ts
├─ lending.admin.test.ts
├─ lending.pause.test.ts
├─ interestRateModel.test.ts
├─ invariants.test.ts
└─ fixtures.ts
```

---

## 🔐 Security Design

AtlasLend follows **industry‑standard security practices**:

* **Checks‑Effects‑Interactions (CEI)** enforced everywhere
* **ReentrancyGuard** on all state‑changing entry points
* **Health Factor** determines borrowing & liquidation safety
* **Strict access control** using `AccessControl`
* **Emergency Pausable mechanism** for incident response

Security reviews are documented and verifiable.

---

## ⚙️ Core Concepts

### Health Factor

```
Health Factor = (Collateral × Liquidation Threshold) / Debt
```

* `HF ≥ 1` → Position is safe
* `HF < 1` → Position is liquidatable

---

### Liquidation

* Any user can liquidate an unhealthy position
* Liquidator repays debt and receives collateral + bonus
* Protocol guarantees atomic execution

---

### Protocol Admin

Admin powers include:

* Updating LTV
* Adjusting liquidation thresholds & bonuses
* Updating interest rate models
* Pausing / unpausing protocol

The role is **DAO‑ready** and designed to be transferred to governance.

---

## 🧪 Testing Strategy

AtlasLend uses **exhaustive unit testing**:

* All user flows tested
* All failure paths reverted
* Invariants enforced
* Admin & emergency paths covered

Run tests:

```bash
npx hardhat test
```

---

## 📊 Solidity Coverage

Coverage is measured using `solidity-coverage`.

Run locally:

```bash
npm run coverage
```

Targets:

* Statements ≥ 90%
* Functions ≥ 90%
* Branches ≥ 85%

---

## 🚀 Deployment

Deploy locally:

```bash
npx hardhat run scripts/deploy.ts
```

Deploy to Sepolia:

```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

Required environment variables:

```bash
SEPOLIA_RPC_URL=...
PRIVATE_KEY=...
```

---

## 🌐 Network Configuration

All network-specific values are centralized:

* `config/networks.ts` — RPC URLs & chain IDs
* `config/accounts.ts` — named roles
* `config/protocol.ts` — risk parameters

This ensures **safe, repeatable deployments** across environments.

---

## 🛣 Roadmap

Planned enhancements:

* Chainlink price oracles
* DAO governance (Timelock + Governor)
* Mainnet fork testing
* Frontend integration
* Audits & formal verification

---

## ⚠️ Disclaimer

This project is **for educational and portfolio purposes**.
It has not been audited and should not be used in production without a professional security audit.

---

