// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract WrappedNativeMock is ERC20Mock {
  receive() external payable {
    _mint(msg.sender, msg.value);
  }
}
