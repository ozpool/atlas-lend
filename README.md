## Contributing

All contributions must follow the repository's issue and pull
request templates.

Security-related concerns should follow the guidelines outlined
in `.github/SECURITY.md`.
## Mock Stablecoin (aUSD)

AtlasLend uses a mock ERC20 stablecoin (`aUSD`) for development
and testing purposes.

### Characteristics
- ERC20 compliant
- Mintable only by the protocol owner
- Used exclusively for protocol simulations

## Health Factor
The Health Factor measures a user's liquidation risk.

HF ≥ 1   → Safe  
HF < 1   → Subject to liquidation

This calculation is independent of price oracles
and assumes 1:1 valuation in the base phase.

⚠️ **Note:**  
This token is **not** intended for production use and does not represent
a real stablecoin or value peg.
