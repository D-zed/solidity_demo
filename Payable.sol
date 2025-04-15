// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Payable{

    //address payable：这是一个特殊的地址类型，用于表示可以接收以太币（ETH）的地址。普通的 address 类型不能直接接收以太币，而 address payable 可
    address payable public owner;

    constructor(){
        //payable(msg.sender)：将 msg.sender 转换为 address payable 类型，然后将其赋值给 owner 变量。这样，合约的所有者地址就被记录下来了。
        owner=payable(msg.sender);
    }

    //外部调用可以发送以太过来
    function deposit() external payable  {

    }

    function getBalance() external  view returns(uint){
        return address(this).balance;
    }
}