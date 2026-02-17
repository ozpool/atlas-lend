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

## Liquidation Engine

When a user's Health Factor drops below 1:
- Anyone can liquidate their position
- Liquidator repays debt
- Collateral is seized with a bonus

This mechanism ensures protocol solvency.

⚠️ **Note:**  
This token is **not** intended for production use and does not represent
a real stablecoin or value peg.
