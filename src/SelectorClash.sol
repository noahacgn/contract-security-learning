// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// 函数选择器很容易被碰撞，即使改变参数类型，依然能构造出具有相同选择器的函数。
// 管理好合约函数的权限，确保拥有特殊权限的合约的函数不能被用户调用。

contract SelectorClash {

    bool public b;

    function putCurEpochConPubKeyBytes(bytes memory _bytes) external {
        require(msg.sender == address(this));
        b = true;
    }

    function executeCrossChainTx(string memory _method, bytes memory _bytes, bytes memory _bytes1, uint64 _num) public returns(bool success) {
        (success, ) = address(this).call(
            abi.encodeWithSelector(
                bytes4(keccak256(abi.encodePacked(_method))),
                _bytes,
                _bytes1,
                _num)
            );
    }
}
