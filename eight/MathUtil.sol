// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract MathUtil{
    using Math for uint;
    function testAdd(uint a, uint b) external pure {
        Math.tryAdd(a,b);
    }

    function testAdd2(uint a,uint b) external pure {
        a.tryAdd(b);
    }

}