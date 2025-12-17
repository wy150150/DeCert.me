# NFT Market 实战操作指南

本指南将教你如何使用 IPFS 存储图片与元数据，如何部署 NFT 合约并铸造 NFT，以及如何部署 Market 合约进行挂单交易。

## 前置准备

### 1. 安装依赖
由于你的合约代码使用了 OpenZeppelin 4.x 版本的路径（例如 `security/ReentrancyGuard.sol`），请确保安装 4.x 版本：

```bash
npm install @openzeppelin/contracts@4.9.6
```

### 2. 准备 MetaMask 钱包与测试币
- 确保你的 MetaMask 钱包连接到 **Sepolia 测试网**。
- 前往 [Sepolia Faucet](https://sepoliafaucet.com/) 领取测试 ETH。

## 步骤一：上传图片和元数据到 IPFS

我们需要将 NFT 的图片和描述信息存储在去中心化网络 IPFS 上。推荐使用 [Pinata](https://www.pinata.cloud/)。

1. **上传图片**:
   - 注册并登录 Pinata。
   - 点击 "Upload" -> "File"，选择你的 NFT 图片（例如 `my_nft_image.png`）。
   - 上传成功后，复制 **CID** (例如 `QmXyZ...`).
   - 图片 URI 为: `ipfs://QmXyZ...`

2. **创建元数据 (Metadata JSON)**:
   - 在本地创建一个 JSON 文件 `metadata.json`，内容如下（替换为你刚才的图片 URI）：
     ```json
     {
       "name": "My Unique NFT",
       "description": "This is an NFT created for the DeCert.me practice.",
       "image": "ipfs://YOUR_IMAGE_CID_HERE"
     }
     ```

3. **上传元数据**:
   - 再次在 Pinata 点击 "Upload" -> "File"，上传 `metadata.json`。
   - 复制新的 **CID** (例如 `QmRef...`).
   - **最终 Token URI**: `ipfs://QmRef...` (这个字符串将用于铸造 NFT)。

## 步骤二：部署合约 (使用 Remix)

对于初学者，**Remix IDE** 是最直观的部署工具。

1. 打开 [Remix IDE](https://remix.ethereum.org/)。
2. 在 `contracts` 文件夹下新建 `MyNFT.sol` 和 `NFTMarket.sol`，并将你的代码复制进去。
3. **编译**:
   - 点击左侧 "Solidity Compiler" 图标。
   - Compiler 版本选择 `0.8.20`。
   - 点击 "Compile MyNFT.sol" 和 "Compile NFTMarket.sol"。
4. **部署 MyNFT**:
   - 点击左侧 "Deploy & Run Transactions" 图标。
   - Environment 选择 "**Injected Provider - MetaMask**" (确保 MetaMask 连在 Sepolia)。
   - Contract 选择 `MyNFT`。
   - 点击 "Deploy" 并确认交易。
   - **记录 MyNFT 合约地址** (例如 `0x123...`).

5. **部署 NFTMarket**:
   - Contract 选择 `NFTMarket`。
   - 点击 "Deploy" 并确认交易。
   - **记录 NFTMarket 合约地址** (例如 `0xABC...`).

## 步骤三：铸造 (Mint) NFT

1. 在 Remix 的 "Deployed Contracts" 区域找到 `MyNFT`。
2. 展开 `mint` 函数。
3. 参数填写：
   - `to`: 你的钱包地址。
   - `uri`: 步骤一中获得的 Metadata URI (例如 `ipfs://QmRef...`)。
4. 点击 "transact" 并确认。
5. 等待交易确认。此时你已拥有 tokenId 为 `0` 的 NFT（因为代码是从 0 开始计数的）。

## 步骤四：查看 OpenSea

1. 前往 [OpenSea Testnet](https://testnets.opensea.io/)。
2. 搜索你的 `MyNFT` 合约地址，或者连接钱包查看 "My Profile" -> "Collected"。
3. 你应该能看到你刚才铸造的图片显示出来了！

## 步骤五：在 Market 上架 (List)

要将 NFT 上架到 Market，需要两步：**授权** 和 **上架**。

1. **授权 (Approve)**:
   - 在 Remix 找到 `MyNFT` 合约。
   - 找到 `approve` 函数。
   - `to`: 填入 **NFTMarket 合约地址**。
   - `tokenId`: `0` (你刚才铸造的 ID)。
   - 点击 "transact"。

2. **上架 (List)**:
   - 在 Remix 找到 `NFTMarket` 合约。
   - 找到 `list` 函数。
   - `nft`: `MyNFT` 合约地址。
   - `tokenId`: `0`。
   - `price`: 设置价格 (单位是 wei)。例如 0.001 ETH = `1000000000000000` (15个0)。
   - 点击 "transact"。

## 步骤六：购买 (Buy)

为了测试购买，你可以切换到 MetaMask 的另一个账户（或者让朋友帮忙）。

1. 切换 MetaMask 账户。
2. 在 Remix `NFTMarket` 合约中找到 `buy` 函数。
3. `nft`: `MyNFT` 合约地址。
4. `tokenId`: `0`。
5. **重要**: 在 "Value" 输入框（Remix 左上角）填入 `0.001` 并选择 `Ether` (要与上架价格一致)。
6. 点击 "transact"。
7. 交易成功后，NFT 所有权将转移给购买者，卖家将收到 ETH。

## 常用链接
- [Sepolia Scan](https://sepolia.etherscan.io/) (查询交易)
- [OpenSea Testnet](https://testnets.opensea.io/) (查看 NFT)
