// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {ZupRouterBaseTest, IZupRouter} from "test/ZupRouterBaseTest.t.sol";
import {PoolToken} from "src/types/PoolToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @dev Unit tests for the ZupRouter deposit function
contract ZupRouterDepositUnitTest is ZupRouterBaseTest {
  function setUp() public override {
    super.setUp();
  }

  function testUnit_deposit_revertsIfCallToPositionManagerFail() public {
    uint256 depositAmount = 213;
    bytes memory revertData = "PROPOSITAL REVERT";
    bytes memory depositData = positionManager.getMintCallData(
      address(token0),
      address(token1),
      depositAmount,
      depositAmount,
      address(this)
    );

    vm.mockCallRevert(address(positionManager), depositData, revertData);
    vm.expectRevert(
      abi.encodeWithSelector(
        IZupRouter.ZupRouter__FailedToDeposit.selector,
        address(positionManager),
        depositData,
        revertData
      )
    );
    zupRouter.deposit(
      PoolToken(token0, depositAmount),
      PoolToken(token1, depositAmount),
      address(positionManager),
      depositData
    );
  }

  function testUnit_deposit_transferTokens() public {
    uint256 deposit0Amount = 213;
    uint256 deposit1Amount = 321;

    vm.expectCall(
      address(token0),
      abi.encodeWithSelector(IERC20.transferFrom.selector, address(this), address(zupRouter), deposit0Amount)
    );
    vm.expectCall(
      address(token1),
      abi.encodeWithSelector(IERC20.transferFrom.selector, address(this), address(zupRouter), deposit1Amount)
    );
    zupRouter.deposit(
      PoolToken(token0, deposit0Amount),
      PoolToken(token1, deposit1Amount),
      address(positionManager),
      positionManager.getMintCallData(address(token0), address(token1), deposit0Amount, deposit1Amount, address(this))
    );
  }

  function testUnit_deposit_approveTokensToPositionManager() public {
    uint256 deposit0Amount = 213;
    uint256 deposit1Amount = 321;

    vm.expectCall(
      address(token0),
      abi.encodeWithSelector(IERC20.approve.selector, address(positionManager), deposit0Amount)
    );
    vm.expectCall(
      address(token1),
      abi.encodeWithSelector(IERC20.approve.selector, address(positionManager), deposit1Amount)
    );
    zupRouter.deposit(
      PoolToken(token0, deposit0Amount),
      PoolToken(token1, deposit1Amount),
      address(positionManager),
      positionManager.getMintCallData(address(token0), address(token1), deposit0Amount, deposit1Amount, address(this))
    );
  }

  function testUnit_deposit_nativeToken0ApproveWrappedTokenToPositonManager() public {
    uint256 deposit0Amount = 213;
    uint256 deposit1Amount = 321;

    vm.expectCall(
      address(wrappedNative),
      abi.encodeWithSelector(IERC20.approve.selector, address(positionManager), deposit0Amount)
    );
    zupRouter.deposit{value: deposit0Amount}(
      PoolToken(IERC20(address(0)), 0),
      PoolToken(token1, deposit1Amount),
      address(positionManager),
      positionManager.getMintCallData(
        address(wrappedNative),
        address(token1),
        deposit0Amount,
        deposit1Amount,
        address(this)
      )
    );
  }

  function testUnit_deposit_nativeToken1ApproveWrappedTokenToPositonManager() public {
    uint256 deposit0Amount = 213;
    uint256 deposit1Amount = 321;

    vm.expectCall(
      address(wrappedNative),
      abi.encodeWithSelector(IERC20.approve.selector, address(positionManager), deposit1Amount)
    );
    zupRouter.deposit{value: deposit1Amount}(
      PoolToken(token0, deposit0Amount),
      PoolToken(IERC20(address(0)), 0),
      address(positionManager),
      positionManager.getMintCallData(
        address(token0),
        address(wrappedNative),
        deposit0Amount,
        deposit1Amount,
        address(this)
      )
    );
  }

  function testUnit_deposit_revertsIfWrapNativeFail() public {
    uint256 deposit0Amount = 213;
    uint256 deposit1Amount = 321;
    bytes memory revertData = "PROPOSITAL REVERT";
    bytes memory positionManagerCalldata = positionManager.getMintCallData(
      address(token0),
      address(wrappedNative),
      deposit0Amount,
      deposit1Amount,
      address(this)
    );

    vm.mockCallRevert(address(wrappedNative), deposit1Amount, "", revertData);
    vm.expectRevert(
      abi.encodeWithSelector(
        IZupRouter.ZupRouter__FailedToWrapNativeToken.selector,
        deposit1Amount,
        address(wrappedNative)
      )
    );
    zupRouter.deposit{value: deposit1Amount}(
      PoolToken(token0, deposit0Amount),
      PoolToken(IERC20(address(0)), 0),
      address(positionManager),
      positionManagerCalldata
    );
  }
}
