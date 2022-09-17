pragma solidity 0.8.15;

import {GovernorBravoDelegateInterface} from "./interfaces/GovernorBravoDelegateInterface.sol";
import {AthensFactoryInterface} from "./interfaces/AthensFactoryInterface.sol";
import "openzeppelin/contracts/proxy/utils/Initializable.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

interface AthensVoterInterface {
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

    function initialize(address _factoryAddress, address _govAddress,  address _tokenAddress, uint256 _proposalId, uint8 _vote) external;
    function executeVote() external;        
    function delegate() external;
    function underlyingToken() external returns (address);
}

interface IComp {
    function delegate(address) external;
}

error OnlyFactory();
error VoteStillActive();
error FailedToReturnTokensToFactory();

contract AthensVoter is AthensVoterInterface, Initializable {
    address factoryAddress;

    address public govAddress;
    address public tokenAddress;
    uint8 public vote;
    uint256 public proposalId;

    modifier onlyFactory() {
        if (msg.sender != factoryAddress) revert OnlyFactory();
        _;
    }

    function initialize(address _factoryAddress, address _govAddress,  address _tokenAddress, uint256 _proposalId, uint8 _vote) external initializer {
        factoryAddress = _factoryAddress;
        govAddress = _govAddress;
        tokenAddress = _tokenAddress;
        proposalId = _proposalId;
        vote = _vote; 
    }

    // TODO: Will this be callable by anyone - should there be constraints in the block time allowed;
    function executeVote() external onlyFactory {        
        GovernorBravoDelegateInterface(govAddress).castVote(proposalId, vote);
    }

    // Delegate function can be called by anyone
    function delegate() external {
        IComp(tokenAddress).delegate(address(this));
    }

    /**
     * Has Vote Expired
     * @notice Call the factory to check if the vote has expired, if so then use to allow withdrwawl
     */
    function hasVoteExpired() internal {
        bool voteExpired = AthensFactoryInterface(factoryAddress).hasVoteExpired(govAddress, proposalId);
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
