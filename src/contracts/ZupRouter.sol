// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {IZupRouter, PoolToken} from "src/interfaces/IZupRouter.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {FeeController} from "src/contracts/FeeController.sol";

//
//                                                   XEX
//                                                 XJEEEX
//                                                XEEEEEN
//                                            X SEEEEEES
//                                              NEEEEEEES
//                                           XXJEEEEEEEJXX
//                                           XJEEEEEEEEJX
//                                          SEEEEEEEEEEJ X
//                                        XNEEEEEEEEEEEN
//                                       XJEEEEEEEEEEEEX
//                                      XJEEEEEEEEEEEEE X
//                                     XEEEEEEEEEEEEEEJ   X  X  X  X
//                                  X SEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEES
//                                  XNEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEJXX
//                                XXJEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEN
//                                XEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEESXX
//                             X SEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEES
//                            X NEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEX
//                            X NEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEJ
//                             X XSSSSSSSSSSSSSSSJEEEEEEEEEEEEEEN X
//                                             X EEEEEEEEEEEEEES X
//                                              XEEEEEEEEEEEEEX
//                                              SEEEEEEEEEEEJX
//                                            XJEEEEEEEEEEN X
//                                            X JEEEEEEEEES X
//                                             XJEEEEEEEEX X
//                                             XEEEEEEEJXX
//                                             XEEEEEEJ X
//                                            XSEEEEES X
//                                             SEEEES X
//                                            X XXX
//

/**
 * @title ZupRouterV1
 * @notice the ZupRouterV1 contract is responsible for adding liquidity into Pools
 */
contract ZupRouter is IZupRouter {
  using SafeERC20 for IERC20;

  IERC20 private immutable i_wrappedNative;
  FeeController private immutable i_feeController;

  /**
   * @param wrappedNative the address of the wrapped native token of the current chain.
   * e.g WETH on Ethereum or WAVAX on Avalanche
   * @param feeController the address of the FeeController contract
   *  */
  constructor(address wrappedNative, address feeController) {
    i_wrappedNative = IERC20(wrappedNative);
    i_feeController = FeeController(feeController);
  }

  /// @inheritdoc IZupRouter
  function deposit(
    PoolToken calldata token0,
    PoolToken calldata token1,
    address positionManager,
    bytes calldata depositData
  ) external payable override returns (uint256 tokenId) {
    bool isToken0Native = address(token0.token) == address(0);
    bool isToken1Native = address(token1.token) == address(0);
    bool isNativeDeposit = isToken0Native || isToken1Native;

    if (isNativeDeposit) {
      _wrapNative();
      i_wrappedNative.forceApprove(positionManager, msg.value);
    }

    if (!isToken0Native) {
      token0.token.safeTransferFrom(msg.sender, address(this), token0.amount);
      token0.token.forceApprove(positionManager, token0.amount);
    }

    if (!isToken1Native) {
      token1.token.safeTransferFrom(msg.sender, address(this), token1.amount);
      token1.token.forceApprove(positionManager, token1.amount);
    }

    {
      (uint256 feeToken0, uint256 feeToken1) = i_feeController.calculateJoinPoolFee(
        isToken0Native ? msg.value : token0.amount,
        isToken1Native ? msg.value : token1.amount
      );

      address feeReceiver = i_feeController.getFeeReceiver();

      (isToken0Native ? i_wrappedNative : token0.token).transfer(feeReceiver, feeToken0);
      (isToken1Native ? i_wrappedNative : token1.token).transfer(feeReceiver, feeToken1);
    }

    (bool success, bytes memory answer) = positionManager.call(depositData);
    if (!success) revert ZupRouter__FailedToDeposit(positionManager, depositData, answer);

    tokenId = abi.decode(answer, (uint256));
    address lpOwner = ERC721(positionManager).ownerOf(tokenId);

    if (lpOwner != msg.sender) revert ZupRouter__InvalidLpOwner(lpOwner, msg.sender);

    emit ZupRouter__Deposited(
      tokenId,
      isToken0Native ? address(i_wrappedNative) : address(token0.token),
      isToken1Native ? address(i_wrappedNative) : address(token1.token),
      isToken0Native ? msg.value : token0.amount,
      isToken1Native ? msg.value : token1.amount,
      positionManager,
      msg.sender
    );
  }

  /**
   * @notice wraps the native token into the wrapped ERC20 version
   *  */
  function _wrapNative() private {
    (bool success, ) = address(i_wrappedNative).call{value: msg.value}("");
    if (!success) revert ZupRouter__FailedToWrapNativeToken(msg.value, address(i_wrappedNative));
  }
}
