// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Constants
 * @dev Centralized protocol-wide constants for risk and precision.
 */
library Constants {
    /// @dev Precision used for percentage calculations (1e4 = 100%)
    uint256 internal constant PERCENTAGE_PRECISION = 1e4;

    /// @dev Health factor precision (1e18)
    uint256 internal constant HEALTH_FACTOR_PRECISION = 1e18;
}
