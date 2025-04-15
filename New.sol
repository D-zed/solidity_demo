// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Account{
    address public bank;
    address public owner;

    constructor(address _owner) payable {
        bank=msg.sender;
        owner=_owner;
    }
}

contract AccountFactory{

    Account[] public accounts;

    function createAccount(address _owner) external payable {
        //新增合约自动部署,且创建的方法执行的时候必须指定大于111的以太，并且111的以太会打到对应的账号中
        Account account= new Account{value:111}(_owner);
        accounts.push(account);
    }
}