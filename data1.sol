// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract ValueTypes{

    bool public b=true;
    uint public u=123; // uint256缩写 值得范围是 0-2^256 -1(没有符号位)
    // uint8 值得范围 0-2^8 -1(没有符号位)
    // uint16 值得范围 0-2^16 -1(没有符号位)
    int public i=-123; // int256缩写 值得范围是 -2^255 - 2^255
    int public minInt=type(int).min; // 最小int值
    int public maxInt=type(int).max; // 最大int值
    address public addr = 0x1234567890123456789012345678901234567890; // address 类型用于存储以太坊地址。以太坊地址为 20 字节（160 位）的数值，一般以十六进制形式呈现。
    bytes32 public b32 = 0x1234567890123456789012345678901234567890123456789012345678901234;//它能够存储任意的 32 字节数据，比如哈希值、加密密钥等

    
}