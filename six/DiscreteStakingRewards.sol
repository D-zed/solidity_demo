// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DiscreteStakingRewards {
    // 质押代币合约地址（如LP Token）
    IERC20 public immutable stakingToken;
    // 奖励代币合约地址
    IERC20 public immutable rewardToken;

    // 用户质押余额记录
    mapping(address => uint) public balanceOf;
    // 总质押量
    uint public totalSupply;

    // 精度扩展因子（解决整数运算精度问题）
    uint private constant MULTIPLIER = 1e18;

    // 全局奖励指数（每单位质押代币累积的奖励）
    uint private rewardIndex;
    // 用户待领取奖励存储
    mapping(address => uint) private earned;
    // 用户最后一次更新时的奖励指数
    mapping(address => uint) private rewardIndexOf;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    /**
     * @dev 更新全局奖励指数（仅管理员可调用）
     * @param reward 注入的奖励代币数量
     * 公式：rewardIndex += (reward * 1e18) / totalSupply
     */
    function updateRewardIndex(uint reward) external {
        require(totalSupply>0,"Total supply is zero");
        // 将奖励代币转入合约
        rewardToken.transferFrom(msg.sender, address(this), reward);
        // 当总质押量为0时此操作会失败（需前置检查） 每次发奖都会累加当前的奖励指数
        rewardIndex += (reward * MULTIPLIER) / totalSupply;
    }

    /**
     * @dev 计算账户待领取的增量奖励
     * @return 基于指数差计算的新增奖励
     */
    function _calculateRewards(address account) private view returns (uint) {
        uint shares = balanceOf[account];
        return (shares * (rewardIndex - rewardIndexOf[account])) / MULTIPLIER;
    }

    /**
     * @dev 获取账户总待领取奖励（外部查询接口）
     */
    function calculateRewardEarned(address account) external view returns (uint) {
        return earned[account] + _calculateRewards(account);
    }

    /**
     * @dev 更新用户奖励状态（关键内部函数）
     * 1. 将新增奖励计入earned
     * 2. 更新用户奖励指数快照
     */
    function _updateRewards(address account) private {
        //计算出来奖励
        earned[account] += _calculateRewards(account);
        //更新该用户的奖励指数
        rewardIndexOf[account] = rewardIndex;
    }

    /**
     * @dev 质押操作
     * @param amount 质押代币数量
     */
    function stake(uint amount) external {
        _updateRewards(msg.sender); // 先更新奖励
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev 解除质押
     * @param amount 解除质押数量
     */
    function unstake(uint amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        _updateRewards(msg.sender);
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    /**
     * @dev 领取奖励
     * @return 实际领取数量
     */
    function claim() external returns (uint) {
        _updateRewards(msg.sender);
        uint reward = earned[msg.sender];
        if (reward > 0) {
            earned[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
        }
        return reward;
    }
}