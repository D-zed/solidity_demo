// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
/*
0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 ADMIN
0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 NORMAL
0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db MANAGER
*/
contract AccessControlTest is AccessControl{
    bytes32 public constant ROLE_MANAGER = keccak256("ROLE_MANAGER");
    bytes32 public constant ROLE_NORMAL=keccak256("ROLE_NORMAL");

    constructor(){
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function setRoleAdmin() external onlyRole(DEFAULT_ADMIN_ROLE){
        _setRoleAdmin(ROLE_NORMAL, ROLE_MANAGER);
    }

    function normalThing() external onlyRole(ROLE_NORMAL){

    }

    function speciaThing() external onlyRole(ROLE_MANAGER){

    }
}