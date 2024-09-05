// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ZupRouter, IZupRouter} from "src/contracts/ZupRouter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

enum ForkNetwork {
  ETHEREUM,
  ARBITRUM,
  BASE
}

struct NetworkParams {
  IERC20 wrappedNative;
  IERC20 usdc;
  string rpc;
}

contract BaseForkTest is Test {
  using SafeERC20 for IERC20;

  IZupRouter internal zupRouter;
  NetworkParams internal networkParams;
  ForkNetwork internal network;

  constructor(ForkNetwork _network) {
    network = _network;

    if (network == ForkNetwork.ETHEREUM) {
      networkParams = NetworkParams({
        wrappedNative: IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2),
        usdc: IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),
        rpc: "https://1rpc.io/eth"
      });
    }

    if (network == ForkNetwork.ARBITRUM) {
      networkParams = NetworkParams({
        wrappedNative: IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1),
        usdc: IERC20(0xaf88d065e77c8cC2239327C5EDb3A432268e5831),
        rpc: "https://1rpc.io/arb"
      });
    }

    if (network == ForkNetwork.BASE) {
      networkParams = NetworkParams({
        wrappedNative: IERC20(0x4200000000000000000000000000000000000006),
        usdc: IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913),
        rpc: "https://1rpc.io/base"
      });
    }
  }

  function setUp() public virtual {
    vm.createSelectFork(networkParams.rpc);
    zupRouter = new ZupRouter(address(networkParams.wrappedNative));
    _mintUSDC(address(this), 999999999e6);
    _mintWrappedNative(9999999e18);
  }

  function _mintWrappedNative(uint256 amount) public virtual {
    (bool success, ) = address(networkParams.wrappedNative).call{value: amount}("");
    require(success, "FAILED TO MINT WRAPPED NATIVE");
  }

  function _mintUSDC(address to, uint256 amount) internal {
    address masterMinter;

    {
      (bool success, bytes memory data) = address(networkParams.usdc).staticcall(
        abi.encodeWithSignature("masterMinter()")
      );
      require(success, "FAILED TO GET MASTER_MINTER OF USDC");
      masterMinter = abi.decode(data, (address));
    }

    {
      vm.startPrank(masterMinter);
      (bool success, ) = address(networkParams.usdc).call(
        abi.encodeWithSignature("configureMinter(address,uint256)", address(this), UINT256_MAX)
      );
      require(success, "FAILED TO SET MINTER OF USDC");
      vm.stopPrank();
    }

    {
      (bool success, ) = address(networkParams.usdc).call(abi.encodeWithSignature("mint(address,uint256)", to, amount));
      require(success, "FAILED TO MINT USDC");
    }
  }
}
