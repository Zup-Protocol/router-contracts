// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {ZupMath} from "src/libraries/ZupMath.sol";
import {Test} from "forge-std/Test.sol";

contract ZupMathBipsPercentOfUnitTest is Test {
  function testUnit_bipsPercentOf_LowerPercentage() external pure {
    uint256 inputNumber = 1e3;
    uint256 bips = 5_000; // 50%
    uint256 expectedOutputNumber = 5e2;

    uint256 actualOutputNumber = ZupMath._bipsPercentageOf(bips, inputNumber);
    assertEq(actualOutputNumber, expectedOutputNumber);
  }

  function testUnit_bipsPercentOf_HigherPercentage() external pure {
    uint256 inputNumber = 101e3;
    uint256 bips = 20_000; // 200%
    uint256 expectedOutputNumber = 202e3;

    uint256 actualOutputNumber = ZupMath._bipsPercentageOf(bips, inputNumber);
    assertEq(actualOutputNumber, expectedOutputNumber);
  }

  function testUnit_bipsPercentOf_ZeroPercentage() external pure {
    uint256 inputNumber = 1323143e32;
    uint256 bips = 0;
    uint256 expectedOutputNumber = 0;

    uint256 actualOutputNumber = ZupMath._bipsPercentageOf(bips, inputNumber);
    assertEq(actualOutputNumber, expectedOutputNumber);
  }

  function testUnit_bipsPercentOf_100Percent() external pure {
    uint256 inputNumber = 1323143e32;
    uint256 bips = 10_000; // 100%
    uint256 expectedOutputNumber = inputNumber;

    uint256 actualOutputNumber = ZupMath._bipsPercentageOf(bips, inputNumber);
    assertEq(actualOutputNumber, expectedOutputNumber);
  }
}
