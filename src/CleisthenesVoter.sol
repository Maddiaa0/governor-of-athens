pragma solidity 0.8.15;

import {GovernorBravoDelegateInterface} from "./interfaces/GovernorBravoDelegateInterface.sol";
import {CleisthenesFactoryInterface} from "./interfaces/CleisthenesFactoryInterface.sol";
import {Clone} from "clones-with-immutable-args/Clone.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

interface CleisthenesVoterInterface {
    /// @notice Possible states that a proposal may be in
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
}

error OnlyFactory();
error VoteStillActive();
error FailedToReturnTokensToFactory();

contract CleisthenesVoter is Clone, CleisthenesVoterInterface {
    address immutable factoryAddress;

    // TODO: pack proposal address nad vote and voteId into one slot
    address immutable proposalAddress;
    address immutable tokenAddress;
    uint8 immutable vote;
    uint256 immutable proposalId;

    modifier onlyFactory() {
        if (msg.sender != factoryAddress) {
            revert OnlyFactory();
        }
        _;
    }

    constructor() {
        // TODO: an nice comment showing the layout of the args
        factoryAddress = _getArgAddress(0);
        proposalAddress = _getArgAddress(20);
        tokenAddress = _getArgAddress(40);
        proposalId = _getArgUint256(60);
        vote = _getArgUint8(92); // TODO: this is incorrect
    }

    // TODO: Will this be callable by anyone - should there be constraints in the block time allowed;
    function executeVote() external onlyFactory {
        GovernorBravoDelegateInterface(proposalAddress).castVote(proposalId, vote);
    }

    /**
     * Has Vote Expired
     * @notice Call the factory to check if the vote has expired, if so then use to allow withdrwawl
     */
    function hasVoteExpired() internal {
        bool voteExpired = CleisthenesFactoryInterface(factoryAddress).hasVoteExpired(tokenAddress, proposalId);
        if (!voteExpired) {
            revert VoteStillActive();
        }
    }

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

    function underlyingToken() external returns (address) {
        return tokenAddress;
    }
}
