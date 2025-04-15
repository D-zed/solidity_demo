// 声明SPDX许可证标识（MIT许可证）
// SPDX-License-Identifier: MIT
// 指定Solidity编译器版本要求（0.8.28及以上，不包括0.9.0）
pragma solidity ^0.8.28;

// 导入OpenZeppelin合约库
// ERC20标准代币合约
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// ERC20许可扩展（支持签名授权）
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
// ERC20投票扩展（支持治理投票）
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
// Nonces工具（防止重放攻击）
import "@openzeppelin/contracts/utils/Nonces.sol";
// 权限控制（合约所有者功能）
import "@openzeppelin/contracts/access/Ownable.sol";

// 主合约继承多个功能模块
contract MyToken is ERC20, ERC20Permit, ERC20Votes, Ownable {
    // 构造函数初始化各个父合约
    constructor() 
        // 初始化ERC20代币（名称，符号）
        ERC20("MyToken", "MTK") 
        // 初始化ERC20Permit（需要与代币名称一致）
        ERC20Permit("MyToken") 
        // 初始化Ownable，设置部署者为所有者
        Ownable(msg.sender) 
    {} // 构造函数体为空，初始化已完成

    // 获取指定地址的nonce值（用于签名授权防重放）
    // override表示覆盖父合约的nonces函数，合并两个父合约的实现
    function nonces(address owner) 
        public 
        view 
        virtual 
        override (ERC20Permit, Nonces) 
        returns (uint256) 
    {
        // 调用父合约Nonces的nonces方法
        return super.nonces(owner);
    }

    // 内部函数：处理代币转账的核心逻辑（重写父合约方法）
    function _update(
        address from,   // 发送地址
        address to,     // 接收地址
        uint256 value   // 转账金额
    ) 
        internal 
        virtual 
        // 覆盖两个父合约的_update方法
        override(ERC20, ERC20Votes) 
    {
        // 先调用父合约的_update方法（执行标准ERC20转账逻辑）
        super._update(from, to, value);
        // 自动执行ERC20Votes的更新逻辑（投票权转移记录）
    }

    // 铸造新代币函数（仅所有者可调用）
    function mint(
        address account,  // 接收铸币的地址
        uint256 amount    // 铸造数量（以最小单位计算）
    ) 
        external 
        onlyOwner         // 权限修饰符：仅合约所有者可调用
    {
        // 检查接收地址是否设置了投票代理
        if (delegates(account) == address(0)) {
            // 若未设置，则自动将投票权代理给自己
            _delegate(account, account);
        }
        // 调用ERC20的铸造方法（实际铸造数量 = amount * 10^小数位数）
         _mint(account,amount*10**decimals());
    }
}