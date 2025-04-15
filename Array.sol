// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract TestArray { 
       // 固定长度的数组
       uint[] public myArray = new uint[](3);

       // 动态长度的数组
       uint[] public nums;

       //
       uint[] public nums1=[1,2,3];

       uint[3] public nums2= [4,5,6];
       

       function examples() external {
         //添加元素
         nums.push(4);
         nums.push(6);
         nums.push(22);
         nums.push(46);
         nums.push(99);
         //删除元素
         nums[1];
         //修改元素
         nums[2]=777;
         //删除元素,将对应的位置的值设置为0
         delete nums[1];
        //弹出最后一个元素
         nums.pop(); //
         uint len=nums.length;
         
         //内存中只能创建固定长度的数组，无法pop和push
         uint[] memory a=new uint[](5);
       }

       function returnArray() external view returns (uint[] memory) {
            //返回的数组越长越浪费gas
            return nums;
       }

}