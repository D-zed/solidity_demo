// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20{

    constructor(string memory name,string memory symbol) public  ERC20(name,symbol){
    }

    function mint(address to,uint256 amount) external {
        _mint(to, amount);
    }
}