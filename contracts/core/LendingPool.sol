// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ILendingPool.sol";

contract LendingPool is ILendingPool, ReentrancyGuard {
    /// @dev Loan-to-Value ratio (75%)
    uint256 public constant LTV = 75;
    uint256 public constant LTV_PRECISION = 100;

    /// @dev Liquidation threshold (85%)
    uint256 public constant LIQUIDATION_THRESHOLD = 85;
    uint256 public constant THRESHOLD_PRECISION = 100;

    /// @dev Liquidation bonus (10%)
    uint256 public constant LIQUIDATION_BONUS = 10;
    uint256 public constant LIQUIDATION_PRECISION = 100;

    /// @dev Close factor (max 50% of debt can be liquidated)
    uint256 public constant CLOSE_FACTOR = 50;

    /// @dev user => asset => deposited amount
    mapping(address => mapping(address => uint256)) internal balances;

    /// @dev user => asset => borrowed amount
    mapping(address => mapping(address => uint256)) internal debts;

    event Deposit(address indexed user, address indexed asset, uint256 amount);
    event Withdraw(address indexed user, address indexed asset, uint256 amount);

    event Borrow(address indexed user, address indexed asset, uint256 amount);
    event Repay(address indexed user, address indexed asset, uint256 amount);

    event Liquidation(
        address indexed liquidator,
        address indexed user,
        address asset,
        uint256 debtRepaid,
        uint256 collateralSeized
    );

    function repay(address asset, uint256 amount)
        external
        nonReentrant
    {
        uint256 repayAmount = amount;

        if (amount == type(uint256).max) {
            repayAmount = debts[msg.sender][asset];
        }

        repayAmount = _repay(msg.sender, asset, repayAmount);

        IERC20(asset).transferFrom(
            msg.sender,
            address(this),
            repayAmount
        );

        emit Repay(msg.sender, asset, repayAmount);
    }

    /**
     * @dev Reverts if user's health factor falls below 1
     */
    function _validateHealthFactor(
        address user,
        address asset
    ) internal view {
        uint256 debt = debts[user][asset];
        if (debt == 0) return;

        uint256 hf = getHealthFactor(user, asset);
        require(hf >= 1e18, "HF_TOO_LOW");
    }

    /**
     * @dev Returns health factor after a hypothetical withdrawal
     */
    function _healthFactorAfterWithdraw(
        address user,
        address asset,
        uint256 withdrawAmount
    ) internal view returns (uint256) {
        uint256 remainingCollateral =
            balances[user][asset] - withdrawAmount;

        return HealthFactor.calculate(
            remainingCollateral,
            debts[user][asset],
            LIQUIDATION_THRESHOLD
        );
    }

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
