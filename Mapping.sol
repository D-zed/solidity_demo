// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Mapping {
    // key:address val:uint256
    mapping(address => uint256) public balances;

    //
    mapping(address => mapping (address => bool))public isFriend;

    function examples() external {
        balances[msg.sender] = 123;
        uint bal=balances[msg.sender];
        uint bal2=balances[address(1)];
        balances[msg.sender]+=465;
        delete balances[msg.sender];

        isFriend[msg.sender][address(this)]=true;
    }
}