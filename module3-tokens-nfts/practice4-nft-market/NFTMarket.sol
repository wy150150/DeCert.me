// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarket is IERC721Receiver {
    IERC20 public paymentToken;
    IERC721 public nftContract;

    struct Listing {
        address seller;
        uint256 price;
    }

    // TokenId => Listing
    mapping(uint256 => Listing) public listings;

    event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event Purchased(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event Canceled(address indexed seller, uint256 indexed tokenId);

    constructor(address _paymentToken, address _nftContract) {
        paymentToken = IERC20(_paymentToken);
        nftContract = IERC721(_nftContract);
    }

    /**
     * @notice 上架 NFT (需要先 approve)
     * @param tokenId 要上架的 NFT ID
     * @param price 出售价格
     */
    function list(uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be > 0");
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not owner");
        require(
            nftContract.getApproved(tokenId) == address(this) || nftContract.isApprovedForAll(msg.sender, address(this)),
            "Market not approved"
        );

        // 将 NFT 转入 Market 合约托管
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);

        listings[tokenId] = Listing(msg.sender, price);
        emit Listed(msg.sender, tokenId, price);
    }

    /**
     * @notice 购买 NFT
     * @param tokenId 要购买的 NFT ID
     */
    function buy(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "Not listed");

        // 转移代币：Buyer -> Seller
        bool success = paymentToken.transferFrom(msg.sender, listing.seller, listing.price);
        require(success, "Payment failed");

        // 转移 NFT：Market -> Buyer
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        // 清除上架信息
        delete listings[tokenId];

        emit Purchased(msg.sender, tokenId, listing.price);
    }

    /**
     * @notice 取消上架 (仅卖家)
     */
    function cancel(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.seller == msg.sender, "Not seller");

        // 此时 NFT 在 Market 合约中，转回给卖家
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        delete listings[tokenId];
        emit Canceled(msg.sender, tokenId);
    }

    // 实现 IERC721Receiver 以接收 NFT
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
