// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// 统一使用可升级合约库
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract UUPSV1 is
    Initializable,         // 来自可升级合约库
    UUPSUpgradeable,       // 来自可升级合约库
    OwnableUpgradeable     // 显式继承 Ownable
{


    uint public x;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(uint _var) {
        x=_var;
    }

    function _authorizeUpgrade(address implement) internal override {
        
    }
    // 初始化函数替代构造函数
    function initialize(uint _var) external initializer {
        x = _var;
        __Ownable_init(msg.sender);  // 正确调用初始化函数
    }

    function cal() external { 
        x= x+1;
    }

    function showInitCode() external view returns(bytes memory){
        return abi.encodeCall(this.initialize,(1));
    }

}