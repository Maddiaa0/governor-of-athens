pragma solidity 0.8.15;

import { AthensVoter } from "../AthensVoter.sol";

interface AthensFactoryInterface {
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

    function createVoterProxy(address _tokenAddress, address _governorAddress, uint256 _proposalId, uint8 _vote)
        external
        returns (AthensVoter clone);
}
