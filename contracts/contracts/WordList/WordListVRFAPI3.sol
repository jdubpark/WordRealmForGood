// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {RrpRequesterV0} from "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {WordListBase} from "./Base.sol";
import {INFT} from "../interfaces/INFT.sol";

contract WordListVRFAPI3 is WordListBase, RrpRequesterV0 {
    event RequestedUint256(bytes32 indexed requestId);
    event ReceivedUint256(bytes32 indexed requestId, uint256 response);
    event RequestedUint256Array(bytes32 indexed requestId, uint256 size);
    event ReceivedUint256Array(bytes32 indexed requestId, uint256[] response);
    event WithdrawalRequested(
        address indexed airnode,
        address indexed sponsorWallet
    );

    struct QRNGAirnodeRequestStatus {
        address requester;
        bool expectFulfill;
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomValues;
        // uint256 tokenId;
        // string[] words;
    }

    //
    // API3 Airnode varaibles
    //

    address public airnode; /// The address of the QRNG Airnode
    bytes32 public endpointIdUint256; /// The endpoint ID for requesting a single random number
    bytes32 public endpointIdUint256Array; /// The endpoint ID for requesting an array of random numbers
    address public sponsorWallet; /// The wallet that will cover the gas costs of the request

    // mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    /* requestId --> requestStatus */
    mapping(bytes32 => QRNGAirnodeRequestStatus) public airnodeRequests;

    constructor(
        address _airnodeRrp
    ) WordListBase(msg.sender) RrpRequesterV0(_airnodeRrp) {}

    // Assumes the subscription is funded sufficiently.
    // `string[] memory` return is ignored for interface compatibility.
    function requestRandomWordFromBank(
        address requester
    )
        external
        override
        payable
        onlyConnectedNFT
        returns (bytes32 requestId, string[] memory)
    {
        requestId = makeRequestUint256Array();

        airnodeRequests[requestId] = QRNGAirnodeRequestStatus({
            exists: true,
            expectFulfill: true,
            fulfilled: false,
            randomValues: new uint256[](0),
            requester: requester
            // tokenId: tokenId,
            // words: new string[](0)
        });
    }

    /// @notice Requests a `uint256[]`
    function makeRequestUint256Array() internal returns (bytes32 requestId) {
        requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256Array,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillUint256Array.selector,
            // Using Airnode ABI to encode the parameters
            abi.encode(bytes32("1u"), bytes32("size"), wordsize)
        );

        emit RequestedUint256Array(requestId, wordsize);
    }

    /// @notice Called by the Airnode through the AirnodeRrp contract to fulfill the request
    function fulfillUint256Array(
        bytes32 requestId,
        bytes calldata data
    ) external onlyAirnodeRrp {
        require(
            airnodeRequests[requestId].expectFulfill,
            "Request ID not known"
        );
        airnodeRequests[requestId].expectFulfill = false;

        uint256[] memory qrngUint256Array = abi.decode(data, (uint256[]));

        string[] memory randomWords = _getRandomWords(qrngUint256Array);

        airnodeRequests[requestId].fulfilled = true;
        airnodeRequests[requestId].randomValues = qrngUint256Array;
        // airnodeRequests[requestId].words = randomWords;

        INFT(connectedNFT).fulfillMintWords(
            airnodeRequests[requestId].requester,
            randomWords
        );

        emit ReceivedUint256Array(requestId, qrngUint256Array);
    }

    function _getRandomWords(
        uint256[] memory qrngUint256Array
    ) internal view returns (string[] memory) {
        // 3 => # of categories (landmark, cuisine, carpet)
        string[] memory randomWords = new string[](wordsize * 3);

        uint256 wbLandmark_len = wordbankLandmark.length;
        uint256 wbCuisine_len = wordbankCuisine.length;
        uint256 wbCarpet_len = wordbankCarpet.length;

        uint256 idxLandmark = qrngUint256Array[0] % wbLandmark_len;
        uint256 idxCuisine = qrngUint256Array[1] % wbCuisine_len;
        uint256 idxCarpet = qrngUint256Array[2] % wbCarpet_len;

        // using the indices above and wordbanks, add three elements starting from
        // each index in each wordbank into randomWords (sum to 9 elements total)
        for (uint256 i = 0; i < wordsize; ) {
            randomWords[i] = wordbankLandmark[
                (idxLandmark + i) % wbLandmark_len
            ];
            randomWords[i + wordsize] = wordbankCuisine[
                (idxCuisine + i) % wbCuisine_len
            ];
            randomWords[i + wordsize * 2] = wordbankCarpet[
                (idxCarpet + i) % wbCarpet_len
            ];
            unchecked {
                ++i;
            }
        }

        return randomWords;
    }

    //
    // Storage getters/setters
    //

    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256,
        bytes32 _endpointIdUint256Array,
        address _sponsorWallet
    ) external onlyOwner {
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        endpointIdUint256Array = _endpointIdUint256Array;
        sponsorWallet = _sponsorWallet;
    }

    function getRequestStatus(
        bytes32 requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(airnodeRequests[requestId].exists, "request not found");
        QRNGAirnodeRequestStatus memory request = airnodeRequests[requestId];
        return (request.fulfilled, request.randomValues);
    }

    ///
    /// Misc.
    ///

    /// @notice To withdraw funds from the sponsor wallet to the contract.
    function withdraw() external onlyOwner {
        airnodeRrp.requestWithdrawal(airnode, sponsorWallet);
    }

    /// @notice To receive funds from the sponsor wallet and send them to the owner.
    receive() external payable {
        payable(owner()).transfer(msg.value);
        emit WithdrawalRequested(airnode, sponsorWallet);
    }
}
