pragma solidity 0.8.15;

import {GovernorBravoDelegateInterface} from "./interfaces/GovernorBravoDelegateInterface.sol";
import {AthensFactoryInterface} from "./interfaces/AthensFactoryInterface.sol";
import {AthensVoterInterface} from "./interfaces/AthensVoterInterface.sol";
import "openzeppelin/contracts/proxy/utils/Initializable.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

interface IComp {
    function delegate(address) external;
}

/*//////////////////////////////////////////////////////////////
                        Errors
//////////////////////////////////////////////////////////////*/
error OnlyFactory();
error VoteStillActive();
error FailedToReturnTokensToFactory();

/*//////////////////////////////////////////////////////////////
                        Athens Voter
//////////////////////////////////////////////////////////////*/

/// @title AthensVoter
/// @author Maddiaa <Twitter: @Maddiaa0, Github: /cheethas>
contract AthensVoter is AthensVoterInterface, Initializable {
    /// @notice The address of the Athens Factory Contract
    /// Sensitive operations can only be called by it
    address factoryAddress;

    /// @notice Address of Governor Bravo for the given protocol
    address public govAddress;

    /// @notice Governance token
    address public tokenAddress;

    /// @notice Vote to be cast
    uint8 public vote;

    /// @notice The proposal Id to be voted on
    uint256 public proposalId;

    /*//////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/

    /// Only Factory
    /// @notice Sensitive operations can only be called by the Athens Factory which in turn can only be
    ///         called by the bridge
    modifier onlyFactory() {
        if (msg.sender != factoryAddress) {
            revert OnlyFactory();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            Initializer
    //////////////////////////////////////////////////////////////*/
    /// Initialize
    /// @notice Initialize the Athens Voter
    /// @dev Should only be able to be called once
    function initialize(
        address _factoryAddress,
        address _govAddress,
        address _tokenAddress,
        uint256 _proposalId,
        uint8 _vote
    )
        external
        initializer
    {
        factoryAddress = _factoryAddress;
        govAddress = _govAddress;
        tokenAddress = _tokenAddress;
        proposalId = _proposalId;
        vote = _vote;
    }

    /*//////////////////////////////////////////////////////////////
                        External Functions
    //////////////////////////////////////////////////////////////*/

    /// Execute Vote
    /// @notice Cast vote to Governor Bravo
    /// @dev TODO: Should only be able to be called within X blocks of the vote
    function executeVote() external {
        GovernorBravoDelegateInterface(govAddress).castVote(proposalId, vote);
    }

    /// Delegate
    /// @notice Delegate votes to oneself
    /// @dev As votes cannot be delgate within the same block as voting, this function must
    ///      be called by a keeper before each vote.
    /// @dev There are risks that block builders will try to exclude this funciton from their blocks
    function delegate() external {
        IComp(tokenAddress).delegate(address(this));
    }

    /// Has Vote Expired
    /// @notice Call the factory to check if the vote has expired, if so then use to allow withdrwawl
    /// @dev Users will not be able to withdraw from the proxy if the vote has not complete.
    function hasVoteExpired() internal {
        bool voteExpired = AthensFactoryInterface(factoryAddress).hasVoteExpired(govAddress, proposalId);
        if (!voteExpired) {
            revert VoteStillActive();
        }
    }

    /// Return Tokens to Rollup
    /// @notice Return users tokens back to the rollup for user collection
    /// @dev The vote must have completed before this function can be called
    function returnTokenToRollup() internal {
        // Only able to be called if the vote has expired
        hasVoteExpired();

        // Return the balance of the factory back to the rollup
        uint256 balance = ERC20(tokenAddress).balanceOf(address(this));
        bool success = ERC20(tokenAddress).transfer(factoryAddress, balance);
        if (!success) {
            revert FailedToReturnTokensToFactory();
        }
    }
}
