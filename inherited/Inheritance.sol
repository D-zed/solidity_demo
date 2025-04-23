// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract A {
    //virtual 抽象方法，标识这个的才可以重写
    function foo() public pure virtual returns(string memory){
        return "A-foo";
    }
    //virtual 抽象方法，标识这个的才可以重写
    function bar() public pure virtual returns(string memory){
        return "A-bar";
    }

    function baz() public pure returns(string memory){
        return "A-baz";
    }
}
//继承
contract B is A {
    //virtual 抽象方法，标识这个的才可以重写
    function foo() public pure override  returns(string memory){
        return "B-foo";
    }
    //virtual 抽象方法，标识这个必须重写否则报错
    function bar() public pure virtual override returns(string memory){
        return "B-bar";
    }
}

//继承
contract C is B {
    //virtual 抽象方法，标识这个必须重写否则报错
    function bar() public pure virtual override returns(string memory){
        return "B-bar";
    }

}