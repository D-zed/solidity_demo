// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract EtherWallet{

    address payable public owner;

    constructor(){
        owner = payable(msg.sender);
    }

    //只接受以太就用这个
    receive() external payable {

    }

    function withdraw(uint _amount) external {
        /*
        比较 msg.sender 和 owner 的地址是否相同，并返回比较结果。这里不需要对 msg.sender 或者 owner 进行类型转换，因为地址比较操作会自动处理类型差异。
综上所述，在进行地址比较时，不需要使用 payable 来包装地址，Solidity 会直接比较地址的实际数据。
        */
        require(msg.sender==owner,"only owner");
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}