// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IInterestRateModel.sol";

contract LinearInterestRateModel is IInterestRateModel {
    uint256 public constant BASE_RATE = 2e16; // 2%
    uint256 public constant SLOPE = 1e17;     // 10%
    uint256 public constant PRECISION = 1e18;

    function getBorrowRate(
        uint256 totalBorrows,
        uint256 totalDeposits
    ) external pure override returns (uint256) {
        if (totalDeposits == 0) {
            return BASE_RATE;
        }

        uint256 utilization =
            (totalBorrows * PRECISION) / totalDeposits;

        return BASE_RATE + (utilization * SLOPE) / PRECISION;
    }
}
