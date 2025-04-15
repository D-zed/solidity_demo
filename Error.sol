// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// require revert assert
// 可以通过抛出异常，出现异常导致程序中断会退回一部分gas，其中的东西也会撤销，相当于事务回滚吧，来节省gas
contract Error {

    function testRequire(uint i) public pure{
        require(i<=10,"i<=10");
    }

    function testRevert(uint i) public pure{
        if (i<=10){
            revert("i<=10");
        }
    }

    uint public num=123;

    function testAssert(uint i) public view {
        assert(num == i);
    }

    

    function incNum()public {
        num+=1;
    }

    error MyError(address caller,uint i);

    function testCustomError(uint i) public view {
        if(i>10){
            revert MyError(msg.sender,i);
        }
    }

}