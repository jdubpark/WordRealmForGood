// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {NFT} from "../contracts/NFT.sol";
import {WordList} from "../contracts/WordList/WordList.sol";

import {BaseSetup} from "./utils/BaseSetup.sol";

contract NFTTest is BaseSetup {
    WordList public wordList;
    NFT public nft;

    function setUp() public override {
        super.setUp();

        wordList = new WordList();
        nft = new NFT(
            "Test",
            "TEST",
            address(ccipRouter),
            address(LINK),
            address(WETH)
        );

        nft.setConnectedWordList(address(wordList));
        wordList.setConnectedNFT(address(nft));
    }

    function test_NFT_Mint() public {
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

        vm.startPrank(alice);

        nft.mint{value: 0.1 ether}("ipfs://url/image");

        string[] memory words = nft.getWords(address(alice));

        assertEq(words.length, wordList.readWordsize());

        vm.stopPrank();
    }
}
