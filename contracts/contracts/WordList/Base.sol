// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ConfirmedOwner} from "@chainlink/ConfirmedOwner.sol";

import {INFT} from "../interfaces/INFT.sol";
import {IWordListBase} from "../interfaces/WordList/IWordListBase.sol";

abstract contract WordListBase is IWordListBase, ConfirmedOwner {
    string[] internal wordbank;

    address public connectedNFT;

    // how many words to return, default 5
    uint256 internal wordsize = 5;

    constructor() ConfirmedOwner(msg.sender) {}

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

    //
    // Storage setters
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

    //
    // WordBank functions
    //

    function emptyWordbank() external onlyOwner {
        delete wordbank;
    }

    function replaceWordbank(string[] memory words) external onlyOwner {
        delete wordbank;
        wordbank = words;
    }

    function insertIntoWordbank(string[] memory words) external onlyOwner {
        for (uint256 i = 0; i < words.length; ) {
            wordbank.push(words[i]);
            unchecked {
                ++i;
            }
        }
    }

    function removeFromWordbank(uint256[] memory indices) external onlyOwner {
        // Let N be the cardinality of `indices`.
        // Move N items to the last N indices of the array and then pop N times.
        // Load into memory and assign to storage at the end to save gas.
        string[] memory t_wordbank = wordbank;
        uint256 i = 0;
        uint256 t_wordbank_length = t_wordbank.length;

        for (; i < indices.length; ) {
            uint256 index = indices[i];

            unchecked {
                ++i;
            }

            t_wordbank[index] = t_wordbank[t_wordbank_length - i];
        }

        // Need to load to storage here since we can't pop on memory arrays.
        wordbank = t_wordbank;
        while (i > 0) {
            wordbank.pop();
            unchecked {
                --i;
            }
        }
    }

    function readWordbank() external view override returns (string[] memory) {
        return wordbank;
    }

    function readWordsize() external view override returns (uint256) {
        return wordsize;
    }
}
