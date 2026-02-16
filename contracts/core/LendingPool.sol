// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/ILendingPool.sol";
import "../interfaces/IInterestRateModel.sol";

contract LendingPool is ILendingPool, ReentrancyGuard {
    /// @dev Loan-to-Value ratio (75%)
    uint256 public constant LTV = 75;
    uint256 public constant LTV_PRECISION = 100;

    uint256 public totalDeposits;
    uint256 public totalBorrows;

    IInterestRateModel public interestRateModel;

    /// @dev user => asset => deposited amount
    mapping(address => mapping(address => uint256)) internal balances;

    /// @dev user => asset => borrowed amount
    mapping(address => mapping(address => uint256)) internal debts;

    event Deposit(address indexed user, address indexed asset, uint256 amount);
    event Withdraw(address indexed user, address indexed asset, uint256 amount);
    event Borrow(address indexed user, address indexed asset, uint256 amount);
    event Repay(address indexed user, address indexed asset, uint256 amount);

    constructor(address _rateModel) {
        require(_rateModel != address(0), "INVALID_RATE_MODEL");
        interestRateModel = IInterestRateModel(_rateModel);
    }

    // -------------------------------------------------------
    // VIEW: Borrow APR
    // -------------------------------------------------------

    function getCurrentBorrowRate()
        external
        view
        returns (uint256)
    {
        return interestRateModel.getBorrowRate(
            totalBorrows,
            totalDeposits
        );
    }

    // -------------------------------------------------------
    // DEPOSIT
    // -------------------------------------------------------

    function deposit(address asset, uint256 amount)
        external
        nonReentrant
    {
        require(amount > 0, "INVALID_AMOUNT");

        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        balances[msg.sender][asset] += amount;
        totalDeposits += amount;

        emit Deposit(msg.sender, asset, amount);
    }

    // -------------------------------------------------------
    // WITHDRAW
    // -------------------------------------------------------

    function withdraw(address asset, uint256 amount)
        external
        nonReentrant
    {
        require(amount > 0, "INVALID_AMOUNT");
        require(balances[msg.sender][asset] >= amount, "INSUFFICIENT_BALANCE");

        require(_isSolvent(msg.sender, asset, amount, 0), "WOULD_BECOME_UNDERCOLLATERALIZED");

        balances[msg.sender][asset] -= amount;
        totalDeposits -= amount;

        IERC20(asset).transfer(msg.sender, amount);

        emit Withdraw(msg.sender, asset, amount);
    }

    // -------------------------------------------------------
    // BORROW
    // -------------------------------------------------------

    function borrow(address asset, uint256 amount)
        external
        nonReentrant
    {
        require(amount > 0, "INVALID_AMOUNT");

        require(_isSolvent(msg.sender, asset, 0, amount), "INSUFFICIENT_COLLATERAL");

        debts[msg.sender][asset] += amount;
        totalBorrows += amount;

        IERC20(asset).transfer(msg.sender, amount);

        emit Borrow(msg.sender, asset, amount);
    }

    // -------------------------------------------------------
    // REPAY
    // -------------------------------------------------------

    function repay(address asset, uint256 amount)
        external
        nonReentrant
    {
        uint256 repayAmount = amount;

        if (amount == type(uint256).max) {
            repayAmount = debts[msg.sender][asset];
        }

        repayAmount = _repay(msg.sender, asset, repayAmount);

        IERC20(asset).transferFrom(msg.sender, address(this), repayAmount);

        emit Repay(msg.sender, asset, repayAmount);
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

    // -------------------------------------------------------
    // RISK ENGINE
    // -------------------------------------------------------

    function _isSolvent(
        address user,
        address asset,
        uint256 withdrawAmount,
        uint256 borrowAmount
    ) internal view returns (bool) {
        uint256 collateral = balances[user][asset] - withdrawAmount;
        uint256 debt = debts[user][asset] + borrowAmount;

        return (collateral * LTV) / LTV_PRECISION >= debt;
    }
}
