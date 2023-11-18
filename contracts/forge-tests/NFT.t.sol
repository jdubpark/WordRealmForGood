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

        string[] memory words = nft.getWords(address(alice));
        assertEq(words.length, wordList.readWordsize());

        nft.mint{value: 0.1 ether}("ipfs://url/image");

        vm.stopPrank();
    }

    function test_Integration() public {
        fillWordlist();

        //
        // Mint as Alice
        vm.startPrank(alice);

        uint256 alicePays = 0.1 ether;

        string[] memory words = nft.getWords(address(alice));
        assertEq(words.length, wordList.readWordsize());

        string memory imageUri = "ipfs://url/image-alice";
        nft.mint{value: alicePays}(imageUri);

        string memory uri = nft.tokenURI(0);
        assertEq(uri, imageUri);

        vm.stopPrank();

        //
        // Mint as Bob
        vm.startPrank(bob);

        uint256 bobPays = 0.2 ether;
        imageUri = "ipfs://url/image-bob";

        // vm.expectRevert(INFT.MustMintWordsBeforeMintNFT.selector);
        // vm.expectRevert(bytes4(keccak256("MustMintWordsBeforeMintNFT()")));
        // nft.mint{value: 0}(imageUri);

        words = nft.getWords(address(bob));
        assertEq(words.length, wordList.readWordsize());

        // vm.expectRevert(INFT.AlreadyMintedWords.selector);
        // nft.getWords(address(bob));

        // vm.expectRevert(INFT.MintCostNotMet.selector);
        // nft.mint{value: 0}(imageUri);

        nft.mint{value: bobPays}(imageUri);

        uri = nft.tokenURI(0);
        assertEq(uri, imageUri);

        vm.stopPrank();

        //
        // Contract balance validation post Mints
        assertEq(address(nft).balance, alicePays + bobPays);

        //
        // CCIP

        // vm.expectEmit();
        // emit IWETH.Deposit(address(nft), address(this).balance);

        uint256 fee = nft.getCCIPFee(nft.getCCIPMessage(alicePays + bobPays));
        console2.log("fee", fee);
        nft.sendTreasuryToMainnet{value: fee}();
    }
}
