// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IWordListBase {
    function replaceWordbank(string[] memory words) external;

    function insertIntoWordbank(string[] memory words) external;

    function removeFromWordbank(uint256[] memory indices) external;

    function readWordbank() external view returns (string[] memory);

    function readWordsize() external view returns (uint256);
}
