// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import { CleisthenesVoter } from "./CleisthenesVoter.sol";



error NotBridge();

/// @title Greeter
contract CliesthenesFactory {

  address constant bridgeContractAddress = 0x000;

  CleisthenesVoter public implementation;

  
  uint64 public nextAvailableSlot; 
  mapping(uint64 => address) public voterProxies;
  mapping(address => address) public syntheticVoterTokens;
  event CliesthenesVoterCreated(uint64 indexed auxData, address indexed govenorAddress, address indexed proposalId, address shadowCourtVoterAddress, uint8 vote);


  modifier onlyBridge() {
    if (!(msg.sender == bridgeContractAddress)){
      revert NotBridge();
    } 
    _;
  }


  constructor() {
    implementation = new CleisthenesVoter();
    cloneErc20Implementation = new ERC20();
  }


  function createVoter(
    address _tokenAddress,
    address _governorAddress,
    uint256 _proposalId,
    uint8 _vote
  ) external returns (CleisthenesVoter clone) {
    // Encode the immutable args to be appended to the end of the clone bytecode
    bytes memory immutableArgs = abi.encode(
      address(this),
      _governorAddress,
      _proposalId,
      _vote
    );

    // Check if the underlying token has an erc20 token, if no create it.
    if (syntheticVoterTokens[_tokenAddress] == 0) {
      syntheticVoterTokens[_tokenAddress] = createSyntheticVoterToken(_tokenAddress);
    } 

    // Store the immutable args in the mapping
    clone = CliesthenesVoter(address(implementation)).clone(immutableArgs);
    
    // cache next available slot in memory
    uint64 _nextAvailableSlot = nextAvailableSlot;
    voterProxies[_nextAvailableSlot] = address(clone);
    
    // Emit that a voter event is created for the front end
    emit CliesthenesVoterCreated(_nextAvailableSlot, govenorAddress, proposalId, shadowCourtVoterAddress, vote);
  
    // Increment the next available slot
    nextAvailableSlot = ++_nextAvailableSlot;
  }


  // Called by the bridge contract to get the proxy address of a vote - can only be called by the bridge
  function allocateVote(uint64 _auxData) external onlyBridge returns (CliesthenesVoter voterClone) {
    
    // TODO: receive the voting token and return an erc20 representing it to the shadow voter

    // Store voter clone in memory
    voterClone = CliesthenesVoter(voterProxies[_auxData]);
  }


  // Deploy an erc20 factory to represent the tokens in the votes i.e. zkvComp, zkvUni
  function createSyntheticVoterToken(address _underlyingToken) {
    // Use clone deteministic to do this?
  }

  

}