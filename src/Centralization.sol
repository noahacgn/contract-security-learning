// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/*
如何减少中心化/伪去中心化风险？

1. 使用多签钱包管理国库和控制合约参数。为了兼顾效率和去中心化，可以选择 4/7 或 6/9 多签。如果你不了解多签钱包，可以阅读WTF Solidity 第 50 讲：多签钱包。
2. 多签的持有人要多样化，分散在创始团队、投资人、社区领袖之间，并且不要相互授权签名。
3. 使用时间锁控制合约，在黑客或项目内鬼修改合约参数/盗取资产时，项目方和社区有一些时间来应对，将损失最小化。如果你不了解时间锁合约，可以阅读WTF Solidity 第 45 讲：时间锁。
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Centralization is ERC20, Ownable {

    constructor() ERC20("Centralization", "Cent") Ownable(msg.sender) {
        address exposedAccount = 0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2;
        transferOwnership(exposedAccount);
    }

    function mint(address to, uint256 amount) external onlyOwner{
        _mint(to, amount);
    }
}
