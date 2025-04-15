// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 未检查数据，检查上下溢问题
// 加入uncheck，让solidity不会报出错误
// 默认上下溢出会抛出异常，且多花费gas检查，
// unchecked之后不会花费gas检查，上下溢出会截断
contract UncheckedMath {

    function add(uint x,uint y) external pure returns (uint){
        unchecked{
            return x+y;
        }
    }
    
    function sub(uint x,uint y) external pure returns (uint){
        unchecked{
            return x-y;
        }
    }
}