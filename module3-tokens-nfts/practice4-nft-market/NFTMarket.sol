// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    // nft => tokenId => listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    event Listed(address indexed nft, uint256 indexed tokenId, address seller, uint256 price);
    event Sold(address indexed nft, uint256 indexed tokenId, address buyer, uint256 price);
    event Cancelled(address indexed nft, uint256 indexed tokenId);

    function list(
        address nft,
        uint256 tokenId,
        uint256 price
    ) external {
        require(price > 0, "price must > 0");

        IERC721 token = IERC721(nft);
        require(token.ownerOf(tokenId) == msg.sender, "not owner");
        require(
            token.getApproved(tokenId) == address(this) ||
            token.isApprovedForAll(msg.sender, address(this)),
            "market not approved"
        );

        listings[nft][tokenId] = Listing(msg.sender, price);
        emit Listed(nft, tokenId, msg.sender, price);
    }

    function buy(address nft, uint256 tokenId) external payable nonReentrant {
        Listing memory item = listings[nft][tokenId];
        require(item.price > 0, "not listed");
        require(msg.value == item.price, "incorrect price");

        delete listings[nft][tokenId];

        payable(item.seller).transfer(msg.value);
        IERC721(nft).safeTransferFrom(item.seller, msg.sender, tokenId);

        emit Sold(nft, tokenId, msg.sender, item.price);
    }

    function cancel(address nft, uint256 tokenId) external {
        Listing memory item = listings[nft][tokenId];
        require(item.seller == msg.sender, "not seller");

        delete listings[nft][tokenId];
        emit Cancelled(nft, tokenId);
    }
}