// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {FeeController} from "src/contracts/FeeController.sol";
import {Test} from "forge-std/Test.sol";

contract FeeControllerCalculateJoinPoolFeeUnitTest is Test {
  FeeController public feeController;

  function setUp() public {
    feeController = new FeeController(0, address(this));
  }

  function testUnit_calculateJoinPoolFee_1percent() public {
    feeController.setJoinPoolFee(100);

    uint256 token0Amount = 1000e18;
    uint256 token1Amount = 1000e18;
    uint256 expectedToken0Fee = 5e18;
    uint256 expectedToken1Fee = 5e18;

    (uint256 token0Fee, uint256 token1Fee) = feeController.calculateJoinPoolFee({
      token0Amount: token0Amount,
      token1Amount: token1Amount
    });

    assertEq(token0Fee, expectedToken0Fee, "Token0 fee mismatch");
    assertEq(token1Fee, expectedToken1Fee, "Token1 fee mismatch");
  }

  function testUnit_calculateJoinPoolFee_0percent() public {
    feeController.setJoinPoolFee(0);

    uint256 token0Amount = 1000e18;
    uint256 token1Amount = 1000e18;
    uint256 expectedToken0Fee = 0;
    uint256 expectedToken1Fee = 0;

    (uint256 token0Fee, uint256 token1Fee) = feeController.calculateJoinPoolFee({
      token0Amount: token0Amount,
      token1Amount: token1Amount
    });

    assertEq(token0Fee, expectedToken0Fee, "Token0 fee mismatch");
    assertEq(token1Fee, expectedToken1Fee, "Token1 fee mismatch");
  }

  function testUnit_calculateJoinPoolFee_015percent() public {
    feeController.setJoinPoolFee(15);

    uint256 token0Amount = 1000e18;
    uint256 token1Amount = 1000e18;
    uint256 expectedToken0Fee = 75e16;
    uint256 expectedToken1Fee = 75e16;

    (uint256 token0Fee, uint256 token1Fee) = feeController.calculateJoinPoolFee({
      token0Amount: token0Amount,
      token1Amount: token1Amount
    });

    assertEq(token0Fee, expectedToken0Fee, "Token0 fee mismatch");
    assertEq(token1Fee, expectedToken1Fee, "Token1 fee mismatch");
  }

  function testUnit_calculateJoinPoolFee_100percent() public {
    feeController.setJoinPoolFee(10_000);

    uint256 token0Amount = 1000e18;
    uint256 token1Amount = 3e18;
    uint256 expectedToken0Fee = token0Amount / 2;
    uint256 expectedToken1Fee = token1Amount / 2;

    (uint256 token0Fee, uint256 token1Fee) = feeController.calculateJoinPoolFee({
      token0Amount: token0Amount,
      token1Amount: token1Amount
    });

    assertEq(token0Fee, expectedToken0Fee, "Token0 fee mismatch");
    assertEq(token1Fee, expectedToken1Fee, "Token1 fee mismatch");
  }

  function testUnit_calculateJoinPoolFee_50percent() public {
    feeController.setJoinPoolFee(5_000);

    uint256 token0Amount = 1000e18;
    uint256 token1Amount = 3e18;
    uint256 expectedToken0Fee = 250e18;
    uint256 expectedToken1Fee = 75e16;

    (uint256 token0Fee, uint256 token1Fee) = feeController.calculateJoinPoolFee({
      token0Amount: token0Amount,
      token1Amount: token1Amount
    });

    assertEq(token0Fee, expectedToken0Fee, "Token0 fee mismatch");
    assertEq(token1Fee, expectedToken1Fee, "Token1 fee mismatch");
  }

  function testUnit_calculateJoinPoolFee_tokensWith6decimals() public {
    feeController.setJoinPoolFee(100); // 1%

    uint256 token0Amount = 1000e6;
    uint256 token1Amount = 1000e6;
    uint256 expectedToken0Fee = 5e6;
    uint256 expectedToken1Fee = 5e6;

    (uint256 token0Fee, uint256 token1Fee) = feeController.calculateJoinPoolFee({
      token0Amount: token0Amount,
      token1Amount: token1Amount
    });

    assertEq(token0Fee, expectedToken0Fee, "Token0 fee mismatch");
    assertEq(token1Fee, expectedToken1Fee, "Token1 fee mismatch");
  }
}
