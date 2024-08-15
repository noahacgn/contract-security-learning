// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
此外，OpenZeppelin 也提倡遵循 PullPayment(拉取支付)模式以避免潜在的重入攻击。其原理是通过引入第三方(escrow)，
将原先的“主动转账”分解为“转账者发起转账”加上“接受者主动拉取”。当想要发起一笔转账时，
会通过_asyncTransfer(address dest, uint256 amount)将待转账金额存储到第三方合约中，
从而避免因重入导致的自身资产损失。而当接受者想要接受转账时，需要主动调用withdrawPayments(address payable payee)进行资产的主动获取。
*/

contract Bank {

    mapping(address => uint256) balanceOf;

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
