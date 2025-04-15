// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TestCall{
    string public message;
    uint public x;
    event Log(address caller,uint amount,string message);

    receive() external payable { }  

    fallback() external payable {
        //在你的代码里，当 fallback 函数被调用时，msg.sender 就是调用这个 fallback 
        // 函数的外部地址（可以是用户的以太坊钱包地址，也可以是另一个合约的地址）。
        //msg.value 表示在当前调用中发送的以太币数量，单位是 wei（以太坊的最小货币单位）。
        // 在以太坊中，当用户或合约调用某个函数时，可以选择附带一定数量的以太币一起发送。
        // msg.value 就是用来获取这个附带的以太币数量的。
        emit Log(msg.sender,msg.value,"fallback was called");
     }

     function foo(string memory _message,uint256 _x) public payable returns (bool,uint){
        message=_message;
        x=_x;
        return (true,999);
     }
}

contract Call{

   bytes public data;
   function callFoo(address _test) external payable {
      //调用此方法的测试环节必须要给左侧的VALUE设置为大于等于111
     (bool success,bytes memory _data)= _test.call{value:111}(abi.encodeWithSignature("foo(string,uint256)", "call foo",123));
      require(success,"call failed");
      data=_data;
   }

   function callNotExist(address _test) external payable {
     (bool success,)= _test.call(abi.encodeWithSignature("aa()"));
      require(success,"call failed");
   }
}