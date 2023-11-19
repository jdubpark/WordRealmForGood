// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import "./ScriptHelper.sol";

import "../contracts/NFT.sol";
import "../contracts/interfaces/WordList/IWordListVRF.sol";

contract DeployNFT is ScriptHelper {
    address internal wordList;

    function setUp() public {
        // Note: When deploying NFT, make sure to deploy WordList first or use an existing WordList contract
        wordList = address(0x9C303D0E32072651333F3De1D74DdE6daf1Acc9d);
    }

    function run() external {
        (
            address WETH,
            address LINK,
            address CCIP_BnM,
            address ccipRouter,
            address worldIdRouter
        ) = loadAddresses();

        string
            memory worldcoinAppId = "app_staging_2d47d08eb224ee65b40dacafa16115f5";
        string memory worldcoinActionId = "mint-nft";

        // uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();

        NFT nft = new NFT(
            "WordRealmPublicGood",
            "WordRPG",
            ccipRouter,
            LINK,
            WETH,
            CCIP_BnM,
            worldIdRouter,
            worldcoinAppId,
            worldcoinActionId
        );

        nft.setConnectedWordList(address(wordList));
        IWordListVRF(wordList).setConnectedNFT(address(nft));

        nft.setTreasuryAddressOnMainnet(
            0x6837Cbcd4ff0bCF18222C4090e0536Db6E4909Cd
        );

        vm.stopBroadcast();
    }
}
