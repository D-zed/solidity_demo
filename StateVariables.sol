// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract StateVariables {

    // 状态变量，存储在链上的变量 类似java的属性
    uint public myUint=123;
    function foo() external {
        // 局部变量
        uint notStateVar=456;
    }

}
