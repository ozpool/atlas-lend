// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* ───────────────────────────── Imports ───────────────────────────── */
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/ILendingPool.sol";
import "../interfaces/IInterestRateModel.sol";
import "../libraries/HealthFactor.sol";

/* ───────────────────────────── Contract ───────────────────────────── */
contract LendingPool is
    ILendingPool,
    AccessControl,
    ReentrancyGuard,
    Pausable
{
    /* ───────────────────────── Roles ───────────────────────── */
    bytes32 public constant PROTOCOL_ADMIN_ROLE =
        keccak256("PROTOCOL_ADMIN_ROLE");

    /* ───────────────────────── Risk Params ───────────────────────── */
    uint256 public ltv;                     // e.g. 75
    uint256 public liquidationThreshold;    // e.g. 85
    uint256 public liquidationBonus;        // e.g. 105

    uint256 public constant PERCENT_PRECISION = 100;
    uint256 public constant CLOSE_FACTOR = 50;

    /* ───────────────────────── External Dependencies ───────────────────────── */
    IInterestRateModel public interestRateModel;

    /* ───────────────────────── Storage ───────────────────────── */
    /// @dev user => asset => deposited amount
    mapping(address => mapping(address => uint256)) internal balances;

    /// @dev user => asset => borrowed amount
    mapping(address => mapping(address => uint256)) internal debts;

    /// @dev total deposits across all users/assets (accounting metric)
    uint256 public totalDeposits;

    /* ───────────────────────── Events ───────────────────────── */
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

    event ProtocolPaused(address indexed admin);
    event ProtocolUnpaused(address indexed admin);

    /* ───────────────────────── Constructor ───────────────────────── */
    constructor(address _rateModel) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PROTOCOL_ADMIN_ROLE, msg.sender);

        interestRateModel = IInterestRateModel(_rateModel);

        ltv = 75;
        liquidationThreshold = 85;
        liquidationBonus = 105;
    }

    /* ───────────────────────── Admin Controls ───────────────────────── */
    function pause() external onlyRole(PROTOCOL_ADMIN_ROLE) {
        _pause();
        emit ProtocolPaused(msg.sender);
    }

    function unpause() external onlyRole(PROTOCOL_ADMIN_ROLE) {
        _unpause();
        emit ProtocolUnpaused(msg.sender);
    }

    /* ───────────────────────── User Actions ───────────────────────── */

    /**
     * @notice Deposit collateral into the protocol
     * @dev CEI-compliant and reentrancy-protected
     */
    function deposit(address asset, uint256 amount)
        external
        nonReentrant
        whenNotPaused
    {
        /* ───── CHECKS ───── */
        require(amount > 0, "INVALID_AMOUNT");

        /* ───── EFFECTS ───── */
        balances[msg.sender][asset] += amount;
        totalDeposits += amount;

        /* ───── INTERACTIONS ───── */
        IERC20(asset).transferFrom(
            msg.sender,
            address(this),
            amount
        );

        emit Deposit(msg.sender, asset, amount);
    }

    function repay(address asset, uint256 amount)
        external
        nonReentrant
        whenNotPaused
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

    /* ───────────────────────── Internal Logic ───────────────────────── */

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

    function _validateHealthFactor(
        address user,
        address asset
    ) internal view {
        uint256 debt = debts[user][asset];
        if (debt == 0) return;

        uint256 hf = getHealthFactor(user, asset);
        require(hf >= 1e18, "HF_TOO_LOW");
    }

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
            liquidationThreshold
        );
    }

    /* ───────────────────────── Views ───────────────────────── */

    function getHealthFactor(
        address user,
        address asset
    ) public view returns (uint256) {
        return HealthFactor.calculate(
            balances[user][asset],
            debts[user][asset],
            liquidationThreshold
        );
    }
}
