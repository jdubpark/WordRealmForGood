// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {console2} from "forge-std/console2.sol";

import {NFT} from "../contracts/NFT.sol";
import {WordList} from "../contracts/WordList/WordList.sol";
import {INFT} from "../contracts/interfaces/INFT.sol";
// import {IWETH} from "../contracts/interfaces/tokens/IWETH.sol";

import {BaseSetup} from "./utils/BaseSetup.sol";

contract NFTTest is BaseSetup {
    WordList public wordList;
    NFT public nft;

    INFT.WorldcoinVerifiedAction public wva;

    function setUp() public override {
        super.setUp();

        string
            memory worldcoinAppId = "app_staging_2d47d08eb224ee65b40dacafa16115f5";
        string memory worldcoinActionId = "mint-nft";

        wordList = new WordList();
        nft = new NFT(
            "Test",
            "TEST",
            address(ccipRouter),
            address(LINK),
            address(WETH),
            address(CCIP_BnM),
            worldIdRouter,
            worldcoinAppId,
            worldcoinActionId
        );

        nft.setConnectedWordList(address(wordList));
        wordList.setConnectedNFT(address(nft));

        // Random address as recipient for test
        nft.setTreasuryAddressOnMainnet(
            0x2B540f917F5F46d878De2c24fC14CDddcaF967ad
        );

        uint256[8] memory dummyProofs;
        wva = INFT.WorldcoinVerifiedAction({
            signal: address(0),
            root: 0,
            nullifierHash: 0,
            proof: dummyProofs
        });
    }

    function fillWordlist() internal {
        string[] memory add = new string[](13);
        add[0] = "hello";
        add[1] = "world";
        add[2] = "!";
        add[3] = "welcome";
        add[4] = "to";
        add[5] = "test";
        add[6] = ".";
        add[7] = "public";
        add[8] = "good";
        add[9] = "funding";
        add[10] = "is";
        add[11] = "awesome";
        add[12] = ":)";
        wordList.insertIntoWordbank(add);
    }

    function test_NFT_Mint() public {
        fillWordlist();

        vm.startPrank(alice);

        nft.mintWords();

        string[] memory words = nft.getWords(address(alice));
        assertEq(words.length, wordList.readWordsize());

        nft.mint{value: 0.1 ether}("ipfs://url/image", wva);

        vm.stopPrank();
    }

    function test_Integration() public {
        fillWordlist();

        //
        // Mint as Alice
        vm.startPrank(alice);

        uint256 tokenId = 0;
        uint256 alicePays = 0.1 ether;

        nft.mintWords();

        string[] memory words = nft.getWords(address(alice));
        assertEq(words.length, wordList.readWordsize());

        string memory imageUri = "ipfs://url/image-alice";
        nft.mint{value: alicePays}(imageUri, wva);

        string memory uri = nft.tokenURI(tokenId);
        assertEq(uri, imageUri);

        vm.stopPrank();

        tokenId++;

        //
        // Mint as Bob
        vm.startPrank(bob);

        uint256 bobPays = 0.2 ether;
        imageUri = "ipfs://url/image-bob";

        // vm.expectRevert(INFT.MustMintWordsBeforeMintNFT.selector);
        // vm.expectRevert(bytes4(keccak256("MustMintWordsBeforeMintNFT()")));
        // nft.mint{value: 0}(imageUri);

        nft.mintWords();

        words = nft.getWords(address(bob));
        assertEq(words.length, wordList.readWordsize());

        // vm.expectRevert(INFT.AlreadyMintedWords.selector);
        // nft.getWords(address(bob));

        // vm.expectRevert(INFT.MintCostNotMet.selector);
        // nft.mint{value: 0}(imageUri);

        nft.mint{value: bobPays}(imageUri, wva);

        uri = nft.tokenURI(tokenId);
        assertEq(uri, imageUri);

        vm.stopPrank();

        //
        // Contract balance validation post Mints
        assertEq(address(nft).balance, alicePays + bobPays);

        //
        // CCIP

        // vm.expectEmit();
        // emit IWETH.Deposit(address(nft), address(this).balance);

        uint256 fee = nft.getCCIPFee(
            nft.getCCIPMessage(
                address(CCIP_BnM),
                CCIP_BnM.balanceOf(address(nft))
            )
        );
        console2.log("fee", fee);
        nft.sendTreasuryToMainnetBnM{value: fee}();
    }
}
