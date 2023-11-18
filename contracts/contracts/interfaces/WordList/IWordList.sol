// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWordListBase} from "./IWordListBase.sol";

interface IWordList is IWordListBase {
    function requestWordsFromBank()
        external
        returns (string[] memory words, uint256 startIndex);
}
