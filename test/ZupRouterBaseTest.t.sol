// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {ZupRouter, IZupRouter} from "src/contracts/ZupRouter.sol";
import {WrappedNativeMock} from "test/mocks/WrappedNative.mock.sol";
import {PositionManagerMock} from "test/mocks/PositionManager.mock.sol";
import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract ZupRouterBaseTest is Test {
  WrappedNativeMock internal wrappedNative = new WrappedNativeMock();
  IZupRouter internal zupRouter = new ZupRouter(address(wrappedNative));
  ERC20Mock internal token0;
  ERC20Mock internal token1;
  PositionManagerMock internal positionManager = new PositionManagerMock();

  modifier customSender(address sender) {
    vm.assume(sender != address(0));

    // Reset the token0 and token1 to not conflict with default sender
    token0 = new ERC20Mock();
    token1 = new ERC20Mock();

    _setupAddress(sender);
    startHoax(sender, UINT256_MAX);
    _setupApprovals();
    _;
    vm.stopPrank();
  }

  function setUp() public virtual {
    token0 = new ERC20Mock();
    token1 = new ERC20Mock();

    _setupAddress(address(this));
    _setupApprovals();
  }

  function _setupAddress(address who) private {
    vm.deal(who, UINT256_MAX);
    token0.mint(who, UINT256_MAX);
    token1.mint(who, UINT256_MAX);
  }

  function _setupApprovals() private {
    token0.approve(address(zupRouter), UINT256_MAX);
    token1.approve(address(zupRouter), UINT256_MAX);
    wrappedNative.approve(address(zupRouter), UINT256_MAX);
  }
}
