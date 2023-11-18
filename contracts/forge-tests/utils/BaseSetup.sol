// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {LinkTokenInterface} from "@chainlink/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink-ccip/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {Util} from "./Util.sol";

import {IWETH} from "../../contracts/interfaces/tokens/IWETH.sol";

contract BaseSetup is Test {
    // Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Util internal util;

    IWETH internal WETH;
    LinkTokenInterface internal LINK;
    IERC20 internal CCIP_BnM;

    IRouterClient internal ccipRouter;

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
        vm.label(address(CCIP_BnM), "CCIP_BnM");
    }

    function loadAddresses() public {
        if (block.chainid == 84531) {
            // Base Goerli
            WETH = IWETH(0x4200000000000000000000000000000000000006);
            LINK = LinkTokenInterface(
                0xD886E2286Fd1073df82462ea1822119600Af80b6
            );
            CCIP_BnM = IERC20(0xbf9036529123DE264bFA0FC7362fE25B650D4B16);

            ccipRouter = IRouterClient(
                0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D
            );
        } else {
            console2.log("BaseSetup: chain id %d", block.chainid);
            revert("BaseSetup: unsupported chain ID");
        }
    }
}
