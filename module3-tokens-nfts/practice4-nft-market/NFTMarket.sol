// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title NFTMarket
 * @dev 简单的 NFT 市场，支持使用 ERC20 代币购买 NFT
 */
contract NFTMarket is IERC721Receiver {
    // 支付使用的代币
    IERC20 public paymentToken;
    // 交易的 NFT 合约
    IERC721 public nftContract;

    struct Listing {
        address seller;
        uint256 price;
    }

    // tokenId => Listing
    mapping(uint256 => Listing) public listings;

    event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event Purchased(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event Canceled(address indexed seller, uint256 indexed tokenId);

    constructor(address _paymentToken, address _nftContract) {
        paymentToken = IERC20(_paymentToken);
        nftContract = IERC721(_nftContract);
    }

    /**
     * @notice 上架 NFT（需要先 approve 或 setApprovalForAll）
     * 方式1：用户先 approve NFT 给市场，然后调用此 list 函数（市场内部调用 transferFrom 将 NFT 转入市场合约）
     */
    function list(uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be > 0");
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not owner");
        
        // 也就是市场托管模式：卖家将 NFT 转给 Metket 合约持有
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);

        listings[tokenId] = Listing(msg.sender, price);
        
        emit Listed(msg.sender, tokenId, price);
    }

    /**
     * @notice 购买 NFT
     */
    function buy(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "Not listed");
        
        // 删除 listing，防止重入/重复购买
        delete listings[tokenId];

        // 1. 转账 ERC20：买家 -> 卖家
        require(paymentToken.transferFrom(msg.sender, listing.seller, listing.price), "Transfer failed");

        // 2. 转移 NFT：市场 -> 买家
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Purchased(msg.sender, tokenId, listing.price);
    }

    /**
     * @notice 取消上架（赎回 NFT）
     */
    function cancel(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.seller == msg.sender, "Not seller");

        delete listings[tokenId];
        
        // 将 NFT 转回给卖家
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Canceled(msg.sender, tokenId);
    }

    /**
     * @notice 用于接收 safeTransferFrom 转过来的 NFT
     * 也可以通过扩展此函数来实现“转入即上架”的功能 (onERC721Received hook)
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
