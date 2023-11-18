// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import {AutomationCompatibleInterface} from "@chainlink/automation/interfaces/AutomationCompatibleInterface.sol";

interface ISmartTreasury {
    function evaluateWeather() external returns (bytes32 requestId);

    function triggerFundReleaseRequest() external;

    ///
    /// Getters/Setters
    ///

    function setConfig(
        uint64 _subscriptionId,
        uint32 _fulfillGasLimit,
        uint256 _updateInterval,
        address _fundReleaseRecipient
    ) external;

    function setLatitude(string memory _latitude) external;

    function setLongitude(string memory _longitude) external;

    function setMaxReleaseAmountPerCase(
        uint256 _maxReleaseAmountPerCase
    ) external;

    function setMinWindThreshold(uint256 _minWindThreshold) external;

    function setDonId(bytes32 newDonId) external;

    function setFundTokens(address[] memory _fundTokens) external;
}
