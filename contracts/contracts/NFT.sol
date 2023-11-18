// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinkTokenInterface} from "@chainlink/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink-ccip/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink-ccip/ccip/libraries/Client.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import {IWETH} from "./interfaces/tokens/IWETH.sol";
import {INFT} from "./interfaces/INFT.sol";
import {IWordList} from "./interfaces/WordList/IWordList.sol";

contract NFT is INFT, ERC721URIStorage, Ownable {
    event MessageSent(bytes32 indexed messageId);

    ///
    /// NFT variables
    ///

    IWordList public wordList;

    uint256 private tokenIdCounter = 0;

    uint256 public mintCost = 0.01 ether;

    // token ID => bool (has fulfilled or not)
    mapping(uint256 => bool) public fulfilledDraws;

    // user Address => word list
    mapping(uint256 => string[]) private mintedWords;

    // user Address => bool
    mapping(uint256 => bool) private canMintWords;

    // token ID => sentence
    mapping(uint256 => string) private mintedSentence;

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

    function getWords() public {
        require(!canMintWords[msg.sender], "NFT: Aalready minted words");

        (string[] memory words, ) = wordList.requestWordsFromBank();
        mintedWords[msg.sender] = words;
    }

    function mint(string memory _tokenURI) public payable {
        require(msg.value >= mintCost, "NFT: Mint cost not met");

        // mint a new NFT with (pseudo-random) words from the bank
        _mint(msg.sender, tokenIdCounter);
        _setTokenURI(_tokenId, _tokenURI);

        ++tokenIdCounter;

        canMintWords[msg.sender] = false;
    }

    function combine(uint256[] memory tokenIds) public {
        // combine multiple NFTs into one
        ++tokenIdCounter;

        uint256 len = 0;
        for (uint256 i = 0; i < tokenIds.length; ) {
            require(
                ownerOf(tokenIds[i]) == msg.sender,
                "NFT: Only owner can combine"
            );

            len += mappedWords[tokenIds[i]].length;

            unchecked {
                ++i;
            }
        }

        string[] memory words = new string[](len);
        for (uint256 i = 0; i < tokenIds.length; ) {
            string[] memory _words = mappedWords[tokenIds[i]];

            for (uint256 j = 0; j < _words.length; ) {
                words[i + j] = _words[j];

                unchecked {
                    ++j;
                }
            }

            _burn(tokenIds[i]);

            unchecked {
                i += _words.length;
            }
        }

        mappedWords[tokenIdCounter] = words;
    }

    function setConnectedWordList(address _wordList) external onlyOwner {
        require(
            _wordList != address(0),
            "NFT: Connected WordList cannot be 0x0"
        );

        wordList = IWordList(_wordList);
    }

    function getMappedWords(
        uint256 tokenId
    ) external view returns (string[] memory) {
        return mappedWords[tokenId];
    }

    ///
    /// CCIP
    ///

    function getSupportedTokens(
        uint64 chainSelector
    ) external view returns (address[] memory tokens) {
        tokens = ccipRouter.getSupportedTokens(chainSelector);
    }

    function sendTreasuryToMainnet() external {
        uint64 destinationChainSelector = 16015286601757825753; // mainnet chain selector

        WETH.deposit{value: address(this).balance}();

        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({
            token: address(WETH),
            amount: WETH.balanceOf(address(this))
        });

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(treasuryAddressOnMainnet),
            data: "",
            tokenAmounts: tokenAmounts,
            extraArgs: "",
            feeToken: address(0) // pay with native token
        });

        uint256 fee = ccipRouter.getFee(destinationChainSelector, message);

        bytes32 messageId;

        messageId = ccipRouter.ccipSend{value: fee}(
            destinationChainSelector,
            message
        );

        emit MessageSent(messageId);
    }

    ///
    /// Storage setters
    ///
    function setMintCost(uint256 _mintCost) external onlyOwner {
        mintCost = _mintCost;
    }

    function setTreasuryAddressOnMainnet(address _treasury) external onlyOwner {
        treasuryAddressOnMainnet = _treasury;
    }

    ///
    /// Misc.
    ///

    receive() external payable {}
}
