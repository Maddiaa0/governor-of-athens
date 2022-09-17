// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {CleisthenesVoter} from "./CleisthenesVoter.sol";
import {CleisthenesVoterTokenERC20} from "./CleisthenesVoterTokenERC20.sol";

import {GovernorBravoDelegateInterface} from "./interfaces/GovernorBravoDelegateInterface.sol";

import {ClonesWithImmutableArgs} from "clones-with-immutable-args/ClonesWithImmutableArgs.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

error NotBridge();

enum ProposalState {
    Pending,
    Active,
    Canceled,
    Defeated,
    Succeeded,
    Queued,
    Expired,
    Executed
}

/// @title Greeter
contract CleisthenesFactory {
    using ClonesWithImmutableArgs for address;

    address constant bridgeContractAddress = address(0x000);

    // make immutable?
    CleisthenesVoter public implementation;
    CleisthenesVoterTokenERC20 public cloneErc20Implementation;

    uint64 public nextAvailableSlot;
    mapping(uint64 => CleisthenesVoter) public voterProxies;
    mapping(address => CleisthenesVoterTokenERC20) public syntheticVoterTokens;

    // Events
    event CliesthenesVoterCreated(
        uint64 indexed auxData,
        address indexed governorAddress,
        uint256 indexed proposalId,
        address voterCloneAddress,
        uint8 vote
    );
    event CliesthenesVoterTokenERC20Created(address indexed underlyingToken, address indexed syntheticToken);

    modifier onlyBridge() {
        if (msg.sender != bridgeContractAddress) {
            revert NotBridge();
        }
        _;
    }

    constructor() {
        implementation = new CleisthenesVoter();
        cloneErc20Implementation = new CleisthenesVoterTokenERC20(address(this));
    }

    function createVoterProxy(address _tokenAddress, address _governorAddress, uint256 _proposalId, uint8 _vote)
        external
        returns (CleisthenesVoter clone)
    {
        // Encode the immutable args to be appended to the end of the clone bytecode
        bytes memory immutableArgs = abi.encode(address(this), _governorAddress, _proposalId, _vote);

        // Check if the underlying token has an erc20 token, if no create it.
        if (address(syntheticVoterTokens[_tokenAddress]) == address(0x0)) {
            syntheticVoterTokens[_tokenAddress] = createSyntheticVoterToken(_tokenAddress);
        }

        // Store the immutable args in the mapping
        clone = CleisthenesVoter(address(implementation).clone(immutableArgs));

        // cache next available slot in memory
        uint64 _nextAvailableSlot = nextAvailableSlot;
        voterProxies[_nextAvailableSlot] = clone;

        // Emit that a voter event is created for the front end
        emit CliesthenesVoterCreated(_nextAvailableSlot, _governorAddress, _proposalId, address(clone), _vote);

        // Increment the next available slot
        nextAvailableSlot = ++_nextAvailableSlot;
    }

    // Called by the bridge contract to get the proxy address of a vote - can only be called by the bridge
    /**
     * @param _auxData _aux bridge data, this tells us which voter proxy we are targeting
     * @param _totalInputValue The total number of input tokens being vote with
     */
    function allocateVote(uint64 _auxData, uint256 _totalInputValue) external onlyBridge {
        // TODO: receive the voting token and return an erc20 representing it to the shadow voter

        // Transfer the number of input tokens to the voter proxy
        // Store voter clone in memory
        CleisthenesVoter voterClone = voterProxies[_auxData];
        address _underlyingToken = voterClone.underlyingToken();

        // Send the underlying token to the voter proxy
        ERC20(_underlyingToken).transfer(address(voterClone), _totalInputValue);

        // Send the correct number of voter tokens to the bridge
        CleisthenesVoterTokenERC20 _syntheticToken = syntheticVoterTokens[_underlyingToken];
        _syntheticToken.mint(msg.sender, _totalInputValue);
    }

    // function redeemVotingTokens(uint256 _totalInputValue) onlyBridge {
    //   // Return the number of voter tokens back to the bridge

    //   // Check that the factory has enough tokens to return to the bridge

    // }

    function returnUnderlyingToFactory(uint64 _proxyId) external {
        // If the vote has finished then return the tokens back to the factory so they can be withdrawn
    }

    // Call the comptroller contract and see if the vote has expired
    function hasVoteExpired(address _tokenAddress, uint256 _proposalId) external returns (bool validState) {
        GovernorBravoDelegateInterface.ProposalState returnedProposalState =
            GovernorBravoDelegateInterface(_tokenAddress).state(_proposalId);
        // TODO: more gas efficient way to do this?
        validState = (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Succeeded)
            || (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Expired)
            || (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Canceled)
            || (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Defeated)
            || (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Defeated);
    }

    // Deploy an erc20 factory to represent the tokens in the votes i.e. zkvComp, zkvUni
    function createSyntheticVoterToken(address _underlyingToken)
        internal
        returns (CleisthenesVoterTokenERC20 voterToken)
    {
        // args
        bytes memory immutableArgs = abi.encode(_underlyingToken);

        // Deploy clone of the base erc20 token
        voterToken = CleisthenesVoterTokenERC20(address(cloneErc20Implementation).clone(immutableArgs));

        // Emit an event as a new voter token has been created
        emit CliesthenesVoterTokenERC20Created(_underlyingToken, address(voterToken));
    }
}
