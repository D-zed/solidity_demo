// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract AbiDecode{
    //结构体的传参是["c2n",[7,9]]
    struct Mystruct{
        string name;
        uint[2] nums;

    }

    function encode(uint x,address addr,uint [] calldata arr,Mystruct calldata myStruct)
    external pure returns (bytes memory result)
    {
        return abi.encode(x,addr,arr,myStruct);
    }

    function decode(bytes calldata data) 
    external pure returns(
        uint x,address addr,uint[] memory arr,Mystruct memory myStruct
    ){
       (x,addr,arr,myStruct)= abi.decode(data, (uint,address,uint[],Mystruct));
    }
}