// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import "./ScriptHelper.sol";

import "../contracts/NFT.sol";
import "../contracts/interfaces/WordList/IWordList.sol";

contract DeployNFT is ScriptHelper {
    address internal wordList;

    function setUp() public {
        // Note: When deploying NFT, make sure to deploy WordList first or use an existing WordList contract
        wordList = address(0x5ff0e42Ec998aA787561111F112917d7Ae4a64Cb);
    }

    function run() external {
        (
            address WETH,
            address LINK,
            address CCIP_BnM,
            address ccipRouter
        ) = loadAddresses();

        // uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();

        NFT nft = new NFT("WordRealmPublicGood", "WordRPG", ccipRouter, LINK, WETH, CCIP_BnM);

        nft.setConnectedWordList(address(wordList));
        IWordList(wordList).setConnectedNFT(address(nft));

        // Random address as recipient for now
        nft.setTreasuryAddressOnMainnet(
            0x2B540f917F5F46d878De2c24fC14CDddcaF967ad
        );

        vm.stopBroadcast();
    }
}
