// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// 构造器的执行顺序是按照继承顺序执行的
contract S{
    string public name;
    constructor(string memory _name){
        name=_name;
    }
}

contract T{
    string public text;
    constructor(string memory _text){
        text=_text;
    }
}

contract U is S("a"),T("B"){
    
}

contract V is S,T{
    //感觉这个是最常用的
    constructor(string memory _name,string memory _text)S(_name) T(_text){
        
    }
}

//以上两种可以结合使用
contract W is S("a"),T{
    constructor(string memory _name,string memory _text) T(_text){
        
    }
}