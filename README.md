## Contributing

All contributions must follow the repository’s issue and pull request templates.

Security-related reports must follow the guidelines outlined in `.github/SECURITY.md`.

---

## Mock Stablecoin (aUSD)

AtlasLend uses a mock ERC-20 stablecoin (`aUSD`) for development and testing purposes.

---

## Interest Rate Model

AtlasLend uses a utilization-based interest rate model.

The borrow APR increases as utilization rises in order to:
- Incentivize repayments  
- Protect protocol liquidity  
- Balance supply and demand  

Interest accrual is introduced in later phases.

---

### aUSD Characteristics

- ERC-20 compliant  
- Mintable only by the protocol owner  
- Used exclusively for protocol simulations  

⚠️ **Note:**  
This token is **not intended for production use** and does not represent a real stablecoin, currency, or value peg.
