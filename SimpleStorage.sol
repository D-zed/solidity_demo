// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract SimpleStorage{
    string public text;

    function set(string calldata _text) external {
        text = _text;
    }
    
    // 复杂类型必须指明数据位置否则会报错
    function get() external view returns (string memory) {
        return text;
    }

}