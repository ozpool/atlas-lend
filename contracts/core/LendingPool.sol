// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ILendingPool.sol";

contract LendingPool is ILendingPool, ReentrancyGuard {
    /// @dev Loan-to-Value ratio (75%)
    uint256 public constant LTV = 75;
    uint256 public constant LTV_PRECISION = 100;

    /// @dev user => asset => deposited amount
    mapping(address => mapping(address => uint256)) internal balances;

    /// @dev user => asset => borrowed amount
    mapping(address => mapping(address => uint256)) internal debts;

    event Deposit(address indexed user, address indexed asset, uint256 amount);
    event Withdraw(address indexed user, address indexed asset, uint256 amount);
    event Borrow(address indexed user, address indexed asset, uint256 amount);
    event Repay(address indexed user, address indexed asset, uint256 amount);

    /**
     * @dev Calculates the maximum borrowable amount based on collateral and LTV
     */
    function _maxBorrowable(
        address user,
        address asset
    ) internal view returns (uint256) {
        uint256 collateral = balances[user][asset];
        return (collateral * LTV) / LTV_PRECISION;
    }

    /**
     * @notice Borrow assets against deposited collateral
     */
    function borrow(address asset, uint256 amount)
        external
        nonReentrant
    {
        require(amount > 0, "INVALID_AMOUNT");

        uint256 maxBorrow = _maxBorrowable(msg.sender, asset);
        uint256 currentDebt = debts[msg.sender][asset];

        require(
            currentDebt + amount <= maxBorrow,
            "INSUFFICIENT_COLLATERAL"
        );

        debts[msg.sender][asset] += amount;
        IERC20(asset).transfer(msg.sender, amount);

        emit Borrow(msg.sender, asset, amount);
    }
}
