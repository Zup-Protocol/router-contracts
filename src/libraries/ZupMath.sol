// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

library ZupMath {
  uint256 private constant BASE_BIPS = 10_000; // 100%

  /**
   * @notice get X percent of Y using bips
   * @param bips the percentage represented as basis points (bips)
   * @param number the number to get the percentage from
   * @return result the X percent of Y
   */
  function _bipsPercentageOf(uint256 bips, uint256 number) internal pure returns (uint256 result) {
    return ((number * bips) / BASE_BIPS);
  }
}
