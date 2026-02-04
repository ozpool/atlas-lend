// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ILendingPool.sol";

contract LendingPool is ILendingPool, ReentrancyGuard {
    /// @dev user => asset => deposited amount
    mapping(address => mapping(address => uint256)) internal balances;

    event Deposit(address indexed user, address indexed asset, uint256 amount);
    event Withdraw(address indexed user, address indexed asset, uint256 amount);

    /**
     * @notice Deposit ERC20 tokens into the lending pool
     * @param asset The ERC20 token address
     * @param amount The amount to deposit
     */
    function deposit(address asset, uint256 amount)
        external
        nonReentrant
    {
        require(asset != address(0), "INVALID_ASSET");
        require(amount > 0, "INVALID_AMOUNT");

        // Effects
        balances[msg.sender][asset] += amount;

        // Interactions
        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, asset, amount);
    }
}
