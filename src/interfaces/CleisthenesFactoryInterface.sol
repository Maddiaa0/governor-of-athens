pragma solidity 0.8.15;

interface CleisthenesFactoryInterface {
    function hasVoteExpired(address tokenAddress, uint256 voteId) external returns (bool);
}
