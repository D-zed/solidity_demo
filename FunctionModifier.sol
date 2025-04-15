// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FunctionModifier {
    bool public paused;
    uint public count;

    function setPause(bool _paused)external {
        paused=_paused;
    }

    //装饰器
    modifier whenNotPaused(){
        require(!paused,"Pause");
        //执行被装饰的代码
        _;
    }

    function inc()external whenNotPaused{
        count+=1;
    }

    function dec()external whenNotPaused{
        count-=1;
    }
}