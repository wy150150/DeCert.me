# NFT Market 实战

## 目标
实现一个简单的 NFT 市场，支持使用 ERC20 代币购买 ERC721 NFT。

## 主要功能
1. **上架 (List)**
   - 卖家必须拥有 NFT。
   - 卖家需要将 NFT 转移给 `NFTMarket` 合约进行托管（`safeTransferFrom`）。
   - 托管前需先 `approve` 市场合约。
   
2. **购买 (Buy)**
   - 买家支付 ERC20 代币给卖家。
   - 市场将 NFT 转移给买家。
   - 交易原子性：一手交钱，一手交货。

3. **下架 (Cancel)**
   - 卖家可以随时取消上架，取回 NFT。

## 文件说明
- `MyNFT.sol`: 基于 ERC721URIStorage 的标准 NFT 合约，用于铸造测试用的 NFT。
- `NFTMarket.sol`: 市场逻辑合约，托管 NFT 并处理买卖。

## 部署与测试建议
1. 部署一个 ERC20 代币（可复用之前的 BERC20）。
2. 部署 `MyNFT` 合约。
3. 部署 `NFTMarket` 合约，传入 ERC20 和 MyNFT 地址。
4. 铸造 NFT 给用户 A。
5. 用户 A `approve` 市场合约，调用 `list` 上架。
6. 用户 B `approve` 市场合约使用其 ERC20 代币。
7. 用户 B 调用 `buy` 购买 NFT。
