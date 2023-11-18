// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {VRFConsumerBaseV2} from "@chainlink/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/interfaces/VRFCoordinatorV2Interface.sol";

import {WordListBase} from "./Base.sol";
import {INFT} from "../interfaces/INFT.sol";
import {IWordListVRF} from "../interfaces/WordList/IWordListVRF.sol";

contract WordListVRFAPI3 is IWordListVRF, WordListBase, VRFConsumerBaseV2 {
    event RequestSent(uint256 requestId, uint32 numValues);
    event RequestFulfilled(uint256 requestId, string[] randomWords);

    struct RequestStatus {
        address requester;
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomValues;
        uint256 tokenId;
        string[] words;
    }

    //
    // Chainlink VRF variables
    //

    uint64 private vrfSubscriptionId;

    /* requestId --> requestStatus */
    mapping(uint256 => RequestStatus) public vrfRequests;

    VRFCoordinatorV2Interface public VrfCoordinator;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // See https://docs.chain.link/vrf/v2/subscription/supported-networks#arbitrum-goerli-testnet
    bytes32 private vrfKeyHash;

    // Max on Arbitrum Goerli: 2_500_000
    uint32 public vrfCallbackGasLimit = 1_000_000;

    constructor(
        address _vrfCoordinator,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        VrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWordFromBank(
        address requester,
        uint256 tokenId
    ) external payable onlyConnectedNFT returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = VrfCoordinator.requestRandomWords(
            vrfKeyHash,
            vrfSubscriptionId,
            // Request confirmations, hardcoded to 1.
            1,
            vrfCallbackGasLimit,
            // How many random values to retrieve in a request. Since it's always 1,
            // directly encode it instead of saving & accessing it from storage.
            1
        );

        vrfRequests[requestId] = RequestStatus({
            exists: true,
            fulfilled: false,
            randomValues: new uint256[](0),
            requester: requester,
            tokenId: tokenId,
            words: new string[](0)
        });

        emit RequestSent(requestId, 1);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(vrfRequests[_requestId].exists, "request not found");

        vrfRequests[_requestId].fulfilled = true;
        vrfRequests[_requestId].randomValues = _randomWords;

        uint256 wordbank_len = wordbank.length;
        uint256 randomIndex = _randomWords[0] % wordbank_len;
        string[] memory words = new string[](wordsize);

        for (uint256 i = 0; i < wordsize; ) {
            words[i] = wordbank[(randomIndex + i) % wordbank_len];
            unchecked {
                ++i;
            }
        }

        vrfRequests[_requestId].words = words;

        // Remove the selected word from the bank.
        // Since ordering in the wordbank array doesn't matter,
        // swap the selected index with the last element, and then
        // pop the last element.
        // wordbank[randomIndex] = wordbank[wordbank.length - 1];
        // wordbank.pop();

        revert("fulfillmint not in");
        // INFT(connectedNFT).fulfillMint(
        //     vrfRequests[_requestId].requester,
        //     vrfRequests[_requestId].tokenId,
        //     words
        // );

        emit RequestFulfilled(_requestId, words);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(vrfRequests[_requestId].exists, "request not found");
        RequestStatus memory request = vrfRequests[_requestId];
        return (request.fulfilled, request.randomValues);
    }

    //
    // Storage setters
    //

    function setVrfCallbackGasLimt(uint32 limit) external onlyOwner {
        vrfCallbackGasLimit = limit;
    }
}
