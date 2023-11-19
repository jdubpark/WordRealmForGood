// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LinkTokenInterface} from "@chainlink/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink-ccip/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink-ccip/ccip/libraries/Client.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";

import {ICCIP_BnM} from "./interfaces/tokens/ICCIP_BnM.sol";
import {IWETH} from "./interfaces/tokens/IWETH.sol";
import {INFT} from "./interfaces/INFT.sol";
import {IWorldID} from "./interfaces/IWorldID.sol";
import {IWordListVRF} from "./interfaces/WordList/IWordListVRF.sol";
import {ByteHasher} from "./libs/ByteHasher.sol";

contract NFT is INFT, ERC721URIStorage, Ownable {
    using ByteHasher for bytes;

    ///
    /// NFT variables
    ///

    IWordListVRF public wordList;

    uint256 private tokenIdCounter = 0;

    uint256 public mintCost = 0.01 ether;

    uint64 public destinationChainSelector = 16015286601757825753; // mainnet chain selector

    // token ID => bool (has fulfilled or not)
    mapping(uint256 => bool) public fulfilledDraws;

    // user Address => word list
    mapping(address => string[]) private mintedWords;

    // token ID => sentence
    mapping(uint256 => string) private mintedSentences;

    ///
    /// Worldcoin variables
    ///
    /// @dev The World ID instance that will be used for verifying proofs
    IWorldID internal immutable worldIdRouter;

    /// @dev The contract's external nullifier hash
    uint256 internal immutable externalNullifier;

    /// @dev The World ID group ID (always 1)
    uint256 internal immutable groupId = 1;

    /// @dev Whether a nullifier hash has been used already. Used to guarantee an action is only performed once by a single person
    mapping(uint256 => bool) internal nullifierHashes;

    ///
    /// CCIP variables
    ///

    IRouterClient public immutable ccipRouter;
    LinkTokenInterface public immutable LINK;

    ICCIP_BnM public immutable CCIP_BnM;

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
        address _wethToken,
        address _ccipBnMToken,
        address _worldIdRouter,
        string memory _worldcoinAppId,
        string memory _worldcoinActionId
    ) Ownable(msg.sender) ERC721(_name, _symbol) {
        // MAKE SURE TO CHANGE THE OPERATOR of WordList to this contract's address
        // by calling setConnectedNFT(address(this)) on WordList so this NFT can get
        // random word from the bank

        LINK = LinkTokenInterface(_linkToken);
        WETH = IWETH(_wethToken);
        CCIP_BnM = ICCIP_BnM(_ccipBnMToken);

        ccipRouter = IRouterClient(_ccipRouter);

        worldIdRouter = IWorldID(_worldIdRouter);
        externalNullifier = abi
            .encodePacked(abi.encodePacked(_worldcoinAppId).hashToField(), _worldcoinActionId)
            .hashToField();

        LINK.approve(_ccipRouter, type(uint256).max);
        WETH.approve(_ccipRouter, type(uint256).max);
        CCIP_BnM.approve(_ccipRouter, type(uint256).max);
    }

    // function mintWords() public {
    //     if (mintedWords[msg.sender].length > 0) revert AlreadyMintedWords();

    //     (string[] memory words, ) = wordList.requestWordsFromBank();
    //     mintedWords[msg.sender] = words;
    // }

    function mintWords() public {
        if (mintedWords[msg.sender].length > 0) revert AlreadyMintedWords();

        wordList.requestRandomWordFromBank(msg.sender);
    }

    function fulfillMintWords(
        address user,
        string[] memory words
    ) public {
        require(
            msg.sender == address(wordList),
            "NFT: Only WordList can fulfill mintWords"
        );

        mintedWords[user] = words;
    }

    function mint(
        string memory _tokenURI,
        WorldcoinVerifiedAction calldata wva
    ) public payable {
        verifyWithWorldcoin(wva);

        if (msg.value < mintCost) revert MintCostNotMet();
        if (mintedWords[msg.sender].length == 0)
            revert MustMintWordsBeforeMintNFT();

        // mint a new NFT with (pseudo-random) words from the bank
        _mint(msg.sender, tokenIdCounter);
        _setTokenURI(tokenIdCounter, _tokenURI);

        ++tokenIdCounter;

        delete mintedWords[msg.sender];

        // for CCIP test, drip 1 CCIP_BnM for every mint (as treasury)
        CCIP_BnM.drip(address(this));
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
    /// Note: When calling "sendTreasury...", make sure to send ETH along with it
    //        to pay for CCIP gas cost. Get the fee by calling getCCIPFee(getCCIPMessage(...))

    function sendTreasuryToMainnetBnM() external payable {
        Client.EVM2AnyMessage memory message = getCCIPMessage(
            address(CCIP_BnM),
            CCIP_BnM.balanceOf(address(this))
        );

        uint256 fee = getCCIPFee(message);
        require(msg.value >= fee, "NFT: Not enough fee for CCIP");

        bytes32 messageId = ccipRouter.ccipSend{value: fee}(
            destinationChainSelector,
            message
        );

        emit MessageSent(messageId);
    }

    function sendTreasuryToMainnet() external payable {
        // msg.value is for paying fee, don't deposit that
        WETH.deposit{value: address(this).balance - msg.value}();

        Client.EVM2AnyMessage memory message = getCCIPMessage(
            address(WETH),
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
    /// Worldcoin
    ///

    // the verification will revert if the data is incorrect
    function verifyWithWorldcoin(WorldcoinVerifiedAction calldata wva) public {
        address signal = wva.signal;
        uint256 root = wva.root;
        uint256 nullifierHash = wva.nullifierHash;
        uint256[8] memory proof = wva.proof;

        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();

        worldIdRouter.verifyProof(
            root,
            groupId,
            abi.encodePacked(signal).hashToField(),
            nullifierHash,
            externalNullifier,
            proof
        );

        nullifierHashes[nullifierHash] = true;
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

        wordList = IWordListVRF(_wordList);
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
        address transferToken,
        uint256 transferAmount
    ) public view returns (Client.EVM2AnyMessage memory message) {
        require(
            treasuryAddressOnMainnet != address(0),
            "NFT: Treasury not set"
        );

        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);

        tokenAmounts[0] = Client.EVMTokenAmount({
            token: transferToken,
            amount: transferAmount
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
