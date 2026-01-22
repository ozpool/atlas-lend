# 🔐 Security Policy

AtlasLend takes protocol security very seriously.  
We appreciate the efforts of security researchers and community members
to responsibly disclose vulnerabilities.

---

## 📌 Supported Versions

Only the latest code in the `main` branch is considered actively maintained
and eligible for security updates.

Earlier commits, forks, or experimental branches are not supported.

---

## 🚨 Reporting a Vulnerability

⚠️ **Please do NOT open a public GitHub issue for security vulnerabilities.**

To report a potential security issue, disclose responsibly by contacting:

📧 **security@atlaslend.protocol**  
_(example placeholder email)_

When reporting, please include:
- A clear description of the vulnerability
- Steps to reproduce the issue
- Affected contracts, functions, or modules
- Potential impact (e.g., fund loss, DoS, privilege escalation)
- Proof-of-concept code (if available)
- Suggested remediation (optional but appreciated)

---

## ⏳ Disclosure Process

1. The AtlasLend maintainers will acknowledge receipt within **48 hours**
2. The issue will be reviewed and validated
3. A fix will be developed and tested
4. The reporter will be notified before public disclosure
5. Public disclosure will occur after mitigation or patch release

We kindly ask reporters to allow a reasonable remediation period
before sharing findings publicly.

---

## 🧩 Security Scope

### ✅ In Scope
- Smart contracts (`contracts/`)
- Core lending logic
- Liquidation mechanisms
- Interest rate calculations
- Access control & privilege boundaries
- Reentrancy, arithmetic, and state-consistency bugs

### ❌ Out of Scope
- Frontend or UI-related issues
- Test-only artifacts
- Gas optimizations without security impact
- Third-party service outages

---

## 🛡 Security Best Practices Followed

AtlasLend aims to follow industry best practices, including:
- Solidity compiler version pinning
- CEI (Checks-Effects-Interactions) pattern
- Reentrancy protection where applicable
- Explicit access control modifiers
- Extensive unit and integration testing
- Clear separation of protocol responsibilities

---

## ⚖️ Responsible Disclosure

We strongly encourage ethical and responsible disclosure.
Researchers acting in good faith will not be subject to legal action
for responsibly disclosed vulnerabilities.

---

## 🙏 Acknowledgements

We thank the security community for helping make DeFi safer for everyone.
gi