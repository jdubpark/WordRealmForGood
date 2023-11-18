// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Client} from "@chainlink-ccip/ccip/libraries/Client.sol";

interface INFT {
    event MessageSent(bytes32 indexed messageId);
    error AlreadyMintedWords();
    error MintCostNotMet();
    error MustMintWordsBeforeMintNFT();
    error InvalidNullifier();

    struct WorldcoinVerifiedAction {
        address signal;
        uint256 root;
        uint256 nullifierHash;
        uint256[8] proof;
    }

    function mintWords() external;

    function mint(string memory _tokenURI, WorldcoinVerifiedAction calldata wva) external payable;

    ///
    /// CCIP
    ///

    function sendTreasuryToMainnet() external payable;

    function sendTreasuryToMainnetBnM() external payable;

    ///
    /// Getters/Setters
    ///

    function setMintCost(uint256 _mintCost) external;

    function setConnectedWordList(address _wordList) external;

    function setTreasuryAddressOnMainnet(address _treasury) external;

    function getSentence(
        uint256 _tokenId
    ) external view returns (string memory sentence);

    function getWords(
        address user
    ) external view returns (string[] memory words);

    function getCCIPMessage(
        address transferToken,
        uint256 transferAmount
    ) external view returns (Client.EVM2AnyMessage memory message);

    function getCCIPFee(
        Client.EVM2AnyMessage memory message
    ) external view returns (uint256 fee);
}
