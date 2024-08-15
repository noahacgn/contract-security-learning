// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
预防办法
你可以使用以下几种方法来预防未检查低级调用的漏洞：

1. 检查低级调用的返回值，在上面的银行合约中，我们可以改正 withdraw()。

bool success = payable(msg.sender).send(balance);
require(success, "Failed Sending ETH!")

2. 合约转账ETH时，使用 call()，并做好重入保护。

3. 使用OpenZeppelin的Address库，它将检查返回值的低级调用封装好了。
*/

contract Bank {

    mapping(address => uint256) public balanceOf;

    uint256 private _status;

    modifier reentrantLock() {
        require(_status == 0, "reentrant call");
        _status = 1;
        _;
        _status = 0;
    }

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw() external reentrantLock {
        // query
        uint256 balance = balanceOf[msg.sender];
        require(balance > 0, "no money");

        // transfer
        (bool ok,) = msg.sender.call{value: balance}("");

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
        revert("unchecked call");
    }

    function attack() external payable {
        require(msg.value == 1 ether, "need 1 ether to attack");
        bank.deposit{value: 1 ether}();
        bank.withdraw();
    }
}
