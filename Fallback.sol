// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
/*
在 Solidity 中，处理以太币接收的函数有 receive 和 fallback，它们的调用规则如下：
当向合约发送以太币且 msg.data 为空时，如果合约中存在 receive 函数，那么会优先调用 receive 函数。
当向合约发送以太币且 msg.data 为空，但是合约中不存在 receive 函数时，若 fallback 函数使用了 payable 修饰，就会调用该 fallback 函数；若 fallback 函数没有使用 payable 修饰，那么此次以太币发送操作将会失败。

fallback 函数：在调用合约中不存在的函数或者调用时携带了数据但没有匹配到具体函数时被调用。
receive 函数：在向合约发送以太币且不附带任何数据时被调用。

总结：receive只有在不携带任何信息，且发送以太币的时候才调用

且二者同时存在时候只会触发一个调用

*/
contract Fallback{

    event Log(string func,address sendere,uint value,bytes data);
    //CALLDATA的时候
    //当调用不存在的函数的时候会默认调用到fallback方法
    fallback() external payable {
        emit Log("fallback",msg.sender,msg.value,msg.data);
    }
    //CALLDATA的时候
    //data 为空的时候走这个
    receive() external payable {
        emit Log("receive",msg.sender,msg.value,"");
    }

}