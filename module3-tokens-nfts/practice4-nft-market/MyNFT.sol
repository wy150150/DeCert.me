// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public nextTokenId;

    // tokenId => tokenURI
    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    function mint(address to, string memory uri) external onlyOwner {
        uint256 tokenId = nextTokenId;
        nextTokenId++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_ownerOf(tokenId) != address(0), "URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _tokenURIs[tokenId];
    }
}