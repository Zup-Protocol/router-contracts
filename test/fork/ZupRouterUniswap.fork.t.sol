// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {BaseForkTest, ForkNetwork, SafeERC20} from "test/fork/BaseForkTest.t.sol";
import {PoolToken} from "src/types/PoolToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @dev Fork tests targeting Uniswap using the ZupRouter
contract ZupRouterUniswapForkTest is BaseForkTest(ForkNetwork.ETHEREUM) {
  using SafeERC20 for IERC20;

  address private uniswapNonFungiblePositionManager;

  function setUp() public override {
    uniswapNonFungiblePositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    super.setUp();
  }

  function testFork_depositUniswapV3() public {
    address token0 = address(networkParams.usdc);
    address token1 = address(networkParams.wrappedNative);
    uint256 token0Amount = 10e6;
    uint256 token1Amount = 0.0004 ether;

    bytes memory depositCalldata = abi.encodeWithSignature(
      "mint((address,address,uint24,int24,int24,uint256,uint256,uint256,uint256,address,uint256))",
      token0, // token0
      token1, // token1
      100, // fee
      -10, // tickLower
      10, // tickUpper
      token0Amount, // amount0Desired
      token1Amount, // amount1Desired
      0, // amount0Min
      0, // amount1Min
      address(this), // recipient
      UINT256_MAX // deadline
    );

    IERC20(token0).forceApprove(address(zupRouter), token0Amount);
    IERC20(token1).forceApprove(address(zupRouter), token1Amount);

    uint256 tokenId = zupRouter.deposit(
      PoolToken(IERC20(token0), token0Amount),
      PoolToken(IERC20(token1), token1Amount),
      uniswapNonFungiblePositionManager,
      depositCalldata
    );

    assertEq(IERC721(uniswapNonFungiblePositionManager).ownerOf(tokenId), address(this));
  }
}
