# 银行合约进阶与继承实战 (Inheritance & Interface)

## 目标
1. **接口 (Interface)**: 定义 `IBank` 接口。
2. **继承 (Inheritance)**: `BigBank` 继承自 `Bank`。
3. **多态 (Polymorphism)**: 重写 `deposit` 和 `receive`，添加限制条件。
4. **合约交互**: `Admin` 合约通过接口与 `Bank` 交互。

## 内容
- **IBank.sol**: 银行接口定义。
- **Bank.sol**: 基础银行合约，实现了 IBank。
- **BigBank.sol**: 继承自 Bank，要求存款金额 > 0.001 ether，并支持转移管理员。
- **Admin.sol**: 管理员合约，用于接收 BigBank 的资金。

## 模拟流程 (Simulation Flow)
1. **部署**:
   - 部署 `BigBank` 合约。
   - 部署 `Admin` 合约。
2. **转移权限**:
   - 调用 `BigBank.transferOwner(Admin合约地址)`，将 BigBank 的所有权交给 Admin 合约。
3. **用户存款**:
   - 多个地址向 `BigBank` 转账或调用 `deposit` (金额需 > 0.001 ETH)。
4. **资金归集**:
   - Admin 合约的拥有者调用 `Admin.adminWithdraw(BigBank合约地址)`。
   - `Admin` 合约调用 `BigBank.withdraw`。
   - `BigBank` 验证调用者是 owner (即 Admin 合约)，将资金转给 Admin。
   - 资金最终停留在 `Admin` 合约中。

## 目录结构
- `IBank.sol`
- `Bank.sol`
- `BigBank.sol`
- `Admin.sol`
