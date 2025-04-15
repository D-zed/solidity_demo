// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
/*

*/
contract HashFuc{
    function hash(string memory text,uint num,address addr) external pure returns(bytes32){
        //kei cak 256
        return keccak256(abi.encodePacked(text,num,addr));
    }

    function encodeTest(string memory text,string memory text1) external pure returns(bytes memory){
        return abi.encode(text,text1);
    }

    function encodePackedTest(string memory text,string memory text1) external pure returns(bytes memory){
        /*
        AAAA,BBB
        AAA,ABBB
        以上两组参数的结果相同
        可以采用 在两个加密串之前再加入一个动态字符串的方式解决这种问题 
        text + random + text1
        */
        return abi.encodePacked(text,text1);
    }
}