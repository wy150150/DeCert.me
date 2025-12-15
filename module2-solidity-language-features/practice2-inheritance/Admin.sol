// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IBank.sol";

contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function adminWithdraw(IBank bank) external onlyOwner {
        // 获取合约余额
        uint256 balance = bank.contractBalance();
        require(balance > 0, "No balance to withdraw");
        
        // 调用 Bank 的 withdraw，因为 Admin 是 Bank 的 owner，资金会转入 Admin
        bank.withdraw(balance);
    }
    
    // 接收转账
    receive() external payable {}
}
