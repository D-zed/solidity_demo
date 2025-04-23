// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "hardhat/console.sol";
// 这个代码的执行顺序为 
/*
console.log:
N-bar
G-bar
F-bar
E-bar
*/
// 引入console（假设使用Hardhat环境）
import "hardhat/console.sol";

import "hardhat/console.sol";  // 确保正确引入 console.log

contract E {
    event Log(string message);

    function foo() public virtual {
        emit Log("E-foo");
    }

    function bar() public view virtual {  // 修改为 view
        console.log("E-bar");
    }
}

contract F is E {
    function foo() public virtual override {
        emit Log("F-foo");
        E.foo();
    }

    function bar() public view virtual override {  // 修改为 view
        console.log("F-bar");
    }
}

contract G is E {
    function foo() public virtual override {
        emit Log("G-foo");
        E.foo();
    }
}

contract N is F, G {
    function foo() public override(F, G) {  // 覆盖 F 和 G 的 foo()
        F.foo();
    }

    function bar() public view override(F, E) {  // 覆盖 F 和 E 的 bar() 因为G  中没有bar，但是G的父类 E中有bar，所以要显示的指出重写的父类
        console.log("N-bar");
        super.bar();  // 调用顺序：G -> F -> E
    }
}