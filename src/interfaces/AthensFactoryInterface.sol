pragma solidity 0.8.15;

import { AthensVoter } from "../AthensVoter.sol";
import {AthensVoterTokenERC20} from "../AthensVoterTokenERC20.sol";

/// @title AthensFactory
/// @author Maddiaa <Twitter: @Maddiaa0, Github: /cheethas>
interface AthensFactoryInterface {
    
    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    event CliesthenesVoterCreated(
        uint64 indexed auxData,
        address indexed governorAddress,
        uint256 indexed proposalId,
        address voterCloneAddress,
        uint8 vote
    );
    event CliesthenesVoterTokenERC20Created(address indexed underlyingToken, address indexed syntheticToken);
    
    
    /*//////////////////////////////////////////////////////////////
                            Functions
    //////////////////////////////////////////////////////////////*/
    
    function hasVoteExpired(address tokenAddress, uint256 voteId) external returns (bool);
    function createVoterProxy(address _tokenAddress, address _governorAddress, uint256 _proposalId, uint8 _vote)
        external
        returns (AthensVoter clone);
    function allocateVote(uint64 _auxData, uint256 _totalInputValue) external;
    function voterProxies(uint64) external returns (AthensVoter);
    function zkVoterTokens(address) external returns (AthensVoterTokenERC20);
}
