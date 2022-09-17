pragma solidity 0.8.15;

import {Clone} from "clones-with-immutable-args/Clone.sol";
import {ERC20_Cloneable} from "./utils/ERC20_Cloneable.sol";


error AlreadyInitialised();
contract CleisthenesVoterTokenERC20 is ERC20_Cloneable {
    address underlying;

    // Must have same number of decimals as the underlying
    constructor(uint8 _decimals) ERC20_Cloneable("PRIVATE_TOKEN", "PRIVATE", _decimals) {}
        

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}
