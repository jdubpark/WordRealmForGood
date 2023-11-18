// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface INFT {
    function mintWords() external;

    function mint(string memory _tokenURI) external payable;

    function setMintCost(uint256 _mintCost) external;

    function setConnectedWordList(address _wordList) external;

    function setTreasuryAddressOnMainnet(address _treasury) external;

    function getSentence(
        uint256 _tokenId
    ) external view returns (string memory sentence);

    function getWords(
        address user
    ) external view returns (string[] memory words);
}
