// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {AutomationCompatibleInterface} from "@chainlink/automation/AutomationCompatible.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/interfaces/VRFCoordinatorV2Interface.sol";
import {FunctionsClient} from "@chainlink/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";
import {ConfirmedOwner} from "@chainlink/shared/access/ConfirmedOwner.sol";
import {VRFConsumerBaseV2} from "@chainlink/VRFConsumerBaseV2.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {ISmartTreasury} from "./interfaces/ISmartTreasury.sol";
import {IPUSHCommInterface} from "./interfaces/IPUSHCommInterface.sol";

// import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract SmartTreasury is
    ISmartTreasury,
    FunctionsClient,
    ConfirmedOwner,
    AutomationCompatibleInterface
{
    using FunctionsRequest for FunctionsRequest.Request;

    error UnexpectedRequestID(bytes32 requestId);
    event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

    event WeatherInfoReceived(
        bytes32 indexed requestId,
        bool triggerFundRelease
    );
    event RequestFailed(bytes error);

    string public latitude = "41.008240";
    string public longitude = "28.978359";

    uint256 public maxReleaseAmountPerCase = 0.01 ether;
    uint256 public minWindThreshold = 10; // 10 is

    bool public isReleaseTriggered;
    address public fundReleaseRecipient;
    address[] public fundTokens;

    // State variables for Chainlink Functions
    bytes32 public s_donId; // DON ID for the Functions DON to which the requests are sent
    uint64 private s_subscriptionId; // Subscription ID for the Chainlink Functions
    uint32 private s_fulfillGasLimit; // Gas limit for the Chainlink Functions callbacks

    // State variables for Chainlink Automation
    uint256 public s_updateInterval;
    uint256 public s_lastUpkeepTimeStamp;
    uint256 public s_upkeepCounter;
    uint256 public s_responseCounter;
    bytes32 public s_lastRequestId;

    // Chainlink Functions script soruce code
    string private constant CHAINLINK_FUNCTIONS_SOURCE =
        // solhint-disable-next-line
        "const lon = args[0], lat = args[1], threshold = args[2]; const url = 'https://api.met.no/weatherapi/locationforecast/2.0/compact'; const forecastRes = await Functions.makeHttpRequest({ url: url, params: { lat: lat, lon: lon }}); if (forecastRes.error) { throw Error(`Request failed. Read message: ${forecastRes.error}`); } const data = forecastRes['data']; if (data.Response === 'Error') { throw Error(`Functional error. Read message: ${data.Message}`); } let forecasts = data['properties']['timeseries']; const lookStart = 432_000 * 1000 + Date.now(); forecasts = forecasts.filter((x) => { const ts = (new Date(x['time'])).getTime(); return ts > lookStart; }); let triggered = false; for (const forecast of forecasts) { const windSpeed = forecast['data']['instant']['details']['wind_speed']; let sym = 'n/a'; if ('next_6_hours' in forecast['data']) { sym = forecast['data']['next_6_hours']['summary']['symbol_code']; } else if ('next_12_hours' in forecast['data']) { sym = forecast['data']['next_12_hours']['summary']['symbol_code']; } if (windSpeed >= threshold || sym == 'hurricane') { triggered = true; break; }} return Functions.encodeUint256(triggered ? 1 : 0);";

    constructor(
        address _router,
        bytes32 _donId
    ) FunctionsClient(_router) ConfirmedOwner(msg.sender) {
        s_donId = _donId;
        s_lastUpkeepTimeStamp = 0;
    }

    function evaluateWeather() public returns (bytes32 requestId) {
        string[] memory args = new string[](3);
        args[0] = latitude;
        args[1] = longitude;
        args[2] = Strings.toString(minWindThreshold);

        requestId = _sendRequest(args);
    }

    // For now, it's directly released without intermediary verification step.
    // But we could use EAS to verify in the middle using another data source.
    function triggerFundReleaseRequest() public {
        require(isReleaseTriggered, "SmartTresury: Weather trigger is off");
        isReleaseTriggered = false;

        for (uint256 i = 0; i < fundTokens.length; ) {
            IERC20 fundToken = IERC20(fundTokens[i]);
            uint256 bal = fundToken.balanceOf(address(this));
            uint256 maxRelease = bal > maxReleaseAmountPerCase
                ? maxReleaseAmountPerCase
                : bal;
            fundToken.transfer(fundReleaseRecipient, maxRelease);

            unchecked {
                ++i;
            }
        }

        // Push notification
        IPUSHCommInterface(0x0C34d54a09CFe75BCcd878A469206Ae77E0fe6e7)
            .sendNotification(
                0xbF57d398b7a166E255c0Bf83f6e9C322d12FB00a, // from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel
                address(this), // to recipient, put address(this) in case you want Broadcast or Subset. For targeted put the address to which you want to send
                bytes(
                    string(
                        // We are passing identity here: https://push.org/docs/notifications/notification-standards/notification-standards-advance/#notification-identity
                        abi.encodePacked(
                            "0", // this represents minimal identity, learn more: https://push.org/docs/notifications/notification-standards/notification-standards-advance/#notification-identity
                            "+", // segregator
                            "1", // define notification type:  https://push.org/docs/notifications/build/types-of-notification (1, 3 or 4) = (Broadcast, targeted or subset)
                            "+", // segregator
                            "[Disaster Relief Fund] Dispatched", // this is notificaiton title
                            "+", // segregator
                            "Based on the forecasted weather data in the next 10 days, we have dispatched funding for local disaster reliefs to prepare in advance." // notification body
                        )
                    )
                )
            );
    }

    function _processResponse(
        bytes32 requestId,
        bytes memory response
    ) private {
        isReleaseTriggered = uint256(bytes32(response)) == 1;
        emit WeatherInfoReceived(requestId, isReleaseTriggered);

        if (isReleaseTriggered) triggerFundReleaseRequest();
    }

    ///
    /// Chainlink Automations
    ///

    function checkUpkeep(
        bytes memory
    ) public view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded =
            (block.timestamp - s_lastUpkeepTimeStamp) > s_updateInterval;
    }

    /// Anyone can call this function, but primarily it's Chainlink Automation
    /// calling it in interval.
    function performUpkeep(bytes calldata) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        require(upkeepNeeded, "Time interval not met");
        s_lastUpkeepTimeStamp = block.timestamp;
        s_upkeepCounter = s_upkeepCounter + 1;

        s_lastRequestId = evaluateWeather();
    }

    ///
    /// Chainlink Functions
    ///

    /**
     * @notice Triggers an on-demand Functions request
     * @param args String arguments passed into the source code and accessible via the global variable `args`
     */
    function _sendRequest(
        string[] memory args
    ) internal returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequest(
            FunctionsRequest.Location.Inline,
            FunctionsRequest.CodeLanguage.JavaScript,
            CHAINLINK_FUNCTIONS_SOURCE
        );

        if (args.length > 0) req.setArgs(args);

        // call parent _sendRequest
        requestId = _sendRequest(
            req.encodeCBOR(),
            s_subscriptionId,
            s_fulfillGasLimit,
            s_donId
        );
    }

    /**
     * @notice Fulfillment callback function
     * @param requestId The request ID, returned by sendRequest()
     * @param response Aggregated response from the user code
     * @param err Aggregated error from the user code or from the execution pipeline
     * Either response or error parameter will be set, but never both
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (err.length > 0) {
            emit RequestFailed(err);
            return;
        }
        _processResponse(requestId, response);
    }

    ///
    /// Storage getters/setters
    ///

    // function getUrl() public view returns (string memory) {
    //     return
    //         string.concat(
    //             "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=",
    //             latitude,
    //             "&lon=",
    //             longitude
    //         );
    // }

    /**
   * @notice Sets the bytes representing the CBOR-encoded FunctionsRequest.Request that is sent when performUpkeep is called

   * @param _subscriptionId The Functions billing subscription ID used to pay for Functions requests
   * @param _fulfillGasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @param _updateInterval Time interval at which Chainlink Automation should call performUpkeep
   */
    function setConfig(
        uint64 _subscriptionId,
        uint32 _fulfillGasLimit,
        uint256 _updateInterval,
        address _fundReleaseRecipient
    ) external onlyOwner {
        require(_fundReleaseRecipient != address(0), "a0");

        s_updateInterval = _updateInterval;
        s_subscriptionId = _subscriptionId;
        s_fulfillGasLimit = _fulfillGasLimit;

        fundReleaseRecipient = _fundReleaseRecipient;
    }

    function setLatitude(string memory _latitude) public onlyOwner {
        latitude = _latitude;
    }

    function setLongitude(string memory _longitude) public onlyOwner {
        longitude = _longitude;
    }

    function setMaxReleaseAmountPerCase(
        uint256 _maxReleaseAmountPerCase
    ) public onlyOwner {
        maxReleaseAmountPerCase = _maxReleaseAmountPerCase;
    }

    function setMinWindThreshold(uint256 _minWindThreshold) public onlyOwner {
        minWindThreshold = _minWindThreshold;
    }

    function setDonId(bytes32 newDonId) external onlyOwner {
        s_donId = newDonId;
    }

    function setFundTokens(address[] memory _fundTokens) external onlyOwner {
        fundTokens = _fundTokens;
    }
}
