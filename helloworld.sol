// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract HelloWorld {
  string public greeting = "Hello, World!";
  
  function sayHello() external view returns (string memory) {
    return greeting;
  }
}