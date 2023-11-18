// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface INFT {
    function getWords() external payable;

    function mint(string memory _tokenURI) external payable;

    function setConnectedWordList(address _wordList) external;

    function getMappedWords(
        uint256 _tokenId
    ) external view returns (string[] memory);

    function setTreasuryAddressOnMainnet(address _treasury) external;
}
