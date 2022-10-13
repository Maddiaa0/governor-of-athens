// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.10;

import {Script} from "forge-std/Script.sol";

import {AthensFactory} from "../src/AthensFactory.sol";

/// @notice A very simple deployment script
contract Deploy is Script {
    /// @notice The main script entrypoint
    /// @return factory The deployed contract
    function run() external returns (AthensFactory factory) {
        vm.startBroadcast();
        factory = new AthensFactory();
        vm.stopBroadcast();
    }
}
