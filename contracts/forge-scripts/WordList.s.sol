// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import "./ScriptHelper.sol";

import "../contracts/WordList/WordListVRFAPI3.sol";

contract DeployWordList is ScriptHelper {
    function setUp() public {
        require(block.chainid == 84531, "Only for Base Goerli");
    }

    function run() external {
        address airnode = address(0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd);

        // uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();

        WordListVRFAPI3 wordList = new WordListVRFAPI3(airnode);

        // wordList.setRequestParameters(
        //     airnode,
        //     bytes32(0x94555f83f1addda23fdaa7c74f27ce2b764ed5cc430c66f5ff1bcf39d583da36),
        //     bytes32(0x9877ec98695c139310480b4323b9d474d48ec4595560348a2341218670f7fbc2),
        //     sponsorWallet
        // );

        vm.stopBroadcast();
    }
}
