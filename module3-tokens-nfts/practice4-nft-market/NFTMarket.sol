// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * 示例包含三个合约：
 * 1. MyToken (ERC777，用作可回调的 ERC20 扩展 Token)
 * 2. MyNFT (ERC721)
 * 3. NFTMarket (NFT 市场，支持 list / buyNFT / tokensReceived)
 *
 * 重点：
 * - 使用 ERC777 的 tokensReceived 回调完成“转 Token 即买 NFT”
 * - 额外数据 data 中携带 tokenId
 */

import "@openzeppelin/contracts@4.9.5/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts@4.9.5/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.9.5/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts@4.9.5/utils/introspection/IERC1820Registry.sol";

/* ---------------- ERC777 Token ---------------- */
contract MyToken is ERC777 {
    constructor(uint256 initialSupply)
        ERC777("MarketToken", "MTK", new address[](0))
    {
        _mint(msg.sender, initialSupply, "", "");
    }
}

/* ---------------- ERC721 NFT ---------------- */
contract MyNFT is ERC721 {
    uint256 public nextId;

    constructor() ERC721("MyNFT", "MNFT") {}

    function mint(address to) external {
        _mint(to, nextId);
        nextId++;
    }
}

/* ---------------- NFT Market ---------------- */
contract NFTMarket is IERC777Recipient {
    IERC1820Registry private constant _ERC1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    bytes32 private constant TOKENS_RECIPIENT_HASH =
        keccak256("ERC777TokensRecipient");

    IERC777 public immutable token;

    struct Listing {
        address seller;
        uint256 price;
    }

    // nft => tokenId => listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    constructor(IERC777 _token) {
        token = _token;
        _ERC1820.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_HASH,
            address(this)
        );
    }

    /* -------- list NFT -------- */
    function list(address nft, uint256 tokenId, uint256 price) external {
        require(price > 0, "price=0");
        IERC721 erc721 = IERC721(nft);
        require(erc721.ownerOf(tokenId) == msg.sender, "not owner");

        erc721.transferFrom(msg.sender, address(this), tokenId);
        listings[nft][tokenId] = Listing({
            seller: msg.sender,
            price: price
        });
    }

    /* -------- 普通购买方式 -------- */
    function buyNFT(address nft, uint256 tokenId) external {
        Listing memory item = listings[nft][tokenId];
        require(item.price > 0, "not listed");

        delete listings[nft][tokenId];

        token.operatorSend(
            msg.sender,
            item.seller,
            item.price,
            "",
            ""
        );

        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
    }

    /* -------- ERC777 回调购买 -------- */
    /*
     * data 编码格式：abi.encode(address nft, uint256 tokenId)
     */
    function tokensReceived(
        address /*operator*/,
        address from,
        address /*to*/,
        uint256 amount,
        bytes calldata data,
        bytes calldata /*operatorData*/
    ) external override {
        require(msg.sender == address(token), "invalid token");

        (address nft, uint256 tokenId) = abi.decode(data, (address, uint256));
        Listing memory item = listings[nft][tokenId];

        require(item.price > 0, "not listed");
        require(amount == item.price, "price mismatch");

        delete listings[nft][tokenId];

        // Token 已经在转账过程中到达 market，这里直接转给卖家
        token.send(item.seller, amount, "");

        IERC721(nft).transferFrom(address(this), from, tokenId);
    }
}
