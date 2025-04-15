// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MultiDelegatecall{
    error DelegateCallFailed();

    function multiDelegatecall(bytes[] calldata data) external payable returns(bytes[] memory results){
        results=new bytes[](data.length);
        for (uint i;i<data.length;i++){
            (bool success,bytes memory res)= address(this).delegatecall(data[i]);
            if (!success){
                revert DelegateCallFailed();
            }
            results[i]= res;
        }
    }

}

contract TestMultiDelegatecall is MultiDelegatecall{

    event Log(address caller,string func,uint256 i);

    function func1(uint x,uint y) external {
        emit Log(msg.sender, "func1", x+y);
    }

    function func2() external returns(uint256){
        emit Log(msg.sender, "func2", 2);
        return 111;
    }

    mapping(address => uint256) public balanceOf;

    //这种会有问题，代理调用的时候明明是一个以太，但是如果传参为
    //["0x1249c58b","0x1249c58b","0x1249c58b"] 会调用三次这个方法
    //从而加三次，与实际发送的以太值不符合
    //这种场景很危险，需要考虑
    function mint() external payable {
        balanceOf[msg.sender] +=msg.value;
    }

}

contract Helper{
    function getFunc1Data(uint256 x,uint256 y)
    external pure returns (bytes memory)
    {
        return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x,y);
    }

    function getFunc2Data()
    external pure returns (bytes memory)
    {
        return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
    }

    function getMintData()
    external pure returns (bytes memory)
    {
        return abi.encodeWithSelector(TestMultiDelegatecall.mint.selector);
    }
}