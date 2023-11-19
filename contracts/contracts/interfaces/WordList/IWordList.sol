// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import {IWordListBase} from "./IWordListBase.sol";

interface IWordList {
    function requestWordsFromBank()
        external
        returns (string[] memory words);

    // Setters/Getters

    function replaceWordbank(string memory category, string[] memory words) external;

    function setConnectedNFT(address nft) external;

    function setWordsize(uint256 _wordsize) external;

    function readWordbank(
        string memory category
    ) external view returns (string[] memory);

    function readWordsize() external view returns (uint256);
}
