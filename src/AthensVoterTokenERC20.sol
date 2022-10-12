pragma solidity 0.8.10;

import "openzeppelin/contracts/utils/Context.sol";
import "openzeppelin/contracts/token/ERC20/ERC20.sol";
import "openzeppelin/contracts/proxy/utils/Initializable.sol";

error AlreadyInitialised();

/// @title AthensVoterTokenERC20
/// @author Maddiaa <Twitter: @Maddiaa0, Github: /cheethas>
contract AthensVoterTokenERC20 is ERC20, Initializable {
    /// @notice ERC20 Metadata
    uint8 _decimals;
    string private _name;
    string private _symbol;

    /// @notice The token Owner (AthensFactory)
    address public owner;

    /*//////////////////////////////////////////////////////////////
                            Modifiers
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        require(msg.sender == owner, "msg.sender not owner");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

    /// @dev Uses Dummy data as implementation will be cloned
    constructor() ERC20("ZKV", "ZKV") {}

    /*//////////////////////////////////////////////////////////////
                            Initializer
    //////////////////////////////////////////////////////////////*/

    /// Initialize
    /// @notice Sets the values for {name}, {symbol} and {decimals}.
    function initialize(address factory, string memory name_, string memory symbol_, uint8 decimals_)
        external
        initializer
    {
        owner = factory;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /// Mint
    /// @notice Mint ZKVoter tokens to the bridge user
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    /// Burn
    /// @notice Destroy ZKVoter tokens
    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                        Getter Overrides
    //////////////////////////////////////////////////////////////*/

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /// Transfer Ownership
    /// @notice Transfer ownership. Implemented to help with initializable
    function transferOwnership(address _owner) external onlyOwner {
        require(_owner != address(0), "Owner: setting to 0 address");
        owner = _owner;
    }
}
