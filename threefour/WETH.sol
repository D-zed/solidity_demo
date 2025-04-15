// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.7;          // 指定Solidity编译器版本为0.8.7及以上

// 导入OpenZeppelin的ERC20标准实现
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 包装以太坊原生代币(ETH)的智能合约
// 通过ERC20标准实现ETH的代币化，使其兼容DeFi协议
contract WETH is ERC20 {
    // 定义存款事件（当用户存入ETH时触发）
    event Deposit(address indexed account, uint amount);
    // 定义取款事件（当用户销毁WETH取回ETH时触发）
    event Withdraw(address indexed account, uint amount);

    // 构造函数初始化ERC20代币参数
    constructor() ERC20("Wrapped Ether", "WETH") {
        // 继承的ERC20构造函数会设置代币名称和符号
        // 不进行初始铸造，采用按需铸造模式
    }

    // 后备函数（当合约收到纯ETH转账时自动执行）
    fallback() external payable {
        deposit(); // 自动触发存款逻辑
    }

    // 存款函数（将ETH转换为等量WETH）
    function deposit() public payable {
        _mint(msg.sender, msg.value); // 铸造与发送ETH等量的WETH给调用者
        emit Deposit(msg.sender, msg.value); // 记录存款事件
    }

    // 取款函数（销毁WETH取回ETH）
    function withdraw(uint _amount) external {
        _burn(msg.sender, _amount);     // 销毁调用者的WETH
        payable(msg.sender).transfer(_amount); // 发送等量ETH给调用者
        emit Withdraw(msg.sender, _amount);    // 记录取款事件
    }
}