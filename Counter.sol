// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Counter{
    uint public cnt=0;

    function inc() external {
        cnt+=1; 
    }

    function dec() external  {
        cnt-=1;
    }

}