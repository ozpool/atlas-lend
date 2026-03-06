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

    /// @dev Liquidation bonus (5%)
    uint256 public constant LIQUIDATION_BONUS = 105;
    uint256 public constant BONUS_PRECISION = 100;

    /// @dev Total protocol accounting
    uint256 public totalDeposits;
    uint256 public totalBorrows;

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
        address indexed asset,
        uint256 repaidAmount,
        uint256 collateralSeized
    );

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
     */
    function _isLiquidatable(
        address user,
        address asset
    ) internal view returns (bool) {
        return getHealthFactor(user, asset) < 1e18;
    }

    /**
     * @notice Liquidate an unhealthy position
     */
    function liquidate(
        address user,
        address asset,
        uint256 repayAmount
    ) external nonReentrant {
        require(_isLiquidatable(user, asset), "NOT_LIQUIDATABLE");
        require(repayAmount > 0, "INVALID_AMOUNT");

        uint256 userDebt = debts[user][asset];
        require(userDebt > 0, "NO_DEBT");

        uint256 actualRepay =
            repayAmount > userDebt ? userDebt : repayAmount;

        // Liquidator repays user's debt
        IERC20(asset).transferFrom(
            msg.sender,
            address(this),
            actualRepay
        );

        debts[user][asset] -= actualRepay;
        totalBorrows -= actualRepay;

        // Calculate collateral to seize (with liquidation bonus)
        uint256 collateralSeized =
            (actualRepay * LIQUIDATION_BONUS) / BONUS_PRECISION;

        require(
            balances[user][asset] >= collateralSeized,
            "INSUFFICIENT_COLLATERAL"
        );

        balances[user][asset] -= collateralSeized;
        totalDeposits -= collateralSeized;

        // Send seized collateral to liquidator
        IERC20(asset).transfer(msg.sender, collateralSeized);

        emit Liquidation(
            msg.sender,
            user,
            asset,
            actualRepay,
            collateralSeized
        );
    }

    /**
     * @notice Repay borrowed asset
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
        totalBorrows -= repayAmount;

        return repayAmount;
    }
}