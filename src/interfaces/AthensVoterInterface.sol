/*//////////////////////////////////////////////////////////////
                    Athens Voter Interface
//////////////////////////////////////////////////////////////*/


/// @title AthensFactory
/// @author Maddiaa <Twitter: @Maddiaa0, Github: /cheethas>
interface AthensVoterInterface {

    /*//////////////////////////////////////////////////////////////
                            ENUMS
    //////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function initialize(address _factoryAddress, address _govAddress,  address _tokenAddress, uint256 _proposalId, uint8 _vote) external;
    function executeVote() external;        
    function delegate() external;
}
