// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import "./ScriptHelper.sol";

import "../contracts/WordList/WordList.sol";

contract DeployWordList is ScriptHelper {
    function setUp() public {}

    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();

        new WordList();

        vm.stopBroadcast();
    }
}
