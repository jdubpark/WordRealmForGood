// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import "./ScriptHelper.sol";

import "../contracts/SmartTreasury.sol";

contract DeploySmartTreasury is ScriptHelper {
    address internal wordList;

    function setUp() public {
        require(block.chainid == 11155111, "Only for Ethereum Sepolia");
    }

    function run() external {
        // Chainlink Sepolia accepts 0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534 as WETH
        // address WETH = 0xE67ABDA0D43f7AC8f37876bBF00D1DFadbB93aaa;
        // address LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
        // address CCIP_BnM = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;
        address functionsRouter = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

        // bytes32("fun-ethereum-sepolia-1")
        bytes32 chainlinkDONId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

        // uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();

        SmartTreasury treasury = new SmartTreasury(
            functionsRouter,
            chainlinkDONId
        );

        treasury.setConfig(
            uint64(1696), // subscription id (Sepolia)
            uint32(300_000), // upkeep callback gas limit (300k wei)
            uint256(86_400), // upkeep interval (86400s = 1 day)
            address(0x2B540f917F5F46d878De2c24fC14CDddcaF967ad) // fund recipient
        );

        vm.stopBroadcast();
    }
}
