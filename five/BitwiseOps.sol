// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract BitwiseOps{

    function and(uint x,uint y) external pure returns (uint){
        return x&y;
    }
    
    function or(uint x,uint y) external pure returns (uint){
        return x|y;
    }

    function xor(uint x,uint y) external pure returns (uint){
        return x^y;
    }

    function not(uint x) external pure returns (uint){  
        //对每一位按位取反
        return  ~x;
    }

    function shiftLeft(uint x, uint y) external pure returns (uint){
       return x << y;
    }


    function shiftRight(uint x , uint y) external pure returns (uint){
        return x >>y; 
    }

    function getLastNBits(uint x,uint y) external pure returns (uint)   //获取x中最后n位
    {
        uint mask=(1<<y)-1;
        return x&mask;
    }

    function getLastNBitsUsingMod(uint x,uint y) external pure returns (uint){

        return x %(1<<y);
    }
}