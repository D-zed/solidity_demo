// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract XYZ {
    function someFuncWithManyInputs(
        uint x,uint y,uint z,address a, address b ,string memory c
    ) public pure returns (uint) {
        
    }

    function callFunc() external pure returns(uint) {
        return someFuncWithManyInputs(1, 2, 3, address(0), address(0), "c");
    }
    //传参调用的时候可以使用 key：val 格式传参
    function callFunc2() external pure returns(uint) {
        return someFuncWithManyInputs(
            {
                x:1,y:3,z:4,a:address(0),b:address(0),c:""
            }
        );
    }

}
