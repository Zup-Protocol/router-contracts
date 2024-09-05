// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PositionManagerMock is ERC721("V3 POSITION NFT", "V3-NFT") {
  uint256 private _transientTokenIdSlot;

  struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    address recipient;
    uint256 deadline;
  }

  /// @dev uses transient storage to only update the token id within the transaction
  function changeMintTokenId(uint256 newTokenId) external {
    require(newTokenId != 0, "NEW TOKEN ID CANNOT BE ZERO");

    assembly {
      tstore(_transientTokenIdSlot.slot, newTokenId)
    }
  }

  function mint(
    MintParams calldata params
  ) external payable returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) {
    IERC20(params.token0).transferFrom(msg.sender, address(this), params.amount0Desired);
    IERC20(params.token1).transferFrom(msg.sender, address(this), params.amount1Desired);

    _mint(params.recipient, _getTokenIdToMint());
    return (_getTokenIdToMint(), 0, 0, 0);
  }

  function getMintCallData(
    address token0,
    address token1,
    uint256 token0Amount,
    uint256 token1Amount,
    address recipient
  ) external pure returns (bytes memory) {
    return
      abi.encodeWithSignature(
        "mint((address,address,uint24,int24,int24,uint256,uint256,uint256,uint256,address,uint256))",
        token0,
        token1,
        1,
        1,
        1,
        token0Amount,
        token1Amount,
        1,
        1,
        recipient,
        1
      );
  }

  function _getTokenIdToMint() private view returns (uint256 tokenId) {
    assembly {
      let transientTokenId := tload(_transientTokenIdSlot.slot)
      let hasTransientStorage := iszero(transientTokenId)

      // does have transient storage value
      if eq(hasTransientStorage, 0) {
        tokenId := transientTokenId
      }

      // does not have transient storage value
      if eq(hasTransientStorage, 1) {
        tokenId := 1
      }
    }
  }
}
