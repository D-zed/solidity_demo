// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 不能有自己的状态变量
library Math {
    //使用 internal 关键字是为了可以在部署合约的时候内嵌进来，而无需单独部署
    function max(uint x,uint y) internal pure returns (uint){
        return x >= y ? x : y;
    }
}

contract Test{

    function testMax(uint x,uint y) external pure returns (uint) { 
        return Math.max(x,y);
    }

}

library ArrayLibrary{
    //使用storage的为了节省gas，如果使用mem则会将其复制到内存造成浪费
    function find(uint[] storage arr,uint x) internal view returns (uint){
        for (uint i = 0;i<arr.length;i++) {
            if (arr[i]==x){
                return i;
            }
        }
        revert("not found");
    }
}

contract TestArray{
    //增强数组类型
    using ArrayLibrary for uint[];

    uint[] public arr=[3,2,1];

    function testFind(uint index) external view returns(uint i){
        return  ArrayLibrary.find(arr,index);
    }

    function testFind2(uint index) external view returns(uint i){
        return  arr.find(index);
    }
}
