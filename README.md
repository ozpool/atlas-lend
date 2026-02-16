## Contributing

All contributions must follow the repository's issue and pull
request templates.

Security-related concerns should follow the guidelines outlined
in `.github/SECURITY.md`.
## Mock Stablecoin (aUSD)

AtlasLend uses a mock ERC20 stablecoin (`aUSD`) for development
and testing purposes.

## Repayment Logic

- Repayment is capped to outstanding debt
- Overpayment is safely handled
- `repay(type(uint256).max)` repays full debt
- Repaying without debt reverts

This logic is designed to support future interest accrual.

### Characteristics
- ERC20 compliant
- Mintable only by the protocol owner
- Used exclusively for protocol simulations

⚠️ **Note:**  
This token is **not** intended for production use and does not represent
a real stablecoin or value peg.
