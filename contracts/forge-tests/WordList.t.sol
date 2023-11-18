// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {WordList} from "../contracts/WordList/WordList.sol";

import {BaseSetup} from "./utils/BaseSetup.sol";

contract WordListTest is BaseSetup {
    WordList public wordList;

    function setUp() public override {
        super.setUp();

        wordList = new WordList();
    }

    function test_Wordbank_Basic() public {
        string[] memory add = new string[](2);
        add[0] = "hello";
        add[1] = "world";
        wordList.insertIntoWordbank(add);

        string[] memory words = wordList.readWordbank();
        assertEq(words.length, 2);
        assertEq(words[0], "hello");
        assertEq(words[1], "world");

        uint256[] memory remove = new uint256[](1);
        remove[0] = 0;
        wordList.removeFromWordbank(remove);
        words = wordList.readWordbank();
        assertEq(words.length, 1);
        assertEq(words[0], "world");

        add[0] = "chain";
        add[1] = "link";
        wordList.replaceWordbank(add);
        words = wordList.readWordbank();
        assertEq(words.length, 2);
        assertEq(words[0], "chain");
        assertEq(words[1], "link");

        delete add;
        add = new string[](1);
        add[0] = "NFT";
        wordList.insertIntoWordbank(add);
        words = wordList.readWordbank();
        assertEq(words.length, 3);
        assertEq(words[2], "NFT");

        wordList.emptyWordbank();
        words = wordList.readWordbank();
        assertEq(words.length, 0);

        delete add;
        add = new string[](3);
        add[0] = "hello";
        add[1] = "world";
        add[2] = "!";
        wordList.insertIntoWordbank(add);
        words = wordList.readWordbank();
        assertEq(words.length, 3);
        assertEq(words[0], "hello");
        assertEq(words[1], "world");
        assertEq(words[2], "!");
    }

    function test_Wordbank_RequestWords() public {
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

        string[] memory wordbank = wordList.readWordbank();
        assertEq(wordbank.length, 13);

        (string[] memory words, ) = wordList
            .requestWordsFromBank();
        // assertEq(requestId, 0);
        assertEq(words.length, wordList.readWordsize());
    }
}
