// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ConfirmedOwner} from "@chainlink/ConfirmedOwner.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {INFT} from "../interfaces/INFT.sol";
import {IWordListVRF} from "../interfaces/WordList/IWordListVRF.sol";

abstract contract WordListBase is IWordListVRF, ConfirmedOwner {
    string[] internal wordbankLandmark;
    string[] internal wordbankCuisine;
    string[] internal wordbankCarpet;

    address public connectedNFT;

    // how many words to return, default 3
    uint256 internal wordsize = 3;

    constructor(address _owner) ConfirmedOwner(_owner) {}

    modifier onlyConnectedNFT() {
        require(msg.sender == connectedNFT, "WordListVRF: Only Connected NFT");
        _;
    }

    modifier onlyOwnerOrConnectedNFT() {
        require(
            msg.sender == owner() || msg.sender == connectedNFT,
            "WordListVRF: Only Owner or Connected NFT"
        );
        _;
    }

    function requestRandomWordFromBank(
        address
    ) external virtual payable returns (bytes32, string[] memory) {}

    //
    // WordBank functions
    //

    function emptyWordbank(string memory category) external onlyOwner {
        if (Strings.equal(category, "landmark")) {
            delete wordbankLandmark;
        } else if (Strings.equal(category, "cuisine")) {
            delete wordbankCuisine;
        } else if (Strings.equal(category, "carpet")) {
            delete wordbankCarpet;
        } else revert("WordListVRF: Invalid category");
    }

    function replaceWordbank(
        string memory category,
        string[] memory words
    ) external onlyOwner {
        if (Strings.equal(category, "landmark")) {
            delete wordbankLandmark;
            wordbankLandmark = words;
        } else if (Strings.equal(category, "cuisine")) {
            delete wordbankCuisine;
            wordbankCuisine = words;
        } else if (Strings.equal(category, "carpet")) {
            delete wordbankCarpet;
            wordbankCarpet = words;
        } else revert("WordListVRF: Invalid category");
    }

    function readWordbank(
        string memory category
    ) external view override returns (string[] memory) {
        if (Strings.equal(category, "landmark")) return wordbankLandmark;
        else if (Strings.equal(category, "cuisine")) return wordbankCuisine;
        else if (Strings.equal(category, "carpet")) return wordbankCarpet;
        else revert("WordListVRF: Invalid category");
    }

    function readWordsize() external view override returns (uint256) {
        return wordsize;
    }

    //
    // Storage getters/setters
    //

    function setConnectedNFT(address _connectedNFT) external {
        require(
            msg.sender == owner() || msg.sender == connectedNFT,
            "WordListVRF: Only Owner or Connected NFT"
        );
        require(
            _connectedNFT != address(0),
            "WordListVRF: Connected NFT cannot be 0x0"
        );

        connectedNFT = _connectedNFT;
    }

    function setWordsize(uint256 _wordsize) external onlyOwner {
        wordsize = _wordsize;
    }
}
