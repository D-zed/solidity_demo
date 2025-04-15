// SPDX-License-Identifier: MIT
//指定该合约的开源许可证为 MIT 许可证。
pragma solidity ^0.8.7;

// Runtime code
// Creation code
// 构造字节码 + 运行字节码组成一整个合约字节码
// Factory contract 通过工厂合约来运行字节码
/*
运行时字节码：602a60005260206000f3
PUSH1 0x2a    // 将数字 42（十六进制为 0x2a）压入栈中
PUSH1 0       // 将内存偏移量 0 压入栈中
MSTORE        // 将栈顶的数字 42 存储到内存偏移量为 0 的位置
PUSH1 0x20    // 将返回数据的长度 32 字节（十六进制为 0x20）压入栈中
PUSH1 0       // 将返回数据的起始内存偏移量 0 压入栈中
RETURN        // 从内存偏移量 0 开始返回 32 字节的数据

创建字节码：69602a60005260206000f3600052600a6016f3
PUSH10 602a60005260206000f3    // 将运行时代码压入栈中
PUSH1 0                        // 将内存偏移量 0 压入栈中
MSTORE                         // 将运行时代码存储到内存偏移量为 0 的位置
PUSH1 0x0a                     // 将返回数据的长度 10 字节（十六进制为 0x0a）压入栈中
PUSH1 0x16                     // 将返回数据的起始内存偏移量 22（十六进制为 0x16）压入栈中
RETURN                         // 从内存偏移量 22 开始返回 10 字节的数据

bytes memory bytecode= hex"69602a60005260206000f3600052600a6016f3"; //就是创建字节码和运行字节码一起组成的
 http://www.evm.codes/playground
 Run time code - return 42
 602a60005260206000f3

*/
contract Factory{
    event Log (address addr);
    function deploy() external {
        bytes memory bytecode= hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        assembly{
            /*
            在 Solidity 中，​动态类型（如 bytes）的内存布局遵循以下规则：
            ​前 32 字节（0x20）存储数据长度​（单位为字节）
            ​后续字节存储实际数据​（连续存储，不足 32 字节的部分按需填充）
            即使你的字节码只有 ​19 字节，它的内存布局也会强制包含 ​32 字节长度头，结构如下：
            param1：发送的eth，0表示不发送ETH
            param2：字节码起始位置（bytecode变量内存布局中数据区起始地址），即跳过32字节长度头后的位置
            param3: 字节码长度0x13（19字节）
            */
            addr:=  create(0 ,add(bytecode,0x20),0x13)
        }
        require(addr != address(0),"deploy failed");
        emit Log(addr);
    }
}

interface IContract {
    function getMeaningOfLife() external view returns (uint);
}








