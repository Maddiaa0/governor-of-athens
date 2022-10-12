pragma solidity 0.8.15;

import {GovernorBravoDelegateInterface} from "./interfaces/GovernorBravoDelegateInterface.sol";
import {AthensFactoryInterface} from "./interfaces/AthensFactoryInterface.sol";
import {AthensVoterInterface} from "./interfaces/AthensVoterInterface.sol";
import "openzeppelin/contracts/proxy/utils/Initializable.sol";

import {Clone} from "clones-with-immutable-args/Clone.sol";

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
contract AthensVoter is AthensVoterInterface, Clone {
    /*//////////////////////////////////////////////////////////////
                Clones with Immutable Args Offsets
    //////////////////////////////////////////////////////////////*/

    /// @dev First address (20 bytes)
    uint256 internal constant FACTORY_OFFSET = 0;

    /// @dev Second address (20 bytes) (20)
    uint256 internal constant GOV_OFFSET = 20;

    /// @dev Third address (20 bytes) (20 + 20)
    uint256 internal constant TOKEN_ADDRESS = 40;

    /// @dev Fourth uint256 (32 bytes) (20 + 20 + 20)
    uint256 internal constant PROPOSAL_ID = 60;

    /// @dev Firth uint8 (1 byte) (20 + 20 + 20 + 32)
    uint256 internal constant VOTE = 92;

    /*//////////////////////////////////////////////////////////////
                Clones with Immutable Args Functions
    //////////////////////////////////////////////////////////////*/

    /// @notice The address of the Athens Factory Contract
    /// Sensitive operations can only be called by it
    /// @dev Value is 20 bytes
    function factoryAddress() public pure returns (address) {
        return _getArgAddress(FACTORY_OFFSET);
    }

    /// @notice Address of Governor Bravo for the given protocol
    /// @dev Value is 20 bytes
    function govAddress() public pure returns (address) {
        return _getArgAddress(GOV_OFFSET);
    }

    /// @notice Governance token
    /// @dev Value is 20 bytes
    function tokenAddress() public pure returns (address) {
        return _getArgAddress(TOKEN_ADDRESS);
    }

    /// @notice The proposal Id to be voted on
    /// @dev Value is 32 bytes
    function proposalId() public pure returns (uint256) {
        return _getArgUint256(PROPOSAL_ID);
    }

    /// @notice Vote to be cast
    /// @dev Value is 1 byte
    function vote() public returns (uint8) {
        return _getArgUint8(VOTE);
    }

    /*//////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/

    /// Only Factory
    /// @notice Sensitive operations can only be called by the Athens Factory which in turn can only be
    ///         called by the bridge
    modifier onlyFactory() {
        if (msg.sender != factoryAddress()) {
            revert OnlyFactory();
        }
        _;
    }

    /// @notice No constructor required
    constructor() {}

    /*//////////////////////////////////////////////////////////////
                        External Functions
    //////////////////////////////////////////////////////////////*/

    /// Execute Vote
    /// @notice Cast vote to Governor Bravo
    /// @dev TODO: Should only be able to be called within X blocks of the vote
    function executeVote() external {
        GovernorBravoDelegateInterface(govAddress()).castVote(proposalId(), vote());
    }

    /// Delegate
    /// @notice Delegate votes to oneself
    /// @dev As votes cannot be delgate within the same block as voting, this function must
    ///      be called by a keeper before each vote.
    /// @dev There are risks that block builders will try to exclude this funciton from their blocks
    function delegate() external {
        IComp(tokenAddress()).delegate(address(this));
    }

    /// Has Vote Expired
    /// @notice Call the factory to check if the vote has expired, if so then use to allow withdrwawl
    /// @dev Users will not be able to withdraw from the proxy if the vote has not complete.
    function hasVoteExpired() internal {
        bool voteExpired = AthensFactoryInterface(factoryAddress()).hasVoteExpired(govAddress(), proposalId());
        if (!voteExpired) {
            revert VoteStillActive();
        }
    }

    /// Return Tokens to Rollup
    /// @notice Return users tokens back to the rollup for user collection
    /// @dev The vote must have completed before this function can be called
    function returnTokenToFactory() external onlyFactory {
        // Only able to be called if the vote has expired
        hasVoteExpired();

        // Return the balance of the factory back to the rollup
        address _tokenAddress = tokenAddress();
        uint256 balance = ERC20(_tokenAddress).balanceOf(address(this));
        bool success = ERC20(_tokenAddress).transfer(factoryAddress(), balance);
        if (!success) {
            revert FailedToReturnTokensToFactory();
        }
    }
}
