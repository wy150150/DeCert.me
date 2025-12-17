// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title 这里的接口定义了我们预期的回调方法
 * 为了简单起见，我们定义一个简化版的 tokensReceived
 */
interface ITokenReceiver {
    function tokensReceived(
        address from,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

/**
 * @title ERC20 扩展 Token
 * @dev 在标准 ERC20 基础上增加 transferWithCallback
 */
contract ExtendedERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 10000 * 10**decimals());
    }

    // 铸造函数（为了测试方便）
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    /**
     * @dev 扩展的转账方法，支持携带数据并回调接收者
     */
    function transferWithCallback(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        _transfer(msg.sender, recipient, amount);

        // 如果接收者是合约，尝试调用其回调函数
        if (recipient.code.length > 0) {
            bool rv = ITokenReceiver(recipient).tokensReceived(msg.sender, amount, data);
            require(rv, "No tokensReceived");
        }
        return true;
    }
}

/**
 * @title NFTMarket
 * @dev 使用自定义的 ERC20 扩展 Token 进行买卖
 */
contract NFTMarket is ReentrancyGuard, ITokenReceiver {
    struct Listing {
        address seller;
        uint256 price;
    }

    ExtendedERC20 public paymentToken;
    // nft => tokenId => Listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    event Listed(address indexed nft, uint256 indexed tokenId, address seller, uint256 price);
    event Bought(address indexed nft, uint256 indexed tokenId, address buyer, uint256 price);

    constructor(address _paymentToken) {
        paymentToken = ExtendedERC20(_paymentToken);
    }

    /**
     * @notice 上架功能
     * @dev NFT 持有者需先 approve NFT 给 Market
     */
    function list(
        address nft,
        uint256 tokenId,
        uint256 price
    ) external {
        require(price > 0, "Price must be > 0");
        IERC721 token = IERC721(nft);
        
        require(token.ownerOf(tokenId) == msg.sender, "Not owner");
        require(
            token.getApproved(tokenId) == address(this) || 
            token.isApprovedForAll(msg.sender, address(this)), 
            "Not approved"
        );

        // 将 NFT 转入 Market 托管
        token.transferFrom(msg.sender, address(this), tokenId);

        listings[nft][tokenId] = Listing({
            seller: msg.sender,
            price: price
        });

        emit Listed(nft, tokenId, msg.sender, price);
    }

    /**
     * @notice 普通购买功能 (buyNFT)
     * @dev 用户需先 approve ERC20 给 Market
     */
    function buyNFT(address nft, uint256 tokenId) external nonReentrant {
        Listing memory item = listings[nft][tokenId];
        require(item.price > 0, "Not listed");

        // 删除上架信息
        delete listings[nft][tokenId];

        // 转移代币: Buyer -> Seller
        bool success = paymentToken.transferFrom(msg.sender, item.seller, item.price);
        require(success, "Token transfer failed");

        // 转移 NFT: Market -> Buyer
        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);

        emit Bought(nft, tokenId, msg.sender, item.price);
    }

    /**
     * @notice 实现 ERC20 扩展 Token 的接收者方法
     * @dev 能够处理 "转账即购买"
     * @param from 付款人
     * @param amount 付款金额
     * @param data 附加数据 (应包含 nftAddress 和 tokenId)
     */
    function tokensReceived(
        address from,
        uint256 amount,
        bytes calldata data
    ) external override nonReentrant returns (bool) {
        // 确保回调来自指定的 paymentToken
        require(msg.sender == address(paymentToken), "Invalid token");

        // 解析 data: (address nft, uint256 tokenId)
        (address nft, uint256 tokenId) = abi.decode(data, (address, uint256));

        Listing memory item = listings[nft][tokenId];
        require(item.price > 0, "Not listed");
        require(amount == item.price, "Incorrect price");

        // 交易确认：代币已经转入本合约(Market)
        // 我们需要把代币转发给卖家 (seller)
        delete listings[nft][tokenId];

        // 此时 Market 已经拥有了 amount 数量的代币，直接转给 seller
        paymentToken.transfer(item.seller, amount);

        // 将 NFT 转给买家 (from)
        IERC721(nft).transferFrom(address(this), from, tokenId);

        emit Bought(nft, tokenId, from, item.price);
        return true;
    }
    
    // 增加一个辅助函数用于生成 data，方便测试
    function getCallData(address nft, uint256 tokenId) public pure returns (bytes memory) {
        return abi.encode(nft, tokenId);
    }
}
