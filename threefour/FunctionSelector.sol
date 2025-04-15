// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FunctionSelector{
    //将 "transfer(address,uint256)" 参数传递的结果就是0xa9059cbb，也就是msg.data的前四个字节
    function getSelector(string calldata _func) external pure returns (bytes4){
        return  bytes4(keccak256(abi.encodePacked(_func)));
    }
}

contract Receiver{
    //0xa9059cbb
    //000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb2
    //000000000000000000000000000000000000000000000000000000000000000b
    event Log(bytes data);

    function transfer(address _to,uint _amount) external {
        emit Log(msg.data);
    }
}