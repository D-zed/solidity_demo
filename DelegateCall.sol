// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//代理调用的上下文最终还是代理调用方的上下文
// 以下例子在合约A中通过代理调用DelegateCall的setVars方法，并不会改变DelegateCall合约的上下文
// 相当于借用DelegateCall的方法干自己合约的活
// 且调用地址也会是原始的调用地址而不是 A合约的地址
contract DelegateCall {

    uint256 public num;
    address public sender;
    uint256 public value;
    //代理的合约必须和调用方的合约的状态变量名字顺序完全一致，如果需要增加自定义的则需要放在后边
    //不允许打乱原有的顺序，否则会报错
    address public owner;

    function setVars(uint256 _num) public payable {
        num=_num;
        sender=msg.sender;
        value=msg.value;
    }
}

contract A{

    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars1(address _contract,uint256 _num) public payable {
        //代理调用
        _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }

    function setVars2(address _contract,uint256 _num) public payable {
        //代理调用
       (bool success,bytes memory b) = _contract.delegatecall(
            //此种非硬编码比较灵活
            abi.encodeWithSelector(DelegateCall.setVars.selector, _num)
        );
    }

}