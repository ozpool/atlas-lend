// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Constants.sol";

/**
 * @title AssetConfig
 * @dev Risk parameters for supported collateral assets.
 * Values are intentionally conservative for safety.
 */
library AssetConfig {
    /// @notice Max LTV: 75%
    uint256 internal constant MAX_LTV =
        7500; // 75% (based on PERCENTAGE_PRECISION)

    /// @notice Liquidation threshold: 80%
    uint256 internal constant LIQUIDATION_THRESHOLD =
        8000; // 80%

    /// @notice Liquidation bonus: 5%
    uint256 internal constant LIQUIDATION_BONUS =
        10500; // 5% bonus for liquidators
}
