// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {Util} from "./Util.sol";

import {IWETH} from "../../contracts/interfaces/tokens/IWETH.sol";

contract BaseSetup is Test {
    // Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Util internal util;

    IWETH internal WETH;
    IERC20 internal LINK;

    address payable[] internal users;
    address internal alice;
    address internal bob;

    function setUp() public virtual {
        loadAddresses();

        util = new Util();
        users = util.createUsers(2);

        alice = users[0];
        vm.label(alice, "Alice");

        bob = users[1];
        vm.label(bob, "Bob");

        vm.label(address(WETH), "WETH");
        vm.label(address(LINK), "LINK");
    }

    function loadAddresses() public {
        if (block.chainid == 421613) {
            // Arbitrum Goerli
            // https://goerli.arbiscan.io/token/0xee01c0cd76354c383b8c7b4e65ea88d00b06f36f
            WETH = IWETH(0xEe01c0CD76354C383B8c7B4e65EA88D00B06f36f);
            // https://sepolia.etherscan.io/token/0xd14838A68E8AFBAdE5efb411d5871ea0011AFd28
            LINK = IERC20(0xd14838A68E8AFBAdE5efb411d5871ea0011AFd28);
        } else {
            console2.log("BaseSetup: chain id %d", block.chainid);
            revert("BaseSetup: unsupported chain ID");
        }
    }
}
