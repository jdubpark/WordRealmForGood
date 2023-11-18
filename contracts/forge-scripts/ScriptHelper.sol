// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

abstract contract ScriptHelper is Script {
    function loadAddresses()
        public
        view
        returns (
            address WETH,
            address LINK,
            address CCIP_BnM,
            address ccipRouter
        )
    {
        if (block.chainid == 84531) {
            // Base Goerli

            // Tokens
            WETH = 0x4200000000000000000000000000000000000006;
            LINK = 0xD886E2286Fd1073df82462ea1822119600Af80b6;
            CCIP_BnM = 0xbf9036529123DE264bFA0FC7362fE25B650D4B16;

            // Routers
            ccipRouter = 0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D;
        } else {
            console2.log("BaseSetup: chain id %d", block.chainid);
            revert("BaseSetup: unsupported chain ID");
        }
    }
}
