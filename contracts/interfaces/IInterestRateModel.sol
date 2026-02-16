// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IInterestRateModel {
    function getBorrowRate(
        uint256 totalBorrows,
        uint256 totalDeposits
    ) external pure returns (uint256);
}
