// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Immutable{

    //不可以改变，并且可以节省gas
    address public immutable immutable_owner = msg.sender;

        //不可以改变，并且可以节省gas
    address public immutable owner = msg.sender;
}