// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import {IWordListBase} from "./IWordListBase.sol";

interface IWordListVRF {
    function requestRandomWordFromBank(
        address requester
    ) external payable returns (bytes32 requestId);

    function replaceWordbank(string memory category, string[] memory words) external;

    // Setters/Getters

    function setConnectedNFT(address nft) external;

    function setWordsize(uint256 _wordsize) external;

    function readWordbank(string memory category) external view returns (string[] memory);

    function readWordsize() external view returns (uint256);
}
