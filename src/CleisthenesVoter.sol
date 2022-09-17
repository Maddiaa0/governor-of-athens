pragma solidity 0.8.15;

import {GovernorBravoDelegateInterface} from "./interfaces/GovernorBravoDelegateInterface.sol";
import {Clone} from "./lib/Clone.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";


error OnlyFactory();
error VoteStillActive();
error FailedToReturnTokensToFactory();
contract CliesthenesVoter is CliesthenesVoterInterface {

    address immutable factoryAddress;

    // TODO: pack proposal address nad vote and voteId into one slot
    address immutable proposalAddress;
    address immutable tokenAddress;
    uint8 immutable vote;
    uint256 immutable proposalId;

    modifier onlyFactory() {
        if (msg.sender != factoryAddress) revert OnlyFactory();
        _;
    }


    // TODO: Will this be callable by anyone - should there be constraints in the block time allowed;
    function executeVote() external onlyFactory {
        GovernorBravoDelegateInterface(proposalAddress).castVote(proposalId, vote);
    }



    /** Has Vote Expired
     * @notice Call the factory to check if the vote has expired, if so then use to allow withdrwawl
     */
    function hasVoteExpired() internal {
        bool voteExpired = CliesthenesFactoryInterface(factoryAddress).hasVoteExpired(proposalId);
        if (!voteExpired) revert VoteStillActive();
    }


    function returnTokenToRollup() internal {
        // Only able to be called if the vote has expired
        hasVoteExpired();

        // Return the balance of the factory back to the rollup
        (bool success, _) = ERC20(tokenAddress).transfer(factoryAddress);
        if (!success) revert FailedToReturnTokensToFactory();
    }
}


interface CliesthenesVoterInterface {
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