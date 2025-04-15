// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "hardhat/console.sol";
// 这个代码的执行顺序为 
/*
console.log:
N-bar
G-bar
F-bar
E-bar
*/
contract E{

    event Log(string message);

    function foo() public virtual {
        emit Log("E-foo");
    } 
    function bar() public pure virtual {
       console.log("E-bar");
    }
    
}

contract F is E{

    function foo() public virtual override {
        emit Log("F-foo");
        E.foo();
    } 
    function bar() public pure virtual override{
        console.log("F-bar");
        //执行所有的父级方法
        //super.bar();
    }
    
}


contract G is E{

    function foo() public virtual override {
        emit Log("G-foo");
        E.foo();
    } 
    function bar() public pure virtual override{
        console.log("G-bar");
        //super.bar();
    }
    
}

contract N is F,G{

    function foo() public virtual override(F,G) {
        F.foo();
    } 
    function bar() public pure virtual  override(F,G){
        console.log("N-bar");
        super.bar();
    }
    
}