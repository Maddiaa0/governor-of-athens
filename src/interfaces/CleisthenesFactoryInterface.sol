pragma solidity 0.8.15;

interface CleisthenesFactoryInterface {
    // Events
    event CliesthenesVoterCreated(
        uint64 indexed auxData,
        address indexed governorAddress,
        uint256 indexed proposalId,
        address voterCloneAddress,
        uint8 vote
    );
    event CliesthenesVoterTokenERC20Created(address indexed underlyingToken, address indexed syntheticToken);

    function hasVoteExpired(address tokenAddress, uint256 voteId) external returns (bool);
}
