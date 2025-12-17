# NFT Market 实战

## 目标
实现 Token 与 NFT 的兑换，掌握 NFT 市场上架、买卖、下架的实现。

## 功能特性
1. **上架 (List)**:
   - 卖家设定价格。
   - 调用 `list` 函数，将 NFT 所有权转移给 `NFTMarket` 合约（托管模式）。
2. **购买 (Buy)**:
   - 买家调用 `buy` 函数。
   - 检查买家对 ERC20 的授权额度。
   - 执行 ERC20 转账：买家 -> 卖家。
   - 执行 NFT 转账：Market -> 买家。
3. **下架 (Cancel)**:
   - 卖家可以随时取回未售出的 NFT。

## 合约文件
- `MyNFT.sol`: 用于测试发行的 ERC721。
- `NFTMarket.sol`: NFT 交易市场逻辑。

## 部署与交互流程
1. 部署 `BaseERC20` (作为支付代币)。
2. 部署 `MyNFT`。
3. 部署 `NFTMarket` (传入上述两个地址)。
4. 铸造 NFT 给用户 A，铸造 ERC20 给用户 B。
5. **上架**: 用户 A `approve` Market 合约，然后调用 `list`。
6. **购买**: 用户 B `approve` Market 合约 (ERC20)，然后调用 `buy`。
