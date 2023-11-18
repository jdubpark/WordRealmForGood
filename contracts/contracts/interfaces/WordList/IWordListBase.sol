// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IWordListBase {
    function replaceWordbank(string[] memory words) external;

    function insertIntoWordbank(string[] memory words) external;

    function removeFromWordbank(uint256[] memory indices) external;

    // Setters/Getters

    function setConnectedNFT(address nft) external;

    function setWordsize(uint256 _wordsize) external;

    function readWordbank() external view returns (string[] memory);

    function readWordsize() external view returns (uint256);
}
