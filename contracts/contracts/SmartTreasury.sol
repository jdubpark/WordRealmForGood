// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {VRFConsumerBaseV2} from "@chainlink/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/interfaces/VRFCoordinatorV2Interface.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract SmartTreasury is Ownable {
	string public latitude = "41.008240";
	string public longitude = "28.978359";

	constructor() Ownable(msg.sender) {
		
	}

	function setLatitude(string memory _latitude) public onlyOwner {
		latitude = _latitude;
	}

	function setLongitude(string memory _longitude) public onlyOwner {
		longitude = _longitude;
	}

	function getUrl() public view returns (string memory) {
		return string.concat("https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=", latitude, "&lon=", longitude);
	}
}