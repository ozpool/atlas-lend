## Reentrancy & CEI Review

Reviewed functions:
- deposit
- withdraw
- borrow
- repay
- liquidate

Standards applied:
- Checks → Effects → Interactions
- No external calls before state updates
- nonReentrant on all user-entry functions

