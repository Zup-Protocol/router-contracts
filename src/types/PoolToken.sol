// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @notice Token that is used to deposit into a Liquidity Pool
 * @param tokenAddress the address of the token
 * @param amount the amount of the token (with decimals)
 */
struct PoolToken {
  IERC20 token;
  uint256 amount;
}
