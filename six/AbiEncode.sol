// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 三种都是可以进行对方法签名进行编码，效果相同，注意灵活使用
interface ITransfer {
    function transfer(address ,uint256) external ;
}

contract Token{
    function transfer(address _address,uint256 _amount) external {

    }
}

contract AbiEncode{

    function test(address _address,bytes calldata data) external returns(bool){
        (bool ok,) = _address.call(data);
        return ok;
    }

    function encodeWithSignature(address _to,uint _amount)
    external 
    pure 
    returns (bytes memory){
        return abi.encodeWithSignature("signatureString(address,uint256)", _to,_amount);
    }

    function encodeWithSelector(address _to,uint _amount)
    external 
    pure 
    returns (bytes memory){
        return abi.encodeWithSelector(ITransfer.transfer.selector, _to,_amount);
    }

    function encodeCall(address _to,uint _amount)
    external 
    pure 
    returns (bytes memory){
        return abi.encodeCall(ITransfer.transfer, (_to,_amount));
    }
}