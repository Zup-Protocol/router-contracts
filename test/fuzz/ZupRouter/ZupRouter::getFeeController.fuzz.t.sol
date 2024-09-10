// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ZupRouter, IZupRouter} from "src/contracts/ZupRouter.sol";

contract ZupRouterGetFeeControllerFuzzTest is Test {
  function test_getFeeController_returnsTheCorrectFeeController(address feeController) external {
    IZupRouter zupRouter = new ZupRouter(address(0), feeController);

    assertEq(zupRouter.getFeeController(), feeController);
  }
}
