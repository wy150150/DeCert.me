# TokenBank 实战

## 目标
实现一个代币银行 TokenBank，理解 ERC20 转账与授权流程。

## 核心逻辑
1. **Deposit (存款)**:
   - 核心方法：`transferFrom`。
   - **前提**：用户必须先在目标 ERC20 代币合约上调用 `approve`，授权给 `TokenBank` 合约足够的额度。
   - 流程：`User` -> 调用 Token 合约 `approve(TokenBankAddress, amount)` -> 调用 `TokenBank.deposit(amount)` -> `TokenBank` 内部调用 `token.transferFrom(User, TokenBank, amount)`。

2. **Withdraw (提款)**:
   - 核心方法：`transfer`。
   - 流程：`TokenBank.withdraw(amount)` -> 检查 Bank 内账本余额是否充足 -> `TokenBank` 内部调用 `token.transfer(User, amount)`。

## 文件说明
- `TokenBank.sol`: 银行合约，管理用户存款。
  - 依赖 `@openzeppelin/contracts/token/ERC20/IERC20.sol` 接口与任意符合标准的 ERC20 代币交互。
