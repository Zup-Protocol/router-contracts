// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {ZupMath} from "../libraries/ZupMath.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract FeeController is Ownable2Step {
  using ZupMath for uint256;

  uint256 private s_joinPoolFeeBips;
  uint256 private constant POOL_TOKEN_AMOUNT = 2;

  /**
   * @notice emitted when the admin sets a new fee for joining a pool
   * @param oldFee the previous fee that was set
   * @param newFee the new fee set
   */
  event FeeController__JoinPoolFeeSet(uint256 oldFee, uint256 newFee);

  /**
   * @param joinPoolFeeBips the initial fee to set for joining a pool in basis points (bips)
   * @param feeAdmin the admin of this contract that can perform admin operations. e.g set the fee
   */
  constructor(uint256 joinPoolFeeBips, address feeAdmin) Ownable(feeAdmin) {
    s_joinPoolFeeBips = joinPoolFeeBips;
  }

  /**
   * @notice sets a new fee for joining a pool
   * @param newFee the new fee to join a pool (in basis points)
   */
  function setJoinPoolFee(uint256 newFee) external onlyOwner {
    uint256 oldFee = s_joinPoolFeeBips;
    s_joinPoolFeeBips = newFee;

    emit FeeController__JoinPoolFeeSet(oldFee, newFee);
  }

  /**
   * @notice gets the current fee for joining a pool in basis points (bips)
   */
  function getJoinPoolFee() external view returns (uint256 feeBips) {
    return s_joinPoolFeeBips;
  }

  /**
   * @notice gets the address of the wallet that will receive the fees
   */
  function getFeeReceiver() external view returns (address feeReceiver) {
    return owner();
  }

  /**
   * @notice calculates the fee to join a liquidity pool using Zup
   * @param token0Amount the amount of the token0 that is desired to deposit into the pool
   * @param token1Amount the amount of the token1 that is desired to deposit into the pool
   * @return feeToken0 the amount of token0 that will be paid as fee
   * @return feeToken1 the amount of token1 that will be paid as fee
   */
  function calculateJoinPoolFee(
    uint256 token0Amount,
    uint256 token1Amount
  ) public view returns (uint256 feeToken0, uint256 feeToken1) {
    uint256 fee = s_joinPoolFeeBips;

    feeToken0 = fee._bipsPercentageOf(token0Amount) / POOL_TOKEN_AMOUNT;
    feeToken1 = fee._bipsPercentageOf(token1Amount) / POOL_TOKEN_AMOUNT;
  }
}
