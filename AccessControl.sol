// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract AccessControl {

    event GrantRole(bytes32 indexed role,address indexed account);
    event RevokeRole(bytes32 indexed role,address indexed account);

    //角色名使用byte32 统一格式可能节省gas
    mapping(bytes32 => mapping(address => bool) ) public roles;

    //使用private更加节省gas
    //0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private constant ADMIN=keccak256(abi.encodePacked("ADMIN"));
    //0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
    bytes32 private constant USER=keccak256(abi.encodePacked("USER"));

    constructor(){
        //这个是部署合约的账户的地址，并非合约本身的地址，不要弄混淆了
        _grantRole(ADMIN, msg.sender);
    }
    
    modifier onlyRole(bytes32 _role){
        require(roles[_role][msg.sender],"Not authorized");
        _;
    }

    function _grantRole(bytes32 _role,address _account) internal {
        roles[_role][_account] = true;
        emit GrantRole(_role,_account);
    }

    function grantRole(bytes32 _role,address _account) external  onlyRole(ADMIN){
        _grantRole(_role,_account);
    }

    function revokeRole(bytes32 _role,address _account) external  onlyRole(ADMIN){
        roles[_role][_account] = false;
        emit RevokeRole(_role,_account);
    }


}