// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "./interfaces/IBotProtector.sol";

contract Pays is
    AccessControlEnumerable,
    ERC20Burnable,
    ERC20Pausable,
    ERC20Capped
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MAINTAINER_ROLE = keccak256("MAINTAINER_ROLE");

    address private _bpAddress;
    bool public bpEnabled;
    event BPUpdated(address indexed bpAddress);
    event BPEnabled(bool enabled);

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
        ERC20Capped(90000000 * 10**18)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MAINTAINER_ROLE, _msgSender());
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function mint(address to_, uint256 amount_) public {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "must have minter role to mint"
        );
        require(amount_ > 0, "invalid amount");
        _mint(to_, amount_);
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount)
        internal
        override(ERC20, ERC20Capped)
    {
        ERC20Capped._mint(account, amount);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `owner`.
     */
    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "must have pauser role to pause"
        );
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `owner`.
     */
    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "must have pauser role to unpause"
        );
        _unpause();
    }

    function enableBP(bool enabled_) public {
        require(
            hasRole(MAINTAINER_ROLE, _msgSender()),
            "must have maintainer role to enable bp"
        );
        bpEnabled = enabled_;

        emit BPEnabled(enabled_);
    }

    function updateBPContract(address bpAddress_) public {
        require(
            hasRole(MAINTAINER_ROLE, _msgSender()),
            "must have maintainer role to update bp address"
        );
        require(bpAddress_ != address(0), "bpAddress_ is zero address");
        _bpAddress = bpAddress_;

        emit BPUpdated(bpAddress_);
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Pausable) {
        if (bpEnabled) {
            IBotProtector(_bpAddress).protect(from, to, amount);
        }

        ERC20Pausable._beforeTokenTransfer(from, to, amount);
    }
}
