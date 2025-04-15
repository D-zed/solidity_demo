// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//返回多个输出
//结构赋值
contract FunctionOutputs {

    function returnMany() public pure returns (uint256, bool){
        return (1,true);
    }

    function named()public pure  returns(uint x, bool b){
        return (1,true);
    } 

    function assigned() public pure returns (uint x,bool b){
        x=1;
        b=true;
    }


    function destructingAssignments()public pure {
        (uint a, bool c) = returnMany();
        (uint h,)  =returnMany();   // 这样赋值会返回第二个值
        (,bool b)=assigned();// 这种方式不会返回第二个值 
    }



}