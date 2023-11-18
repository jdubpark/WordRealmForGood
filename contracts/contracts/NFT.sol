// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinkTokenInterface} from "@chainlink/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink-ccip/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink-ccip/ccip/libraries/Client.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";

import {IWETH} from "./interfaces/tokens/IWETH.sol";
import {INFT} from "./interfaces/INFT.sol";
import {IWordList} from "./interfaces/WordList/IWordList.sol";

contract NFT is INFT, ERC721URIStorage, Ownable {
    ///
    /// NFT variables
    ///

    IWordList public wordList;

    uint256 private tokenIdCounter = 0;

    uint256 public mintCost = 0.01 ether;

    uint64 public destinationChainSelector = 16015286601757825753; // mainnet chain selector

    // token ID => bool (has fulfilled or not)
    mapping(uint256 => bool) public fulfilledDraws;

    // user Address => word list
    mapping(address => string[]) private mintedWords;

    // user Address => bool
    mapping(address => bool) private canMintWords;

    // token ID => sentence
    mapping(uint256 => string) private mintedSentences;

    ///
    /// CCIP variables
    ///

    IRouterClient public immutable ccipRouter;
    LinkTokenInterface public immutable LINK;

    ///
    /// Misc. variables
    ///

    address public treasuryAddressOnMainnet;
    IWETH public immutable WETH;

    constructor(
        string memory _name,
        string memory _symbol,
        address _ccipRouter,
        address _linkToken,
        address _wethToken
    ) Ownable(msg.sender) ERC721(_name, _symbol) {
        // MAKE SURE TO CHANGE THE OPERATOR of WordList to this contract's address
        // by calling setConnectedNFT(address(this)) on WordList so this NFT can get
        // random word from the bank

        LINK = LinkTokenInterface(_linkToken);
        WETH = IWETH(_wethToken);

        ccipRouter = IRouterClient(_ccipRouter);

        LINK.approve(_ccipRouter, type(uint256).max);
        WETH.approve(_ccipRouter, type(uint256).max);
    }

    function mintWords() public {
        if (!canMintWords[msg.sender]) revert AlreadyMintedWords();

        (string[] memory words, ) = wordList.requestWordsFromBank();
        mintedWords[msg.sender] = words;
    }

    function mint(string memory _tokenURI) public payable {
        if (msg.value < mintCost) revert MintCostNotMet();
        if (canMintWords[msg.sender]) revert MustMintWordsBeforeMintNFT();

        // mint a new NFT with (pseudo-random) words from the bank
        _mint(msg.sender, tokenIdCounter);
        _setTokenURI(tokenIdCounter, _tokenURI);

        ++tokenIdCounter;

        canMintWords[msg.sender] = false;
        delete mintedWords[msg.sender];
    }

    function combine(uint256[] memory tokenIds) public {
        // combine multiple NFTs into one
        ++tokenIdCounter;

        string memory sentence = "";
        for (uint256 i = 0; i < tokenIds.length; ) {
            require(
                ownerOf(tokenIds[i]) == msg.sender,
                "NFT: Only owner can combine"
            );

            string memory _sentence = mintedSentences[tokenIds[i]];

            // Concat sentences
            sentence = string(abi.encode(sentence, _sentence));

            _burn(tokenIds[i]);

            unchecked {
                ++i;
            }
        }

        mintedSentences[tokenIdCounter] = sentence;
    }

    ///
    /// Treasury
    ///

    function convertETH2WETH(uint256 amount) external payable {
        WETH.deposit{value: amount}();
    }

    ///
    /// CCIP
    ///

    function sendTreasuryToMainnet() external payable {
        // msg.value is for paying fee, don't deposit that
        WETH.deposit{value: address(this).balance - msg.value}();

        Client.EVM2AnyMessage memory message = getCCIPMessage(
            WETH.balanceOf(address(this))
        );

        uint256 fee = getCCIPFee(message);
        require(msg.value >= fee, "NFT: Not enough fee for CCIP");

        bytes32 messageId = ccipRouter.ccipSend{value: fee}(
            destinationChainSelector,
            message
        );

        emit MessageSent(messageId);
    }

    ///
    /// Storage getters/setters
    ///

    function setMintCost(uint256 _mintCost) external onlyOwner {
        mintCost = _mintCost;
    }

    function setTreasuryAddressOnMainnet(address _treasury) external onlyOwner {
        treasuryAddressOnMainnet = _treasury;
    }

    function setConnectedWordList(address _wordList) external onlyOwner {
        require(
            _wordList != address(0),
            "NFT: Connected WordList cannot be 0x0"
        );

        wordList = IWordList(_wordList);
    }

    function setDestinationChainSelector(
        uint64 _destinationChainSelector
    ) external onlyOwner {
        destinationChainSelector = _destinationChainSelector;
    }

    function getSentence(
        uint256 tokenId
    ) external view returns (string memory) {
        return mintedSentences[tokenId];
    }

    function getWords(address user) external view returns (string[] memory) {
        return mintedWords[user];
    }

    function getCCIPMessage(
        uint256 wethTransferAmount
    ) public view returns (Client.EVM2AnyMessage memory message) {
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);

        tokenAmounts[0] = Client.EVMTokenAmount({
            token: address(WETH),
            amount: wethTransferAmount
        });

        message = Client.EVM2AnyMessage({
            receiver: abi.encode(treasuryAddressOnMainnet),
            data: "",
            tokenAmounts: tokenAmounts,
            extraArgs: "",
            feeToken: address(0) // pay with native token
        });
    }

    function getCCIPFee(
        Client.EVM2AnyMessage memory message
    ) public view returns (uint256 fee) {
        fee = ccipRouter.getFee(destinationChainSelector, message);
    }

    // function getCCIPSupportedTokens(
    //     uint64 chainSelector
    // ) external view returns (address[] memory tokens) {
    //     tokens = ccipRouter.getSupportedTokens(chainSelector);
    // }

    ///
    /// Misc.
    ///

    receive() external payable {}
}
