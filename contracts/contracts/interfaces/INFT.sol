// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface INFT {
    function fulfillMint(
        address requester,
        uint256 tokenId,
        string[] memory randomWords
    ) external;
}
