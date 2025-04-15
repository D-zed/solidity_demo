// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Constructor{
    address public owner;

    uint public x;

    //构造函数只能在部署的时候调用一次
    constructor(uint _x){
        x=_x;
        owner=msg.sender;
    }
}