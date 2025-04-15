// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
// storage memory calldata
//storage 局部变量可以显示的指定为storage 用于指定变量存储于区块链的存储中，这属于永久存储，数据会一直存在于合约的生命周期内
// memory 用于指定变量存储在内存里，内存是临时的，在函数调用结束后就会被清除
//calldata 最省gas ,可以理解为引用传递，是一种特殊的数据位置，用于存储函数调用时的参数。它是只读的，意味着在函数内部无法修改 calldata 中的数据
contract LocalVariables{

    struct MyStruct{
        uint foo;
        string text;
    }

    mapping (address=>MyStruct) myMap;

    function examples(uint[] memory y,string memory s) external returns (uint[] memory){
        myMap[msg.sender]=MyStruct(256,"mystruct1");

        MyStruct storage storageStruct =myMap[msg.sender];
        //会修改链上的数据
        storageStruct.text="update";
        
        MyStruct memory readOnly= myMap[msg.sender];
        //只会在内存中修改
        readOnly.foo = 456;
        //
        uint[] memory memArr=new uint[](10);
        memArr[0]=234;
        return memArr;
    }

}