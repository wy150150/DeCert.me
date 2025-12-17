# NFT Market 实战 (ERC777 回调版)

本版本 NFT Market 引入了 ERC777 代币作为支付货币，利用其 `tokensReceived` 钩子函数实现了“转账即购买”的原子化交易体验。

## 文件说明
- `NFTMarket.sol`: 包含 `MyToken` (ERC777)、`MyNFT` (ERC721) 和 `NFTMarket` (交易市场) 三个合约。

## 功能特性
1. **ERC777 支付**: 使用 ERC777 代币进行交易，支持回调机制。
2. **转账即购买**: 用户通过直接向 Market 合约发送 Token 并附带 `data` 参数，即可一步完成购买 NFT。
3. **托管式上架**: 卖家上架时将 NFT 转入 Market 合约托管。

## 部署与交互流程 (Remix)

### 1. 部署 MyToken (ERC777)
   - 部署 `MyToken` 合约。
   - 构造参数 `initialSupply`: 输入初始供应量（注意精度，例如 10000000000000000000000 代表 10000 个）。
   - 记录 `MyToken` 地址。

### 2. 部署 MyNFT (ERC721)
   - 部署 `MyNFT` 合约。
   - 记录 `MyNFT` 地址。

### 3. 部署 NFTMarket
   - 部署 `NFTMarket` 合约。
   - 构造参数 `_token`: 填入 `MyToken` 的合约地址。
   - **注意**: 部署成功后，确保 `ERC1820Registry` 在当前网络已部署（测试网通常已有，本地开发网可能需手动部署）。

### 4. 铸造 NFT 与 Token
   - 调用 `MyNFT.mint(UserA_Address)` 给自己铸造一个 NFT (tokenId 0)。
   - (如果在部署 MyToken 时未给自己铸币，需调用 mint 或 transfer 获取一些 Token)。

### 5. 上架 (List) - User A
   - 所谓“托管式上架”，**需先授权**:
     - 调用 `MyNFT.approve(Market_Address, 0)`。
   - 调用 `NFTMarket.list(MyNFT_Address, 0, Price)`。
     - `Price`: 设置价格（例如 1000000000000000000）。
   - 成功后，NFT 0 被转移到 Market 合约中。

### 6. 购买 (Buy) - User B

   **方式一：普通购买 (approve + buyNFT)**
   - 切换到 User B。
   - 确保 User B 有足够的 `MyToken`。
   - 调用 `MyToken.approve(Market_Address, Price)`。
   - 调用 `NFTMarket.buyNFT(MyNFT_Address, 0)`。

   **方式二：转账即购买 (ERC777 send)**
   - 切换到 User B。
   - 构造 `data` 参数:
     - 可以在 Remix Scripts 或其他工具中生成 `abi.encode(MyNFT_Address, 0)` 的 bytes 数据。
     - 或者手算: NFT地址 (32字节补零) + tokenId (32字节补零)。
   - 调用 `MyToken.send(Market_Address, Price, data)`。
   - 交易成功后，Market 收到 Token 回调 `tokensReceived`，自动解析 `data`，完成交易并将 NFT 发给 User B。

## 常用工具
- [Sepolia Faucet](https://sepoliafaucet.com/)
- [ERC1820Registry Address](https://etherscan.io/address/0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24) (主网/测试网通用)
