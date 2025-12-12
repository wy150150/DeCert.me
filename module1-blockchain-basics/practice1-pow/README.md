# Practice 1: POW 与非对称加密

这是 DeCert.me 区块链学习的实践练习，包含两个部分：

## 题目 1：工作量证明 (POW)

使用 `昵称 + nonce` 进行 SHA256 哈希运算，寻找满足特定难度条件的哈希值。

### 运行结果

#### 4 个 0 开头的哈希值
- **花费时间**: 55 ms
- **Nonce**: 125798
- **Hash 内容**: `wesley125798`
- **Hash 值**: `0000d043b92d604bf8429684de65f0d55066264305bda748e8108c5d982865e3`

#### 5 个 0 开头的哈希值
- **花费时间**: 158 ms
- **Nonce**: 418280
- **Hash 内容**: `wesley418280`
- **Hash 值**: `000000aada45ee199910458b13d8e99cf2b4ec8ecff1dd9f0828b342e0cdf5e7`

### 运行命令

```bash
npx ts-node module1-blockchain-basics/practice1-pow/pow_sha256.ts
```

---

## 题目 2：RSA 非对称加密签名

1. 生成 RSA 公私钥对
2. 用私钥对满足 POW 4 个 0 开头的 "昵称 + nonce" 进行签名
3. 用公钥验证签名

### 运行结果

- **签名数据**: `wesley125798`
- **SHA256 哈希值**: `0000d043b92d604bf8429684de65f0d55066264305bda748e8108c5d982865e3`
- **签名验证**: ✅ 通过
- **篡改数据后验证**: ❌ 失败 (预期结果)

### 运行命令

```bash
npx ts-node module1-blockchain-basics/practice1-pow/rsa_signature.ts
```

---

## 安装依赖

```bash
npm install
```

## 技术说明

- 使用 Node.js 内置的 `crypto` 模块进行 SHA256 哈希运算和 RSA 签名
- POW 难度越高，需要尝试的 nonce 越多，花费时间越长
- RSA 签名使用 2048 位密钥和 PSS 填充方式

## 学习资源

- [DeCert.me](https://decert.me) - 区块链学习平台
