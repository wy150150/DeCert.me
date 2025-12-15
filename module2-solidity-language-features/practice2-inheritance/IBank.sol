// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBank {
    function withdraw(uint256 amount) external;
    function contractBalance() external view returns (uint256);
}
