// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// PUSH Comm Contract Interface
interface IPUSHCommInterface {
    function sendNotification(
        address _channel,
        address _recipient,
        bytes calldata _identity
    ) external;
}
