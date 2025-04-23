// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//优化节省了 2000 gas
contract GasGolf{

    uint256 public total;

    uint256 public total2;

    uint256 public total3;

    uint256 public total4;

    uint256 public total5;
    
    uint256 public total6;

    //[1,2,3,4,5,100] gas消耗：55182
    function sumIfEventAndLessThan99_1(uint[] memory nums) external {
        for(uint i=0;i<nums.length;i+=1){
            bool isEven=nums[i]%2==0;
            bool isLessThan99 = nums[i] <99;
            if(isEven && isLessThan99){
                total += nums[i];
            }
        }
    }

    //gas消耗：54445
    //相比1 使用calldata
    function sumIfEventAndLessThan99_2(uint[] calldata nums) external {
        for(uint i=0;i<nums.length;i+=1){
            bool isEven=nums[i]%2==0;
            bool isLessThan99 = nums[i] <99;
            if(isEven && isLessThan99){
                total2 += nums[i];
            }
        }
    }

    //gas消耗：54216
    //相比较2 使用缓存了状态变量到本地
    function sumIfEventAndLessThan99_3(uint[] calldata nums) external {
        uint _total=total3;
        for(uint i=0;i<nums.length;i+=1){
            bool isEven=nums[i]%2==0;
            bool isLessThan99 = nums[i] <99;
            if(isEven && isLessThan99){
                _total += nums[i];
            }
        }
        total3=_total;
    }

    //gas消耗：53977 
    //想比较3 使用了短路写法，而不是一开始就把 isEven 和 isLessThan99 计算出来
    function sumIfEventAndLessThan99_4(uint[] calldata nums) external {
        uint _total=total4;
        for(uint i=0;i<nums.length;i+=1){
            bool isEven=nums[i]%2==0;
            //短路写法 而不是一开始就把俩条件都计算出来
            if(isEven && nums[i] <99){
                _total += nums[i];
            }
        }
        total4=_total;
    }

    //gas消耗：53441
    //相比较4 i+=1 调整成了 i++
    function sumIfEventAndLessThan99_5(uint[] calldata nums) external {
        uint _total=total5;
        for(uint i=0;i<nums.length;i++){
            bool isEven=nums[i]%2==0;
            //短路写法 而不是一开始就把俩条件都计算出来
            if(isEven && nums[i] <99){
                _total += nums[i];
            }
        }
        total5=_total;
    }


    //gas消耗：53158
    //相比较5 减少了 nums[i] 的重复计算
    function sumIfEventAndLessThan99_6(uint[] calldata nums) external {
        uint _total=total6;
        for(uint i=0;i<nums.length;i++){
            uint numi=nums[i];
            bool isEven=numi%2==0;
            //短路写法 而不是一开始就把俩条件都计算出来
            if(isEven && numi <99){
                _total += numi;
            }
        }
        total6=_total;
    }
}