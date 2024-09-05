// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {PoolToken} from "src/contracts/ZupRouter.sol";
import {ZupRouterBaseTest, IZupRouter} from "test/ZupRouterBaseTest.t.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @dev Fuzz tests for the ZupRouter deposit function
contract ZupRouterDepositFuzzTest is ZupRouterBaseTest {
  function setUp() public override {
    super.setUp();
  }

  function testFuzz_deposit_token0AndToken1AsERC20(
    uint256 token0Amount,
    uint256 token1Amount,
    address lpReceiver
  ) public customSender(lpReceiver) {
    uint256 tokenId = zupRouter.deposit(
      PoolToken(token0, token0Amount),
      PoolToken(token1, token1Amount),
      address(positionManager),
      positionManager.getMintCallData(address(token0), address(token1), token0Amount, token1Amount, lpReceiver)
    );

    assertEq(positionManager.ownerOf(tokenId), lpReceiver);
  }

  function testFuzz_deposit_nativeToken0(
    uint256 token0Amount,
    uint256 token1Amount,
    address lpReceiver
  ) public customSender(lpReceiver) {
    uint256 tokenId = zupRouter.deposit{value: token0Amount}(
      PoolToken(IERC20(address(0)), 0),
      PoolToken(token1, token1Amount),
      address(positionManager),
      positionManager.getMintCallData(address(wrappedNative), address(token1), token0Amount, token1Amount, lpReceiver)
    );

    assertEq(positionManager.ownerOf(tokenId), lpReceiver);
  }

  function testFuzz_deposit_nativeToken1(
    uint256 token0Amount,
    uint256 token1Amount,
    address lpReceiver
  ) public customSender(lpReceiver) {
    uint256 tokenId = zupRouter.deposit{value: token1Amount}(
      PoolToken(token0, token0Amount),
      PoolToken(IERC20(address(0)), 0),
      address(positionManager),
      positionManager.getMintCallData(address(token0), address(wrappedNative), token0Amount, token1Amount, lpReceiver)
    );

    assertEq(positionManager.ownerOf(tokenId), lpReceiver);
  }

  function testFuzz_deposit_nativeToken0WrapsTheNativeToken(uint256 token0Amount, uint256 token1Amount) public {
    vm.expectCall(address(wrappedNative), token0Amount, "");
    zupRouter.deposit{value: token0Amount}(
      PoolToken(IERC20(address(0)), 0),
      PoolToken(token1, token1Amount),
      address(positionManager),
      positionManager.getMintCallData(
        address(wrappedNative),
        address(token1),
        token0Amount,
        token1Amount,
        address(this)
      )
    );
  }

  function testFuzz_deposit_nativeToken0MsgValueIsUsed(
    uint256 msgValue,
    uint256 token0Amount,
    uint256 token1Amount
  ) public {
    vm.assume(token0Amount != 0 && msgValue != token0Amount);

    vm.expectCall(address(wrappedNative), msgValue, "");
    vm.mockCallRevert(
      address(wrappedNative),
      token0Amount,
      "",
      "msg.value should be used to wrap when depositing with native token as token0"
    );

    zupRouter.deposit{value: msgValue}(
      PoolToken(IERC20(address(0)), token0Amount),
      PoolToken(token1, token1Amount),
      address(positionManager),
      positionManager.getMintCallData(address(wrappedNative), address(token1), msgValue, token1Amount, address(this))
    );
  }

  function testFuzz_deposit_nativeToken1WrapsTheNativeToken(uint256 token0Amount, uint256 token1Amount) public {
    vm.expectCall(address(wrappedNative), token1Amount, "");

    zupRouter.deposit{value: token1Amount}(
      PoolToken(token0, token0Amount),
      PoolToken(IERC20(address(0)), 0),
      address(positionManager),
      positionManager.getMintCallData(
        address(token0),
        address(wrappedNative),
        token0Amount,
        token1Amount,
        address(this)
      )
    );
  }

  function testFuzz_deposit_nativeToken1MsgValueIsUsed(
    uint256 msgValue,
    uint256 token0Amount,
    uint256 token1Amount
  ) public {
    vm.assume(token1Amount != 0 && msgValue != token1Amount);

    vm.expectCall(address(wrappedNative), msgValue, "");
    vm.mockCallRevert(
      address(wrappedNative),
      token1Amount,
      "",
      "msg.value should be used to wrap when depositing with native token as token1"
    );

    zupRouter.deposit{value: msgValue}(
      PoolToken(token0, token0Amount),
      PoolToken(IERC20(address(0)), token1Amount),
      address(positionManager),
      positionManager.getMintCallData(address(token0), address(wrappedNative), token0Amount, msgValue, address(this))
    );
  }

  function testFuzz_deposit_revertsIfLpOwnerIsNotMsgSender(
    address sender,
    address lpReceiver,
    uint256 token0Amount,
    uint256 token1Amount
  ) public customSender(sender) {
    vm.assume(lpReceiver != sender);
    assumeNotZeroAddress(lpReceiver);

    bytes memory depositCalldata = positionManager.getMintCallData(
      address(token0),
      address(token1),
      token0Amount,
      token1Amount,
      lpReceiver
    );

    vm.expectRevert(abi.encodeWithSelector(IZupRouter.ZupRouter__InvalidLpOwner.selector, lpReceiver, sender));
    zupRouter.deposit(
      PoolToken(token0, token0Amount),
      PoolToken(token1, token1Amount),
      address(positionManager),
      depositCalldata
    );
  }

  function testFuzz_deposit_emitsDepositedEvent(
    uint256 depositAmountToken0,
    uint256 depositAmountToken1,
    address lpReceiver,
    uint256 tokenIdToMint
  ) public customSender(lpReceiver) {
    vm.assume(tokenIdToMint != 0);
    positionManager.changeMintTokenId(tokenIdToMint);

    vm.expectEmit();
    emit IZupRouter.ZupRouter__Deposited(
      tokenIdToMint,
      address(token0),
      address(token1),
      depositAmountToken0,
      depositAmountToken1,
      address(positionManager),
      lpReceiver
    );

    zupRouter.deposit(
      PoolToken(token0, depositAmountToken0),
      PoolToken(token1, depositAmountToken1),
      address(positionManager),
      positionManager.getMintCallData(
        address(token0),
        address(token1),
        depositAmountToken0,
        depositAmountToken1,
        lpReceiver
      )
    );
  }

  function testFuzz_deposit_callPositionManagerWithCorrectData(
    uint256 depositAmountToken0,
    uint256 depositAmountToken1,
    address lpReceiver
  ) public customSender(lpReceiver) {
    bytes memory callData = positionManager.getMintCallData(
      address(token0),
      address(token1),
      depositAmountToken0,
      depositAmountToken1,
      lpReceiver
    );

    vm.expectCall(address(positionManager), callData);
    zupRouter.deposit(
      PoolToken(token0, depositAmountToken0),
      PoolToken(token1, depositAmountToken1),
      address(positionManager),
      callData
    );
  }
}
