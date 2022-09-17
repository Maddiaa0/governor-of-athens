

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";

import {AthensFactory} from "../src/AthensFactory.sol";

/// @notice A very simple deployment script
contract Create is Script {

    address compToken = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address compGov = 0xc0Da02939E1441F497fd74F78cE7Decb17B66529;
    uint256 proposalId = 124;
    uint8 vote = 2;

    address factoryAddress = 0xEda20d8344b89bE4cE1c6690F9bA6C181026742e;

    /// @notice The main script entrypoint
    /// @return clone The deployed contract
    function run() external returns (address clone) {
        
        AthensFactory factory = AthensFactory(factoryAddress);
        vm.startBroadcast();
        
        clone = address(factory.createVoterProxy(compToken, compGov, proposalId, vote));

        vm.stopBroadcast();
    }
}
