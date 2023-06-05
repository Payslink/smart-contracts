// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBotProtector {
    function protect(address from, address to, uint256 amount) external;
}