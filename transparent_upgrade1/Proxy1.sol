// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
/*
测试的时候先部署proxy 然后 v1设置为代理合约的implementation，然后
选择v1合约，At Address：proxy的地址，则当前地址会被加载为新的合约可以处理v1的各种方法

*/
contract CounterV1{
    //添加这俩是为了和代理合约的状态变量的布局一致
    address public  implementation;
    address public admin;
    uint256 public count;

    function inc() external {
        count=count+1;
    }
}

contract CounterV2{
    address public  implementation;

    address public admin;
    uint256 public count;

    function inc() external {
        count +=1;
    }

    function dec() external {
        count -=1;
    }
}
contract BuggyProxy{
    address public  implementation;

    address public admin;

    constructor(){
        admin=msg.sender;
    }

    function _delegate(address _implementation) private {
        assembly {
            // 将calldata完整复制到内存0位置
            // 参数说明：
            // 0 - 目标内存起始位置  EVM的内存是一个连续的字节数组 内存起始位置0指的是这个字节数组的第一个存储单元（0x00位置）内存地址0x00在每个新调用帧中都是"全新"的
            // 0 - 源calldata起始位置
            // calldatasize() - 要复制的字节长度
            calldatacopy(0, 0, calldatasize())

            // 执行委托调用（关键代理逻辑）
            // 参数说明：
            // gas() - 传递当前剩余的所有gas
            // _implementation - 目标合约地址
            // 0 - 输入数据在内存的起始位置
            // calldatasize() - 输入数据长度
            // 0 - 输出数据存放的内存位置（暂时置0）
            // 0 - 输出数据长度（暂时置0）
            let result := delegatecall(
                gas(),
                _implementation,
                0,
                calldatasize(),
                0,
                0
            )

            // 将返回数据完整复制到内存0位置
            // 参数说明：
            // 0 - 目标内存起始位置
            // 0 - 源返回数据起始位置
            // returndatasize() - 返回数据的字节长度
            returndatacopy(0, 0, returndatasize())

            // 处理调用结果
            switch result
            case 0 {  // 调用失败
                // 回滚状态并返回错误数据
                // 参数说明：
                // 0 - 错误数据在内存的起始位置
                // returndatasize() - 错误数据长度
                revert(0, returndatasize())
            }
            default {  // 调用成功
                // 返回执行结果数据
                // 参数说明：
                // 0 - 返回数据在内存的起始位置
                // returndatasize() - 返回数据长度
                return(0, returndatasize())
            }
        }
    }
    

    fallback() payable external{
        _delegate(implementation);
    }

    receive() external payable {
        _delegate(implementation);
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not authorized");
        implementation=_implementation;
    }
  
}
