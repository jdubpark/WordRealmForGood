// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    function deposit() external payable;

    function withdraw(uint amount) external;
}
