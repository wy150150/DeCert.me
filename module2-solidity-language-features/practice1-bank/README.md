# Bank 合约实战

## 简介
这是一个模拟银行功能的智能合约，旨在帮助理解 Solidity 的核心语言特性，包括接收 ETH、管理余额、数组与映射的使用、以及权限控制。

## 实现了以下功能特性

### 1. 合约账号与 ETH 接收
合约能够像普通账号一样持有 ETH。
- **receive()**: 实现了 `receive` 回调函数，允许用户直接向合约地址转账 ETH（例如通过 MetaMask 发送）。
- **deposit()**: 提供了一个明确的 `deposit` 函数，用于主动调用进行存款。
- **payable**: 两个存款入口都标记为 `payable`，使其能够接收 Value。

### 2. 数据结构的使用
- **mapping**: 使用 `mapping(address => uint256) public balances` 记录每个地址的存款余额。
- **Address Array**: 使用 `address[3] public topDepositors` 固定长度数组，实时记录存款金额最高的前 3 名用户地址。

### 3. 资金管理与权限控制
- **Owner**: 合约部署时将 `msg.sender` 设定为 `owner`（管理员）。
- **Modifier**: 定义了 `onlyOwner` 修饰符，确保只有管理员可以执行敏感操作。
- **Withdraw**: 实现了 `withdraw(uint256 amount)` 函数，允许管理员从合约中提取资金。

### 4. 事件 (Events)
- **Deposit**: 存款时抛出事件，记录用户地址和金额。
- **Withdraw**: 提款时抛出事件，记录管理员地址和金额。

## 合约接口说明

| 函数名 | 类型 | 可支付 | 权限 | 描述 |
| :--- | :--- | :--- | :--- | :--- |
| `receive()` | external | ✅ | 无 | 用户直接转币时触发，更新余额与排行 |
| `deposit()` | external | ✅ | 无 | 调用此方法存款，更新余额与排行 |
| `withdraw(uint256 amount)` | external | ❌ | Owner | 管理员提取合约内的 ETH |
| `contractBalance()` | external | ❌ | 无 | 查看合约当前的 ETH 总余额 |
| `balances(address)` | public | ❌ | 无 | 查看指定地址的存款余额 |
| `topDepositors(uint256)` | public | ❌ | 无 | 查看前三名存款大户的地址 |

## 核心逻辑：Top 3 排行榜更新
每次用户存款后，合约会调用内部函数 `_updateTop3(address user)`：
1. **去重**：如果用户已在榜单中，先将其移除（位置置空）。
2. **插入与排序**：将用户余额与榜单上的用户比较，插入到正确位置，并自动向后移动其他用户，保持榜单按金额从高到低排序。
