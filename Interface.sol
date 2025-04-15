// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Counter{
    uint public count;

    function increment() external {
        count++;
    }

}
//接口的调用
interface ICounter {
    //签名定义
    function count() external view returns(uint);
    function increment() external;
}

contract MyContract {

    function incrementCounter(address _counter) external {
        //将counter的合约的地址强转为Counter合约
        ICounter(_counter).increment();
    }

    function getCount(address _count) external view returns(uint){
        // 获取状态变量count
        return ICounter(_count).count();
    }
}