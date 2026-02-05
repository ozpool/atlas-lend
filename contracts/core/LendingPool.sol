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
     */
    function deposit(address asset, uint256 amount)
        external
        nonReentrant
    {
        require(asset != address(0), "INVALID_ASSET");
        require(amount > 0, "INVALID_AMOUNT");

        balances[msg.sender][asset] += amount;
        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, asset, amount);
    }

    /**
     * @notice Withdraw ERC20 tokens from the lending pool
     */
    function withdraw(address asset, uint256 amount)
        external
        nonReentrant
    {
        require(asset != address(0), "INVALID_ASSET");
        require(amount > 0, "INVALID_AMOUNT");
        require(balances[msg.sender][asset] >= amount, "INSUFFICIENT_BALANCE");

        balances[msg.sender][asset] -= amount;
        IERC20(asset).transfer(msg.sender, amount);

        emit Withdraw(msg.sender, asset, amount);
    }

    /**
     * @notice Get user balance for an asset
     */
    function balanceOf(address user, address asset)
        external
        view
        returns (uint256)
    {
        return balances[user][asset];
    }
}
