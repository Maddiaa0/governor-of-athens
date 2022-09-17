pragma solidity 0.8.15;


import {Clone} from "./lib/Clone.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";
import { Owned } from "solmate/auth/Owned.sol";

contract CleisthenesVoterTokenERC20 is Clone, ERC20, Owned {

    address immutable underlying;
    string public immutable name;
    string public immutable symbol;
    uint8 public immutable decimals;


    // Must have same number of decimals as the underlying 
    constructor() {
        // Get underlying token from end of deployment bytecode;
        address _underlying = _getArgAddress(0);
        underlying = _underlying;
        
        // call the underlying and get the name symbol and decimals;
        name = abi.encodePacked("zkv", ERC20(_underlying).name());
        symbol = abi.encodePacked("zkv", ERC20(_underlying).symbol());
        decimals = ERC20(_underlying).decimals();
    }


    function mint(address account, uint256 amount) external override onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external override onlyOwner {
        _burn(account, amount); 
    }
}