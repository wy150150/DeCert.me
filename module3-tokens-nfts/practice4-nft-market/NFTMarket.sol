// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarket is IERC721Receiver {
    struct Listing {
        address seller;
        uint256 price;
    }

    IERC20 public paymentToken;
    IERC721 public nftContract;

    // NFT ID -> Listing info
    mapping(uint256 => Listing) public listings;

    event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event Sold(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event Canceled(address indexed seller, uint256 indexed tokenId);

    constructor(address _paymentToken, address _nftContract) {
        paymentToken = IERC20(_paymentToken);
        nftContract = IERC721(_nftContract);
    }

    // 上架：卖家需要先 approve NFTMarket 合约
    function list(uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be > 0");
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(
            nftContract.isApprovedForAll(msg.sender, address(this)) ||
            nftContract.getApproved(tokenId) == address(this),
            "Market not approved"
        );

        // 转移 NFT 到市场合约
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
        
        listings[tokenId] = Listing(msg.sender, price);
        emit Listed(msg.sender, tokenId, price);
    }

    // 购买
    function buy(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "Not listed");

        // 转移代币：买家 -> 卖家
        require(paymentToken.transferFrom(msg.sender, listing.seller, listing.price), "Transfer failed");

        // 转移 NFT：市场 -> 买家
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        // 删除上架信息
        delete listings[tokenId];
        emit Sold(msg.sender, tokenId, listing.price);
    }

    // 取消上架/赎回（只有卖家自己操作）(作业扩展要求，通常市场应支持cancel)
    function cancel(uint256 tokenId) external {
         Listing memory listing = listings[tokenId];
         require(listing.seller == msg.sender, "Not the seller");
         
         nftContract.safeTransferFrom(address(this), msg.sender, tokenId);
         
         delete listings[tokenId];
         emit Canceled(msg.sender, tokenId);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
