// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {CleisthenesFactory} from "../src/CleisthenesFactory.sol";

contract CleisthenesFactoryTest is Test {
    using stdStorage for StdStorage;

    CleisthenesFactory factory;

    event GMEverybodyGM();

    function setUp() external {
        factory = new CleisthenesFactory();
    }

    // VM Cheatcodes can be found in ./lib/forge-std/src/Vm.sol
    // Or at https://github.com/foundry-rs/forge-std
    function testDeployFactory() external {
        // slither-disable-next-line reentrancy-events,reentrancy-benign
    }
}
