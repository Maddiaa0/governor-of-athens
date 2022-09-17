interface CleisthenesFactoryInterface {
    function hasVoteExpired(address tokenAddress, uint256 voteId) external returns (bool);
}
