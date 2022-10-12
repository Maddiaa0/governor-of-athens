// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {AthensVoter} from "./AthensVoter.sol";
import {AthensVoterTokenERC20} from "./AthensVoterTokenERC20.sol";
import {GovernorBravoDelegateInterface} from "./interfaces/GovernorBravoDelegateInterface.sol";
import {AthensFactoryInterface} from "./interfaces/AthensFactoryInterface.sol";
import "openzeppelin/contracts/proxy/Clones.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {ClonesWithImmutableArgs} from "clones-with-immutable-args/ClonesWithImmutableArgs.sol";

/*//////////////////////////////////////////////////////////////
                        ERRORS
//////////////////////////////////////////////////////////////*/
error NotBridge();
error InvalidAuxData();

/// @title AthensFactory
/// @author Maddiaa <Twitter: @Maddiaa0, Github: /cheethas>
contract AthensFactory is AthensFactoryInterface, Owned {
    using ClonesWithImmutableArgs for address;

    /// @notice Address of the Athens Bridge
    address bridgeContractAddress;

    /// @notice Athens Voter Proxy Implementation
    AthensVoter public implementation;

    /// @notice Athens ZK Voter Token ERC20 Proxy Implementation
    AthensVoterTokenERC20 public cloneErc20Implementation;

    /// @notice Next available aux index for a voter proxy
    uint64 public nextAvailableSlot;

    /// @notice Mapping of aux index to voter proxy
    mapping(uint64 => AthensVoter) public voterProxies;

    /// @notice Mapping of underlying token to zK Voter token
    mapping(address => AthensVoterTokenERC20) public zkVoterTokens;

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyBridge() {
        if (msg.sender != bridgeContractAddress) {
            revert NotBridge();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor() Owned(msg.sender) {
        // Init proxy implementation, no need to initialize as it uses immutable args
        implementation = new AthensVoter();

        // Init base erc20 token implementation with dummy values
        cloneErc20Implementation = new AthensVoterTokenERC20();
        cloneErc20Implementation.initialize(address(this), "base", "BASE", 18);
    }

    /*//////////////////////////////////////////////////////////////
                            STATEFUL
    //////////////////////////////////////////////////////////////*/

    /// Create Voter Proxy
    /// @notice Creates a new voter proxy, a voter proxy represents a position in a governance proposal. I.e. A for position in compound proposal 121
    /// @dev If the _tokenAddress has not been seen before, then a new zk voter token is created to represent it
    /// @param _tokenAddress Address of the underlying token
    /// @param _governorAddress Address of the governor contract
    /// @param _proposalId Id of the proposal
    /// @param _vote Vote of the voter proxy // TODO: remove, automatically produce 3 positions (yay, nay, abstain)
    function createVoterProxy(address _tokenAddress, address _governorAddress, uint256 _proposalId, uint8 _vote)
        external
        returns (AthensVoter clone)
    {
        // Check if the underlying token has an erc20 token, if no create it.
        if (address(zkVoterTokens[_tokenAddress]) == address(0x0)) {
            zkVoterTokens[_tokenAddress] = createSyntheticVoterToken(_tokenAddress);
        }

        // Pack clone arguements and deploy
        bytes memory data = abi.encodePacked(address(this), _governorAddress, _tokenAddress, _proposalId, _vote);
        clone = AthensVoter(address(implementation).clone(data));

        // cache next available slot in memory
        uint64 _nextAvailableSlot = nextAvailableSlot;
        voterProxies[_nextAvailableSlot] = clone;

        // Emit that a voter event is created for the front end
        emit AthensVoterCreated(_nextAvailableSlot, _governorAddress, _proposalId, address(clone), _vote);

        // Increment the next available slot
        nextAvailableSlot = ++_nextAvailableSlot;
    }

    /// Set Bridge
    /// @notice Set the aztec bridge contract for only bridge methods
    /// @dev Can only be called by the contract owner
    /// @param _bridgeContractAddress Address of the bridge contract
    function setBridge(address _bridgeContractAddress) external onlyOwner {
        bridgeContractAddress = _bridgeContractAddress;
    }

    /// Allocate Vote
    /// @notice Batched called by the Athens Bridge to batch multiple votes into a single vote.
    ///         The bridge will receive zkVoter tokens representing the governance tokens which balance will be assigned
    ///         to each user inside the rollup.
    /// @dev Called by the bridge contract to get the proxy address of a vote - can only be called by the bridge
    /// @param _auxData _aux bridge data, this tells us which voter proxy we are targeting
    /// @param _totalInputValue The total number of input tokens being vote with
    function allocateVote(uint64 _auxData, uint256 _totalInputValue) external onlyBridge {
        // Transfer the number of input tokens to the voter proxy
        // Store voter clone in memory
        AthensVoter voterClone = voterProxies[_auxData];

        // Revert if no proxy is deployed for the given aux data
        if (address(voterClone) == address(0x0)) {
            revert InvalidAuxData();
        }

        address _underlyingToken = voterClone.tokenAddress();

        // Send the underlying token to the voter proxy
        ERC20(_underlyingToken).transferFrom(address(bridgeContractAddress), address(voterClone), _totalInputValue);

        // Send the correct number of voter tokens to the bridge
        AthensVoterTokenERC20 _syntheticToken = zkVoterTokens[_underlyingToken];
        _syntheticToken.mint(msg.sender, _totalInputValue);
    }

    /// Redeem Voting Tokens
    /// @notice Redeems the zkVoting tokens for the underlying token
    /// @dev onlyBridge - Trusts that the bridge calls with the correct _totalInputValue
    /// @param _auxData The proxy we are targeting
    /// @param _totalInputValue The number of tokens being redeemed
    function redeemVotingTokens(uint64 _auxData, uint256 _totalInputValue) external onlyBridge {
        // Return the number of voter tokens back to the bridge
        // Get the voter proxy
        AthensVoter voterClone = voterProxies[_auxData];

        // Return remaining tokens to the factory- this will fail if the vote has not completed yet
        voterClone.returnTokenToFactory();

        // Transfer the tokens to the bridge
        address _underlyingToken = voterClone.tokenAddress();
        ERC20(_underlyingToken).transfer(address(bridgeContractAddress), _totalInputValue);

        // Burn the matching number of voter tokens
        AthensVoterTokenERC20 _zkVoterToken = zkVoterTokens[_underlyingToken];
        _zkVoterToken.burn(msg.sender, _totalInputValue);
    }

    /// Has Vote Expired
    /// @notice Calls the comptroller current contract to check if the vote has expired.
    /// @dev Called by a proxy, code is included in here to decrease the size of the proxy.
    /// @param _governorAddress Address of the governor contract
    /// @param _proposalId Id of the proposal
    /// @return validState True if the vote has ended
    function hasVoteExpired(address _governorAddress, uint256 _proposalId) external returns (bool validState) {
        GovernorBravoDelegateInterface.ProposalState returnedProposalState =
            GovernorBravoDelegateInterface(_governorAddress).state(_proposalId);

        // TODO: more gas efficient way to do this - check inverse?
        validState = (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Succeeded)
            || (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Expired)
            || (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Canceled)
            || (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Defeated)
            || (returnedProposalState == GovernorBravoDelegateInterface.ProposalState.Executed);
    }

    /// Create Synthetic Voter Token
    /// @notice Deploy an erc20 factory to represent the tokens in the votes i.e. zkvComp, zkvUni
    /// @dev Used by the aztec bridge to track users votes
    /// @param _underlyingToken Address of the underlying token
    /// @return voterToken Address of the newly deployed voter token
    function createSyntheticVoterToken(address _underlyingToken) internal returns (AthensVoterTokenERC20 voterToken) {
        // args
        bytes32 tokenHash = keccak256(abi.encode(_underlyingToken));

        // Get the name, symbol and decimals of the underlying
        string memory _name = string(abi.encodePacked("zkv", ERC20(_underlyingToken).name()));
        string memory _symbol = string(abi.encodePacked("zkv", ERC20(_underlyingToken).symbol()));
        uint8 decimals = ERC20(_underlyingToken).decimals();

        // deploy and initialised the erc20 implementation
        voterToken = AthensVoterTokenERC20(Clones.cloneDeterministic(address(cloneErc20Implementation), tokenHash));
        voterToken.initialize(address(this), _name, _symbol, decimals);

        // Emit an event as a new voter token has been created
        emit AthensVoterTokenERC20Created(_underlyingToken, address(voterToken));
    }
}
