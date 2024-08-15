// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// 预防办法

// Solidity 0.8.0 之前的版本，在合约中引用 Safemath 库，在整型溢出时报错。
// Solidity 0.8.0 之后的版本内置了 Safemath，因此几乎不存在这类问题。开发者有时会为了节省gas使用 unchecked 关键字在代码块中临时关闭整型溢出检测，这时要确保不存在整型溢出漏洞。

contract Overflow {

    mapping(address => uint256) public banlanceOf;

    function transfer(address _to, uint256 _amount) external {
        unchecked {
            require(banlanceOf[msg.sender] - _amount >= 0, "Insufficient balance");
            banlanceOf[msg.sender] -= _amount;
            banlanceOf[_to] += _amount;
        }
    }
}
