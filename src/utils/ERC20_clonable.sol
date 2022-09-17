// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "openzeppelin/contracts/utils/Context.sol";
import "openzeppelin/contracts/token/ERC20/ERC20.sol";
import "openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @dev Minimal Clones compatible implementation of the {IERC20} interface.
 * @dev Based Openzeppelin 3.4 ERC20 contract
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20_Cloneable is ERC20, Initializable {
    uint8 _decimals;
    string private _name;
    string private _symbol;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "msg.sender not owner");
        _;
    }

    /**
     * @dev Sets the values for {name}, {symbol} and {decimals}.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_) {
        _decimals = decimals_;
    }

    function initialize(
        address _pool,
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) external initializer {
        owner = _pool;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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