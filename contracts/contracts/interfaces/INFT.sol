// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface INFT {
    function mint() external payable;

    function fulfillMint(
        address requester,
        uint256 tokenId,
        string[] memory randomWords
    ) external;

    function fulfillDraw(uint256 _tokenId, string memory _tokenURI) external;

    function setConnectedWordList(address _wordList) external;

    function getMappedWords(
        uint256 _tokenId
    ) external view returns (string[] memory);

    function setTreasuryAddressOnMainnet(address _treasury) external;
}
