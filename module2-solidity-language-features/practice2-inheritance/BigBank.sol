// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Bank.sol";

contract BigBank is Bank {
    
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "Deposit must be > 0.001 ether");
        _;
    }

    function deposit() public payable override minDeposit {
        super.deposit();
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        owner = newOwner;
    }
}
