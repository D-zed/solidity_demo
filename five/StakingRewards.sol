// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/*
一段时间的奖励=（当前每个token积累的奖励-上次奖励计算时候每个token积累的奖励） *余额
将奖励累加到rewards数组中做记录
由于以上阶段的奖励已经计算完，所以更新用户结算进度（每个token累计的奖励）
更新 updateAt （更新rewards的时候做一次更新，重新设置奖励的时候进行一次更新，
总之updateAt是作为下一次计算奖励的时间起点，如果当前操作重新计算了奖励指数（每token累计奖励）
并且仍然处于一次奖励周期中则会更新其updateAt为当前时间，如果以及处于当前周期之外，
则updateAt需要设置为finishAt，当再次设置奖励的时候notifyRewardAmount会先更新
奖励指数，然后再设置updateAt为当前时间，总之每次重要操作之前都会重新计算奖励指数，将对应的奖励
保存在rewards中，再更新时间，后续计算的就是下一段奖励指数，依次累加每一段奖励指数
）
*/
contract StakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;
    
    address public owner;
    
    // 时间相关参数
    uint public duration;    // 奖励总持续时间（秒）
    uint public finishAt;    // 奖励结束时间戳
    uint public updatedAt;   // 最后更新时间戳
    
    // 奖励计算参数
    uint public rewardRate;              // 每秒发放的奖励数量
    uint public rewardPerTokenStored;     // 累计每Token奖励（精度1e18）
    
    // 用户状态
    mapping(address => uint) public userRewardPerTokenPaid;  // 用户上次领取时的奖励状态
    mapping(address => uint) public rewards;                 // 待领取奖励
    mapping(address => uint) public balanceOf;               // 用户质押余额
    uint public totalSupply;               // 总质押量

    // 权限修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // 奖励更新修饰器（核心逻辑）
    // 核心思想是在 质押和取回还有获取奖励之前，计算当前时间之前的全局奖励（每token累计多少奖励）
    // 计算用户累计的奖励: 
    //      思路就是先更新当前时间之前的有效时间内的每个token累计多少奖励 ，然后 使用 （当前时间每个token累计奖励- 当前用户的记录的每个token累计奖励）* 当前用户的质押量+原始未提取的奖励
    //      最后计算好了，再将当前的每个token累计奖励更新到对应的用户上
    modifier updateReward(address _account) {
        // 更新全局奖励状态（精度1e18）
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();
        
        if (_account != address(0)) {
            //计算用户应累积的奖励 = 质押量 × (当前全局奖励进度 - 用户上次进度) + 历史未提奖励
            rewards[_account] = earned(_account);
            // 更新用户奖励状态到最新
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    // 设置奖励持续时间（仅上一周期结束后可调用）
    function setRewardDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "Previous rewards not completed");
        duration = _duration;
    }

    // 设置奖励总量（核心管理函数）
    // 设置奖励金额，重置奖励的持续时间
    // updateReward(address(0)) 主要是为了记录设置之前的 每token的前一段时间积累的奖励 ，如果是第一次设置则为0
    // 若奖励率=1代币/秒，时间差=100秒，总质押=100代币
    // → 增量 = (1 * 100 * 1e18) / 100 = 1e18 → 每token累积1代币奖励
    function notifyRewardAmount(uint _amount) external onlyOwner updateReward(address(0)) {
        // 如果当前没有活跃奖励周期
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            // 计算剩余奖励并合并新奖励
            // 计算当前时间到结束时间还有多少奖励没有发放
            uint remaining = (finishAt - block.timestamp) * rewardRate;
            // 剩余奖励加上当前的奖励就是下一段时间的总奖励，除以持续时间就是下一段时间的奖励速率
            rewardRate = (remaining + _amount) / duration;
        }

        require(rewardRate > 0, "Reward rate zero");
        // 验证奖励代币余额充足
        require(
            rewardRate * duration <= rewardsToken.balanceOf(address(this)),
            "Insufficient reward tokens"
        );
        //更新结束时间
        finishAt = block.timestamp + duration;
        //更新 update时间
        updatedAt = block.timestamp;
    }

    // 质押函数（需提前approve）
    // 质押的时候会造成总的累计 totalSupply的变化，需要记录变化之前的进度
    function stake(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "Amount zero");
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
        // 转移代币需检查allowance
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    // 解除质押
    function withdraw(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "Amount zero");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    // 领取奖励
    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    // 计算有效结束时间
    function lastTimeRewardApplicable() public view returns (uint) {
        return block.timestamp < finishAt ? block.timestamp : finishAt;
    }

    // 计算当前每Token奖励（精度1e18）
    function rewardPerToken() public view returns (uint) {
        if (totalSupply == 0) return rewardPerTokenStored;
        return rewardPerTokenStored + 
            (rewardRate * 
            (lastTimeRewardApplicable() - updatedAt) // 时间差（秒）
            * 1e18) // 精度放大
            / totalSupply;  // 按质押量均分
    }

    // 计算用户应得奖励
    function earned(address _account) public view returns (uint) {
        // 应得奖励 = 质押量 × (当前全局奖励进度 - 用户上次进度) + 历史未提奖励
        return (balanceOf[_account] * 
            (rewardPerToken() //如果是在 modifier updateReward 中，其实前一步已经调用了rewardPerToken更新了
            - 
            userRewardPerTokenPaid[_account])) 
            / 1e18 
            + rewards[_account];
    }

    // 最小值工具函数
    function _min(uint x, uint y) private pure returns (uint) {
        return x < y ? x : y;
    }
}