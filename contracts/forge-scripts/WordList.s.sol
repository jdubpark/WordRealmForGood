// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import "./ScriptHelper.sol";

import "../contracts/WordList/WordList.sol";

contract DeployWordList is ScriptHelper {
    function setUp() public {
        require(block.chainid == 84531, "Only for Base Goerli");
    }

    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();

        WordList wordList = new WordList();

        vm.stopBroadcast();
    }
}
