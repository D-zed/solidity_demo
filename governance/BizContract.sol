// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

//提案合约
contract BizContract{
    uint public x;

    function call(uint _var) external payable {
        x = _var;
    }

    function showCallData() external view  returns (bytes memory) {
        return abi.encodeCall(this.call,(1));
    }
}