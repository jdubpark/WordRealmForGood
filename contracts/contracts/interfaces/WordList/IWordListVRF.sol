// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWordListBase} from "./IWordListBase.sol";

interface IWordListVRF is IWordListBase {
    function requestRandomWordFromBank(
        address requester,
        uint256 tokenId
    ) external payable returns (uint256 requestId);
}
