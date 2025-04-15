// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract Caller{
    function setX(TestContract _test,uint _x) external {
        _test.setX(_x);
    }
    function getX(address _test) external view returns(uint){
        // 将地址强转为合约
        uint x= TestContract(_test).getX();
        return x;
    }

    function setXAndSendEther(TestContract _test,uint _x) external payable{
        _test.setXandSendEther{value:msg.value}(_x);
    }

    function getXandValue(address _test) external view returns(uint,uint){
        (uint x,uint value)= TestContract(_test).getXandValue();
        return (x,value);
    }

}

contract TestContract{

    uint public x;
    uint public  value=123;
    function setX(uint _x) public returns(uint){
        x=_x;
        return x;
    }

    function getX() external view returns (uint){
        return x;
    }

    function setXandSendEther(uint _x) public payable returns (uint,uint){
        x=_x;
        value=msg.value;
        return (x,value);
    }

    function getXandValue() external view returns(uint,uint){
        return (x,value);
    }

    

}