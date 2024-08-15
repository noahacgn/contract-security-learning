// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Bank {

    mapping(address => uint256) balanceOf;

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw() external {
        // check
        uint256 balance = balanceOf[msg.sender];
        require(balance > 0, "no money");

        // effect
        balanceOf[msg.sender] = 0;

        // interaction
        (bool ok,) = msg.sender.call{value: balance}("");
        require(ok, "call failed");
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
