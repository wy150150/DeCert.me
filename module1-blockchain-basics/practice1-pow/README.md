# POW (Proof of Work) SHA256 演示

这是一个用 TypeScript 实现的工作量证明（POW）演示程序，模拟比特币等加密货币的挖矿过程。

## 功能

程序使用 `昵称 + nonce` 的方式进行 SHA256 哈希运算，不断递增 nonce 直到找到满足特定难度条件的哈希值。

## 运行结果示例

### 4 个 0 开头的哈希值
- **花费时间**: 55 ms
- **Nonce**: 125798
- **Hash 内容**: `wesley125798`
- **Hash 值**: `0000d043b92d604bf8429684de65f0d55066264305bda748e8108c5d982865e3`

### 5 个 0 开头的哈希值
- **花费时间**: 158 ms
- **Nonce**: 418280
- **Hash 内容**: `wesley418280`
- **Hash 值**: `000000aada45ee199910458b13d8e99cf2b4ec8ecff1dd9f0828b342e0cdf5e7`

## 安装

```bash
npm install
```

## 运行

```bash
npx ts-node pow_sha256.ts
# 或者
npm run pow
```

## 修改昵称

打开 `pow_sha256.ts` 文件，修改第 4 行的 `NICKNAME` 变量为你自己的昵称：

```typescript
const NICKNAME = 'your_nickname';
```

## 技术说明

- 使用 Node.js 内置的 `crypto` 模块进行 SHA256 哈希运算
- 难度越高（前导 0 越多），需要尝试的 nonce 越多，花费的时间越长
- 这演示了为什么工作量证明可以保证区块链的安全性

## 学习资源

- [DeCert.me](https://decert.me) - 区块链学习平台
