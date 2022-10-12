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
    function executeVote() external;
    function delegate() external;
    function returnTokenToFactory() external;

    /*//////////////////////////////////////////////////////////////
                Clones with Immutable Args Getters
    //////////////////////////////////////////////////////////////*/
    function factoryAddress() external returns (address);
    function govAddress() external returns (address);
    function tokenAddress() external returns (address);
    function proposalId() external returns (uint256);
    function vote() external returns (uint8);
}
