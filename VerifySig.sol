// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
// 定义一个名为 VerifySig 的合约，用于验证以太坊签名
contract VerifySig {
    /**
     * @dev 验证签名是否由指定地址创建
     * @param _signer 使用以太坊对哈希值签名的地址
     * @param _message 消息原文
     * @param _sig 签名
     * @return bool 如果签名是由指定地址创建的，返回 true；否则返回 false
     */
    function verigy(address _signer, string memory _message, bytes memory _sig) public pure returns (bool) {
        // 计算消息的哈希值
        bytes32 messageHash = getMessageHash(_message);
        // 计算以太坊签名消息的哈希值
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        // 恢复签名地址并与传入的签名地址进行比较
        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    /*
     * @dev 计算消息的 Keccak-256 哈希值
     * @param _message 消息原文
     * @return bytes32 消息的哈希值
     */
    function getMessageHash(string memory _message) public pure returns (bytes32) {
        // 使用 keccak256 函数计算消息的哈希值
        return keccak256(abi.encodePacked(_message));
    }

    /*
     * @dev 计算以太坊签名消息的哈希值
     * @param _messageHash 消息的哈希值
     * @return bytes32 以太坊签名消息的哈希值
     */
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        // 按照以太坊的规范，在消息哈希前添加特定前缀，然后计算哈希值
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    /*
     * @dev 从以太坊签名中恢复签名地址
     * @param _ethSignedMessageHash 以太坊签名消息的哈希值
     * @param _sig 以太坊的签名，由签名地址和 keccak256 哈希值生成
     * @return address 签名的地址
     */
    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address) {
        // 将签名拆分为 r, s, v 三部分
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        // 使用 ecrecover 函数从哈希值和签名的 r, s, v 部分恢复签名地址
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /*
     * @dev 内部函数，将签名拆分为 r, s, v 三部分
     * @param _sig 以太坊的签名
     * @return bytes32 r 签名的 r 部分
     * @return bytes32 s 签名的 s 部分
     * @return uint8 v 签名的 v 部分
     */
    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        // 检查签名长度是否为 65 字节，如果不是则抛出异常
        require(_sig.length == 65, "invalid signature length");
        // 使用内联汇编从签名中提取 r, s, v 部分
        assembly {
            //因为以太坊的签名默认是65字节
            /*
            代码作用
            ​​add(_sig, 32)​​:
            _sig 是一个指向内存中签名数据的指针。
            add(_sig, 32) 将指针向后移动 ​​32字节​​，跳过签名数据的​​长度字段​​（Solidity动态类型如 bytes 在内存中的前32字节存储数据长度）。
            ​​mload(...)​​:
            mload 是内存加载指令，从指定地址读取 ​​32字节​​ 数据。
            这里从 _sig + 32 的地址开始读取，得到签名中的 ​​r​​ 值（ECDSA签名的第一部分）。
            ​​r := ...​​:
            将读取到的32字节数据赋值给变量 r，即签名中的 ​​r​​ 分量。
            */
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
}