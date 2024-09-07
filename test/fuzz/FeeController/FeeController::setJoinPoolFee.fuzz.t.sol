// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {FeeController} from "src/contracts/FeeController.sol";
import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FeeControllerSetJoinPoolFeeFuzzTest is Test {
  FeeController internal feeController;

  function setUp() public virtual {
    feeController = new FeeController(0, address(this));
  }

  function testFuzz_setJoinPoolFee(uint256 newFee) public virtual {
    feeController.setJoinPoolFee(newFee);

    assertEq(feeController.getJoinPoolFee(), newFee);
  }

  function testFuzz_setJoinPoolFee_revertsIfNotAdmin(uint256 newFee, address notAdmin) public virtual {
    vm.assume(notAdmin != feeController.owner());

    vm.startPrank(notAdmin);
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notAdmin));
    feeController.setJoinPoolFee(newFee);
    vm.stopPrank();
  }

  function testFuzz_setJoinPoolFee_emitsEvent(uint256 newFee, uint256 oldFee) public virtual {
    feeController.setJoinPoolFee(oldFee);

    vm.expectEmit();
    emit FeeController.FeeController__JoinPoolFeeSet(oldFee, newFee);
    feeController.setJoinPoolFee(newFee);
  }
}
