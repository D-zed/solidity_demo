// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract GlobleVaraible{
    //view 可以读取区块链上的变量
    // pure 不可以读取区块链上的数据，但是都是只读的
    // external 只可以从合约外部调用，不可以在合约内部调用
    function globalVars() external view returns (address,uint,uint){
        address sender= msg.sender;
        uint timestamp=block.timestamp;
        uint blockNum= block.number;
        return (sender,timestamp,blockNum);
    }
}