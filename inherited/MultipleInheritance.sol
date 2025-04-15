// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 继承顺序 最上层的最优先
/*
     x
   /   \
 y      a
 |      |
 |      b
  \    /
     z  
x,y,a,b,z
*/


contract X {
    function foo() public pure virtual returns (string memory){
        return "x-foo";
    }
    function bar() public pure virtual returns (string memory) {
        return "x-bar";
    }

    function a() public pure returns (string memory) {
        return "aa";
    }
}

contract Y is X{
    function foo() public pure virtual override  returns (string memory){
        return "Y-foo";
    }
    function bar() public pure virtual override  returns (string memory) {
        return "Y-bar";
    }

    function b() public pure returns (string memory) {
        return "bb";
    }
}

contract Z is X, Y{
    function foo() public pure override(X,Y) returns (string memory){
        return "Z-foo";
    }
    function bar() public pure override(X,Y)  returns (string memory) {
        return "Z-bar";
    }
}