// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
/*
1. 发行治理代币 MyToken，分别mint两个账号100
2. 部署治理合约
3. 发起提案
4. 模拟两人投票全票通过的场景
5. 执行交易
*/
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
contract MyGovernor is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{
    constructor(IVotes _token)
    Governor("MyGovernor") GovernorVotes(_token) GovernorVotesQuorumFraction(4)
    {
    }

    // 定义投票延迟（从提案创建到投票开始的区块数）
    // 此处返回 2 表示需要等待 2 个区块后才能开始投票
    function votingDelay() public pure override returns (uint256) {
        return 2; // 单位：区块数量
    }

    // 定义投票持续时长（以区块数为单位）
    // 此处返回 2 表示投票仅持续 2 个区块高度（实际使用需更大值）
    function votingPeriod() public pure override returns (uint256) {
        return 2; // 单位：区块数量
    }

    function proposalThreshold()public pure override returns(uint256){
        return 0;
    }
}
