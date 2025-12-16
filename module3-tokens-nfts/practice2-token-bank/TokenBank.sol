// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    // 记录每个用户存入的 BERC20 数量
    mapping(address => uint256) public balances;
    
    // 银行管理的 ERC20 Token 地址
    IERC20 public token;

    // 事件
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    /**
     * @notice 存款：用户必须先 approve TokenBank 合约，才能调用 deposit
     * @param amount 存入金额
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        
        // 使用 transferFrom 将 Token 从用户账户转入 Bank 合约
        // 注意：用户必须先在 Token 合约调用 approve(TokenBankAddress, amount)
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        // 记账
        balances[msg.sender] += amount;
        
        emit Deposit(msg.sender, amount);
    }

    /**
     * @notice 提款：用户提取之前存入的 Token
     * @param amount 提取金额
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 更新记账
        balances[msg.sender] -= amount;

        // 将 Token 从 Bank 合约转回给用户
        bool success = token.transfer(msg.sender, amount);
        require(success, "Transfer failed");

        emit Withdraw(msg.sender, amount);
    }
}
