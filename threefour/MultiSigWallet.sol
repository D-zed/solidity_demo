// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
// 多签钱包
//多签钱包是一种需要多个授权地址（即owner）中的一定数量签名才能执行交易的钱包。其主要功能包括：
contract MultiSigWallet{
    // 存款事件，当有用户向钱包存入以太币时触发
    // indexed 关键字用于在区块链上索引该参数，方便查询
    event Deposit (address indexed sender, uint amount);
    // 提交交易事件，当有owner提交一笔新交易时触发
    event Submit(uint indexed txId);
    // 批准交易事件，当有owner批准一笔交易时触发
    event Approve(address indexed owner, uint indexed txId);
    // 撤回批准事件，当有owner撤回对一笔交易的批准时触发
    event Revoke(address indexed owner, uint indexed txId);
    // 执行交易事件，当一笔交易被成功执行时触发
    event Execute(uint indexed txId);

    // 交易结构体，用于存储每笔交易的相关信息
    struct Transation{
        address to;  // 交易的接收地址
        uint value;  // 交易的以太币数量
        bytes data;  // 交易附带的数据
        bool executed;  // 交易是否已经执行的标志
    }

    // 存储所有owner地址的数组
    address[] public owners;
    // 映射，用于快速判断一个地址是否为owner
    mapping(address=>bool) public isOwner;
    // 执行交易所需的最少owner批准数量
    uint public required;

    // 存储所有交易的数组
    Transation[] public transations;
    // 双重映射，用于记录每个owner对每笔交易的批准状态
    mapping (uint => mapping(address=>bool)) public approved;

    // 修饰器，只有owner才能调用使用该修饰器的函数
    modifier onlyOwner(){
        // 检查调用者是否为owner，如果不是则抛出错误
        require (isOwner[msg.sender], "not owner");
        _;  // 继续执行被修饰的函数
    }

    // 修饰器，确保交易ID对应的交易存在
    modifier txExists(uint _txId){
        // 检查交易ID是否在交易数组的有效范围内，如果不在则抛出错误
        require (_txId < transations.length, "not txExists");
        _;  // 继续执行被修饰的函数
    }

    // 修饰器，确保调用者还未批准该交易
    modifier notApproved(uint _txId){
        // 检查调用者是否已经批准该交易，如果已经批准则抛出错误
        require (!approved[_txId][msg.sender], "already approved");
        _;  // 继续执行被修饰的函数
    }

    // 修饰器，确保交易还未执行
    modifier notExecuted(uint _txId){
        // 检查交易是否已经执行，如果已经执行则抛出错误
        require (!transations[_txId].executed, "already executed");
        _;  // 继续执行被修饰的函数
    }

    /**
     * @dev 合约构造函数，初始化多签钱包
     * @param _owners 初始的owner地址数组
     * @param _required 执行交易所需的最少owner批准数量
     */
    constructor(address[] memory _owners, uint _required){
        // 检查owner地址数组是否为空，如果为空则抛出错误
        require(_owners.length > 0, "owner require");
        // 检查所需批准数量是否在有效范围内，如果不在则抛出错误
        require(_required > 0 && _required <= _owners.length, "invalied required number");

        // 遍历owner地址数组
        for (uint i; i < _owners.length; i++){
            address owner = _owners[i];
            // 检查owner地址是否为零地址，如果是则抛出错误
            require(owner != address(0), "invalid owner");
            // 检查owner地址是否已经存在于isOwner映射中，如果存在则抛出错误
            require(!isOwner[owner], "owner is not unique");
            // 将该地址标记为owner
            isOwner[owner] = true;
            // 将该地址添加到owners数组中
            owners.push(owner);
        }
        required=_required;
    }

    // 接收以太币的函数，当有以太币转入合约时自动调用
    receive() external payable {
        // 触发存款事件
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev 提交一笔新交易
     * @param _to 交易的接收地址
     * @param _value 交易的以太币数量
     * @param _data 交易附带的数据
     */
    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner{
        // 将新交易添加到交易数组中
        transations.push(Transation(
            {
                to: _to,
                value: _value,
                data: _data,
                executed: false
            }
        ));
        // 触发提交交易事件
        emit Submit(transations.length - 1);
    }

    /**
     * @dev 批准一笔交易
     * @param _txId 要批准的交易ID
     */
    function approve(uint _txId) 
    external 
    onlyOwner
    txExists(_txId)
    notApproved(_txId)
    notExecuted(_txId)
    {
        // 标记调用者已经批准该交易
        approved[_txId][msg.sender] = true;
        // 触发批准交易事件
        emit Approve(msg.sender, _txId);
    }

    /**
     * @dev 私有函数，计算一笔交易的批准数量
     * @param _txId 要计算批准数量的交易ID
     * @return count 该交易的批准数量
     */
    function _getApprovalCount(uint _txId) private view returns (uint count){
        // 遍历所有owner地址
        for (uint i; i < owners.length; i++){
            // 检查该owner是否已经批准该交易
            if (approved[_txId][owners[i]]){
                // 如果批准，则批准数量加1
                count +=1 ;
            }
        }
    }

    function getApprovalCount(uint _txId) external view returns (uint,uint){
        // 获取调用者批准数量
        return ( _getApprovalCount(_txId),required);
    }

    /**
     * @dev 执行一笔交易
     * @param _txId 要执行的交易ID
     */
    function execute(uint _txId) external txExists(_txId) notExecuted(_txId){
        // 检查批准数量是否达到所需的最少数量，如果未达到则抛出错误
        require(_getApprovalCount(_txId) >= required, "less than required");
        // 获取要执行的交易的引用
        Transation storage transaction = transations[_txId];
        // 标记该交易已经执行
        transaction.executed = true;
        // 执行交易
        (bool success, ) = payable(transaction.to).call{value: transaction.value}(transaction.data);
        // 检查交易是否执行成功，如果失败则抛出错误
        require(success, "execute failed");
        // 触发执行交易事件
        emit Execute(_txId);
    }

    /**
     * @dev 撤回对一笔交易的批准
     * @param _txId 要撤回批准的交易ID
     */
    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
        // 检查调用者是否已经批准该交易，如果未批准则抛出错误
        require(approved[_txId][msg.sender], "not approved");
        // 标记调用者已经撤回对该交易的批准
        approved[_txId][msg.sender] = false;
        // 触发撤回批准事件
        emit Revoke(msg.sender, _txId);
    }
}