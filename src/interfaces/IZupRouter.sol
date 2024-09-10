// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {PoolToken} from "../types/PoolToken.sol";
import {FeeController} from "../contracts/FeeController.sol";

interface IZupRouter {
  /**
   * @notice emitted when the user successfully deposits into a liquidity pool
   * @param lpTokenId the ID of the LP NFT
   * @param token0 the token0 of the pool
   * @param token1 the token1 of the pool
   * @param token0Amount the amount of token0 that was sent to Zup Router (with fees included)
   * @param token1Amount the amount of token1 that was sent to Zup Router (with fees included)
   * @param positionManager the address of the contract responsible for adding liquidity into the Pool
   * @param user the user who deposited into the Pool
   */
  event ZupRouter__Deposited(
    uint256 indexed lpTokenId,
    address indexed token0,
    address indexed token1,
    uint256 token0Amount,
    uint256 token1Amount,
    address positionManager,
    address user
  );

  /**
   * @notice thrown when the owner of the LP NFT is not the same as the user who wants to deposit into the Pool
   * @param lpOwner the current owner of the LP NFT
   * @param user the user who requested the deposit into the Pool
   */
  error ZupRouter__InvalidLpOwner(address lpOwner, address user);

  /**
   * @notice thrown when the ZupRouter fails to deposit into a Pool for some reason.
   * @param positionManager the address of the contract that reverted
   * @param depositData the data that was sent to the contract
   * @param errorData the error data that was returned by the contract
   */
  error ZupRouter__FailedToDeposit(address positionManager, bytes depositData, bytes errorData);

  /**
   * @notice thrown when the ZupRouter fails to wrap the native token into the wrapped version for some reason
   * @param amount the amount of the native token that have failed to be wrapped
   * @param wrappedNativeAddress the saved address of the wrapped version of the native token
   */
  error ZupRouter__FailedToWrapNativeToken(uint256 amount, address wrappedNativeAddress);

  /**
   * @notice deposit into a liquidity Pool
   * @param token0 the first token of the Pool. e.g in a USDC/ETH Pool, token0 is USDC
   * @param token1 the second token of the Pool. e.g in a USDC/ETH Pool, token1 is ETH
   * @param positionManager address of the contract used to deposit into the Pool
   * @param depositData calldata to be used when calling the @param positionManager to deposit into the Pool
   * @return tokenId the ID of the received LP NFT
   *
   * @dev in case of depositing the Native token (e.g ETH), the params token0::address or token1::address
   * should be set to the address 0 (based on where the native token is).
   * All the conversion to the Wrapped version will happen in the Contract itself
   */
  function deposit(
    PoolToken calldata token0,
    PoolToken calldata token1,
    address positionManager,
    bytes calldata depositData
  ) external payable returns (uint256 tokenId);

  /**
   * @notice get the contract responsible for managing the fees in this contract
   */
  function getFeeController() external view returns (FeeController feeController);
}
