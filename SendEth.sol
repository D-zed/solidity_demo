// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract SendEth{
    constructor() payable {

    }
    // 不携带信息发送以太币的时候
    receive() external payable { }

    /*
    参数：_to 是一个 address payable 类型的参数，表示接收以太币的地址。
功能：该函数通过 transfer 方法向 _to 地址发送 123 wei 的以太币。transfer 是 Solidity 中用于发送以太币的一种方法。
特点：transfer 方法是一个安全的发送方式，它会自动处理交易失败的情况。如果发送失败，会抛出异常并回滚当前交易。它会预留 2300 gas 用于执行接收地址的 receive 或 fallback 函数
    少量使用
    */
    function senViaTransfer(address payable _to) external payable{
        _to.transfer(123);
    }

    /*
    参数：同样，_to 是接收以太币的地址。
功能：使用 send 方法向 _to 地址发送 123 wei 的以太币。send 方法返回一个布尔值，表示发送是否成功。
特点：send 方法的安全性不如 transfer。如果发送失败，它不会抛出异常，而是返回 false。因此，需要手动检查返回值并处理失败情况，如代码中使用 require 语句。它也会预留 2300 gas 用于执行接收地址的 receive 或 fallback 函数。
    几乎不会用
    */
    function sendViaSend(address payable _to) external payable {
        bool sent= _to.send(123);
        require(sent,"send failed");
    }

    /*
    参数：_to 为接收以太币的地址。
功能：使用 call 方法向 _to 地址发送 123 wei 的以太币。call 方法是一个更底层的调用，它可以执行任意的消息调用，包括发送以太币。
特点：call 方法是最灵活但也是最危险的发送方式。它不会限制执行接收地址的 receive 或 fallback 函数时使用的 gas 量，这意味着接收地址的代码可能会消耗大量 gas 导致发送失败。同时，它返回一个布尔值表示调用是否成功，需要手动检查。
    老师建议这个最常用
    */
    function sendViaCall(address payable _to) external  payable {
        (bool success,)= _to.call{value: 123}("");
        require(success,"call failed");
    }
}

contract EthReceiver{
    event Log(uint amout,uint gas);

    receive() external payable { 
        emit Log(msg.value,gasleft());
    }
}