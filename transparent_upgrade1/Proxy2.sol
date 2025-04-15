// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
/*
测试的时候先部署proxy 然后 v1设置为代理合约的implementation，然后
选择v1合约，At Address：proxy的地址，则当前地址会被加载为新的合约可以处理v1的各种方法

*/
contract CounterV1{
    //添加这俩是为了和代理合约的状态变量的布局一致
    uint256 public count;

    function inc() external {
        count=count+1;
    }
}

contract CounterV2{

    uint256 public count;

    function inc() external {
        count +=1;
    }

    function dec() external {
        count -=1;
    }
}
contract Proxy{
    //给对应的槽位指针赋值，防止操作地址冲突
    bytes32 public constant IMPLEMENATION_SLOT = bytes32(uint(keccak256("eip1967.proxy.implementation"))-1);

    bytes32 public constant ADMIN_SLOT = bytes32(uint(keccak256("eip1967.proxy.admin"))-1);

    constructor(){
        _setAdmin(msg.sender);
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
        _delegate(_getImplemenation());
    }

    receive() external payable {
        _delegate(_getImplemenation());
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == _getAdmin(), "not authorized");
        _setImplemenation(_implementation);
    }

    function _setAdmin(address _admin) private {
        require(_admin!=address(0),"cannot set admin");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value=_admin;
    }

   
    function _getAdmin() private  view  returns(address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setImplemenation(address _implemenation) private {
        require(_implemenation.code.length > 0,"cannot set implemenation");
        StorageSlot.getAddressSlot(IMPLEMENATION_SLOT).value=_implemenation;
    }

  
    function _getImplemenation() private view returns(address) {
        return StorageSlot.getAddressSlot(IMPLEMENATION_SLOT).value;
    }
    
    function getAdmin() external   view  returns(address) {
        return _getAdmin();
    }
    function getImplemenation() external  view returns(address) {
        return _getImplemenation();
    }
}

// 存储槽操作库 - 用于安全访问EVM的特定存储槽
library StorageSlot {
    // 定义存储槽结构体（封装address类型数据）
    // 作用：在指定槽位存储一个address类型数据
    struct AddressSlot {
        address value; // 实际存储的地址值
    }

    // 获取指定存储槽的引用
    // 参数说明：
    // slot -> 要操作的存储槽位置（32字节的bytes32类型）
    // 返回：该存储槽的AddressSlot结构体引用（可直接修改）
    // 关键设计：使用汇编直接指定存储位置，绕过Solidity的类型安全检查
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot // 将返回结构体AddressSlot的存储指针指向目标slot
        }
    }
}

contract TestSlot {
    // 定义存储槽位置常量（重要安全设置）
    // 通过keccak256哈希计算结果作为存储槽位置：
    // 1. 避免存储位置冲突（使用伪随机生成的槽位）
    // 2. 字符串"TEST_SLOT"作为随机种子，确保槽位唯一性
    bytes32 public constant SLOT = keccak256("TEST_SLOT");

    // 读取存储槽地址
    function getSlot() external view returns (address) {
        // 访问流程：
        // 1. 通过预定义槽位SLOT获取存储引用
        // 2. 返回存储的address值
        return StorageSlot.getAddressSlot(SLOT).value;
    }

    // 写入存储槽地址
    // 参数说明：
    // _addr -> 要写入的新地址（外部传入的可信任地址）
    function writeSlot(address _addr) external {
        // 写入流程：
        // 1. 获取SLOT对应的存储引用
        // 2. 修改其value值为新地址
        StorageSlot.getAddressSlot(SLOT).value = _addr;
    }
}