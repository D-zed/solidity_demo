// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 打log的方式，存在链上，不能在合约中再次获取，比状态便宜，一次性的记录事件可以用事件存储数据
contract Event {

    event Log(string message,uint val);
    // 最多只能有三个indexed
    event IndexedLog(address indexed sender,uint val);

    function example() external {
        emit Log("message", 1234);
        emit IndexedLog(msg.sender, 5678);
    }

    event Message(address indexed _from,address indexed _to,string messge);

    function sendMessage(address _to,string calldata m) external {
        emit Message(msg.sender, _to, m);
    }


}