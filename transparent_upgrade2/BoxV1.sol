// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract BoxV1 is Initializable{
    uint public x;
    // constructor(uint _x){
    //     x=_x;
    // }   

    function initialize(uint _val) external initializer{
        x=_val;
    }

    function cal() external {
        x =x +1;
    }

    function showInvoke() external pure returns (bytes memory){
        return abi.encodeWithSelector(this.initialize.selector,1);
    }
}