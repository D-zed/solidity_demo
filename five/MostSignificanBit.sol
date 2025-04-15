// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//使用二分搜索代码找到最显著的位
contract MostSignificantBit {

    // 10101010 ->7
    function findMostSignificantBit(uint x) external pure returns(uint8 r){
        if(x>= 2**128){
            x>>=128;
            r+=128;
        }
        if(x>= 2**64){
            x>>=64;
            r+=64;
        }
        if(x>= 2**32){
            x>>=32;
            r+=32;
        }
        if(x>= 2**16){
            x>>=16;
            r+=16;
        }
        if(x>= 2**8){
            x>>=8;
            r+=8;
        }

        // if(x>= 2**4){
        //     x>>=4;
        //     r+=4;
        // }
        // 使用内联汇编来处理剩余的 4 位
        assembly {
            // 检查 x 是否大于 0xf（二进制 1111）
            // 如果大于，gt(x, 0xf) 返回 1，否则返回 0
            // 将结果左移 2 位，相当于乘以 4
            let f := shl(2, gt(x, 0xf))
            // 将 x 右移 f 位，去掉低 f 位
            x := shr(f, x)
            // 将 r 和 f 进行按位或操作，更新 r 的值
            r := or(r, f)
        }


        // if(x>= 2**2){
        //     x>>=2;
        //     r+=2;
        // }
        // 使用内联汇编来处理剩余的 2 位
        assembly {
            // 检查 x 是否大于 0x3（二进制 11）
            // 如果大于，gt(x, 0x3) 返回 1，否则返回 0
            // 将结果左移 1 位，相当于乘以 2
            let f := shl(1, gt(x, 0x3))
            // 将 x 右移 f 位，去掉低 f 位
            x := shr(f, x)
            // 将 r 和 f 进行按位或操作，更新 r 的值
            r := or(r, f)
        }
        // if(x>=2){
        //     r+=1;
        // }
        // 使用内联汇编来处理最后 1 位
        assembly {
            // 检查 x 是否大于 0x1（二进制 1）
            // 如果大于，gt(x, 0x1) 返回 1，否则返回 0
            let f := gt(x, 0x1)
            // 将 r 和 f 相加，更新 r 的值
            r := add(r, f)
        }
    }

}