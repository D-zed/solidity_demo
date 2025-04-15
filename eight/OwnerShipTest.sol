// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "@openzeppelin/contracts/access/Ownable.sol";
contract OwnershipTest is Ownable{
    constructor(address initOwner)Ownable(initOwner){
    }

    function normalThing()external pure {

    }

    function specialThing()external onlyOwner{

    }
}