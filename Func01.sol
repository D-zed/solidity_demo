// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
//方法的介绍
contract FunctionIntro {
    // external：函数可见性修饰符，表示该函数只能从合约外部调用，不能在合约内部调用。
    // pure：函数状态可变性修饰符，表示该函数既不读取也不修改合约的状态变量，只进行纯数学计算或逻辑操作。
  function add(uint x,uint y) external pure returns (uint) {
    return x+y;
  }

  function sub(uint x, uint y) external pure returns (uint) {
    return x-y;
  }
}