// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ZupRouter, IZupRouter} from "src/contracts/ZupRouter.sol";

contract ZupRouterGetWrappedNativeFuzzTest is Test {
  function test_getWrappedNative_returnsTheCorrectAddress(address wrappedNative) external {
    IZupRouter zupRouter = new ZupRouter(wrappedNative, address(0));

    assertEq(zupRouter.getWrappedNative(), wrappedNative);
  }
}
