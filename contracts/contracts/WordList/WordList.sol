// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {WordListBase} from "./Base.sol";
import {INFT} from "../interfaces/INFT.sol";
// import {IWordListVRF} from "../interfaces/WordList/IWordListVRF.sol";

contract WordList is WordListBase {
    uint256 private randNonce = 0;

    constructor() WordListBase(msg.sender) {}

    // `address` param & `bytes` return are ignored for interface compatibility.
    function requestRandomWordFromBank(
        address
    )
        external
        override
        payable
        onlyOwnerOrConnectedNFT
        returns (bytes32, string[] memory randomWords)
    {
        // 3 => # of categories (landmark, cuisine, carpet)
        randomWords = new string[](wordsize * 3);

        uint256 wbLandmark_len = wordbankLandmark.length;
        uint256 wbCuisine_len = wordbankCuisine.length;
        uint256 wbCarpet_len = wordbankCarpet.length;

        uint256 idxLandmark = pseudorandom(wbLandmark_len) % wbLandmark_len;
        uint256 idxCuisine = pseudorandom(wbCuisine_len) % wbCuisine_len;
        uint256 idxCarpet = pseudorandom(wbCarpet_len) % wbCarpet_len;

        // using the indices above and wordbanks, add three elements starting from
        // each index in each wordbank into randomWords (sum to 9 elements total)
        for (uint256 i = 0; i < wordsize; ) {
            randomWords[i] = wordbankLandmark[
                (idxLandmark + i) % wbLandmark_len
            ];
            randomWords[i + wordsize] = wordbankCuisine[
                (idxCuisine + i) % wbCuisine_len
            ];
            randomWords[i + wordsize * 2] = wordbankCarpet[
                (idxCarpet + i) % wbCarpet_len
            ];
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
