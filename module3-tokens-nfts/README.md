# NFT 实战系列

## Practice 3: 铸造 NFT (MyNFT)
使用 ERC721 标准（基于 OpenZeppelin）发行 NFT 合约。
- **合约文件**: `module3-tokens-nfts/practice3-mint-nft/MyNFT.sol`
- **功能**:
  - `mintNFT(recipient, tokenURI)`: 铸造并设置元数据 URI。
- **资源上传**:
  - 图片和 JSON 元数据建议上传至 IPFS (如使用 Pinata)。
  - 示例 OpenSea 链接: (此处需用户在部署后填入实际链接)

## Practice 4: NFT 市场 (NFTMarket)
实现一个简单的 NFT 交易市场，支持使用 ERC20 代币购买 NFT。
- **合约文件**: `module3-tokens-nfts/practice4-nft-market/NFTMarket.sol`
- **功能**:
  - `list(tokenId, price)`: 上架 NFT (需先授权)。NFT 会被转移到市场合约托管。
  - `buy(tokenId)`: 购买 NFT。买家支付 ERC20 代币给卖家，市场将 NFT 转给买家。
  - `cancel(tokenId)`: 卖家取消上架，取回 NFT。
  - `onERC721Received`: 实现接收 NFT 的钩子函数。
