# NFT Market 事件监听器

使用 Viem.sh 监听 NFTMarket 合约的买卖事件。

## 功能说明

监听 NFTMarket 合约发出的事件：
- `NFTListed`: NFT 上架事件
- `NFTSold`: NFT 售出事件

## 环境要求

- Node.js >= 18
- TypeScript
- Viem
- Foundry/Anvil (本地测试网)

## 安装依赖

```bash
npm install viem dotenv
npm install -D typescript ts-node @types/node
```

## 配置

1. 复制 `.env.example` 为 `.env`：
```bash
cp .env.example .env
```

2. 修改 `.env` 文件中的配置：
```
RPC_URL=http://127.0.0.1:8545
NFT_MARKET_ADDRESS=你的合约地址
```

## 运行

### 启动本地测试网（Foundry）
```bash
anvil
```

### 运行监听器
```bash
npm run watch-nft
# 或
ts-node --esm watchNFTMarket.ts
```

## 功能特性

- ✅ 扫描历史事件（从区块 0 开始）
- ✅ 实时监听新事件
- ✅ 格式化显示价格（使用 formatEther）
- ✅ 显示完整交易信息（交易哈希、区块号）
- ✅ 优雅退出（Ctrl+C）

## 事件说明

### NFTListed 事件
```solidity
event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
```
- `tokenId`: NFT Token ID
- `seller`: 卖家地址
- `price`: 上架价格

### NFTSold 事件
```solidity
event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
```
- `tokenId`: NFT Token ID
- `seller`: 卖家地址
- `buyer`: 买家地址
- `price`: 成交价格

## 测试流程

1. 启动 Anvil 本地测试网
2. 部署 NFTMarket 合约
3. 更新 `.env` 中的合约地址
4. 运行监听器
5. 在另一个终端执行 NFT 上架/购买操作
6. 观察监听器输出的事件信息
