// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library HealthFactor {
    uint256 internal constant PRECISION = 1e18;

    function calculate(
        uint256 collateralValue,
        uint256 debtValue,
        uint256 liquidationThreshold
    ) internal pure returns (uint256) {
        if (debtValue == 0) {
            return type(uint256).max;
        }

        return
            (collateralValue * liquidationThreshold * PRECISION) /
            (debtValue * PRECISION);
    }
}
