pragma solidity 0.8.15;

import "openzeppelin/contracts/utils/Context.sol";
import "openzeppelin/contracts/token/ERC20/ERC20.sol";
import "openzeppelin/contracts/proxy/utils/Initializable.sol";


error AlreadyInitialised();

contract AthensVoterTokenERC20 is ERC20, Initializable {

    uint8 _decimals;
    string private _name;
    string private _symbol;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "msg.sender not owner");
        _;
    }

    constructor() ERC20("ZKV", "ZKV"){}

     /**
     * @dev Sets the values for {name}, {symbol} and {decimals}.
     */
    function initialize(address factory, string memory name_, string memory symbol_, uint8 decimals_)
        external
        initializer
    {
        owner = factory;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }



    // Must have same number of decimals as the underlying
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Transfer ownership. Implemented to help with initializable
     */
    function transferOwnership(address _owner) external onlyOwner {
        require(_owner != address(0), "Owner: setting to 0 address");
        owner = _owner;
    }

}
