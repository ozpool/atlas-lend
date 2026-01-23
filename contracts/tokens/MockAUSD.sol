// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockAUSD
 * @dev Mock stablecoin used for testing and development purposes.
 * Minting is restricted to the contract owner (protocol-controlled).
 */
contract MockAUSD is ERC20, Ownable {
    constructor() 
        ERC20("Atlas USD", "aUSD")
        Ownable(msg.sender)
    {}

    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "INVALID_ADDRESS");
        require(amount > 0, "ZERO_AMOUNT");
        _mint(to, amount);
    }
}
