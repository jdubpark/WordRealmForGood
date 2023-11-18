// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {IERC20} from "./IERC20.sol";

interface ICCIP_BnM is IERC20 {
    function drip(address to) external;
}
