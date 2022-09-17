pragma solidity 0.8.15;

import {Clone} from "clones-with-immutable-args/Clone.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";


error AlreadyInitialised();
contract CleisthenesVoterTokenERC20 is Clone, ERC20, Owned {
    address underlying;
    bool initialised;

    modifier notInitialised() {
        if (initialised) revert AlreadyInitialised();
        _;
    }

    // Must have same number of decimals as the underlying
    constructor(address _underlying) ERC20() Owned(msg.sender) {
        underlying = _underlying;
    }
        
    
    function initialise() notInitialised external {
        setOwner(msg.sender);

    } 

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}
