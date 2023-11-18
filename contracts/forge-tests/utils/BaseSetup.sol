// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import {IFunctionsClient} from "@chainlink/functions/dev/v1_0_0/interfaces/IFunctionsClient.sol";
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

    IFunctionsClient internal functionsRouter;

    bytes32 internal chainlinkDONId;

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
        if (block.chainid == 11155111) {
            // Ethereum Sepolia

            // Tokens
            WETH = IWETH(0xE67ABDA0D43f7AC8f37876bBF00D1DFadbB93aaa);
            // Chainlink Sepolia accepts 0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534 as WETH
            LINK = LinkTokenInterface(
                0x779877A7B0D9E8603169DdbD7836e478b4624789
            );
            CCIP_BnM = IERC20(0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05);

            // Routers
            functionsRouter = IFunctionsClient(
                0xb83E47C2bC239B3bf370bc41e1459A34b41238D0
            );
            // bytes32("fun-ethereum-sepolia-1")
            chainlinkDONId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

            vm.label(address(functionsRouter), "Functions Router");
        } else if (block.chainid == 84531) {
            // Base Goerli

            // Tokens
            WETH = IWETH(0x4200000000000000000000000000000000000006);
            LINK = LinkTokenInterface(
                0xD886E2286Fd1073df82462ea1822119600Af80b6
            );
            CCIP_BnM = IERC20(0xbf9036529123DE264bFA0FC7362fE25B650D4B16);

            // Routers
            ccipRouter = IRouterClient(
                0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D
            );

            vm.label(address(ccipRouter), "CCIP Router");
            vm.label(
                0x19b1bac554111517831ACadc0FD119D23Bb14391,
                "EVM2EVMOnRamp"
            );
        } else {
            console2.log("BaseSetup: chain id %d", block.chainid);
            revert("BaseSetup: unsupported chain ID");
        }
    }
}
