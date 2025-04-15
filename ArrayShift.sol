// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ArrayShift {

    uint [] public arr;

    function example() public {
        arr = [1,2,3];
        delete arr[1];
    }

    function remove(uint _index) public {
        require(_index<arr.length,"index out of bound");

        for(uint i=_index;i<arr.length-1;i++){
            arr[i] = arr[i+1];
        }
        arr.pop();
    }

    function test() external {
        arr=[1,2,3,4,5];
        remove(2);
        assert(arr[2]==4);
    }


    function test2() external {
        arr=[1,2,3,4,5];
        arr[2]=arr[arr.length-1];
        arr.pop();

        assert(arr[2]== 5);
        assert(arr.length==4);

    }
}