// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {SmartTreasury} from "../contracts/SmartTreasury.sol";

import {BaseSetup} from "./utils/BaseSetup.sol";

contract SmartTreasuryTest is BaseSetup {
    SmartTreasury public treasury;

    function setUp() public override {
        super.setUp();

        treasury = new SmartTreasury(address(functionsRouter), chainlinkDONId);

        treasury.setConfig(
            uint64(1696), // subscription id (Sepolia)
            uint32(300_000), // upkeep callback gas limit (300k wei)
            uint256(86_400), // upkeep interval (86400s = 1 day)
            address(0x2B540f917F5F46d878De2c24fC14CDddcaF967ad) // fund recipient
        );
    }

    function test_SmartTreasury_EvaluateWeather_Request() public {
        treasury.evaluateWeather();
    }
}
