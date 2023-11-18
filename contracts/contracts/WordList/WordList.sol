// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {WordListBase} from "./Base.sol";
import {INFT} from "../interfaces/INFT.sol";
import {IWordList} from "../interfaces/WordList/IWordList.sol";

contract WordList is IWordList, WordListBase {
    uint256 private randNonce = 0;

    constructor() {}

    function requestWordsFromBank()
        external
        onlyOwnerOrConnectedNFT
        returns (string[] memory words, uint256 startIndex)
    {
        uint256 wordbank_len = wordbank.length;
        startIndex = pseudorandom(wordbank_len);

        words = new string[](wordsize);

        for (uint256 i = 0; i < wordsize; ) {
            words[i] = wordbank[(startIndex + i) % wordbank_len];
            unchecked {
                ++i;
            }
        }
    }

    function pseudorandom(uint256 max) internal returns (uint256 rand) {
        rand =
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.chainid,
                        block.timestamp,
                        msg.sender,
                        randNonce
                    )
                )
            ) %
            max;
        randNonce++;
    }
}
