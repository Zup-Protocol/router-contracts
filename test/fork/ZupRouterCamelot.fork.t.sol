// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {BaseForkTest, ForkNetwork, SafeERC20} from "test/fork/BaseForkTest.t.sol";
import {PoolToken} from "src/types/PoolToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @dev Fork tests targeting Camelot using the ZupRouter
contract ZupRouterCamelotForkTest is BaseForkTest(ForkNetwork.ARBITRUM) {
  using SafeERC20 for IERC20;

  address private camelotNonFungiblePositionManager;

  function setUp() public override {
    camelotNonFungiblePositionManager = 0x00c7f3082833e796A5b3e4Bd59f6642FF44DCD15;
    super.setUp();
  }

  function testFork_depositCamelotV3() public {
    address token0 = address(networkParams.wrappedNative);
    address token1 = address(networkParams.usdc);
    uint256 token0Amount = 0.0004 ether;
    uint256 token1Amount = 10e6;

    bytes memory depositCalldata = abi.encodeWithSignature(
      "mint((address,address,int24,int24,uint256,uint256,uint256,uint256,address,uint256))",
      token0, // token0
      token1, // token1
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
      camelotNonFungiblePositionManager,
      depositCalldata
    );

    assertEq(IERC721(camelotNonFungiblePositionManager).ownerOf(tokenId), address(this));
  }
}
