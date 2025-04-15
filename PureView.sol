// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
pure 和 view 函数都不会修改合约状态，调用时通常不消耗交易 gas。
view 函数可以读取合约状态变量，而 pure 函数既不能读取也不能修改合约状态变量。
*/