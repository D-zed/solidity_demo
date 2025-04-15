// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// 统一使用可升级合约库
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract UUPSV2 is 
    Initializable,         // 来自可升级合约库
    UUPSUpgradeable,       // 来自可升级合约库
    OwnableUpgradeable     // 显式继承 Ownable
{
    uint public x;

    // 删除构造函数（可升级合约禁止使用构造函数）
    // constructor(uint _var){ x = _var; }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers(); // 防止实现合约被直接初始化
    }

    // 初始化函数替代构造函数
    function initialize(uint _var) external initializer {
        x = _var;
        __Ownable_init(msg.sender);  // 正确调用初始化函数
        __UUPSUpgradeable_init();    // 显式初始化父合约
    }

    // 升级授权逻辑（必须包含权限检查）
    function _authorizeUpgrade(address) internal override onlyOwner {}

    // 业务逻辑保持不变
    function cal() external {
        x = x * 2;
    }

    // 修正ABI编码调用
    function showInitCode() external pure returns(bytes memory) {
        return abi.encodeWithSelector(this.initialize.selector, 1);
    }
}