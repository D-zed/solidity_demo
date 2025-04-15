// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// state variables;
// global variables;
// function modifier;
// function
// error handle

contract Ownable {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        //调用者为owner的时候才可以调用
        require(msg.sender == owner,"not owner");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0),"invalid address" );
        owner=_newOwner;
    }

    
    function onlyOwnerCanCallFunc() external onlyOwner{

    }

    function allOwnerCanCallFunc() external{

    }


}