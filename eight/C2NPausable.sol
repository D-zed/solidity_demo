// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

// 导入OpenZeppelin的ERC20基础合约
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// 导入支持暂停功能的ERC20扩展合约
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
// 导入所有权管理合约
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// 定义MyToken合约，继承自ERC20、ERC20Pausable和Ownable
contract MyToken is ERC20, ERC20Pausable, Ownable {
    constructor(address initialOwner)
        ERC20("MyToken", "MTK")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 100 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause(); // 调用ERC20Pausable的内部暂停函数
    }
    // 恢复代币交易功能（仅所有者可调用）
    function unpause() public onlyOwner {
        _unpause(); // 调用ERC20Pausable的内部恢复函数
    }

    // The following functions are overrides required by Solidity.
   // 以下函数是Solidity要求的覆盖函数
    // 更新代币转账状态（组合ERC20和ERC20Pausable的功能）
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
