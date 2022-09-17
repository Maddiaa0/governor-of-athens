

interface GovernerBravoDelegateInterface {

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

    function state(uint proposalId) external returns (ProposalState);

    /**
    * @notice Cast a vote for a proposal
    * @param proposalId The id of the proposal to vote on
    * @param support The support value for the vote. 0=against, 1=for, 2=abstain
    */
    function castVote(uint256 proposalId, uint8 support) external;
}