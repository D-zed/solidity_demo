// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * 目标部署合约 - 将通过CREATE2方式部署的示例合约
 */
contract DeployWithCreate2 {
    // 存储部署时设置的拥有者地址
    address public owner;
    
    // 构造函数，在部署时接收并设置拥有者地址
    constructor(address _owner) {
        owner = _owner;
    }
}

/**
 * CREATE2工厂合约 - 用于预计算地址并部署目标合约
 */
contract Create2Factory {
    // 部署成功时触发的事件，返回新合约地址
    event Deploy(address addr);

    /**
     * 使用CREATE2操作码部署目标合约
     * @param _salt 用于确定部署地址的盐值（任意uint数值）
     */
    function deploy(uint _salt) external {
        // 使用new关键字配合salt参数部署合约
        // 语法说明：new 合约名{salt: 盐值}(构造函数参数)
        DeployWithCreate2 _contract = new DeployWithCreate2{
            salt: bytes32(_salt)  // 将uint盐值转换为bytes32类型
        }(msg.sender); // 构造函数参数为当前调用者地址

        // 触发部署事件
        emit Deploy(address(_contract));
    }

    /**
     * 预计算目标合约的部署地址
     * @param bytecode 目标合约的完整字节码（包含构造函数参数）
     * @param _salt 部署时使用的盐值
     * @return 预测的合约地址
     * 
     * 地址计算公式遵循EIP-1014标准：
     * address = 最低160位(keccak256(0xff ++ 工厂地址 ++ salt ++ keccak256(bytecode)))
     */
    function getAddress(bytes memory bytecode, uint _salt)
        public
        view
        returns (address)
    {
        // 计算CREATE2地址的哈希值
        bytes32 hash = keccak256(
            abi.encodePacked( // 将以下参数紧密打包
                bytes1(0xff),            // CREATE2固定前缀
                address(this),            // 工厂合约地址
                _salt,                    // 用户提供的盐值
                keccak256(bytecode)       // 目标合约字节码的哈希
            )
        );
        
        // 将哈希转换为地址类型（取后160位）
        //在CREATE2地址计算中确实截取的是哈希结果的最后20字节（160位）
        //uint256 就是32字节，与hash一致
        return address(uint160(uint(hash)));
    }

    /**
     * 生成目标合约的完整字节码（包含构造函数参数）
     * @param _owner 要传递给目标合约构造函数的参数
     * @return 拼接后的完整字节码
     * 
     * 说明：当使用CREATE2时，构造函数参数需要包含在字节码中，
     * 因此需要将creationCode与编码后的参数拼接
     */
    function getByteCode(address _owner)
        public
        pure
        returns (bytes memory)
    {
        // 获取目标合约的初始化字节码（不包含构造函数参数）
        bytes memory bytecode = type(DeployWithCreate2).creationCode;
        
        // 将构造函数参数进行ABI编码，并与初始化字节码拼接
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}