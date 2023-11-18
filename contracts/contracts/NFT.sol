// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";

import {INFT} from "./interfaces/INFT.sol";
import {IWordListVRF} from "./interfaces/WordList/IWordListVRF.sol";

contract NFT is INFT, ERC721URIStorage, Ownable {
    IWordListVRF public wordList;

    uint256 private tokenIdCounter = 0;

    // token ID => bool (has fulfilled or not)
    mapping(uint256 => bool) public fulfilledDraws;

    constructor(
        string memory _name,
        string memory _symbol
    ) Ownable(msg.sender) ERC721(_name, _symbol) {
        // MAKE SURE TO CHANGE THE OPERATOR of WordListVRF to this contract's address
        // so this NFT can get random word from the bank
    }

    function mint() public {
        // mint a new NFT with a random word from the bank
        _mint(msg.sender, tokenIdCounter);

        unchecked {
            ++tokenIdCounter;
        }
    }

    function fulfillMint(
        address requester,
        uint256 tokenId,
        string[] memory randomWords
    ) public {
        require(msg.sender == address(wordList), "NFT: Only WordList");
    }

    function fulfillDraw(
        uint256 _tokenId,
        string memory _tokenURI
    ) external onlyOwner {
        require(!fulfilledDraws[_tokenId], "NFT: already fulfilled");

        fulfilledDraws[_tokenId] = true;
        _setTokenURI(_tokenId, _tokenURI);
    }
}
