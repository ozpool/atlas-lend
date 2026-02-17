// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ILendingPool.sol";
import "../libraries/HealthFactor.sol";

contract LendingPool is ILendingPool, ReentrancyGuard {
    using HealthFactor for uint256;

    /// @dev Loan-to-Value ratio (75%)
    uint256 public constant LTV = 75;
    uint256 public constant LTV_PRECISION = 100;

    /// @dev Liquidation threshold (85%)
    uint256 public constant LIQUIDATION_THRESHOLD = 85;
    uint256 public constant THRESHOLD_PRECISION = 100;

    /// @dev user => asset => deposited amount
    mapping(address => mapping(address => uint256)) internal balances;

    /// @dev user => asset => borrowed amount
    mapping(address => mapping(address => uint256)) internal debts;

    event Deposit(address indexed user, address indexed asset, uint256 amount);
    event Withdraw(address indexed user, address indexed asset, uint256 amount);

    event Borrow(address indexed user, address indexed asset, uint256 amount);
    event Repay(address indexed user, address indexed asset, uint256 amount);

    /**
     * @notice Returns user's health factor for a specific asset
     */
    function getHealthFactor(
        address user,
        address asset
    ) public view returns (uint256) {
        uint256 collateral = balances[user][asset];
        uint256 debt = debts[user][asset];

        return HealthFactor.calculate(
            collateral,
            debt,
            LIQUIDATION_THRESHOLD
        );
    }

    /**
     * @dev Returns true if user is eligible for liquidation
     * Health factor < 1.0 (1e18)
     */
    function _isLiquidatable(
        address user,
        address asset
    ) internal view returns (bool) {
        return getHealthFactor(user, asset) < 1e18;
    }

    /**
     * @notice Repay borrowed asset
     * @param asset The token address being repaid
     * @param amount Amount to repay or type(uint256).max to repay full debt
     */
    function repay(address asset, uint256 amount) external nonReentrant {
        uint256 repayAmount = amount;

        if (amount == type(uint256).max) {
            repayAmount = debts[msg.sender][asset];
        }

        repayAmount = _repay(msg.sender, asset, repayAmount);

        IERC20(asset).transferFrom(msg.sender, address(this), repayAmount);

        emit Repay(msg.sender, asset, repayAmount);
    }

    /**
     * @dev Internal repay logic.
     * Reduces user's debt for a given asset.
     */
    function _repay(
        address user,
        address asset,
        uint256 amount
    ) internal returns (uint256) {
        uint256 debt = debts[user][asset];
        require(debt > 0, "NO_OUTSTANDING_DEBT");

        uint256 repayAmount = amount > debt ? debt : amount;
        debts[user][asset] -= repayAmount;

        return repayAmount;
    }
}
